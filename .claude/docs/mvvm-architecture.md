# MVVM Architecture & UI Guidance

These rules define how to build SwiftUI features in Essentia.

---

## Views + ViewModels

**Views**
- ✅ Use `@State` for local UI state (alerts, sheets, animations)
- ✅ Use `@Environment(AppServices.self)` and `@Environment(AppSession.self)` for app-wide state
- ✅ Use `@Environment(Router<AppTab, AppRoute, AppSheet>.self)` for navigation
- ✅ Use `DSButton`/`DSIconButton` for interactive elements
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

## Design System Usage

- Use DesignSystem components for consistent UI (`DSButton`, `EmptyStateView`, `ErrorStateView`, `LoadingView`, `SkeletonView`, `ToastView`). `ProgressView` is also acceptable for inline loading states.
- Use typography extensions (`.titleLarge()`, `.headlineMedium()`, `.bodySmall()`) instead of hardcoded sizes.
- Use semantic colors (`.textPrimary`, `.backgroundSecondary`, `.success`, `.error`) instead of custom hex values.
- Keep layout clean with `.frame(maxWidth: .infinity, alignment: .leading)` when alignment is the goal; use `Spacer()` for intentional spacing/distribution.

---

## Reusable Components

Components are **dumb UI** and stay stateless:

- ✅ No business logic
- ✅ No data fetching
- ✅ Data injected via init
- ✅ Actions are closures
- ✅ Use `DSButton`/`DSIconButton` for interactions
- ✅ Use `ImageLoaderView` for remote images

---

## View Composition

- Avoid `AnyView` unless a framework API or heterogeneous view collection requires type erasure.
- Prefer `ViewModifier`, `@ViewBuilder`, or dedicated view types for conditional UI and availability branches.
- If type erasure is unavoidable, keep the wrapper scoped to the view file that needs it.
- Prefer `.background(...)` or `.overlay(...)` for static decorative layers instead of wrapping content in a `ZStack`.

---

## Button Usage

Avoid `onTapGesture` for interactive elements. Prefer `DSButton`/`DSIconButton` (or `Button` in lower-level components):

```swift
DSButton(
  title: "Save",
  action: { viewModel.save(...) }
)
```
