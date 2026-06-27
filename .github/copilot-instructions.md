````instructions
You are an AI assistant helping with a Flutter macOS application called "MessageLens".

🚨 **MANDATORY FIRST STEP**: Read `_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md`. These guardrails govern how GitHub Copilot and Codex agents must plan work, request approval, and limit edit scope.

🚨 **MANDATORY SECOND STEP**: Read `_AGENT_INSTRUCTIONS/agent-per-project/README.md` before making ANY code changes. This file contains the canonical index to all project documentation including critical import, database, and architecture patterns.

## Project Context
This is a macOS-native Flutter application that imports and manages Messages and AddressBook data. The project uses:
- Domain Driven Development (DDD) architecture
- Riverpod for state management (hooks_riverpod specifically, NOT flutter_riverpod)
- Drift for database operations
- macOS UI components for native feel
- Rust FFI for high-performance data processing
- ViewSpec-based reactive navigation system

Note: the production app name is `MessageLens`. Some code-level identifiers, package imports, and repository paths may still use the historical names `remember_this_text` or `remember_every_text`.

## Essential Reading Order
You MUST read these files in order before any code changes:
1. **`_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md`** - Planning, approval, and diff-scope expectations for all agents
2. **`_AGENT_INSTRUCTIONS/agent-per-project/README.md`** - Canonical index of all project documentation
3. **`_AGENT_INSTRUCTIONS/agent-instructions-shared/10-language/dart.md`** - Dart linting rules, type annotations, code patterns
4. **`_AGENT_INSTRUCTIONS/agent-instructions-shared/20-flutter/widgets.md`** - Flutter-specific standards, widget patterns, and state expectations
5. **`_AGENT_INSTRUCTIONS/agent-instructions-shared/20-flutter/riverpod-provider-patterns.md`** - MANDATORY provider code generation patterns
6. **`_AGENT_INSTRUCTIONS/agent-per-project/05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md`** - Dark mode hierarchy principles and semantic token design
7. **`_AGENT_INSTRUCTIONS/agent-per-project/07-CENTER-PANEL-LAYOUTS/00-center-panel-control-panels-and-infographics.md`** - Center-panel report, control-panel, and infographic composition rules
8. **`_AGENT_INSTRUCTIONS/agent-per-project/08-SIDEBAR-LAYOUTS/00-sidebar-cassettes-controls-and-info-cards.md`** - Sidebar cassette, control-stack, and info-card composition rules
9. **`_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/00-all-databases-accessed.md`** - Database access patterns and schema references
10. **`_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/06-addressbook-path-resolution.md`** - AddressBook path resolution (CRITICAL for imports)
11. **`_AGENT_INSTRUCTIONS/agent-per-project/01-PROJECT/01-aggregate-boundaries.md`** - DDD structure and aggregate boundaries
12. **`_AGENT_INSTRUCTIONS/agent-per-project/01-PROJECT/02-architecture-overview.md`** - Project architecture and DDD layer responsibilities
13. **`_AGENT_INSTRUCTIONS/agent-per-project/42-SPEC-SYSTEM/`** - 🔥 CRITICAL: How sealed spec classes coordinate UI across all surfaces
14. **`_AGENT_INSTRUCTIONS/agent-per-project/42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/40-feature-responsibilities.md`** - Coordinator → resolver → payload/rendering boundaries
15. **`_AGENT_INSTRUCTIONS/agent-per-project/42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md`** - Sidebar cassette rack, cascade, card chrome
16. **`_AGENT_INSTRUCTIONS/agent-per-project/42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md`** - ViewSpec panel navigation and feature dispatch
17. **`_AGENT_INSTRUCTIONS/agent-per-project/60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md`** - 🔥 MUST-READ before any production build; preserve bundle id and release signing so macOS Full Disk Access grants carry over across shipped builds

## Quick Reference Code Standards
- **Primary import**: Always use `hooks_riverpod`, never `flutter_riverpod`
- **Color opacity**: Use `withValues(alpha: 0.5)`, never `withOpacity(0.5)`
- **Control flow**: Always use braces, never single-line statements
- **Async functions**: Return `Future<void>`, never `void`
- **Containers**: Use `ColoredBox` when only setting color
- **String interpolation**: Use `$variable`, only `${expression}` for complex cases
 - **Redundant defaults**: Do not pass values equal to a parameter's default
 - **Collection literals**: Prefer `[...]`, `{...}` over constructors like `List<T>()`
 - **Control bodies**: Always put control bodies on new lines with braces
- **🔥 FREEZED CLASSES**: ALL Freezed classes MUST be declared as `abstract class`, never just `class`
 - **Freezed unnamed ctor order**: Place `const ClassName._();` AFTER the primary `const factory` constructor in the class body to satisfy `sort_unnamed_constructors_first`.
- **🔥 DATABASE ACCESS**: ALL database access MUST use centralized providers. Ordinary graph reads use `driftConversationGraphDatabaseProvider`; source-scoped import DB construction lives behind `sourceScopedImportDatabaseProvider` in `lib/essentials/db/feature_level_providers.dart`, while ordinary import semantics should consume `sourceScopedImportLedgerProvider`; overlay intent uses `overlayDatabaseProvider`; retired `macos_import.db` and `working.db` have no central app providers and are cleanup/diagnostic files only.
- **AddressBook imports**: MUST use `getFolderAggregateEitherProvider` for path resolution
- **🔥 RIVERPOD PATTERNS**: Follow ONLY the patterns documented in `_AGENT_INSTRUCTIONS/agent-instructions-shared/20-flutter/riverpod-provider-patterns.md` - DO NOT scan codebase for examples
- **Provider naming**: Class names follow documented pattern: `MyFeature` → generates `myFeatureProvider`
- **Navigation**: Use ViewSpec sealed classes, never direct widget management
- **🔥 THEME ACCESS**: NEVER use `MacosTheme.of(context)` or `Theme.of(context)` - use `themeColorsProvider` and `themeTypographyProvider` exclusively
- **🔥 Feature Spec Handling**: Feature coordinators route only; application-layer resolvers own meaning; app-level coordinators choose UI chrome

## Development Workflow
- **Code generation**: `dart run build_runner build --delete-conflicting-outputs`
- **Testing**: `flutter test --plain-name "<pattern>"` (Flutter) / `dart test --plain-name "<pattern>"` (Dart)
- **Run app**: `flutter run -d macos`
- **Production builds**: Read `_AGENT_INSTRUCTIONS/agent-per-project/60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md` first and preserve `com.bigbenchsoftware.MessageLens` plus release signing identity so prior FDA grants continue to apply
- **Lint compliance**: Fix all violations immediately - strict analysis_options.yaml enforced
- **Release metadata**: Any significant user-facing or tester-facing change must include both a `pubspec.yaml` version bump and a new `CHANGELOG.md` entry in the same change
- **Solo Git workflow**: Housekeeping and small bug fixes may go directly to `main`; feature additions and release-worthy changes should use a feature branch plus pull request before merging
- **Release-worthy merge gate**: For release-worthy changes, make sure the pull request is non-draft, checks have run, and both `pubspec.yaml` and `CHANGELOG.md` are updated before merge

## Shared Instructions Submodule Workflow

- `_AGENT_INSTRUCTIONS/agent-instructions-shared` is a Git submodule, not a normal folder.
- Default rule: if a documentation or instruction change is specific to this repo, put it in `AGENTS.md`, `.github/copilot-instructions.md`, or `_AGENT_INSTRUCTIONS/agent-per-project/` instead of the shared submodule.
- Only edit `_AGENT_INSTRUCTIONS/agent-instructions-shared` when the rule is intentionally cross-project and belongs in the shared instruction library.
- If an agent edits the shared submodule, it must finish the full two-repo workflow before ending work: commit inside the submodule first, then stage `_AGENT_INSTRUCTIONS/agent-instructions-shared` in the parent repo and commit the updated submodule pointer on the current branch.
- Agents must not leave the parent repo on a branch with a dirty submodule as the only remaining change.
- Before checking out another branch or asking the user to merge, agents should verify `git status` is clean in the parent repo. If the only dirty path is `_AGENT_INSTRUCTIONS/agent-instructions-shared`, that workflow is incomplete and must be resolved first.

## Project Architecture
- **`lib/essentials/`** - Core systems (navigation, source import, conversation graph, databases, window state)
- **`lib/features/`** - Business features following DDD (messages, chats, contacts, address_book_folders)
- **`lib/essentials/db/`** - Central database providers, graph/retained/overlay database infrastructure, and readiness helpers
- **`lib/essentials/source_scoped_import/`** - Production source-scoped import ledger and importers
- **`lib/essentials/conversation_graph/`** - Production graph projection/build/read layer
- **`lib/essentials/db_importers/`** - Retained import diagnostics, live source monitoring, and archive compatibility bridges
- **Retired `lib/essentials/db_migrate/`** - Historical retained projection reference only; no active app provider or service
- **`lib/essentials/navigation/`** - ViewSpec-based reactive navigation system
- **`rust/`** - High-performance Rust modules via flutter_rust_bridge
- **`_AGENT_INSTRUCTIONS/`** - Comprehensive agent documentation (READ FIRST!)

## Navigation System (Current)
Uses sealed classes and reactive providers for type-safe navigation:
```dart
// Navigate to messages for a specific chat
ref.read(panelsViewStateProvider(SidebarMode.messages).notifier).show(
  panel: WindowPanel.center,
  spec: const ViewSpec.messages(MessagesSpec.forChat(chatId: 42)),
);
````

**Key Pattern**: Features coordinate through ViewSpec declarations only. No direct cross-feature commands.

## 🔥 MANDATORY RIVERPOD PROVIDER PATTERNS

**🚨 CRITICAL**: All Riverpod patterns are documented in `_AGENT_INSTRUCTIONS/agent-instructions-shared/20-flutter/riverpod-provider-patterns.md`

**DO NOT** scan the codebase for provider examples - use ONLY the documented patterns:

### ✅ DOCUMENTED CLASS NAMING PATTERN:

```dart
@riverpod
class MyFeature extends _$MyFeature {
  @override
  StateType build() => initialState;
}
// Generates: myFeatureProvider
```

### ✅ DOCUMENTED FILE NAMING:

- File: `my_feature_provider.dart`
- Generated: `my_feature_provider.g.dart`
- Class: `MyFeature extends _$MyFeature`

### ✅ MANDATORY REQUIREMENTS:

- MUST use `@riverpod` annotation
- MUST include `part 'filename.g.dart';`
- MUST use `hooks_riverpod` import
- NEVER create manual providers

**⚠️ WARNING**: Do not search codebase for naming examples - follow only the documented pattern above.

## Critical Anti-Patterns to Avoid

- ❌ Manual StateNotifierProvider creation (use @riverpod)
- ❌ flutter_riverpod imports (use hooks_riverpod)
- ❌ withOpacity() calls (use withValues(alpha:))
- ❌ Single-line control flow (always use braces)
- ❌ **NON-ABSTRACT FREEZED CLASSES**: Never use `class MyClass with _$MyClass` - MUST be `abstract class`
- ❌ Freezed unnamed ctor at top: Do not place `const ClassName._();` before the primary `const factory` in the class — it must come after.
- ❌ Redundant default args: Don’t pass values that equal defaults (triggers `avoid_redundant_argument_values`).
- ❌ Unnecessary interpolation braces: Avoid `'${value}'` when `'${}'` isn’t needed; use `$value`.
- ❌ Prefer collection literals: Avoid `List<T>()`/typed literal invocation when `[]` or spreads suffice.
- ❌ Direct AddressBook path hardcoding (use getFolderAggregateEitherProvider)
- ❌ String-based navigation (use ViewSpec sealed classes)
- ❌ 🔥 **SCANNING CODEBASE FOR PROVIDER EXAMPLES** (use documented patterns only)
- ❌ 🔥 **CRITICAL**: Direct database instantiation (use centralized graph/import/overlay/retained providers)
- ❌ 🔥 **MacosTheme.of(context) / Theme.of(context)** (use `themeColorsProvider` & `themeTypographyProvider`)
- ❌ 🔥 **Feature coordinators doing logic** (coordinators route only; resolvers own meaning)
- ❌ 🔥 **Application-layer builders returning view models** (return widget content; coordinator wraps in chrome)
- ❌ 🔥 **INVIOLABLE: Dual-writing to overlay AND graph/working projection DBs** (user intent → overlay ONLY; source import / graph projection / retained projection → derived DBs ONLY; providers merge at read time with overlay winning on conflict. See `10-DATABASES/07-overlay-database-independence.md`)
- ❌ 🔥 **INVIOLABLE: Projection snapshot/restore of overlay data** (projection/import must NEVER read overlay, snapshot it, then restore into projection. Providers merge at read time instead.)
- ❌ 🔥 **INVIOLABLE: User-intent columns on projection tables** (flags like `is_blacklisted`/`is_visible` must NOT live on tables rebuilt by graph projection or retained migration. Store in overlay; merge in providers.)
- ❌ 🔥 **INVIOLABLE: Suppressing anomalous records** (NEVER skip, hide, filter, or `SizedBox.shrink()` any record at ANY layer — import, projection, provider, or UI. Anomalous data MUST be rendered visibly and investigated, never concealed. See `10-DATABASES/INVIOLATE_RULES.md` Rule 2)

## 🔥 MANDATORY DATABASE ACCESS RULE

**ANY CLASS accessing application databases MUST use centralized providers:**

- **Graph DB**: `ref.watch(driftConversationGraphDatabaseProvider.future)` from `lib/essentials/db/feature_level_providers.dart`
- **Source-scoped import DB**: physical construction is `sourceScopedImportDatabaseProvider` in `lib/essentials/db/feature_level_providers.dart`; ordinary import semantics should consume `sourceScopedImportLedgerProvider`
- **Overlay DB**: `ref.watch(overlayDatabaseProvider.future)` from `lib/essentials/db/feature_level_providers.dart`
- **Retired import cleanup file**: `macos_import.db` has no central app provider; treat it as cleanup/diagnostic file storage only
- **Retired working cleanup file**: `working.db` has no central app provider; treat it as cleanup/diagnostic file storage only
- **NEVER**: Direct `ImportDatabase()` or `DriftDb()` instantiation
- **REASON**: Prevents SQLite locking issues from multiple connections to same file

⚠️ **CRITICAL**: If you're working with AddressBook imports, read the AddressBook database resolution guide first. Many import failures are caused by using the wrong database path.

When in doubt, ask for clarification rather than guessing. Always prioritize code quality and following established patterns.

```

```
