# Essentia

## About

Essentia is a production-ready iOS 26+ SwiftUI template that ships with MVVM, AppRouter navigation, and clean integrations for Firebase, Mixpanel, RevenueCat, and Google Sign-In. It’s designed to stay simple at the surface while scaling to real-world product complexity.


## Features

- AppRouter-powered navigation (tabs + deep links + sheets)
- MVVM views with `@Observable` view models
- Three build configurations (Mock, Dev, Production)
- Firebase integration (Auth, Firestore, Analytics, Crashlytics)
- RevenueCat for in-app purchases
- Mixpanel analytics
- Consent + ATT settings
- Push notification routing hooks
- Gamification system (Streaks, XP, Progress)

## Requirements

- Xcode 16+ (iOS 26 SDK)
- Swift 5.9+

## Getting Started

1. Clone this repository
2. Run `rename_project.sh` to customize the project name
3. Configure your Firebase and RevenueCat credentials
4. Update `EntitlementOption` product IDs

## Build

Use direct `xcodebuild`:

```bash
xcodebuild -project Essentia.xcodeproj -scheme "Essentia - Mock" -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build
```

Resolve all app warnings before shipping. External package warnings are acceptable.

## Scripts

- `rename_project.sh` - Rename the project (optional `--bundle-id` and `--display-name`)
- `scripts/new-app.sh` - Copy the template to a new folder and rename in one step
- `scripts/setup-secrets.sh` - Create `Secrets.xcconfig.local` from the example file

## Navigation

- Tabs and routes are defined in `Essentia/App/Navigation/`
- Use `AppRoute` for push navigation and `AppSheet` for modal flows
- Deep links are handled via `.onOpenURL` in `AppTabsView`

## Internal Packages (SPM)

The shared modules live in `essentia-core-packages` and are consumed as a single SPM dependency (Core + DesignSystem).

- Remote dependency: `https://github.com/sakhnenkoff/essentia-core-packages.git`
- Local override: in Xcode, use `File > Packages > Add Local...` to point to a local clone when iterating

## SDKs Used

- Firebase (Auth, Firestore, Analytics, Crashlytics, Messaging, RemoteConfig, Storage)
- Mixpanel
- RevenueCat
- GoogleSignIn

## Documentation

See the `.claude/docs/` folder for detailed documentation on:
- Project structure and architecture
- MVVM conventions
- Creating features, components, managers, and models
- Package dependencies and integration

## License

MIT License - See [LICENSE.txt](LICENSE.txt) for details.
