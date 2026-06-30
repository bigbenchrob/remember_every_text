# Onboarding Gate — State Machine and Overlay

## Purpose

The `OnboardingGate` is the top-level bootstrap coordinator. It evaluates
whether the app is ready for normal use and coordinates the readiness,
recovery, import, graph-build, and reimport lifecycle.

Current surface split:

- `awaitingFda` and `awaitingUserAction` are projected into the center panel
  with `ViewSpec.environmentReadiness`.
- `recoveringFailedAttempt`, import/graph-build progress, completion, and
  reimport completion use the blocking `OnboardingOverlay`.

## Ownership

- **Location:** `lib/essentials/onboarding/`
- **Owner:** Essentials layer (not a feature)
- **Rule:** Onboarding coordinates and presents. It never owns source-scoped
  import/projection logic.

## State Machine

The gate tracks a single `OnboardingStatus` enum with 10 states:

```
┌─────────────────────────────────────────────────────────────┐
│                     OnboardingStatus                        │
├─────────────────────────────────────────────────────────────┤
│ notNeeded               — App databases populated, skip     │
│ recoveringFailedAttempt — Reset incomplete DBs before retry │
│ awaitingFda             — FDA not granted, show instructions│
│ awaitingUserAction      — FDA OK, databases empty, show UI  │
│ importing               — Import pipeline running           │
│ buildingGraph           — Conversation graph build running  │
│ complete                — First-run pipeline done           │
│ reimporting             — User-triggered re-import running  │
│ reimportBuildingGraph   — Re-import graph build phase       │
│ reimportComplete        — Re-import finished                │
└─────────────────────────────────────────────────────────────┘
```

### Transition Flow (First Run)

```
App Start
  │
  ├─ environment report → databases populated?
  │   └─ YES → notNeeded (overlay never shown)
  │
  ├─ environment report → FDA blocked?
  │   └─ YES → awaitingFda
  │       └─ center panel shows environment readiness
  │       └─ user grants FDA → refreshEnvironment()
  │           └─ awaitingUserAction
  │
  ├─ environment report → sources readable, DBs empty?
  │   └─ YES → awaitingUserAction
  │       └─ center panel shows environment readiness
  │       └─ user clicks "Import" → startImportAndGraphBuild()
  │           ├─ importing (source-scoped import/projection begins)
  │           ├─ buildingGraph (conversation graph build running)
  │           └─ complete (show summary, "Get Started" button)
  │
  ├─ environment report → incomplete partial app DBs?
  │   └─ recoveringFailedAttempt
  │       └─ reset app-owned source-scoped import/graph DBs
  │           └─ awaitingUserAction
  │
  └─ environment report → import/graph projection previously failed?
      └─ awaitingUserAction (show failure details + retry)
```

### Transition Flow (Re-Import)

```
Settings → "Re-scan & Import"
  │
  ├─ reimporting (skips FDA gate — already granted)
  ├─ reimportBuildingGraph
  └─ reimportComplete → "Done" button
```

## Key Provider

```dart
// lib/essentials/onboarding/application/onboarding_gate_provider.dart
@Riverpod(keepAlive: true)
class OnboardingGate extends _$OnboardingGate {
  @override
  OnboardingStatus build() {
    // Watches environment report provider
    // Classifies into status via resolveBuildStatus()
  }

  void refreshEnvironment() { ... }
  Future<void> startImportAndGraphBuild() async { ... }
  Future<void> startReimport() async { ... }
  Future<void> openFdaSettings() async { ... }
}
```

### Resolution Logic

`resolveBuildStatus()` maps the environment report to a status:

1. If `permissionBlocked` → `awaitingFda`
2. If `ready` (both DBs populated) → `notNeeded`
3. `importFailed`, `graphProjectionFailed`, `sourceUnavailable`,
   `sourceSparseOrUnsynced`, and `readyToImport` → `awaitingUserAction`

Workflow override states are preserved while recovery, import, graph build,
completion, or reimport is in progress. The environment report can also set
`shouldResetAppDatabasesBeforeImport`, which triggers automatic recovery into
`recoveringFailedAttempt`.

## Overlay Rendering

`OnboardingOverlay` is a full-window widget rendered above the main app shell
for blocking workflow phases. It switches content based on the current status:

| Status | Overlay Content |
|--------|-----------------|
| `recoveringFailedAttempt` | Recovery/reset progress |
| `importing` | Progress view with row counts and duration per table |
| `buildingGraph` | Progress view continuing from import |
| `complete` | Summary (total counts, warnings, archive size), "Get Started" button |
| `reimporting` | Progress view (no welcome preamble) |
| `reimportBuildingGraph` | Progress view |
| `reimportComplete` | Summary, "Done" button |
| `notNeeded` | Not rendered — overlay is absent |

Legacy note: `OnboardingOverlay` still contains branches for `awaitingFda` and
`awaitingUserAction`, but the current app shell normally presents those states
through the readiness center panel instead of mounting the overlay.

### Overlay Blocking

The overlay renders a `ModalBarrier` that prevents interaction with the main
app during blocking workflow states. When the shell does not mount the overlay,
FDA and user-action states are handled by panel content and sidebar parking.

## Failure Persistence

Import and graph-projection failures are persisted as JSON in the overlay database's
`OverlaySettings` table via `OverlayOnboardingFailureStorage`. This allows:

- Showing the last failure on next launch without re-running the pipeline
- Distinguishing "never tried" from "tried and failed"
- Clearing on successful completion

## File Inventory

| File | Role |
|------|------|
| `application/onboarding_gate_provider.dart` | State machine and orchestration |
| `application/onboarding_environment_report_provider.dart` | Environment evaluation |
| `application/database_existence_checker.dart` | Filesystem DB presence check |
| `application/fda_checker.dart` | Full Disk Access probe |
| `domain/onboarding_status.dart` | Status enum (10 states) |
| `domain/onboarding_environment_report.dart` | Typed environment snapshot |
| `domain/import_spec.dart` | Retired import-control route tagging for diagnostics/compatibility |
| `domain/spec_classes/onboarding_view_spec.dart` | Onboarding panel spec for dev/debug surfaces |
| `infrastructure/overlay_onboarding_failure_storage.dart` | Failure persistence |
| `presentation/onboarding_overlay.dart` | Full-window blocking overlay |
| `presentation/onboarding_dev_panel.dart` | Debug/simulation overrides |
| `navigation/presentation/widgets/onboarding_center_panel_sync_observer.dart` | Syncs onboarding gate states into `ViewSpec.environmentReadiness` |
