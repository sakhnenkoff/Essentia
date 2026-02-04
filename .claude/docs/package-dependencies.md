# Package Dependencies (Essentia)

This template uses direct SDK integrations plus AppRouter. All shared packages live in `app-core-packages`.

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

## Auth (Firebase Auth + GoogleSignIn + Apple)

**Purpose:** Sign-in (Apple, Google, Anonymous).

**Where:**
- `Managers/Auth/AuthAdapters.swift`
- `Features/Auth/AuthViewModel.swift`

---

## User Data (Firestore)

**Purpose:** Sync user documents.

**Where:**
- `Managers/DataManagers/DataManagerServices.swift`
- `Managers/User/UserManager.swift`

---

## Purchases (RevenueCat)

**Purpose:** In-app purchases and entitlements.

**Where:**
- `Managers/Purchases/PurchaseAdapters.swift`
- `Features/Paywall/PaywallViewModel.swift`

---

## Logging (Mixpanel + Firebase Analytics/Crashlytics)

**Purpose:** Analytics and crash reporting.

**Where:**
- `Managers/Logs/LogAdapters.swift`
- ViewModels track events via `services.logManager`.

---

## LocalPersistance + Networking

**Purpose:** Keychain/UserDefaults helpers and a simple networking client.

**Where:**
- `App/Dependencies/AppServices.swift`
