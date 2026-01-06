# MVVM-lite Rules & UI Guidelines

These rules define how to build SwiftUI features in AppTemplateLite.

---

## Views + ViewModels

**Views**
- ✅ Use `@State` for local UI state (alerts, sheets, animations)
- ✅ Use `@Environment(AppServices.self)` and `@Environment(AppSession.self)` for app-wide state
- ✅ Use `@Environment(Router<AppTab, AppRoute, AppSheet>.self)` for navigation
- ✅ Use `.anyButton()` or `.asButton()` for interactive elements
- ❌ No business logic inside views

**ViewModels**
- ✅ `@Observable` + `@MainActor`
- ✅ Own async work, error handling, analytics events
- ✅ Accept `AppServices` and `AppSession` as parameters (no singletons)
- ❌ No direct UI rendering

**Data flow**
```
View → ViewModel → AppServices → Managers
```

---

## AppRouter Navigation

- Define routes in `AppRoute` and sheets in `AppSheet`.
- Use `router.navigateTo(.route, for: .tab)` for push navigation.
- Use `router.presentSheet(.sheet)` for modals.
- Centralize destinations in `withAppRouterDestinations()` to avoid duplication.

---

## Reusable Components

Components are **dumb UI** and stay stateless:

- ✅ No business logic
- ✅ No data fetching
- ✅ Data injected via init
- ✅ Actions are closures
- ✅ Use `.anyButton()` instead of `Button` for custom tap areas
- ✅ Use `ImageLoaderView` for remote images

---

## Button Usage

Never use `onTapGesture` for interactive elements. Use `Button` or `.anyButton()`:

```swift
Text("Save")
  .callToActionButton()
  .anyButton(.press) {
    viewModel.save(...)
  }
```
