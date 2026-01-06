//
//  FeatureFlags.swift
//  AppTemplateLite
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

    // MARK: - Gamification

    /// Enable streak tracking (daily engagement)
    static let enableStreaks = true

    /// Enable experience points system
    static let enableExperiencePoints = true

    /// Enable progress tracking
    static let enableProgress = true

    /// Convenience: true if any gamification feature is enabled
    static var enableGamification: Bool {
        enableStreaks || enableExperiencePoints || enableProgress
    }

    // MARK: - Notifications

    /// Enable push notifications via Firebase Cloud Messaging
    static let enablePushNotifications = true

    // MARK: - User Experience

    /// Enable haptic feedback
    static let enableHaptics = true

    /// Enable sound effects
    static let enableSoundEffects = true

    // MARK: - A/B Testing

    /// Enable A/B testing (Firebase Remote Config or local)
    static let enableABTesting = true
}
