# ACTION 1: Create New Feature (MVVM-lite)

**Triggers:** "create new screen", "create screen", "new screen", "add new screen", "new feature"

---

## Steps

### 1. Confirm the feature name

- If missing, ask: "What is the feature name?" (e.g., "Home", "Paywall", "Settings")

### 2. Create the folder

- Path: `/AppTemplateLite/Features/FeatureName/`

### 3. Create the files

- `FeatureNameView.swift`
- `FeatureNameViewModel.swift`
- Additional views or supporting models as needed

### 4. Wire navigation (if needed)

- Add a case to `AppRoute` for push destinations
- Add a case to `AppSheet` for modal flows
- Register in `withAppRouterDestinations()` or `AppTabsView.sheetView`

---

## Minimal MVVM-lite pattern

```swift
@MainActor
@Observable
final class FeatureNameViewModel {
  func onAppear(services: AppServices) {
    services.logManager.trackEvent(eventName: "FeatureName_Appear")
  }
}

struct FeatureNameView: View {
  @Environment(AppServices.self) private var services
  @State private var viewModel = FeatureNameViewModel()

  var body: some View {
    Text("Hello")
      .onAppear { viewModel.onAppear(services: services) }
  }
}
```

---

## Notes

- Views stay UI-only; logic goes in ViewModels.
- Use `DSButton`/`DSIconButton` for interactive elements.
- Keep analytics in ViewModels for major actions.
