import Foundation
import CryptoKit

enum TOTPService {
    static func generateCode(secret: Data, algorithm: OTPAlgorithm = .sha1, digits: Int = 6, period: Int = 30) -> TOTPCode {
        let now = Date().timeIntervalSince1970
        let counter = UInt64(now) / UInt64(period)
        let remaining = period - Int(UInt64(now) % UInt64(period))

        var counterBig = counter.bigEndian
        let counterData = Data(bytes: &counterBig, count: 8)

        let hash: Data
        switch algorithm {
        case .sha1:
            let key = SymmetricKey(data: secret)
            let mac = HMAC<Insecure.SHA1>.authenticationCode(for: counterData, using: key)
            hash = Data(mac)
        case .sha256:
            let key = SymmetricKey(data: secret)
            let mac = HMAC<SHA256>.authenticationCode(for: counterData, using: key)
            hash = Data(mac)
        case .sha512:
            let key = SymmetricKey(data: secret)
            let mac = HMAC<SHA512>.authenticationCode(for: counterData, using: key)
            hash = Data(mac)
        }

        let offset = Int(hash[hash.count - 1] & 0x0F)
        let truncated = hash.withUnsafeBytes { ptr -> UInt32 in
            let start = ptr.baseAddress!.advanced(by: offset)
            return start.loadUnaligned(as: UInt32.self).bigEndian & 0x7FFF_FFFF
        }

        let mod = UInt32(pow(10, Double(digits)))
        let otp = truncated % mod
        let code = String(format: "%0\(digits)d", otp)

        return TOTPCode(code: code, remaining: remaining, period: period)
    }

    static func decodeBase32(_ input: String) -> Data? {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        let clean = input.uppercased().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "=", with: "")

        var bits = ""
        for char in clean {
            guard let index = alphabet.firstIndex(of: char) else { return nil }
            let value = alphabet.distance(from: alphabet.startIndex, to: index)
            bits += String(value, radix: 2).leftPadded(to: 5)
        }

        var bytes: [UInt8] = []
        var i = bits.startIndex
        while bits.distance(from: i, to: bits.endIndex) >= 8 {
            let end = bits.index(i, offsetBy: 8)
            if let byte = UInt8(bits[i..<end], radix: 2) {
                bytes.append(byte)
            }
            i = end
        }

        return bytes.isEmpty ? nil : Data(bytes)
    }
}

private extension String {
    func leftPadded(to length: Int) -> String {
        String(repeating: "0", count: max(0, length - count)) + self
    }
}
