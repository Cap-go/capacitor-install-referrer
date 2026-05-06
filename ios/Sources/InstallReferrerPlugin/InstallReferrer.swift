import AdServices
import Foundation

public struct InstallReferrerError: LocalizedError {
    public let code: String
    public let message: String

    public var errorDescription: String? {
        return message
    }

    public static let adServicesUnavailable = InstallReferrerError(
        code: "AD_SERVICES_UNAVAILABLE",
        message: "Apple AdServices attribution is available on iOS 14.3 and later."
    )

    public static let invalidAppleAttributionResponse = InstallReferrerError(
        code: "INVALID_APPLE_ATTRIBUTION_RESPONSE",
        message: "Apple AdServices returned an invalid attribution response."
    )

    public static let appleAttributionNotReady = InstallReferrerError(
        code: "APPLE_ATTRIBUTION_NOT_READY",
        message: "Apple AdServices attribution data is not ready for this token yet."
    )

    public static func appleAttributionRequestFailed(statusCode: Int, body: String) -> InstallReferrerError {
        return InstallReferrerError(
            code: "APPLE_ATTRIBUTION_REQUEST_FAILED",
            message: "Apple AdServices attribution request failed with status \(statusCode): \(body)"
        )
    }
}

@objc public class InstallReferrer: NSObject {
    private let appleAttributionURL = URL(string: "https://api-adservices.apple.com/api/v1/")!

    @objc public func getPluginVersion() -> String {
        return "native"
    }

    public func getAttributionToken() throws -> String {
        guard #available(iOS 14.3, *) else {
            throw InstallReferrerError.adServicesUnavailable
        }

        return try AAAttribution.attributionToken()
    }

    public func fetchAppleAttribution(
        token: String,
        retryCount: Int,
        retryDelayMs: Int
    ) async throws -> [String: Any] {
        let attempts = max(0, retryCount) + 1
        let retryDelay = UInt64(max(0, retryDelayMs)) * 1_000_000

        for attempt in 0..<attempts {
            do {
                return try await requestAppleAttribution(token: token)
            } catch let error as InstallReferrerError {
                if error.code == InstallReferrerError.appleAttributionNotReady.code && attempt < attempts - 1 {
                    try await Task.sleep(nanoseconds: retryDelay)
                    continue
                }
                throw error
            }
        }

        throw InstallReferrerError.appleAttributionNotReady
    }

    private func requestAppleAttribution(token: String) async throws -> [String: Any] {
        var request = URLRequest(url: appleAttributionURL)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = token.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw InstallReferrerError.invalidAppleAttributionResponse
        }

        switch httpResponse.statusCode {
        case 200:
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let attribution = json as? [String: Any] else {
                throw InstallReferrerError.invalidAppleAttributionResponse
            }
            return attribution
        case 404:
            throw InstallReferrerError.appleAttributionNotReady
        default:
            let body = String(data: data, encoding: .utf8) ?? ""
            throw InstallReferrerError.appleAttributionRequestFailed(statusCode: httpResponse.statusCode, body: body)
        }
    }
}
