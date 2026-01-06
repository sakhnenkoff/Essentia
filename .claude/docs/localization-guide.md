# Localization Guide

This project uses Xcode 15+ native localization features with String Catalogs. No manual L10n enum is needed.

---

## Overview

- **String Catalogs (.xcstrings)** - Modern Xcode format with visual editor
- **Auto-extraction** - Xcode automatically extracts strings from code on build
- **Native Asset Symbols** - Type-safe `Image(.name)` and `Color(.name)` access
- **Languages** - English (base) + Ukrainian

---

## How String Catalogs Work

1. You write `Text("Hello")` or `String(localized: "Hello")` in your code
2. When you build, Xcode scans all source files
3. Xcode automatically adds discovered strings to `Localizable.xcstrings`
4. Open the catalog in Xcode to add translations
5. The app uses the appropriate translation at runtime

---

## Usage Patterns

### Static UI Text (Most Common)

SwiftUI `Text` views are automatically localized:

```swift
// These strings are auto-extracted on build
Text("Settings")
Text("Home")
Text("Save")

// Navigation titles
.navigationTitle("Profile")

// Buttons
Button("Cancel") { }
Button("Delete Account") { }
```

### Programmatic Strings

When you need a `String` value (not a `Text` view):

```swift
// In ViewModel - for alerts, toasts, etc.
let title = String(localized: "Delete Account?")
let message = String(localized: "This action cannot be undone.")

// Present via your alert or sheet wiring

// For toast messages
toast = .error(String(localized: "Failed to save"))
toast = .success(String(localized: "Changes saved"))
```

### Strings with Parameters

String interpolation works automatically:

```swift
// UI text with parameters
Text("Welcome, \(userName)")
Text("You have \(itemCount) items")

// Programmatic
let message = String(localized: "Hello, \(name)!")
let status = String(localized: "\(count) items remaining")
```

### Pluralization

Use string interpolation for automatic plural handling:

```swift
// Xcode generates plural variants automatically
Text("\(count) item(s)")

// Or be explicit in the String Catalog editor
// by adding plural variants for the key
```

---

## Asset Symbols

After enabling asset symbol generation in Xcode Build Settings:

```swift
// Type-safe image access
Image(.iconSettings)     // Instead of Image("iconSettings")
Image(.logoApp)          // Instead of Image("logoApp")

// Type-safe color access
Color(.themeAccent)      // Instead of Color("themeAccent")
Color(.backgroundCard)   // Instead of Color("backgroundCard")
```

---

## Where to Use Each Pattern

| Context | Pattern | Example |
|---------|---------|---------|
| SwiftUI Text | `Text("key")` | `Text("Settings")` |
| Navigation title | `.navigationTitle("key")` | `.navigationTitle("Home")` |
| Button label | `Button("key")` | `Button("Save") { }` |
| Alert title/message | `String(localized:)` | `String(localized: "Error")` |
| Toast message | `String(localized:)` | `String(localized: "Saved!")` |
| ViewModel logic | `String(localized:)` | Any string needed in ViewModel |

---

## MVVM-lite Integration

### Views
Use `Text("key")` directly - automatic localization:

```swift
struct SettingsView: View {
    var body: some View {
        Form {
            Section("Account") {
                Button("Sign Out") {
                    viewModel.signOut(...)
                }
            }
        }
        .navigationTitle("Settings")
    }
}
```

### ViewModels
Use `String(localized:)` for programmatic strings:

```swift
@Observable
@MainActor
class SettingsViewModel {
    var toast: Toast?

    func onSignOutCompleted() {
        toast = .success(String(localized: "Signed out successfully"))
    }

    func onError(_ error: Error) {
        // For dynamic error messages, you might not localize
        toast = .error(String(localized: "An error occurred"))
    }
}
```

### Alert Presentation
Pass localized strings to your alert wiring:

```swift
func showDeleteConfirmation() {
    // Wire into your view-level alert presentation.
    let title = String(localized: "Delete Account?")
    let message = String(localized: "This action cannot be undone.")
    _ = (title, message)
}
```

---

## Adding New Strings

### Workflow

1. **Write your code** with `Text("Your String")` or `String(localized: "Your String")`
2. **Build the project** (Cmd+B)
3. Xcode auto-extracts new strings to `Localizable.xcstrings`
4. **Open `Localizable.xcstrings`** in Xcode
5. Find the new string and add Ukrainian translation
6. Build again to verify

### String Catalog Editor

- Strings appear in a table format
- Each row shows: Key, English value, Ukrainian value, State
- States: "New", "Needs Review", "Translated", "Stale"
- Click a cell to edit the translation

---

## Rules

### DO

- Use `Text("key")` for all visible UI text
- Use `String(localized: "key")` for programmatic strings
- Build regularly to sync new strings to the catalog
- Translate strings promptly after adding them
- Use descriptive, full sentences as keys (they ARE the English text)

### DON'T

- Don't create a manual L10n enum (not needed with String Catalogs)
- Don't use `NSLocalizedString` (deprecated pattern)
- Don't use string keys like `"home.title"` - use the actual English text
- Don't localize technical strings (API keys, identifiers, etc.)

---

## Xcode Configuration Required

### 1. Add Ukrainian Language

1. Select project in Navigator
2. Go to Info tab
3. Find "Localizations" section
4. Click "+" and add "Ukrainian (uk)"
5. English should remain as "Development Language"

### 2. Enable Asset Symbol Generation (Optional)

1. Select project in Navigator
2. Go to Build Settings tab
3. Search for "Generate Asset Symbols"
4. Set to "Yes" for all targets

---

## File Locations

| Location | Purpose |
|----------|---------|
| `AppTemplateLite/Localizable.xcstrings` | Main app strings |
| `app-core-packages/DesignSystem/.../Resources/Localizable.xcstrings` | DesignSystem package strings |

Both are auto-synced by Xcode on every build and committed to source control.

---

## Package Localization (DesignSystem)

The DesignSystem package has its own String Catalog for component strings (error messages, empty states, buttons).

### How It Works

Package code uses `bundle: .module` to reference its own String Catalog:

```swift
// In DesignSystem package code
String(localized: "Try Again", bundle: .module)
String(localized: "No Results Found", bundle: .module)
```

### Localized Components

These components have built-in localized strings:

- **ErrorStateView** - "Something Went Wrong", "Try Again", "Connection Problem", etc.
- **EmptyStateView** - "No Results Found", "No Favorites", "Nothing Here Yet", etc.

### Adding Package Strings

1. Add string with `String(localized: "key", bundle: .module)` in package code
2. Build the project
3. Open `app-core-packages/DesignSystem/.../Resources/Localizable.xcstrings`
4. Add translations

### Package.swift Configuration

The DesignSystem package is configured to include resources:

```swift
.target(
    name: "DesignSystem",
    dependencies: [],
    resources: [.process("Resources")]
)
```

---

## Troubleshooting

### Strings Not Appearing in Catalog

1. Ensure you're using `Text("...")` or `String(localized: "...")`
2. Build the project (Cmd+B)
3. Check the file has target membership

### Wrong Language Displaying

1. Check simulator/device language settings
2. Verify the translation exists in the catalog
3. Clean build folder (Cmd+Shift+K) and rebuild

### Asset Symbols Not Working

1. Verify "Generate Asset Symbols" is enabled
2. Ensure images/colors are in an Asset Catalog (.xcassets)
3. Build the project to regenerate symbols
