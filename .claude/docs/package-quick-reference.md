# Packages - Quick Reference

## File Locations

- **Alias files**
  - `Managers/DataManagers/SwiftfulDataManagers+Alias.swift`
  - `Managers/Auth/SwiftfulAuthenticating+Alias.swift`
  - `Managers/Logs/SwiftfulLogging+Alias.swift`
  - `Managers/Purchases/SwiftfulPurchasing+Alias.swift`
  - `Managers/Gamification/SwiftfulGamificiation+Alias.swift`
  - `Managers/Haptics/SwiftfulHaptics+Alias.swift`
  - `Managers/SoundEffects/SwiftfulSoundEffects+Alias.swift`
  - `Utilities/SwiftfulUtilities+Alias.swift`

- **Manager initialization**
  - `App/Dependencies/AppServices.swift`

## 1-Minute Overview

- **AppRouter**: Tabs + routes + sheets in `App/Navigation`
- **SwiftfulAuthenticating**: Apple/Google/Anonymous sign-in
- **SwiftfulDataManagers**: User profile sync (Firestore + local persistence)
- **SwiftfulPurchasing**: RevenueCat entitlements + StoreKit paywall
- **SwiftfulLogging**: Console, Mixpanel, Firebase Analytics, Crashlytics
- **SwiftfulGamification**: Streaks, XP, progress
- **LocalPersistance**: Keychain + UserDefaults helpers
- **Networking**: Async API client helpers
- **SwiftfulUtilities**: App version, event params
- **SwiftfulUI**: `.callToActionButton()`, `.tappableBackground()` (use `DSButton`/`DSIconButton` for interactions)

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
