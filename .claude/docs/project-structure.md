# Project Architecture & Structure

## ⚠️ THIS IS A TEMPLATE PROJECT

This repo is a starter template meant to be copied for new apps.
Replace example screens, keep the architecture.

---

## Architecture Overview

- **Architecture**: MVVM + AppRouter
- **Tech Stack**: SwiftUI (iOS 26+), Swift 5.9+, Firebase, RevenueCat, Mixpanel
- **Build Configs**: Mock, Dev, Production

---

## Key Concepts

### AppServices + AppSession

- `AppServices` initializes managers and is the single access point for services.
- `AppSession` owns session state (auth, onboarding, premium).
- Views access them via `@Environment`.

### AppRouter

- Tabs, routes, and sheets live in `App/Navigation`.
- Register routes in `AppRoute`, sheets in `AppSheet`.
- Map destinations in `withAppRouterDestinations()`.

---

## Project Structure

```
Essentia/
├── Essentia/           # Main app source code
│   ├── App/                   # App entry + routing
│   │   ├── EssentiaApp.swift
│   │   ├── AppDelegate.swift
│   │   ├── AppSession.swift
│   │   ├── AppRootView.swift
│   │   ├── Dependencies/
│   │   │   └── AppServices.swift
│   │   └── Navigation/
│   │       ├── AppTab.swift
│   │       ├── AppRoute.swift
│   │       ├── AppSheet.swift
│   │       └── AppTabsView.swift
│   ├── Features/              # Feature modules (View + ViewModel)
│   │   ├── Home/
│   │   ├── Auth/
│   │   ├── Onboarding/
│   │   ├── Paywall/
│   │   └── Settings/
│   ├── Managers/              # Business logic + data services
│   ├── Components/            # Reusable UI components
│   ├── Extensions/            # Shared extensions
│   ├── Utilities/             # Constants, configuration, helpers
│   └── SupportingFiles/       # Assets and config (Info.plist, entitlements)
├── Essentia.xcodeproj
└── .claude/docs/
```

---

Remember: create files inside `Essentia/` so Xcode auto-syncs them.
