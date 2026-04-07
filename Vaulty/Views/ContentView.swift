import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AccountsViewModel()
    @State private var showingAdd = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            if viewModel.accounts.count > 2 {
                searchBar
            }

            Divider().opacity(0.3)

            // Content
            if viewModel.accounts.isEmpty {
                emptyState
            } else if viewModel.filteredAccounts.isEmpty {
                noResults
            } else {
                accountList
            }

            Divider().opacity(0.3)

            // Footer
            footer
        }
        .frame(width: 340, height: 440)
        .sheet(isPresented: $showingAdd) {
            AddAccountView(viewModel: viewModel, isPresented: $showingAdd)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            HStack(spacing: 7) {
                Image("VaultyIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text("Vaulty")
                    .font(.system(size: 13, weight: .semibold))
            }
            Spacer()
            Button(action: { showingAdd = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 24, height: 24)
                    .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            TextField("Search...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Account list

    private var accountList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(viewModel.filteredAccounts) { account in
                    AccountRowView(
                        account: account,
                        code: viewModel.codes[account.id],
                        onDelete: { viewModel.deleteAccount(account) }
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "lock.shield")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.secondary.opacity(0.5))
            VStack(spacing: 4) {
                Text("No accounts yet")
                    .font(.system(size: 13, weight: .medium))
                Text("Add your first 2FA account")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Button("Add Account") { showingAdd = true }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(.orange)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var noResults: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20, weight: .light))
                .foregroundStyle(.tertiary)
            Text("No matches")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            HStack(spacing: 4) {
                if !viewModel.accounts.isEmpty {
                    Text("\(viewModel.accounts.count)")
                        .foregroundStyle(.secondary)
                    Text("account\(viewModel.accounts.count == 1 ? "" : "s") · Keychain secured")
                } else {
                    Circle()
                        .fill(.green.opacity(0.7))
                        .frame(width: 5, height: 5)
                    Text("Secured by macOS Keychain")
                }
            }
            Spacer()
            Button {
                if let url = URL(string: "https://github.com/abderrahimghazali/vaulty") {
                    AppDelegate.shared.closePopover()
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Image("GitHubMark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                    .foregroundStyle(.secondary)
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("View on GitHub")
            .onHover { inside in
                if inside { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }
        }
        .font(.system(size: 10))
        .foregroundStyle(.tertiary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
