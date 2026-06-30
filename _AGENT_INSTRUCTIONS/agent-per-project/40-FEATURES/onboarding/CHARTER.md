# Onboarding — Feature Charter

> Legacy note (2026-04-21, updated 2026-06-03): this folder is V1 planning material. Current onboarding architecture lives primarily in `lib/essentials/onboarding`; readiness panel UI lives in `lib/features/environment_readiness`; canonical docs are under `../25-ONBOARDING-AND-ARCHIVE/`. Several V1 assumptions below are no longer current, including deferred FDA handling, happy-path-only failure handling, the absence of ViewSpec participation for onboarding dev/readiness panels, and any use of `DbImportControlProvider.runImportAndMigration()`.
>
> Current rule: onboarding and settings reimport are graph-lifecycle flows. They use `MessageDataResetService` for derived-data reset/cleanup and `ConversationGraphBuildController` for source-scoped graph build/rebuild. The retired import-control panel is diagnostic/import-only and must not be used as the onboarding orchestrator.

## Mission

Present a full-window blocking overlay on first launch that detects absent/empty databases, lets the user kick off data import + migration with a single button, and shows the exact same stage-by-stage progress the developer pane shows — without adding, removing, or altering any orchestrator or migrator behavior.

## Inviolate Rules

1. **Zero orchestrator changes for cosmetic purposes.** Onboarding delegates lifecycle work to application services. Current app-facing setup/reimport resets derived data through `MessageDataResetService` and builds the source-scoped graph through `ConversationGraphBuildController`; it does not route through presentation controllers.
2. **No user_overlays.db involvement.** Even if present from a prior run, the overlay DB is never read, written, or consulted during onboarding. The overlay merging at read time continues to work as normal once the app is running — onboarding simply doesn't touch it.
3. **Graph lifecycle is authoritative.** The user-facing setup sequence should describe source-scoped graph readiness/build state. Legacy import/migration progress surfaces are retired diagnostic/archive compatibility only.
4. **Failure and early-dismiss are deferred.** V1 assumes success. Error handling, retry, partial progress, and mid-onboarding dismissal are future work.
5. **Graph readiness, not legacy working readiness.** Current setup gates should use source-scoped import/graph readiness and explicit failure state. `working.db` is no longer the ordinary app readiness signal.

## Two Phases

### Phase 1 — Full Disk Access (deferred)
- Informative dialog explaining why FDA is needed
- Screenshot of the macOS Privacy & Security → Full Disk Access pane
- Ideally, open that Settings pane programmatically
- **Not implemented in V1** — skip straight to Phase 2

### Phase 2 — DB Import & Migration (V1 focus)

#### Trigger
On app launch, before the main UI is usable, a provider checks:
- Does `macos_import_ss.db` exist at `_databaseDirectoryPath` AND contain data?
- Does `working_ss.db` / the conversation graph exist at `_databaseDirectoryPath` AND contain data?

If **either** is absent or empty → show the onboarding overlay.

#### UX Flow
1. **Gray blocking overlay** covers the entire `MacosWindow` (including toolbar actions). Only the overlay is interactive.
2. **Welcome / explanation panel** with a single primary button: _"Import My Messages"_ (or similar).
3. User taps the button → overlay transitions to **progress view**.
4. **Progress view** displays graph lifecycle status:
   - Overall linear progress bar (completed stages / total stages)
   - Per-stage rows: icon (pending / active / complete / failed) + display name + row count + inline progress
   - Source-scoped graph build progress is the current authoritative setup signal.
5. On completion → overlay shows **success summary** (message count, contact count, etc.) with a _"Get Started"_ button.
6. Tapping _"Get Started"_ dismisses the overlay and the normal app UI becomes interactive.

#### Architecture

```
lib/essentials/onboarding/
├── domain/
│   └── onboarding_status.dart           # enum: notNeeded, awaitingUserAction, importing, buildingGraph, complete
├── application/
│   └── onboarding_gate_provider.dart    # @riverpod — checks DB existence, exposes OnboardingStatus
├── infrastructure/
│   └── database_existence_checker.dart  # pure function: path → bool (file exists + has rows)
└── presentation/
    └── onboarding_overlay.dart          # current blocking workflow overlay
```

#### Integration Point

In `MacosAppShell.build()`, the existing `Stack` wrapping `MacosWindow`:

```dart
return Stack(
  children: [
    MacosWindow(...),           // existing
    if (onboardingNeeded)       // NEW — watches onboarding gate provider
      const OnboardingOverlay(),
  ],
);
```

The overlay sits above everything, absorbs all input (via `ModalBarrier` or `AbsorbPointer`), and is removed when the gate provider transitions to `OnboardingStatus.notNeeded`.

#### Progress Data Source

Two options (decide during implementation):

**Retired Option A — Reuse `DbImportControlProvider` directly.**
This option is no longer valid. `runImportAndMigration()` has been deleted, and onboarding must not depend on import-control presentation state.

**Current direction — Dedicated onboarding lifecycle.**
Onboarding owns its lifecycle state and calls application services directly:
`MessageDataResetService` for reset/cleanup and
`ConversationGraphBuildController` for graph build/rebuild. Environment
readiness reads source probes, source-scoped graph readiness, overlay failure
state, and the maintenance lock.

**Recommendation:** preserve this separation. Presentation controllers may show
diagnostics, but they are not lifecycle orchestrators.

## Open Questions (deferred)

- FDA detection and programmatic Settings.app launch (Phase 1)
- Error handling, retry, partial progress recovery
- Mid-onboarding dismissal and resume
- Re-onboarding after DB corruption or manual DB deletion
- Friendly label mapping for stage names
- Animation / polish for stage transitions
