import SwiftUI

struct AddAccountView: View {
    @ObservedObject var viewModel: AccountsViewModel
    @Binding var isPresented: Bool

    @State private var issuer = ""
    @State private var name = ""
    @State private var secret = ""
    @State private var error: String?
    @State private var scanning = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("New Account")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Divider().opacity(0.3)

            ScrollView {
                VStack(spacing: 16) {
                    // QR scan button
                    Button(action: scanQR) {
                        HStack(spacing: 8) {
                            if scanning {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Scanning...")
                            } else {
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.system(size: 14))
                                Text("Scan QR from screen")
                            }
                        }
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(.quaternary, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(scanning)

                    // Divider with text
                    HStack(spacing: 10) {
                        Rectangle().fill(.quaternary).frame(height: 1)
                        Text("OR MANUALLY")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.tertiary)
                            .tracking(1)
                        Rectangle().fill(.quaternary).frame(height: 1)
                    }

                    // Form fields
                    VStack(spacing: 12) {
                        FormField(label: "SERVICE", text: $issuer, placeholder: "Google, GitHub, AWS...")
                        FormField(label: "ACCOUNT", text: $name, placeholder: "user@example.com")
                        FormField(label: "SECRET KEY", text: $secret, placeholder: "Base32 encoded secret", isSecure: true, isMonospaced: true)
                    }

                    // Error
                    if let error {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                            Text(error)
                                .font(.system(size: 11))
                        }
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }

            Divider().opacity(0.3)

            // Actions
            HStack(spacing: 10) {
                Button("Cancel") { isPresented = false }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)

                Button("Add Account") { addAccount() }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .controlSize(.regular)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(width: 340, height: 440)
    }

    private func addAccount() {
        error = nil
        guard !issuer.trimmingCharacters(in: .whitespaces).isEmpty,
              !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !secret.trimmingCharacters(in: .whitespaces).isEmpty else {
            error = "All fields are required"
            return
        }
        do {
            try viewModel.addAccount(issuer: issuer.trimmingCharacters(in: .whitespaces), name: name.trimmingCharacters(in: .whitespaces), secret: secret.trimmingCharacters(in: .whitespaces))
            isPresented = false
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func scanQR() {
        scanning = true
        error = nil

        // Close the popover so it doesn't cover the QR code
        AppDelegate.shared.closePopover()

        // Wait for popover to fully close, then capture
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.6) {
            do {
                let result = try QRScannerService.scanAllScreens()
                DispatchQueue.main.async {
                    AppDelegate.shared.openPopover()
                    issuer = result.issuer
                    name = result.name
                    secret = result.secret
                    scanning = false
                }
            } catch {
                DispatchQueue.main.async {
                    AppDelegate.shared.openPopover()
                    self.error = error.localizedDescription
                    scanning = false
                }
            }
        }
    }
}

struct FormField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var isSecure: Bool = false
    var isMonospaced: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.tertiary)
                .tracking(0.8)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textFieldStyle(.plain)
            .font(isMonospaced ? .system(size: 12, design: .monospaced) : .system(size: 12))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 7))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .strokeBorder(.quaternary, lineWidth: 0.5)
            )
        }
    }
}
