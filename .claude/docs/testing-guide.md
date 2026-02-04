# Testing Guide (MVVM)

## What to Test

- ViewModel logic (async flows, error handling, analytics)
- Managers that encapsulate business rules
- For larger features, run a build and confirm there are no compile errors.

## Build Verification (Required for Large Features)

When shipping larger changes, always run a simulator build using `xcodebuild` and confirm a clean compile with zero app warnings (external package warnings are acceptable):

1. `xcodebuild -project Essentia.xcodeproj -scheme "Essentia - Mock" -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build`
2. If the build fails or emits app warnings, fix them before completing the task.

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
