import Foundation
import Capacitor

@objc(InstallReferrerPlugin)
public class InstallReferrerPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "InstallReferrerPlugin"
    public let jsName = "InstallReferrer"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "getReferrer", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "GetReferrer", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getPluginVersion", returnType: CAPPluginReturnPromise)
    ]

    private let implementation = InstallReferrer()

    @objc func getReferrer(_ call: CAPPluginCall) {
        resolveReferrer(call)
    }

    @objc func GetReferrer(_ call: CAPPluginCall) {
        resolveReferrer(call)
    }

    @objc func getPluginVersion(_ call: CAPPluginCall) {
        call.resolve([
            "version": implementation.getPluginVersion()
        ])
    }

    private func resolveReferrer(_ call: CAPPluginCall) {
        do {
            let token = try implementation.getAttributionToken()
            let fetchAppleAttribution = call.getBool("fetchAppleAttribution") ?? false
            var result: [String: Any] = [
                "platform": "ios",
                "attributionToken": token
            ]

            guard fetchAppleAttribution else {
                call.resolve(result)
                return
            }

            let retryCount = call.getInt("appleAttributionRetryCount") ?? 3
            let retryDelayMs = call.getInt("appleAttributionRetryDelayMs") ?? 5_000

            Task {
                do {
                    let attribution = try await implementation.fetchAppleAttribution(
                        token: token,
                        retryCount: retryCount,
                        retryDelayMs: retryDelayMs
                    )
                    result["appleAttribution"] = attribution
                    call.resolve(result)
                } catch {
                    reject(call, error: error)
                }
            }
        } catch {
            reject(call, error: error)
        }
    }

    private func reject(_ call: CAPPluginCall, error: Error) {
        if let installReferrerError = error as? InstallReferrerError {
            call.reject(installReferrerError.message, installReferrerError.code, error)
            return
        }

        call.reject(error.localizedDescription, "IOS_ATTRIBUTION_ERROR", error)
    }
}
