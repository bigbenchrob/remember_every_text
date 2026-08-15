---
tier: project
scope: presence-onboarding-handoff
owner: agent-per-project
last_reviewed: 2026-08-13
source_of_truth: code
links:
  - 19-POST-READINESS-ONBOARDING-HANDOFF-AUDIT.md
  - ../../25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md
tests:
  - test/features/environment_readiness/application/view_spec/resolver_tools/durable_accepted_readiness_handoff_test.dart
  - test/features/environment_readiness/application/view_spec/resolver_tools/environment_readiness_surface_provider_test.dart
  - test/architecture/forbidden_imports_test.dart
---

# Durable Accepted-Readiness Import Handoff Implementation

## Defect Repaired

The required-sources Presence Schedule could complete after the user chose
**Import Anyway**, but the production Environment Readiness panel still chose
its presentation from `OnboardingEnvironmentReport` alone. Because that report
truthfully remained `sourceSparseOrUnsynced`, removing the completed Presence
surface exposed **Confirm Local Messages History** with only **Re-check**.

The workflow had accepted the source, but the existing import action was not
available.

## Two Authorities, One Handoff

The implementation preserves two distinct truths:

```text
OnboardingEnvironmentReport
    current machine and environment facts

completed required-sources Schedule run
    durable evidence that the human accepted required-source readiness
```

The Environment Readiness surface now composes those truths when selecting the
existing import-readiness presentation. Neither authority is rewritten to
imitate the other.

## Accepted-Readiness Source Of Truth

`PresenceScheduleRepository.watchLatestRunCompletion()` watches the latest run
for a Schedule definition and reports completion only when:

```text
currentTripOccurrenceId == null
```

A missing run reports `false`. The query reads `schedule_runs` only. It does
not inspect execution trace, Trip names, Choice values, or route history.

Onboarding exposes that generic checkpoint through the narrow application fact:

```text
requiredSourcesReadinessAcceptedProvider
```

That provider is specific to the canonical required-sources Schedule. The
Environment Readiness feature therefore consumes an Onboarding fact rather
than learning Presence run identity or workflow geometry.

The Onboarding public provider seam exports only this accepted-readiness fact
from the composition file. Its repository and Scheduler providers remain
internal Onboarding composition concerns.

The Drift watch makes completion changes observable without an imperative
"Presence finished" notification from presentation.

## Final Handoff Composition

The Environment Readiness surface keeps its existing operational precedence
and changes only the sparse-source branch:

| Environment fact | Accepted Schedule | Result |
| --- | --- | --- |
| `sourceSparseOrUnsynced` | `false` | **Confirm Local Messages History**, **Re-check** only |
| `sourceSparseOrUnsynced` | `true` | Existing **Ready To Import** surface and **Import My Messages** action |
| `readyToImport` | either | Existing **Ready To Import** behavior |
| `ready` | either | Existing **Ready To Use** behavior |
| import or graph failure | either | Existing retry surface and action |
| permission or source unavailable | either | Existing blocker-specific surface |

The accepted sparse presentation explicitly says that limited local Messages
history was found and that the user chose to continue. The sparse fact is not
hidden or reclassified.

## Restart Behavior

Schedule completion already lives in `presence.db`. On restart, a fresh
repository/provider graph reads the same latest run checkpoint. Therefore:

- sparse and accepted remains import-ready without re-acceptance;
- sparse and incomplete remains at source confirmation;
- sufficient and accepted retains ordinary import readiness.

No provider-local or duplicate durable state participates in reconciliation.

## Operational Authority Preserved

This change only controls whether the existing import opportunity is shown.
The button still invokes:

```text
EnvironmentReadinessActions.startImportAndGraphBuild()
    -> OnboardingGate.startImportAndGraphBuild()
```

`OnboardingGate` continues to own the pre-mutation FDA check, archive mutation
admission, derived-data reset, graph build, recovery, and failure persistence.
Presence does not start import and does not depend on the Gate.

## Persistence And Schema

No schema changed. No acceptance Boolean was added to `presence.db`, overlay,
preferences, environment reports, or provider-local storage. The handoff does
not recover `import_anyway`; both sufficient-history and Import Anyway paths
produce the same contract by completing the required-sources Schedule.

## Tests

Focused coverage proves:

- the real sparse workflow can traverse guidance, `import_anyway`,
  confirmation, and completion while the environment remains sparse;
- a live repository watch changes from incomplete to complete;
- the production readiness surface then exposes **Import My Messages**;
- recreating repositories/providers from the persisted run preserves that
  action;
- an incomplete sparse workflow exposes only **Re-check**;
- sufficient completion establishes the same accepted-readiness fact;
- ready derived stores and import failure retain their existing behavior;
- architecture tripwires prohibit trace/Choice inspection, duplicate
  acceptance fields, Presence-to-Gate dependency, and movement of the import
  operation into Presence.

## Deviations From Audit 19

There were no architectural deviations. The implementation made the audit's
recommended seam reactive with a read-only Drift watch so the existing panel
updates directly from the authoritative run checkpoint.
