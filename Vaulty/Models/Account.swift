import Foundation

struct Account: Identifiable, Codable, Equatable {
    let id: UUID
    var issuer: String
    var name: String
    var algorithm: OTPAlgorithm
    var digits: Int
    var period: Int

    init(
        id: UUID = UUID(),
        issuer: String,
        name: String,
        algorithm: OTPAlgorithm = .sha1,
        digits: Int = 6,
        period: Int = 30
    ) {
        self.id = id
        self.issuer = issuer
        self.name = name
        self.algorithm = algorithm
        self.digits = digits
        self.period = period
    }
}

enum OTPAlgorithm: String, Codable, CaseIterable {
    case sha1 = "SHA1"
    case sha256 = "SHA256"
    case sha512 = "SHA512"
}

struct TOTPCode {
    let code: String
    let remaining: Int
    let period: Int

    var formatted: String {
        guard code.count == 6 else { return code }
        return "\(code.prefix(3)) \(code.suffix(3))"
    }

    var progress: Double {
        Double(remaining) / Double(period)
    }

    var isUrgent: Bool { remaining <= 5 }
    var isCritical: Bool { remaining <= 3 }
}
