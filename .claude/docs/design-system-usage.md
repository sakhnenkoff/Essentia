# DesignSystem Package Usage

The DesignSystem package provides reusable UI components, colors, and typography for consistent app design.

---

## DSButton - Standardized Buttons

### Basic Usage

```swift
import DesignSystem

// Primary button (default)
DSButton(title: "Submit", action: { })

// With different styles
DSButton(title: "Cancel", style: .secondary, action: { })
DSButton(title: "Delete", style: .destructive, action: { })
DSButton(title: "Learn More", style: .tertiary, action: { })

// With sizes
DSButton(title: "Small", size: .small, action: { })
DSButton(title: "Medium", size: .medium, action: { })
DSButton(title: "Large", size: .large, action: { })

// With icon
DSButton(title: "Add Item", icon: "plus", action: { })

// Full width
DSButton(title: "Continue", isFullWidth: true, action: { })

// Loading state
DSButton(title: "Saving...", isLoading: true, action: { })

// Disabled
DSButton(title: "Submit", isEnabled: false, action: { })
```

### Convenience Initializers

```swift
// Full-width CTA button
DSButton.cta(title: "Get Started", isLoading: isSubmitting, action: { })

// Destructive action with trash icon
DSButton.destructive(title: "Delete Account", action: { })

// Text-only link button
DSButton.link(title: "Forgot Password?", action: { })
```

### Icon-Only Buttons

```swift
DSIconButton(icon: "heart.fill", style: .primary, size: .medium, action: { })
DSIconButton(icon: "plus", style: .secondary, action: { })
DSIconButton(icon: "xmark", style: .tertiary, size: .small, action: { })
```

### Button Styles

| Style | Background | Text | Use Case |
|-------|------------|------|----------|
| `.primary` | Theme primary | White | Main actions |
| `.secondary` | Clear + border | Theme primary | Secondary actions |
| `.tertiary` | Clear | Theme primary | Links, text buttons |
| `.destructive` | Error color | White | Delete, remove actions |

---

## EmptyStateView - Empty Content States

### Basic Usage

```swift
import DesignSystem

EmptyStateView(
    icon: "folder",
    title: "No Documents",
    message: "Create your first document to get started",
    actionTitle: "Create Document",
    action: { createDocument() }
)
```

### Convenience Initializers

```swift
// Search results
EmptyStateView.noSearchResults(query: "swift tutorials", onClearSearch: { })

// Empty list
EmptyStateView.emptyList(
    title: "No Tasks",
    message: "Add tasks to get started",
    actionTitle: "Add Task",
    action: { }
)

// No favorites
EmptyStateView.noFavorites(onBrowse: { })

// No notifications
EmptyStateView.noNotifications()
```

### View Modifier

```swift
List(items) { item in
    ItemRow(item: item)
}
.emptyState(
    items.isEmpty,
    icon: "tray",
    title: "No Items",
    message: "Add items to see them here"
)
```

---

## ErrorStateView - Error States

### Basic Usage

```swift
import DesignSystem

// From an Error object
ErrorStateView(error: someError, onRetry: { fetchData() })

// Custom error
ErrorStateView(
    title: "Upload Failed",
    message: "Please check your connection",
    retryTitle: "Try Again",
    onRetry: { retry() },
    dismissTitle: "Cancel",
    onDismiss: { dismiss() }
)
```

### Convenience Initializers

```swift
// Network error
ErrorStateView.networkError(onRetry: { })

// Server error
ErrorStateView.serverError(onRetry: { })

// Permission denied
ErrorStateView.permissionDenied(feature: "camera", onOpenSettings: { openSettings() })

// Load failed
ErrorStateView.loadFailed(onRetry: { })
```

### View Modifier

```swift
ContentView()
    .errorState(error, retryAction: { fetchData() })
```

---

## SkeletonView - Loading Placeholders

### Basic Usage

```swift
import DesignSystem

// Text lines
SkeletonView(style: .text(lines: 3, lastLineWidth: 0.7))

// Shapes
SkeletonView(style: .circle(diameter: 60))
SkeletonView(style: .rectangle(width: 100, height: 60))
SkeletonView(style: .avatar(size: .medium))

// Presets
SkeletonView(style: .card)
SkeletonView(style: .listRow)
```

### View Modifiers

```swift
// Replace content with skeleton
Text("Hello World")
    .skeleton(isLoading, style: .text(lines: 1))

// Apply shimmer to existing content (uses redacted)
ProfileView()
    .shimmer(isLoading)
```

### Skeleton Styles

| Style | Description |
|-------|-------------|
| `.text(lines:lastLineWidth:)` | Multiple text lines |
| `.circle(diameter:)` | Circle shape |
| `.rectangle(width:height:)` | Rectangle shape |
| `.avatar(size:)` | Avatar placeholder (small/medium/large) |
| `.card` | Card with image and text |
| `.listRow` | List row with avatar and text |

---

## ToastView - Notification System

### Basic Usage

```swift
import DesignSystem

struct MyView: View {
    @State private var toast: Toast?

    var body: some View {
        VStack {
            Button("Show Error") {
                toast = .error("Something went wrong!")
            }

            Button("Show Success") {
                toast = .success("Operation completed!")
            }
        }
        .toast($toast)  // Add toast modifier
    }
}
```

### Toast Types

```swift
Toast.error("Error message")      // Red background
Toast.success("Success message")  // Green background
Toast.warning("Warning message")  // Orange background
Toast.info("Info message")        // Blue background
```

### Custom Duration

```swift
Toast.error("Message", duration: 5.0)  // Shows for 5 seconds (default: 3.0)
```

### Manual Toast Creation

```swift
let toast = Toast(
    style: .success,
    message: "Custom toast message",
    duration: 4.0
)
```

---

## LoadingView - Loading Indicators

### Basic Usage with Modifier

```swift
import DesignSystem

struct MyView: View {
    @State private var isLoading = false

    var body: some View {
        ContentView()
            .loading(isLoading, message: "Loading data...")
    }
}
```

### Loading Styles

```swift
// Default style - standard with background
LoadingView(style: .default)

// Overlay style - dark overlay, larger spinner
LoadingView(message: "Please wait...", style: .overlay)

// Inline style - small, no background
LoadingView(style: .inline)
```

### Inline Loading Example

```swift
HStack {
    Text("Processing")
    LoadingView(style: .inline)
}
```

### Style Properties

| Style | Scale | Background | Tint Color |
|-------|-------|------------|------------|
| `.default` | 1.5x | Secondary background | Primary |
| `.overlay` | 2.0x | Black 70% opacity | White |
| `.inline` | 1.0x | Clear | Primary |

---

## Color Extensions

### Semantic Colors

```swift
Color.success   // Green - for success states
Color.warning   // Orange - for warnings
Color.error     // Red - for errors
Color.info      // Blue - for information
```

### Background Colors

```swift
Color.backgroundPrimary    // System background
Color.backgroundSecondary  // Secondary system background
Color.backgroundTertiary   // Tertiary system background
```

### Text Colors

```swift
Color.textPrimary    // Primary label color
Color.textSecondary  // Secondary label color
Color.textTertiary   // Tertiary label color
```

### Hex Color Initializer

```swift
Color(hex: "#FF5733")   // From hex string with #
Color(hex: "FF5733")    // Also works without #
Color(hex: "F53")       // 3-character shorthand
Color(hex: "80FF5733")  // With alpha (ARGB format)
```

---

## Typography (Font Extensions)

### Title Fonts

```swift
Text("Large Title").font(.titleLarge())    // 34pt bold
Text("Medium Title").font(.titleMedium())  // 28pt bold
Text("Small Title").font(.titleSmall())    // 22pt bold
```

### Headline Fonts

```swift
Text("Large Headline").font(.headlineLarge())   // 20pt semibold
Text("Medium Headline").font(.headlineMedium()) // 17pt semibold
Text("Small Headline").font(.headlineSmall())   // 15pt semibold
```

### Body Fonts

```swift
Text("Large Body").font(.bodyLarge())   // 17pt regular
Text("Medium Body").font(.bodyMedium()) // 15pt regular
Text("Small Body").font(.bodySmall())   // 13pt regular
```

### Caption Fonts

```swift
Text("Large Caption").font(.captionLarge())  // 12pt regular
Text("Small Caption").font(.captionSmall())  // 11pt regular
```

### Button Fonts

```swift
Text("Large Button").font(.buttonLarge())   // 17pt semibold
Text("Medium Button").font(.buttonMedium()) // 15pt semibold
Text("Small Button").font(.buttonSmall())   // 13pt semibold
```

---

## Integration with MVVM

### Toast State in ViewModel

Toast state should be managed in the **ViewModel**:

```swift
@Observable
@MainActor
class MyScreenViewModel {
    var toast: Toast?

    func onActionCompleted() {
        toast = .success("Action completed!")
    }

    func onError(_ error: Error) {
        toast = .error(error.localizedDescription)
    }
}
```

### View Usage with ViewModel

```swift
struct MyScreenView: View {
    @State var viewModel: MyScreenViewModel

    var body: some View {
        ContentView()
            .toast($viewModel.toast)
    }
}
```

### Loading State in ViewModel

```swift
@Observable
@MainActor
class MyScreenViewModel {
    var isLoading = false

    func onLoadData() {
        isLoading = true
        Task {
            defer { isLoading = false }
            try await fetchData()
        }
    }

    func fetchData() async throws { }
}
```

### View with Loading

```swift
struct MyScreenView: View {
    @State var viewModel: MyScreenViewModel

    var body: some View {
        ContentView()
            .loading(viewModel.isLoading, message: "Loading...")
    }
}
```

---

## Complete Example

```swift
import SwiftUI
import DesignSystem

struct ExampleView: View {
    @State var viewModel: ExampleViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome")
                .font(.titleLarge())
                .foregroundColor(.textPrimary)

            Text("This is a demo of DesignSystem")
                .font(.bodyMedium())
                .foregroundColor(.textSecondary)

            Button("Load Data") {
                viewModel.onLoadData()
            }
            .font(.buttonLarge())

            Button("Show Success") {
                viewModel.showSuccess()
            }
            .foregroundColor(.success)

            Button("Show Error") {
                viewModel.showError()
            }
            .foregroundColor(.error)
        }
        .padding()
        .background(Color.backgroundPrimary)
        .toast($viewModel.toast)
        .loading(viewModel.isLoading)
    }
}

@Observable
@MainActor
class ExampleViewModel {
    var toast: Toast?
    var isLoading = false

    func onLoadData() {
        isLoading = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            isLoading = false
            toast = .success("Data loaded!")
        }
    }

    func showSuccess() {
        toast = .success("Operation successful!")
    }

    func showError() {
        toast = .error("Something went wrong!")
    }
}
```

---

## Best Practices

1. **Toast messages should be brief** - Keep messages under 50 characters
2. **Use appropriate toast types** - Match the type to the message meaning
3. **Loading should block interaction** - The overlay style prevents user interaction
4. **Use semantic colors** - Don't hardcode colors, use the semantic extensions
5. **Typography consistency** - Use the font extensions for consistent sizing
6. **State in ViewModel** - Keep toast and loading state in the ViewModel, not the View
