# AGENTS.md

This file provides guidance to AI coding agents (Codex CLI, etc.) when working with this repository.

---

## Primary Documentation

**Read the main documentation file first:**

→ **[CLAUDE.md](./CLAUDE.md)**

This file contains all project architecture, coding standards, and action workflows.

---

## Quick Summary

- **Architecture**: MVVM-lite + AppRouter (TabView + NavigationStack + sheets)
- **Tech Stack**: SwiftUI (iOS 26+), Swift 5.9+, Firebase, RevenueCat, Mixpanel
- **Build Configs**: Mock (no Firebase), Dev, Prod
- **Packages**: SwiftfulThinking ecosystem + app-core-packages

---

## Documentation Structure

All detailed documentation is in `.claude/docs/`:

| File | Purpose |
|------|---------|
| `project-structure.md` | Architecture overview, folder structure |
| `viper-architecture.md` | MVVM-lite rules, UI guidelines |
| `commit-guidelines.md` | Commit message format |
| `package-dependencies.md` | SwiftfulThinking package integration |
| `package-quick-reference.md` | Quick snippets and common patterns |
| `action-create-screen.md` | How to create new MVVM-lite features |
| `action-create-component.md` | How to create reusable components |
| `action-create-manager.md` | How to create new managers |
| `action-create-model.md` | How to create data models |

---

## Critical Rules

1. **MVVM-lite data flow**: View → ViewModel → Services/Managers
2. **Components are dumb UI**: No @State for data, all data injected via init
3. **Use templates**: Manager/model templates exist; screens are regular SwiftUI files
4. **File creation**: Use Write/Edit tools - Xcode 15+ auto-syncs files
5. **Analytics**: ViewModels should track key events

---

## File Locations

- **App Shell**: `/AppTemplateLite/App/`
- **Features**: `/AppTemplateLite/Features/[FeatureName]/`
- **Managers**: `/AppTemplateLite/Managers/[ManagerName]/`
- **Components**: `/AppTemplateLite/Components/Views/`
- **Extensions**: `/AppTemplateLite/Extensions/`
- **SPM Packages**: `app-core-packages` (DesignSystem, Data, LocalPersistance, Networking)

---

For complete details, read **[CLAUDE.md](./CLAUDE.md)** and the files in `.claude/docs/`.
