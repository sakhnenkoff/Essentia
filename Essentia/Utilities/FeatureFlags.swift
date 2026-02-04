//
//  FeatureFlags.swift
//  Essentia
//
//  Configure which features are enabled in your app.
//  Disabled features won't be initialized, reducing memory and startup time.
//
//  To disable a feature:
//  1. Set the corresponding flag to false
//  2. The manager won't be initialized in AppServices
//

enum FeatureFlags {

    // MARK: - Analytics & Monitoring

    /// Enable Mixpanel analytics tracking
    static let enableMixpanel = true

    /// Enable Firebase Analytics
    static let enableFirebaseAnalytics = true

    /// Enable Firebase Crashlytics for crash reporting
    static let enableCrashlytics = true

    // MARK: - Monetization

    /// Enable in-app purchases via RevenueCat
    static let enablePurchases = true

    // MARK: - Authentication

    /// Enable the sign-in demo flow
    static let enableAuth = true

    // MARK: - Notifications

    /// Enable push notifications via Firebase Cloud Messaging
    static let enablePushNotifications = true

    // MARK: - A/B Testing

    /// Enable A/B testing (Firebase Remote Config or local)
    static let enableABTesting = true
}
