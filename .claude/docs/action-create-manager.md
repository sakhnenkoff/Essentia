# ACTION 3: Create New Manager

**Triggers:** "add manager", "new manager", "create manager", "add data manager"

---

## Steps

1. Create a folder: `/Essentia/Managers/ManagerName/`
2. Add alias file for the package types (if needed)
3. Implement the manager class
4. Wire it in `App/Dependencies/AppServices.swift`
5. Expose it via `AppServices` if features need it

---

## AppServices Wiring Example

```swift
// AppServices.swift
var newManager: NewManager?

if FeatureFlags.enableNewFeature {
  newManager = NewManager(service: MockNewService(), logger: logManager)
}

self.newManager = newManager
```

---

Keep manager logic independent of views. ViewModels consume managers through `AppServices`.
