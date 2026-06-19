# Enhanced Onboarding Flow Design Notes

## Current Conformance Note (2026-06-06)

These notes remain useful for the raw-evidence -> typed-report -> user-facing
classification pattern. Replace references to import/migration readiness as
the ordinary success path with source-scoped graph build/readiness. Retained
legacy import/projection health may still appear as compatibility diagnostics
where explicitly named.

## Summary

The onboarding system should evolve from a two-gate startup check into an
environment evaluator plus bootstrap status presenter.

The evaluator should gather evidence from multiple sources, normalize it into a
typed report, classify the report into a small user-facing state set, and map
that state to advice.

## Architectural Fit

This design must remain aligned with the existing system:

- onboarding remains essentials-owned
- source-scoped import remains owned by the graph import spine
- conversation graph build/readiness remains owned by graph orchestration
- retained import/migration systems are compatibility diagnostics only
- navigation remains ViewSpec-driven
- app-level coordinators route; resolvers own meaning

The enhanced onboarding work should therefore introduce a projection layer, not
an alternate workflow engine.

## Proposed Model Layers

### 1. Raw evidence layer

Collect concrete facts such as:

- can open `~/Library/Messages/chat.db`
- can resolve and access required AddressBook source(s)
- source database file sizes and modification timestamps
- source row counts from key tables
- source-scoped import database present / readable / populated
- conversation graph database present / readable / populated
- latest import error summary
- latest graph build/projection error summary
- graph topology / integrity hints
- retained compatibility database health only when clearly labeled diagnostic

### 2. Environment report layer

Convert raw evidence into a typed report that separates facts from inferences.

Suggested fields:

- permission status
- messages source status
- contacts source status
- local history richness estimate
- sync plausibility estimate
- source-scoped import readiness
- conversation graph readiness
- source-scoped pipeline health
- graph build/projection health
- retained compatibility health, if relevant
- top-priority blocker
- recommended actions
- diagnostic notes

### 3. Readiness classification layer

Map the report into a stable user-facing state:

- `permissionBlocked`
- `sourceUnavailable`
- `sourceSparseOrUnsynced`
- `readyToImport`
- `importing`
- `importFailed`
- `buildingGraph`
- `graphBuildFailed`
- `ready`

### 4. Presentation layer

Render:

- a concise headline
- evidence-backed explanation
- recommended next action(s)
- optional advanced details

## Checks to Include

### Permission checks

Required first-pass checks:

- readability of `chat.db`
- readability of AddressBook source path(s)

Important distinction:

- unreadable `chat.db` is usually FDA-related
- readable `chat.db` does not imply useful local history exists

### Source Messages checks

Suggested evidence:

- file exists
- file can be opened
- size is non-trivial
- key row counts from `message`, `chat`, `handle`, and join tables
- newest message date if cheaply available

This can support diagnoses like:

- source absent
- source accessible but nearly empty
- source accessible with apparently meaningful history

### AddressBook checks

Suggested evidence:

- path resolution succeeds via approved provider-driven path logic
- source database readable
- contact row counts available

Important:

- use the documented AddressBook resolution path
- do not hardcode sqlite paths in application logic

### App-owned database checks

Suggested evidence:

- `macos_import_ss.db` existence and row counts
- `working_ss.db` existence and row counts
- graph projection state integrity signals
- obvious corruption or foreign key failure signals where cheap to inspect
- retained `macos_import.db` / `working.db` health only for explicitly labeled
  archive/recovery compatibility diagnostics

Existing compatibility diagnostics utilities may be reused as internal evidence
for retained archive/recovery surfaces rather than exposed as ordinary setup
authority.

### Pipeline checks

Suggested evidence:

- latest source-scoped import result summary
- latest graph build/projection result summary
- known exception summaries
- whether source-scoped import completed but graph projection never populated
  working graph tables
- retained import/migration summaries only as compatibility diagnostics

This should allow the UI to distinguish:

- source is fine, source-scoped import failed
- import succeeded, graph build/projection failed
- both succeeded, but local history is genuinely sparse

## iCloud / Sync Inference

This area must be handled carefully.

The app should never claim direct knowledge of Apple's iCloud state unless a
native integration provides that signal explicitly.

Instead, classify into inferred states such as:

- `likelyLocalHistoryMissing`
- `likelySparseLocalArchive`
- `likelyWaitingForMessagesSync`
- `unknownSyncState`

Inference examples:

- `chat.db` readable but has extremely low message counts
- database exists but appears newly created
- contacts data present while Messages data is absent or tiny
- message counts conflict sharply with user expectation after successful import

The UI should say "This Mac appears to have little or no local Messages history"
rather than "iCloud sync is off."

## Advice Mapping

Each blocker type should map to a small action set.

Examples:

### Permission blocked

- Open System Settings to Full Disk Access
- Relaunch MessageLens after granting access

### Messages source accessible but sparse

- Open Messages on this Mac
- Confirm the correct Apple Account is signed in
- Wait for local message history to appear, then rescan

### AddressBook unavailable

- Grant the required permissions if applicable
- Verify Contacts data is present on this Mac

### Import failed

- Retry import
- Show concise failure summary
- Expose advanced diagnostics in a secondary details view

### Graph build failed

- Retry setup
- Expose the specific stage that failed

## UI Direction

The current overlay can remain the startup shell in phase 1, but its contents
should shift from a simple permission/import script to a diagnosis card.

Recommended structure:

- headline
- current readiness summary
- evidence bullets or status rows
- primary action button
- optional "details" disclosure

Longer-term, the bootstrap flow may also deserve a dedicated center-panel
surface driven by `ViewSpec.onboarding(...)`, with the overlay acting as the
blocking entry point.

## Suggested Internal Types

These names are suggestions, not requirements.

- `OnboardingEnvironmentReport`
- `OnboardingBlockerKind`
- `OnboardingEvidenceItem`
- `OnboardingRecommendedAction`
- `OnboardingSyncPlausibility`
- `OnboardingMessagesSourceStatus`

## Data Flow Sketch

1. startup triggers onboarding evaluator
2. evaluator gathers raw evidence from filesystem, provider-backed DB access,
   and existing pipeline state
3. evaluator produces report
4. gate classifies report into onboarding status + blocker kind
5. UI renders status and advice
6. source-scoped import / graph-build transitions update the same report with
   pipeline health

## Scope Boundaries

Allowed:

- new onboarding application-layer evaluator(s)
- new onboarding domain types
- upgrades to onboarding presentation
- integration with existing diagnostics helpers

Not allowed:

- moving import logic into onboarding
- bypassing centralized DB providers for long-lived access
- feature-local navigation outside ViewSpec/panel coordinator patterns

## Suggested Documentation Artifacts During Implementation

- capture exact heuristics for sparse-source inference
- document which checks are definitive vs inferred
- document what is safe to expose to end users versus debug surfaces
