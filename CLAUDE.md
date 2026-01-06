# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 📚 Documentation Structure

This documentation is organized into focused files for better maintainability. Each file covers a specific aspect of the project:

### Core Documentation

- **Project Architecture & Structure**: @.claude/docs/project-structure.md
  - Project overview and architecture patterns
  - Build configurations (Mock, Dev, Prod)
  - Manager system and dependencies
  - Common development workflows

- **MVVM-lite & AppRouter Rules**: @.claude/docs/viper-architecture.md
  - View + ViewModel conventions
  - AppRouter navigation patterns
  - Layout best practices
  - Data flow summary

- **Commit Style Guidelines**: @.claude/docs/commit-guidelines.md
  - Commit message format and rules
  - Only applies when explicitly asked to "commit"

- **Package Dependencies**: @.claude/docs/package-dependencies.md
  - Project-specific implementation of all SwiftfulThinking packages
  - How THIS project actually uses each package (not general capabilities)
  - Initialization patterns, configurations, and integration examples
  - Critical for understanding package coordination in this architecture

- **Package Quick Reference**: @.claude/docs/package-quick-reference.md
  - 1-minute overview of each package
  - Copy/paste code snippets for common tasks
  - Common mistakes to avoid
  - Quick lookup for frequently used features

- **DesignSystem Usage**: @.claude/docs/design-system-usage.md
  - DSButton, EmptyStateView, ErrorStateView, SkeletonView components
  - ToastView and LoadingView modifiers
  - Color extensions and typography system
  - Copy/paste code snippets

- **Testing Guide**: @.claude/docs/testing-guide.md
  - ViewModel unit testing
  - Accessibility identifier conventions for UI testing
  - Preview helpers and testing strategies
  - Test file templates

- **Localization Guide**: @.claude/docs/localization-guide.md
  - Native String Catalog (.xcstrings) workflow
  - When to use `Text("key")` vs `String(localized: "key")`
  - Asset symbol generation for type-safe images/colors
  - Translation workflow for agents

### Required Actions

When the user triggers specific requests, follow these action workflows:

- **ACTION 1 - Create New Feature**: @.claude/docs/action-create-screen.md
  - Triggers: "create new screen", "create screen", "new screen", "add new screen", "new feature"
  - Creates SwiftUI view + MVVM-lite view model

- **ACTION 2 - Create Reusable Component**: @.claude/docs/action-create-component.md
  - Triggers: "create component", "new component", "create reusable view", "add component"
  - Creates dumb UI components with injected data and callbacks

- **ACTION 3 - Create New Manager**: @.claude/docs/action-create-manager.md
  - Triggers: "add manager", "new manager", "create manager", "add data manager"
  - Supports both Service Managers and Data Sync Managers (SwiftfulDataManagers)

- **ACTION 4 - Create Data Model**: @.claude/docs/action-create-model.md
  - Triggers: "create data model", "new model", "create model", "new data type"
  - Uses Xcode model templates for consistency

---

## 🎯 Quick Start Guide

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

## ⚡ Critical Rules

### File Creation (ALWAYS use Write/Edit tools)
- ✅ This project uses Xcode 15+ File System Synchronization
- ✅ Files created in `AppTemplateLite/` folder automatically appear in Xcode
- ✅ ALWAYS use Write/Edit tools to create .swift files (unless documentation)
- ✅ Files automatically included in build - no manual Xcode steps needed
- ❌ Exception: If file created outside main folder, provide path for manual add (rare)

See @.claude/docs/project-structure.md for details on `PBXFileSystemSynchronizedRootGroup`

### MVVM-lite Data Flow
```
View → ViewModel → Services/Managers
```

### Component Rules
- ✅ NO @State for data (only for UI animations)
- ✅ NO business logic
- ✅ ALL data is injected via init
- ✅ Make properties optional when possible
- ✅ ALL actions are closures

### Layout Best Practices
- ✅ PREFER `.frame(maxWidth: .infinity, alignment: .leading)` over `Spacer()`
- ✅ ALWAYS use `ImageLoaderView` for URL images (never AsyncImage)
- ✅ ALWAYS use `.anyButton()` or `.asButton()` modifier instead of `Button()` wrapper

### Analytics
- ✅ Key ViewModel actions MUST track events
- ✅ Manager methods MUST track events with logger

---

## 🔧 Build Configurations

- **Mock**: Fast development, no Firebase, mock data
- **Development**: Real Firebase with dev credentials
- **Production**: Real Firebase with production credentials

Use Mock for 90% of development.

---

## 📖 Additional Resources

- Official Documentation: https://www.swiftful-thinking.com/offers/REyNLwwH
- AppRouter: https://github.com/Dimillian/AppRouter

---

## 💡 Need Help?

For detailed information on any topic:
- **Architecture questions**: Check project-structure.md
- **MVVM-lite questions**: Check viper-architecture.md
- **Creating new features**: Check the relevant ACTION document
- **UI components**: Check design-system-usage.md
- **Testing patterns**: Check testing-guide.md
- **Localization**: Check localization-guide.md

All documentation files are in `.claude/docs/` directory.
