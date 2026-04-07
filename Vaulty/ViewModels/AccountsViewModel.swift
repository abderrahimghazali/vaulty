import Foundation
import Combine

@MainActor
final class AccountsViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var codes: [UUID: TOTPCode] = [:]
    @Published var searchText = ""
    @Published var showingAddAccount = false
    @Published var error: String?

    private var timer: Timer?
    private let store = AccountStore.shared

    var filteredAccounts: [Account] {
        guard !searchText.isEmpty else { return accounts }
        let q = searchText.lowercased()
        return accounts.filter {
            $0.issuer.lowercased().contains(q) || $0.name.lowercased().contains(q)
        }
    }

    init() {
        accounts = store.loadAccounts()
        refreshCodes()
        startTimer()
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshCodes()
            }
        }
    }

    func refreshCodes() {
        for account in accounts {
            guard let secret = try? KeychainService.load(for: account.id),
                  let secretData = TOTPService.decodeBase32(secret) else { continue }
            codes[account.id] = TOTPService.generateCode(
                secret: secretData,
                algorithm: account.algorithm,
                digits: account.digits,
                period: account.period
            )
        }
    }

    func addAccount(issuer: String, name: String, secret: String, algorithm: OTPAlgorithm = .sha1, digits: Int = 6, period: Int = 30) throws {
        let clean = secret.replacingOccurrences(of: " ", with: "").uppercased()
        guard TOTPService.decodeBase32(clean) != nil else {
            throw ValidationError.invalidSecret
        }

        let account = Account(issuer: issuer, name: name, algorithm: algorithm, digits: digits, period: period)
        try KeychainService.save(secret: clean, for: account.id)
        accounts.append(account)
        store.saveAccounts(accounts)
        refreshCodes()
    }

    func deleteAccount(_ account: Account) {
        try? KeychainService.delete(for: account.id)
        accounts.removeAll { $0.id == account.id }
        codes.removeValue(forKey: account.id)
        store.saveAccounts(accounts)
    }

    func scanQR() throws {
        let result = try QRScannerService.scanAllScreens()
        try addAccount(
            issuer: result.issuer,
            name: result.name,
            secret: result.secret,
            algorithm: result.algorithm,
            digits: result.digits,
            period: result.period
        )
    }
}

enum ValidationError: LocalizedError {
    case invalidSecret
    var errorDescription: String? { "Invalid Base32 secret key" }
}
