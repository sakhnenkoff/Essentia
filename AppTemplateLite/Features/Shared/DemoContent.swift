import Foundation

enum DemoContent {
    enum Common {
        static let cancelAnytime = "Cancel anytime in Settings."
    }

    enum Sections {
        static let actions = "Actions"
        static let analytics = "Analytics"
        static let tracking = "Tracking"
        static let account = "Account"
        static let demoToggles = "Demo toggles"
        static let monetization = "Monetization"
        static let notifications = "Notifications"
        static let navigation = "Navigation"
        static let debugTools = "Debug tools"
        static let environment = "Environment"
        static let user = "User"
    }

    enum Home {
        static let navigationTitle = "Home"
        static let heroTitle = "Design system showcase"
        static let heroSubtitle = "Calm components with sketch icons and focused glass accents."
        static let screensSectionTitle = "Screens"
        static let componentsSectionTitle = "Components"
        static let designSystemGalleryTitle = "Design system gallery"
        static let designSystemGallerySubtitle = "Components, variants, and states."
    }

    enum Auth {
        static let title = "Sign in"
        static let subtitle = "Sync your demo progress and unlock premium previews."
        static let footerNote = "By continuing, you agree to the demo terms and acknowledge the privacy policy."
        static let privacyTitle = "Privacy-first"
        static let privacyMessage = "We only collect what you explicitly share."
        static let flowsTitle = "Production-ready flows"
        static let flowsMessage = "Onboarding, analytics, and paywalls are ready to ship."
        static let growthTitle = "Growth visibility"
        static let growthMessage = "Understand engagement with built-in tracking hooks."
    }

    enum Paywall {
        static let navigationTitle = "Premium"
        static let heroTitle = "Premium Studio"
        static let heroSubtitle = "A refined template pack with analytics, paywalls, and onboarding flows."
        static let processingTitle = "Updating your access..."
    }

    enum Settings {
        static let navigationTitle = "Settings"
        static let header = "Account, notifications, and demo utilities."
    }

    enum SettingsDetail {
        static let navigationTitle = "Settings Detail"
        static let headerTitle = "Privacy & data"
        static let headerSubtitle = "Control analytics and tracking preferences for the demo experience."
        static let restartTitle = "Restart recommended"
        static let restartMessage = "Restart the app to apply analytics changes."
        static let mockTitle = "Mock build"
        static let mockMessage = "Analytics and tracking SDKs are disabled in Mock builds."
    }

    enum Detail {
        static let navigationTitle = "Detail"
        static let headerSubtitle = "A focused detail surface with a single hero card."
        static let heroTitle = "Focus notes"
        static let heroSubtitle = "Capture one idea per day and track progress over time."
    }

    enum Profile {
        static let navigationTitle = "Profile"
        static let headerTitle = "Profile studio"
        static let headerSubtitle = "A calm card with minimal stats and actions."
        static let stats: [(value: String, title: String)] = [
            ("12", "Streak"),
            ("4", "Projects"),
            ("36", "Days")
        ]
    }

    enum DebugMenu {
        static let navigationTitle = "Debug Menu"
    }

    enum Notifications {
        static let reminderPrimary = "17:00"
        static let reminderSecondary = "08:30"
    }
}
