import SwiftUI

struct AccountRowView: View {
    let account: Account
    let code: TOTPCode?
    let onDelete: () -> Void

    @State private var copied = false
    @State private var hovering = false
    @State private var showDeleteConfirm = false

    var body: some View {
        HStack(spacing: 10) {
            // Service icon
            issuerIcon

            // Account info
            VStack(alignment: .leading, spacing: 1) {
                Text(account.issuer)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                Text(account.name)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            // Code + countdown
            if copied {
                copiedBadge
            } else if let code {
                HStack(spacing: 8) {
                    Text(code.formatted)
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .tracking(1.5)
                    CountdownRingView(remaining: code.remaining, period: code.period)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(hovering ? Color.white.opacity(0.05) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering = $0 }
        .onTapGesture { copyCode() }
        .contextMenu {
            Button("Copy Code") { copyCode() }
            Divider()
            Button("Delete Account", role: .destructive) { onDelete() }
        }
        .animation(.easeInOut(duration: 0.15), value: hovering)
        .animation(.spring(duration: 0.3), value: copied)
    }

    private var issuerIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(colorForIssuer.opacity(0.12))
                .frame(width: 30, height: 30)
            Text(String(account.issuer.prefix(1)).uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(colorForIssuer)
        }
    }

    private var copiedBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
            Text("Copied")
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(.green)
        .transition(.scale.combined(with: .opacity))
    }

    private var colorForIssuer: Color {
        let hue = Double(account.issuer.unicodeScalars.reduce(0) { $0 + Int($1.value) } % 360) / 360.0
        return Color(hue: hue, saturation: 0.5, brightness: 0.8)
    }

    private func copyCode() {
        guard let code, !copied else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code.code, forType: .string)
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            copied = false
        }
    }
}
