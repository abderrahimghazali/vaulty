import Foundation

final class AccountStore {
    static let shared = AccountStore()

    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("com.vaulty.desktop", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("accounts.json")
        encoder.outputFormatting = .prettyPrinted
    }

    func loadAccounts() -> [Account] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? decoder.decode([Account].self, from: data)) ?? []
    }

    func saveAccounts(_ accounts: [Account]) {
        guard let data = try? encoder.encode(accounts) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
