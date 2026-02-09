# Rule Loading Guide

Use this file as the first read. It keeps agent context focused and avoids loading every doc for every task.

---

## Core Rule

1. Read this file first.
2. Load only the docs required for the current task.
3. If task scope changes, unload assumptions and load the matching doc set below.

---

## Task-to-Docs Map

### Any code task (baseline)
- `project-structure.md`
- `mvvm-architecture.md`
- `concurrency-guide.md`

### New feature screen
- `action-create-screen.md`
- `design-system-usage.md`
- `design-system-recipes.md`
- `testing-guide.md`

### Reusable component
- `action-create-component.md`
- `design-system-usage.md`
- `design-system-recipes.md`

### New manager/service
- `action-create-manager.md`
- `package-dependencies.md`
- `package-quick-reference.md`
- `testing-guide.md`

### New model
- `action-create-model.md`

### Localization work
- `localization-guide.md`

### Testing only
- `testing-guide.md`

### Commit requested
- `commit-guidelines.md`

---

## Decision Rules

- If a request is ambiguous, clarify with concrete options before implementing.
- If docs conflict, prefer:
  1. `AGENTS.md`
  2. Action doc for the task type
  3. Architecture/design docs
- If code introduces a new recurring pattern, update the relevant doc(s) in the same PR/commit.

---

## Anti-Patterns to Avoid

- Loading all `.claude/docs/*` for small tasks.
- Applying global fixes (especially concurrency isolation) when a local fix is sufficient.
- Adding `@unchecked Sendable`/`nonisolated(unsafe)` without a `SAFETY:` invariant and TODO follow-up.
