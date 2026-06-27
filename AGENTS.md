# Agent Instructions

**⚠️ This file is maintained by OpenAI Codex CLI. For comprehensive agent instructions, see the `_AGENT_INSTRUCTIONS/` directory.**

## Quick Start for AI Agents

🚨 **MANDATORY FIRST STEP**: Read [`_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md`](_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md). These global guardrails control how agents plan work, request approval, and constrain edit scope.

🚨 **MANDATORY SECOND STEP**: Read [`_AGENT_INSTRUCTIONS/agent-per-project/README.md`](_AGENT_INSTRUCTIONS/agent-per-project/README.md) before making ANY code changes.

This README contains the canonical index to all project documentation including:

- Critical import patterns and database access rules
- DDD architecture and aggregate boundaries
- Riverpod provider code generation patterns
- Navigation system (ViewSpec-based)
- AddressBook path resolution (critical for imports)

## Essential Documentation

### Must-Read Before Coding

1. **[Agent Guardrails](_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md)** - Global planning and change-control rules
2. **[Project README](_AGENT_INSTRUCTIONS/agent-per-project/README.md)** - Canonical index
3. **[Dart Guidelines](_AGENT_INSTRUCTIONS/agent-instructions-shared/10-language/dart.md)** - Language rules, async patterns, null-safety expectations
4. **[Flutter Widget Guidelines](_AGENT_INSTRUCTIONS/agent-instructions-shared/20-flutter/widgets.md)** - Composition, navigation, and state management rules
5. **[Riverpod Patterns](_AGENT_INSTRUCTIONS/agent-instructions-shared/20-flutter/riverpod-provider-patterns.md)** - MANDATORY code generation patterns
6. **[Dark Mode Theming](_AGENT_INSTRUCTIONS/agent-per-project/05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md)** - Luminance hierarchy, selection contrast, semantic token rules
7. **[Center Panel Layouts](_AGENT_INSTRUCTIONS/agent-per-project/07-CENTER-PANEL-LAYOUTS/00-center-panel-control-panels-and-infographics.md)** - Report, control-panel, and infographic composition rules
8. **[Sidebar Layouts](_AGENT_INSTRUCTIONS/agent-per-project/08-SIDEBAR-LAYOUTS/00-sidebar-cassettes-controls-and-info-cards.md)** - Cassette, control-stack, and info-card composition rules
9. **[Database Access](_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/00-all-databases-accessed.md)** - Critical: Use centralized providers only
10. **[Architecture Overview](_AGENT_INSTRUCTIONS/agent-per-project/01-PROJECT/02-architecture-overview.md)** - DDD layers and responsibilities
11. **[Cross-Surface Spec System](_AGENT_INSTRUCTIONS/agent-per-project/42-SPEC-SYSTEM/)** - 🔥 CRITICAL: How sealed spec classes coordinate UI across all surfaces
12. **[Feature Spec Responsibilities](_AGENT_INSTRUCTIONS/agent-per-project/42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/40-feature-responsibilities.md)** - Coordinator → resolver → payload/rendering boundaries
13. **[Sidebar Cassette System](_AGENT_INSTRUCTIONS/agent-per-project/42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md)** - Rack state, cascade, card chrome
14. **[View Spec Panel System](_AGENT_INSTRUCTIONS/agent-per-project/42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md)** - ViewSpec panel navigation and feature dispatch
15. **[macOS FDA Grant Continuity](_AGENT_INSTRUCTIONS/agent-per-project/60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md)** - 🔥 MUST-READ before any production build; preserve bundle id and release signing so existing Full Disk Access grants carry over

### Quick Reference

- **Lint Antipatterns**: [`_AGENT_INSTRUCTIONS/agent-instructions-shared/10-language/linter-antipatterns.md`](_AGENT_INSTRUCTIONS/agent-instructions-shared/10-language/linter-antipatterns.md) - One-stop list of analyzer tripwires
- **Navigation / View Spec System**: [`_AGENT_INSTRUCTIONS/agent-per-project/42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md`](_AGENT_INSTRUCTIONS/agent-per-project/42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md)
- **AddressBook Imports**: [`_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/06-addressbook-path-resolution.md`](_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/06-addressbook-path-resolution.md)
- **Dark Mode Theming**: [`_AGENT_INSTRUCTIONS/agent-per-project/05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md`](_AGENT_INSTRUCTIONS/agent-per-project/05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md) - Luminance hierarchy and dark mode selection rules
- **Center Panel Layouts**: [`_AGENT_INSTRUCTIONS/agent-per-project/07-CENTER-PANEL-LAYOUTS/00-center-panel-control-panels-and-infographics.md`](_AGENT_INSTRUCTIONS/agent-per-project/07-CENTER-PANEL-LAYOUTS/00-center-panel-control-panels-and-infographics.md) - Report composition rules for center-panel control surfaces and infographics
- **Sidebar Layouts**: [`_AGENT_INSTRUCTIONS/agent-per-project/08-SIDEBAR-LAYOUTS/00-sidebar-cassettes-controls-and-info-cards.md`](_AGENT_INSTRUCTIONS/agent-per-project/08-SIDEBAR-LAYOUTS/00-sidebar-cassettes-controls-and-info-cards.md) - Composition rules for sidebar branches, controls, and explanatory cards
- **Cross-Surface Spec System**: [`_AGENT_INSTRUCTIONS/agent-per-project/42-SPEC-SYSTEM/`](_AGENT_INSTRUCTIONS/agent-per-project/42-SPEC-SYSTEM/) - Architecture overview and invariant rules
- **Production Build / FDA Continuity**: [`_AGENT_INSTRUCTIONS/agent-per-project/60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md`](_AGENT_INSTRUCTIONS/agent-per-project/60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md) - Keep `com.bigbenchsoftware.MessageLens` and production signing stable so macOS FDA grants persist across shipped builds

## Critical Rules (Quick Reference)

### Imports & Dependencies

- ✅ **Always use**: `hooks_riverpod` (never `flutter_riverpod`)
- ✅ **Database access**: Use centralized providers only. Ordinary graph reads use `driftConversationGraphDatabaseProvider`; source-scoped import DB construction lives behind `sourceScopedImportDatabaseProvider` in `lib/essentials/db/feature_level_providers.dart`, while ordinary import semantics should consume `sourceScopedImportLedgerProvider`; overlay intent and archive-source metadata use `overlayDatabaseProvider`. Retired `macos_import.db` and `working.db` have no central app providers and should be treated as cleanup/diagnostic files only. Physical database filenames and Application Support paths live in `app_database_files.dart` / `database_directory.dart` and must not be re-exported through the provider seam.
- ✅ **Public provider seams**: `feature_level_providers.dart` is for external consumers. Internal code inside the same feature or essential module must import exact sibling provider/repository/action/model files instead of its own public barrel.
- ❌ **Never**: Create direct database instances (causes SQLite locking)

### 🔥 INVIOLABLE: Overlay / Working DB Separation

- ✅ **User intent** (labels, favorites, spam flags, manual links): Write ONLY to overlay DB
- ✅ **Source import / graph projection**: Write ONLY to derived graph/import DBs as a pure function of source data
- ✅ **Providers**: Merge graph projection ∪ overlay at read time; **overlay always wins on conflict**
- ❌ **NEVER** dual-write to both overlay AND graph/working projection DBs
- ❌ **NEVER** have import/projection read or consult overlay DB
- ❌ **NEVER** snapshot overlay before projection then restore into graph/working projection (the old "Restore Overrides" anti-pattern)
- ❌ **NEVER** store user-intent flags (`is_blacklisted`, `is_visible`, manual links) on projection tables rebuilt by graph projection or inside retired cleanup files
- 📖 See [`_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/07-overlay-database-independence.md`](_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/07-overlay-database-independence.md)

### 🔥 INVIOLABLE: Record-Level Data Fidelity — No Suppression of Anomalous Records

- ✅ **Every source record** MUST be faithfully imported, projected, and **rendered visibly** in the UI
- ✅ **Anomalies are diagnostic signals** — a NULL-text message may be attachment-only, a reaction, a system event, or evidence of a pipeline bug
- ✅ **Correct response to anomalous data**: log it, render it (even imperfectly), flag it, investigate the root cause
- ❌ **NEVER** skip/filter records in importers (`if (text == null) continue;`)
- ❌ **NEVER** add WHERE clauses in projectors/migrators that exclude anomalous rows (`WHERE text IS NOT NULL`)
- ❌ **NEVER** hide records in UI with `SizedBox.shrink()`, empty containers, or zero-height boxes
- ❌ **NEVER** silently exclude records in providers before returning query results
- ❌ **NEVER** swallow exceptions during record processing — log them and include the record with error metadata
- 📖 See [`_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/INVIOLATE_RULES.md`](_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/INVIOLATE_RULES.md) Rule 2

### Code Standards

- ✅ Color opacity: `withValues(alpha: 0.5)` (never `withOpacity`)
- ✅ Control flow: Always use braces (never single-line statements)
- ✅ Freezed classes: MUST be `abstract class`, never just `class`
- ✅ Async functions: Return `Future<void>`, never `void`
- ✅ Containers: Use `ColoredBox` when only setting color
- ✅ **Theme access**: Use `themeColorsProvider` and `themeTypographyProvider` exclusively
- ✅ **Release metadata**: Significant user-facing or tester-facing changes must include both a `pubspec.yaml` version bump and a `CHANGELOG.md` entry
- ❌ **Never**: Use `MacosTheme.of(context)` or `Theme.of(context)` for colors/typography

### Solo Git Workflow

- ✅ Housekeeping, maintenance, and small bug fixes that do not merit a version bump may be committed directly to `main`
- ✅ Feature additions and other release-worthy changes should use a feature branch and pull request before merging to `main`
- ✅ For release-worthy changes, agents should ensure checks are run and both `pubspec.yaml` and `CHANGELOG.md` are updated before merge
- ❌ **Do not** require a PR for trivial housekeeping changes that are intentionally staying off the release track

### Shared Instructions Submodule Workflow

- ✅ Treat `_AGENT_INSTRUCTIONS/agent-instructions-shared` as a Git submodule, not a normal project folder
- ✅ Default new repo-specific documentation or instruction rules to `AGENTS.md`, `.github/copilot-instructions.md`, or `_AGENT_INSTRUCTIONS/agent-per-project/`
- ✅ Edit the shared submodule only when the rule is intentionally reusable across multiple repos
- ✅ If the shared submodule is edited, complete both commits before ending work: commit inside `_AGENT_INSTRUCTIONS/agent-instructions-shared`, then stage that path in the parent repo and commit the submodule pointer on the current branch
- ✅ Before switching branches or declaring work complete, verify the parent repo `git status` is clean
- ❌ **Do not** leave `_AGENT_INSTRUCTIONS/agent-instructions-shared` as a dirty submodule in the parent repo at handoff time

### Riverpod Patterns

- ✅ **Use documented patterns only** - Do NOT scan codebase for examples
- ✅ All providers: Use `@riverpod` annotation with code generation
- ✅ Class naming: `MyFeature extends _$MyFeature` → generates `myFeatureProvider`
- ❌ **Never**: Create manual `StateNotifierProvider` instances

## Development Commands

```bash
# Run app
flutter run -d macos

# Code generation (Freezed, Riverpod, etc.)
dart run build_runner build --delete-conflicting-outputs

# Testing
flutter test --plain-name "pattern"

# Analysis & formatting
flutter analyze
dart format .
dart fix --apply
```

## Project Structure

```
lib/
├── essentials/          # Core systems (navigation, source import, graph, databases, window state)
├── features/            # Business features (DDD: messages, chats, contacts, address_book_folders)
└── domain_driven_development/  # Shared DDD utilities

_AGENT_INSTRUCTIONS/     # Comprehensive agent documentation (READ FIRST!)
├── agent-per-project/   # Project-specific patterns and architecture
└── agent-instructions-shared/  # Reusable patterns (Dart, Flutter, Riverpod, etc.)

rust/                    # High-performance Rust modules via flutter_rust_bridge
test/                    # Tests mirroring lib/ structure
```

## For More Details

See the comprehensive documentation in [`_AGENT_INSTRUCTIONS/`](_AGENT_INSTRUCTIONS/) for:

- Detailed architecture and DDD boundaries
- Complete code standards and linting rules
- Database schema, source import, graph projection, and retired cleanup/diagnostic storage patterns
- Navigation system implementation
- Testing strategies
- Rust FFI integration
- And much more...

**When in doubt, consult the agent instructions rather than guessing!**

---

## Original Content (For Reference)

## Project Structure & Module Organization

The Flutter client lives in `lib/`, organized by domain-driven modules: shared utilities in `core/` and `essentials/`, feature flows inside `features/`, and Riverpod providers in `providers.dart` plus generated `providers.g.dart`. Platform scaffolds remain in `macos/`, `ios/`, and `web/`. Mac database and Supabase artifacts are tracked under `supabase/`. The Rust message extractor is in `rust/rust/attributed-string-decoder/` with its release binary expected at `target/release/extract_messages_limited`. Tests sit in `test/` with scenario-focused groupings, and developer tooling such as data reformatters lives under `tool/`.

## Build, Test, and Development Commands

- `flutter pub get` installs Flutter and plugin dependencies.
- `flutter run -d macos` launches the desktop app against the live macOS databases.
- `./tool/build_and_notarize.sh` is the default distribution pipeline for a shareable macOS release build and produces a notarized `MessageLens.dmg` on the Desktop.
- `flutter build macos --release` generates a local release build for verification; by itself it is not the default distribution artifact.
- `flutter analyze` enforces Dart lint rules from `analysis_options.yaml`.
- `flutter test` executes widget and integration tests in `test/`.
- `cargo build --release` and `cargo test` run within `rust/rust/attributed-string-decoder/` for the extractor.

## Coding Style & Naming Conventions

Use `dart format .` (2-space indentation) before submitting. Prefer PascalCase for classes, camelCase for methods and variables, and snake_case for file names such as `timeline_view.dart`. Hook-based Riverpod providers should follow the `<feature>Provider` pattern. Keep generated files (`*.g.dart`, `frb_generated*.dart`) untouched; update them via the relevant build step instead of manual edits.

## Testing Guidelines

Add `*_test.dart` files mirroring the `lib/` structure, grouping tests by feature name. Mock external I/O such as database imports; integration flows can use the extractor binary stubbed at `target/release/extract_messages_limited`. When modifying the Rust extractor, accompany changes with focused `#[test]` cases in `src/`. Aim to keep Flutter tests deterministic and runnable via `flutter test --coverage` before review.

## Commit & Pull Request Guidelines

Recent history favors concise, present-tense commit messages (`fix scroll jitter`). Scope commits narrowly and explain intent in the first line. Pull requests should include a summary of user-visible behavior, linked tracking issue or TODO reference, screenshots for UI updates, and notes on manual verification (e.g., `flutter run -d macos`). Request review from a teammate familiar with the touched module.

## Security & Configuration Tips

Never commit personal database exports or credential files; `.db` artifacts should stay in your local workspace. Confirm Full Disk Access permissions when testing imports, and verify the Rust binary’s execute bit (`chmod +x target/release/extract_messages_limited`) after rebuilding.
