# AGENTS.md

This file provides guidance to AI coding agents when working with this repository.

---

## Building the Project

**ALWAYS use MCP tools for building.** Do not use direct `xcodebuild` commands.

### MCP Build Tools

```
mcp__XcodeBuildMCP__build_sim     # Build for simulator
mcp__XcodeBuildMCP__clean         # Clean build folder
mcp__XcodeBuildMCP__list_schemes  # List available schemes
mcp__XcodeBuildMCP__list_sims     # List available simulators
mcp__XcodeBuildMCP__doctor        # Diagnose build issues
```

### Build Workflow

1. **First time**: Run `mcp__XcodeBuildMCP__session-set-defaults` to configure
2. **Build**: Use `mcp__XcodeBuildMCP__build_sim` for simulator builds
3. **If fails**: Use `mcp__XcodeBuildMCP__doctor` to diagnose
4. **Clean**: Use `mcp__XcodeBuildMCP__clean` before rebuilding if needed

---

## Documentation Structure

All detailed documentation is in `.claude/docs/`:

| File | Purpose |
|------|---------|
| `project-structure.md` | Architecture overview, folder structure |
| `mvvm-lite-architecture.md` | MVVM-lite rules, UI guidelines |
| `commit-guidelines.md` | Commit message format |
| `package-dependencies.md` | SwiftfulThinking package integration |
| `package-quick-reference.md` | Quick snippets and common patterns |
| `design-system-usage.md` | DSButton, EmptyStateView, colors, typography |
| `design-system-recipes.md` | Design system examples and patterns |
| `testing-guide.md` | ViewModel testing, accessibility identifiers |
| `localization-guide.md` | String Catalog workflow |
| `action-create-screen.md` | How to create new MVVM-lite features |
| `action-create-component.md` | How to create reusable components |
| `action-create-manager.md` | How to create new managers |
| `action-create-model.md` | How to create data models |

---

## Quick Summary

- **Architecture**: MVVM-lite + AppRouter (TabView + NavigationStack + sheets)
- **Tech Stack**: SwiftUI (iOS 26+), Swift 5.9+, Firebase, RevenueCat, Mixpanel
- **Build Configs**: Mock (no Firebase), Dev, Prod
- **Packages**: SwiftfulThinking ecosystem + app-core-packages

---

## Quick Start Guide

### For New Screens
1. Create a SwiftUI View + ViewModel under `/Features/[FeatureName]/`
2. Wire navigation in `AppRoute`/`AppSheet` if needed
3. Follow the steps in ACTION 1 documentation

### For New Components
- Always create in `/Components/Views/` (or `/Components/Modals/` for modals)
- Make all data properties optional for flexibility
- Never include business logic - components are dumb UI
- Follow the rules in ACTION 2 documentation

### For New Managers
- Decide: Service Manager (most common) or Data Sync Manager (for Firestore sync)
- Service Managers use protocol-based pattern with Mock/Prod implementations
- Data Sync Managers extend SwiftfulDataManagers classes
- Follow the steps in ACTION 3 documentation

### For New Models
- Models live in `/Managers/[ManagerName]/Models/`
- Must conform to: `StringIdentifiable, Codable, Sendable, DMProtocol`
- Use snake_case for CodingKeys raw values
- Follow the steps in ACTION 4 documentation

---

## Critical Rules

### File Creation (ALWAYS use Write/Edit tools)
- This project uses Xcode 15+ File System Synchronization
- Files created in `AppTemplateLite/` folder automatically appear in Xcode
- ALWAYS use Write/Edit tools to create .swift files (unless documentation)
- Files automatically included in build - no manual Xcode steps needed

### MVVM-lite Data Flow
```
View → ViewModel → Services/Managers
```

### Component Rules
- NO @State for data (only for UI animations)
- NO business logic
- ALL data is injected via init
- Make properties optional when possible
- ALL actions are closures

### Layout Best Practices
- PREFER `.frame(maxWidth: .infinity, alignment: .leading)` over `Spacer()`
- ALWAYS use `ImageLoaderView` for URL images (never AsyncImage)
- ALWAYS use `DSButton` or `DSIconButton` for interactive elements in feature screens

### Analytics
- Key ViewModel actions MUST track events
- Manager methods MUST track events with logger

---

## Build Configurations

- **Mock**: Fast development, no Firebase, mock data
- **Development**: Real Firebase with dev credentials
- **Production**: Real Firebase with production credentials

Use Mock for 90% of development.

---

## File Locations

- **App Shell**: `/AppTemplateLite/App/`
- **Features**: `/AppTemplateLite/Features/[FeatureName]/`
- **Managers**: `/AppTemplateLite/Managers/[ManagerName]/`
- **Components**: `/AppTemplateLite/Components/Views/`
- **Extensions**: `/AppTemplateLite/Extensions/`
- **SPM Packages**: `app-core-packages` (DesignSystem, Data, LocalPersistance, Networking)

---

## Additional Resources

- Official Documentation: https://www.swiftful-thinking.com/offers/REyNLwwH
- AppRouter: https://github.com/Dimillian/AppRouter
