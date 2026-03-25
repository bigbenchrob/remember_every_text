# Enhanced Onboarding Flow Design Notes

## Summary

The onboarding system should evolve from a two-gate startup check into an
environment evaluator plus bootstrap status presenter.

The evaluator should gather evidence from multiple sources, normalize it into a
typed report, classify the report into a small user-facing state set, and map
that state to advice.

## Architectural Fit

This design must remain aligned with the existing system:

- onboarding remains essentials-owned
- import remains owned by `db_importers`
- migration remains owned by `db_migrate`
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
- import database present / readable / populated
- working database present / readable / populated
- latest import error summary
- latest migration error summary
- projection state / integrity hints

### 2. Environment report layer

Convert raw evidence into a typed report that separates facts from inferences.

Suggested fields:

- permission status
- messages source status
- contacts source status
- local history richness estimate
- sync plausibility estimate
- import database readiness
- working database readiness
- import pipeline health
- migration pipeline health
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
- `migrating`
- `migrationFailed`
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

- `macos_import.db` existence and row counts
- `working.db` existence and row counts
- projection state integrity signals
- obvious corruption or foreign key failure signals where cheap to inspect

Existing migration diagnostics utilities may be reused as an internal evidence
source rather than exposed directly to the user.

### Pipeline checks

Suggested evidence:

- latest import result summary
- latest migration result summary
- known exception summaries
- whether import completed but migration never populated working tables

This should allow the UI to distinguish:

- source is fine, import failed
- import succeeded, migration failed
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

### Migration failed

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
6. import/migration transitions update the same report with pipeline health

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