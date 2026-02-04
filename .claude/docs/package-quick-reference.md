# Packages - Quick Reference

## File Locations

- **Adapter files**
  - `Managers/DataManagers/DataManagerServices.swift`
  - `Managers/Auth/AuthAdapters.swift`
  - `Managers/Logs/LogAdapters.swift`
  - `Managers/Purchases/PurchaseAdapters.swift`

- **Manager initialization**
  - `App/Dependencies/AppServices.swift`

## 1-Minute Overview

- **AppRouter**: Tabs + routes + sheets in `App/Navigation`
- **Auth**: Apple/Google/Anonymous sign-in via FirebaseAuth + GoogleSignIn
- **User Data**: Firestore-backed user profile sync + local cache
- **Purchases**: RevenueCat entitlements + StoreKit paywall
- **Logging**: Console, Mixpanel, Firebase Analytics, Crashlytics
- **Core**: Local persistence + networking helpers (Keychain/UserDefaults + API client)

## Common Patterns

### Track an event in a ViewModel
```swift
services.logManager.trackEvent(eventName: "Feature_Action", parameters: ["source": "button"])
```

### Navigate with AppRouter
```swift
@Environment(Router<AppTab, AppRoute, AppSheet>.self) private var router
router.navigateTo(.detail(title: "Hello"), for: .home)
router.presentSheet(.paywall)
```
