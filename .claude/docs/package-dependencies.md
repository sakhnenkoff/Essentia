# Package Dependencies (AppTemplateLite)

This template uses the SwiftfulThinking ecosystem plus AppRouter. All shared packages live in `app-core-packages`.

---

## AppRouter

**Purpose:** Navigation (tabs + push + sheets + deep links).

**Where:**
- `App/Navigation/AppTab.swift`
- `App/Navigation/AppRoute.swift`
- `App/Navigation/AppSheet.swift`
- `App/Navigation/AppTabsView.swift`

**Usage:**
```swift
@Environment(Router<AppTab, AppRoute, AppSheet>.self) private var router
router.navigateTo(.detail(title: "Hello"), for: .home)
router.presentSheet(.paywall)
```

---

## SwiftfulAuthenticating + Firebase

**Purpose:** Sign-in (Apple, Google, Anonymous).

**Where:**
- `Managers/Auth/SwiftfulAuthenticating+Alias.swift`
- `Features/Auth/AuthViewModel.swift`

---

## SwiftfulDataManagers + Firebase

**Purpose:** Sync user documents.

**Where:**
- `Managers/DataManagers/SwiftfulDataManagers+Alias.swift`
- `Managers/User/UserManager.swift`

---

## SwiftfulPurchasing + RevenueCat

**Purpose:** In-app purchases and entitlements.

**Where:**
- `Managers/Purchases/SwiftfulPurchasing+Alias.swift`
- `Features/Paywall/PaywallViewModel.swift`

---

## SwiftfulLogging (Mixpanel + Firebase Analytics/Crashlytics)

**Purpose:** Analytics and crash reporting.

**Where:**
- `Managers/Logs/SwiftfulLogging+Alias.swift`
- ViewModels track events via `services.logManager`.

---

## LocalPersistance + Networking

**Purpose:** Keychain/UserDefaults helpers and a lightweight networking client.

**Where:**
- `App/Dependencies/AppServices.swift`
