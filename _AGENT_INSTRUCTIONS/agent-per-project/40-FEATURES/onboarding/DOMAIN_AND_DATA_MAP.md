# Onboarding — Domain & Data Map

> Legacy note (2026-04-21, updated 2026-06-03): this is V1 planning material. Current code includes `OnboardingStatus.awaitingFda`, environment reports, onboarding failure persistence in overlay settings, reset/retry support, `OnboardingSpec.devPanel`, and `EnvironmentReadinessSpec.readinessPanel`. Use `../25-ONBOARDING-AND-ARCHIVE/` plus `lib/essentials/onboarding` and `lib/features/environment_readiness` for current implementation guidance.
>
> Current rule: onboarding readiness and setup are graph-first. Do not use this historical data map to reintroduce `DbImportControlProvider.runImportAndMigration()` or legacy `working.db` readiness as ordinary app truth.

## Domain Concepts

### OnboardingStatus (enum)
The single state token that drives the entire overlay lifecycle:

| Value | Meaning |
|-------|---------|
| `notNeeded` | Both DBs exist and contain data — skip overlay entirely |
| `awaitingUserAction` | First-run detected — show welcome panel with "Import" button |
| `importing` | Import orchestrator running — show import stage progress |
| `buildingGraph` | Conversation graph build running — show graph build progress |
| `complete` | Import and graph build succeeded — show summary with "Get Started" button |

### Database / Graph Readiness Check
Current readiness is not ordinary `working.db` population. It combines source
availability, FDA state, source-scoped import/graph readiness, persisted
failure state, and maintenance-lock state.

**Key graph readiness checks:**
- `macos_import_ss.db` → source-scoped import ledger message rows
- `working_ss.db` / conversation graph readiness → messages plus required topology

## Data Sources

| Source | How Accessed | Purpose |
|--------|-------------|---------|
| File system | `dart:io` `File.existsSync()` | Check if DB files exist at `_databaseDirectoryPath` |
| `chat.db` / AddressBook | source probes / FDA-aware path providers | Verify source availability and permission state |
| `macos_import_ss.db` | source-scoped import providers | Source-scoped import ledger readiness |
| `working_ss.db` | conversation graph database provider | App-facing graph readiness |
| `user_overlays.db` | overlay failure storage | Persisted setup/build failure summaries only; user intent remains overlay-owned |

## Data Flow

```
App launch
  → OnboardingGateProvider.build()
    → DatabaseExistenceChecker.check(databaseDirectoryPath)
      → source-scoped import ledger ready?    →  false?  →  OnboardingStatus.awaitingUserAction
      → conversation graph ready?             →  false?  →  OnboardingStatus.awaitingUserAction
      → (if both exist) query row counts       →  zero?   →  OnboardingStatus.awaitingUserAction
    → OnboardingStatus.notNeeded (both exist with data)

User taps "Import My Messages"
  → OnboardingGateProvider starts setup/reimport lifecycle
    → MessageDataResetService prepares derived databases as needed
    → ConversationGraphBuildController builds/rebuilds the source-scoped graph
    → onboarding failure storage records graph-build failures
    → on graph build success → state = OnboardingStatus.complete

User taps "Get Started"
  → state = OnboardingStatus.notNeeded
  → overlay removed, app is fully usable
```

## Entities & Value Objects

No new domain entities. Onboarding consumes existing:
- `OnboardingPipelineFailure`
- graph build report/state from `ConversationGraphBuildController`
- source/graph readiness values from onboarding environment providers

The only new domain type is the `OnboardingStatus` enum above.

## Tables / Storage

_To be defined during planning._

## External Systems

- macOS Full Disk Access permissions
- Source-scoped graph import/projection lifecycle
- `MessageDataResetService`
- `ConversationGraphBuildController`
