//
//  AppConfiguration.swift
//  AppTemplateLite
//
//  Reads configuration values from Info.plist (populated by xcconfig at build time).
//  This provides a secure way to access API keys without hardcoding them in source.
//
//  To add your secrets:
//  1. Copy Configurations/Secrets.xcconfig.local.example to Secrets.xcconfig.local
//  2. Fill in your real API keys
//  3. Build and run - the .local file is gitignored, keeping secrets safe
//

import Foundation

enum AppConfiguration {

    nonisolated(unsafe) private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            assertionFailure("Info.plist not found")
            return [:]
        }
        return dict
    }()

    // MARK: - Environment

    /// Current build environment: "mock", "dev", or "prod"
    static var environment: String {
        infoDictionary["ENVIRONMENT"] as? String ?? "mock"
    }

    static var isMock: Bool {
        environment == "mock"
    }

    static var isDev: Bool {
        environment == "dev"
    }

    static var isProd: Bool {
        environment == "prod"
    }

    // MARK: - API Configuration

    /// Base URL for API requests
    static var apiBaseURL: String {
        infoDictionary["API_BASE_URL"] as? String ?? ""
    }

    // MARK: - Third-Party Services

    /// Mixpanel analytics token
    static var mixpanelToken: String {
        infoDictionary["MIXPANEL_TOKEN"] as? String ?? ""
    }

    /// RevenueCat API key for in-app purchases
    static var revenueCatAPIKey: String {
        infoDictionary["REVENUECAT_API_KEY"] as? String ?? ""
    }

    // MARK: - Validation

    /// Call at app launch to verify required configuration exists.
    /// Prints warnings for missing secrets in Dev/Prod builds.
    static func validateConfiguration() {
        #if !MOCK
        if mixpanelToken.isEmpty {
            print("⚠️ MIXPANEL_TOKEN not configured. Add it to Configurations/Secrets.xcconfig.local")
        }
        if revenueCatAPIKey.isEmpty {
            print("⚠️ REVENUECAT_API_KEY not configured. Add it to Configurations/Secrets.xcconfig.local")
        }
        #endif
    }
}
