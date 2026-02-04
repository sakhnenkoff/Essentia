# AppTemplateLite

Lightweight, production-ready iOS 26+ template built with SwiftUI, AppRouter, and MVVM-lite.

## Features

- AppRouter-powered navigation (tabs + deep links + sheets)
- MVVM-lite views with `@Observable` view models
- Three build configurations (Mock, Dev, Production)
- Firebase integration (Auth, Firestore, Analytics, Crashlytics)
- RevenueCat for in-app purchases
- Mixpanel analytics
- Consent + ATT settings
- Push notification routing hooks
- Gamification system (Streaks, XP, Progress)

## Getting Started

1. Clone this repository
2. Run `rename_project.sh` to customize the project name
3. Configure your Firebase and RevenueCat credentials
4. Update `EntitlementOption` product IDs


## Scripts

- `rename_project.sh` - Rename the project (optional `--bundle-id` and `--display-name`)
- `scripts/new-app.sh` - Copy the template to a new folder and rename in one step
- `scripts/setup-secrets.sh` - Create `Secrets.xcconfig.local` from the example file

## Navigation

- Tabs and routes are defined in `AppTemplateLite/App/Navigation/`
- Use `AppRoute` for push navigation and `AppSheet` for modal flows
- Deep links are handled via `.onOpenURL` in `AppTabsView`

## Internal Packages (SPM)

The shared modules live in `app-core-packages` and are consumed as a single SPM dependency.

- Remote dependency: `https://github.com/sakhnenkoff/app-core-packages.git`
- Local override: in Xcode, use `File > Packages > Add Local...` to point to a local clone when iterating

## Documentation

See the `.claude/docs/` folder for detailed documentation on:
- Project structure and architecture
- MVVM-lite conventions
- Creating features, components, managers, and models
- Package dependencies and integration

## License

MIT License - See [LICENSE.txt](LICENSE.txt) for details.
