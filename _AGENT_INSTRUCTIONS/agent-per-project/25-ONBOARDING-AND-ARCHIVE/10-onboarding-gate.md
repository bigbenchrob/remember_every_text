# Onboarding Gate — State Machine and Overlay

## Purpose

The `OnboardingGate` is the top-level bootstrap coordinator. It evaluates
whether the app is ready for normal use and, if not, blocks the main UI with
a status overlay until all prerequisites are satisfied.

## Ownership

- **Location:** `lib/essentials/onboarding/`
- **Owner:** Essentials layer (not a feature)
- **Rule:** Onboarding coordinates and presents. It never owns import or
  migration logic.

## State Machine

The gate tracks a single `OnboardingStatus` enum with 9 states:

```
┌─────────────────────────────────────────────────────────────┐
│                     OnboardingStatus                        │
├─────────────────────────────────────────────────────────────┤
│ notNeeded               — App databases populated, skip     │
│ awaitingFda             — FDA not granted, show instructions│
│ awaitingUserAction      — FDA OK, databases empty, show UI  │
│ importing               — Import pipeline running           │
│ migrating               — Migration pipeline running        │
│ complete                — First-run pipeline done           │
│ reimporting             — User-triggered re-import running  │
│ reimportMigrating       — Re-import migration phase         │
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
  │       └─ user grants FDA → refreshEnvironment()
  │           └─ awaitingUserAction
  │
  ├─ environment report → sources readable, DBs empty?
  │   └─ YES → awaitingUserAction
  │       └─ user clicks "Import" → startImportAndMigration()
  │           ├─ importing (import orchestrator running)
  │           ├─ migrating (migration orchestrator running)
  │           │   └─ includes archiveAllAvailable()
  │           └─ complete (show summary, "Get Started" button)
  │
  └─ environment report → import/migration previously failed?
      └─ awaitingUserAction (show failure details + retry)
```

### Transition Flow (Re-Import)

```
Settings → "Re-scan & Import"
  │
  ├─ reimporting (skips FDA gate — already granted)
  ├─ reimportMigrating
  └─ reimportComplete → "Done" button
```

## Key Provider

```dart
// lib/essentials/onboarding/application/onboarding_gate_provider.dart
@riverpod
class OnboardingGate extends _$OnboardingGate {
  @override
  OnboardingStatus build() {
    // Watches environment report provider
    // Classifies into status via resolveBuildStatus()
  }

  Future<void> refreshEnvironment() async { ... }
  Future<void> startImportAndMigration() async { ... }
  Future<void> startReimport() async { ... }
  void openFdaSettings() { ... }
}
```

### Resolution Logic

`resolveBuildStatus()` maps the environment report to a status:

1. If `permissionBlocked` → `awaitingFda`
2. If `ready` (both DBs populated) → `notNeeded`
3. All other states → `awaitingUserAction`

## Overlay Rendering

`OnboardingOverlay` is a full-window widget rendered above the main app shell.
It switches content based on the current status:

| Status | Overlay Content |
|--------|-----------------|
| `awaitingFda` | FDA instructions, "Open System Settings" button, "Re-check" button |
| `awaitingUserAction` | Welcome message, environment summary, "Import" button |
| `importing` | Progress view with row counts and duration per table |
| `migrating` | Progress view continuing from import |
| `complete` | Summary (total counts, warnings, archive size), "Get Started" button |
| `reimporting` | Progress view (no welcome preamble) |
| `reimportMigrating` | Progress view |
| `reimportComplete` | Summary, "Done" button |
| `notNeeded` | Not rendered — overlay is absent |

### Overlay Blocking

The overlay renders a `ModalBarrier` that prevents interaction with the main
app during onboarding states. When status is `notNeeded`, the overlay returns
`SizedBox.shrink()` and the barrier is absent.

## Failure Persistence

Import and migration results are persisted as JSON in the overlay database's
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
| `domain/onboarding_status.dart` | Status enum (9 states) |
| `domain/onboarding_environment_report.dart` | Typed environment snapshot |
| `domain/import_spec.dart` | Import/migration tagging |
| `domain/onboarding_view_spec.dart` | Overlay navigation spec |
| `infrastructure/overlay_onboarding_failure_storage.dart` | Failure persistence |
| `presentation/onboarding_overlay.dart` | Full-window blocking overlay |
| `presentation/onboarding_progress_view.dart` | Live progress rendering |
| `presentation/onboarding_dev_panel.dart` | Debug/simulation overrides |
