import AppKit
import Vision

enum QRScannerService {
    struct QRResult {
        let issuer: String
        let name: String
        let secret: String
        let algorithm: OTPAlgorithm
        let digits: Int
        let period: Int
    }

    static func scanAllScreens() throws -> QRResult {
        // Use CGWindowListCreateImage to capture ALL visible windows, not just the desktop
        let screenBounds = CGRect.infinite
        guard let screenshot = CGWindowListCreateImage(
            screenBounds,
            .optionOnScreenOnly,
            kCGNullWindowID,
            [.bestResolution]
        ) else {
            throw QRError.captureFailed
        }

        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr]

        let handler = VNImageRequestHandler(cgImage: screenshot, options: [:])
        try? handler.perform([request])

        guard let results = request.results, !results.isEmpty else {
            throw QRError.noQRFound
        }

        for observation in results {
            guard let payload = observation.payloadStringValue,
                  payload.hasPrefix("otpauth://") else { continue }
            if let result = try? parseOTPAuthURI(payload) {
                return result
            }
        }

        // Found QR codes but none were otpauth
        let payloads = results.compactMap { $0.payloadStringValue }
        throw QRError.foundButNotOTP(payloads)
    }

    static func parseOTPAuthURI(_ uri: String) throws -> QRResult {
        guard let url = URL(string: uri),
              url.scheme == "otpauth",
              url.host == "totp" else {
            throw QRError.invalidURI
        }

        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let decoded = path.removingPercentEncoding ?? path

        let issuerFromLabel: String?
        let accountName: String

        if let colonRange = decoded.range(of: ":") {
            issuerFromLabel = String(decoded[decoded.startIndex..<colonRange.lowerBound])
            accountName = String(decoded[colonRange.upperBound...]).trimmingCharacters(in: .whitespaces)
        } else {
            issuerFromLabel = nil
            accountName = decoded
        }

        let params = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.reduce(into: [String: String]()) { $0[$1.name] = $1.value } ?? [:]

        guard let secret = params["secret"]?.uppercased() else {
            throw QRError.missingSecret
        }

        let issuer = params["issuer"] ?? issuerFromLabel ?? "Unknown"
        let algorithm: OTPAlgorithm
        switch params["algorithm"]?.uppercased() {
        case "SHA256": algorithm = .sha256
        case "SHA512": algorithm = .sha512
        default: algorithm = .sha1
        }
        let digits = Int(params["digits"] ?? "") ?? 6
        let period = Int(params["period"] ?? "") ?? 30

        return QRResult(
            issuer: issuer,
            name: accountName,
            secret: secret,
            algorithm: algorithm,
            digits: digits,
            period: period
        )
    }
}

enum QRError: LocalizedError {
    case captureFailed
    case noQRFound
    case invalidURI
    case missingSecret
    case foundButNotOTP([String])

    var errorDescription: String? {
        switch self {
        case .captureFailed: return "Failed to capture screen"
        case .noQRFound: return "No QR code found. Screenshot saved to Desktop for debugging."
        case .invalidURI: return "Not a valid TOTP QR code"
        case .missingSecret: return "QR code is missing the secret key"
        case .foundButNotOTP(let payloads): return "Found QR but not TOTP: \(payloads.first ?? "?")"
        }
    }
}
