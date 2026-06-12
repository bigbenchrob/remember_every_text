# Onboarding — State & Provider Inventory

> Legacy note (2026-04-21, updated 2026-06-03): current providers include `onboardingGateProvider`, `onboardingEnvironmentReportProvider`, `onboardingDevOverridesProvider`, `onboardingFullDiskAccessProvider`, `onboardingMessagesDatabasePathProvider`, and `onboardingDatabaseDirectoryPathProvider`. Current code also has `message_data_reset_service.dart`, `fda_checker.dart`, overlay failure persistence, and direct graph build/rebuild through `ConversationGraphBuildController`. Treat the "New Providers" language below as historical.
>
> Current rule: onboarding must not call `DbImportControlProvider` or `runImportAndMigration()`. Retained import-control presentation is diagnostic/import-only.

## New Providers

### `onboardingGateProvider` (essentials/onboarding/application/)
- **Type:** `@riverpod class OnboardingGate extends _$OnboardingGate`
- **State:** `OnboardingStatus` enum
- **Build:** Checks file existence + row counts → returns `awaitingUserAction` or `notNeeded`
- **Methods:**
  - Current code uses graph lifecycle actions, not `DbImportControlProvider`. Setup/reimport delegates cleanup to `MessageDataResetService` and graph build/rebuild to `ConversationGraphBuildController`.
  - `dismiss()` → sets state to `notNeeded`
- **keepAlive:** Yes — must survive widget rebuilds during import/graph build

## Existing Providers Consumed (not modified)

| Provider | From | Used For |
|----------|------|----------|
| `conversationGraphBuildControllerProvider` | `conversation_graph/application/` | App-facing graph build/rebuild lifecycle |
| `messageDataResetServiceProvider` | `onboarding/application/` | Derived-data reset, reimport preparation, database cleanup |
| `onboardingEnvironmentReportProvider` | `onboarding/application/` | Source probes, graph readiness, FDA state, persisted failure summaries |
| `retainedArchiveMetadataStoreProvider` | `db/feature_level_providers.dart` | Retained archive-source metadata checks only where explicitly needed |
| `conversationGraphDatabaseProvider` | `db/feature_level_providers.dart` | Source-scoped graph readiness / app-facing data state |

## New Domain Types

### `OnboardingStatus` (essentials/onboarding/domain/)
```dart
enum OnboardingStatus {
  notNeeded,           // App is ready — no overlay
  awaitingUserAction,  // First run — show welcome + button
  importing,           // Source-scoped import phase has started
  buildingGraph,       // Conversation graph build running
  complete,            // Success — show summary + "Get Started"
}
```

## Files to Create

| File | Layer | Purpose |
|------|-------|---------|
| `onboarding_status.dart` | domain | `OnboardingStatus` enum |
| `database_existence_checker.dart` | application | Filesystem fallback: do graph DBs exist? |
| `onboarding_gate_provider.dart` | application | Riverpod notifier driving overlay lifecycle |
| `onboarding_overlay.dart` | presentation | Top-level overlay widget with `ModalBarrier` |

## State Objects

_To be defined during implementation._

## Invalidation Rules

_To be defined during implementation._
