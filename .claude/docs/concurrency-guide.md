# Concurrency Guide

This project is configured for Swift 6 strict concurrency with an app-first `MainActor` baseline.

---

## Current Baseline

- App target (`Essentia`) uses:
  - Strict concurrency checking: `complete`
  - Default actor isolation: `MainActor`
  - Upcoming features:
    - `NonisolatedNonsendingByDefault`
    - `InferIsolatedConformances`
- Local package (`essentia-core-packages`) uses upcoming features but does not set default isolation to `MainActor`.

---

## Practical Impact

- Unannotated app declarations are now treated as `MainActor`-isolated unless marked otherwise.
- Nonisolated async methods can inherit caller isolation under `NonisolatedNonsendingByDefault`.
- Protocol conformances involving actor-isolated types are inferred more strictly.

---

## Rules for New Code

1. Keep UI-facing ViewModels `@MainActor` and `@Observable`.
2. Use `@concurrent` on async APIs that should not inherit caller actor isolation.
3. Use `nonisolated` only for small, truly actor-independent helpers.
4. Prefer structured concurrency (`async let`, task groups) over detached tasks.
5. Do not use `Thread.current` in async contexts.

---

## Unsafe Annotation Policy

- Avoid `@unchecked Sendable` and `nonisolated(unsafe)` in new code by default.
- If unavoidable:
  - Add a short `SAFETY:` comment documenting the invariant.
  - Add a TODO follow-up ticket to remove it.

Example:

```swift
// SAFETY: Protected by lock on all access paths.
// TODO(CONC-123): Replace with actor-backed storage.
final class LegacyCache: @unchecked Sendable { ... }
```

---

## Validation Commands

### App

```bash
xcodebuild -project Essentia.xcodeproj -scheme "Essentia - Mock" -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build
xcodebuild -project Essentia.xcodeproj -scheme "Essentia - Development" -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build
xcodebuild -project Essentia.xcodeproj -scheme "Essentia - Production" -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build
```

### Packages

```bash
cd /Users/matvii/Documents/Developer/Packages/essentia-core-packages
xcodebuild -scheme Core -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build
xcodebuild -scheme CoreMock -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build
xcodebuild -scheme DesignSystem -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build
xcodebuild -scheme essentia-core-packages-Package -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' test
```
