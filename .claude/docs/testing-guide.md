# Testing Guide (MVVM-lite)

## What to Test

- ViewModel logic (async flows, error handling, analytics)
- Managers that encapsulate business rules

Note: Presenter/Interactor patterns are not used in this project. Any legacy presenter tests should be treated as examples to delete or ignore when building new tests.

## ViewModel Testing Pattern

1. Create a mock `AppServices` or use `AppServices(configuration: .mock(isSignedIn: true))`.
2. Drive the ViewModel method.
3. Assert on state changes.

```swift
@Test
func testSignOutResetsSession() async {
  let services = AppServices(configuration: .mock(isSignedIn: true))
  let session = AppSession()
  let viewModel = SettingsViewModel()

  viewModel.signOut(services: services, session: session)
  // Assert session state changes after task completes.
}
```

## UI Testing

Add accessibility identifiers on key controls using `.buttonTestID` or `.testID` helpers where available.
