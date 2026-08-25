---
tier: project
scope: onboarding-advanced-start-fresh
owner: agent-per-project
last_reviewed: 2026-08-25
source_of_truth: implementation-record
---

# Advanced Start Fresh Presence Maintenance Correction

## Observed Failure

The fresh manual build correctly transferred presentation ownership to the
advanced Start Fresh operation surface. The operation then produced a typed
failure instead of becoming visually inert.

The durable application log identified the failure precisely:

```text
No Test Agent binding exists for
TestAgentId(onboarding.messages-source-readable).
```

The failure occurred after `ArchiveMutationCoordinator` admitted `startFresh`
but before derived MessageLens stores were deleted. `StartFreshService` asked
the narrow `PresenceScheduleRunMaintenance` repository to supersede the
required-sources run. Its implementation called `loadDefinition()`, which
reconstructed executable Test Steps and therefore required Onboarding's
runtime Test Agent bindings.

## Ownership Correction

Run supersession returns a complete `ScheduleRun`, including its current
executable Trip. Reconstructing that truthful return value requires the same
client-owned Test Agent bindings as ordinary Onboarding Schedule loading.

The Start Fresh composition had incorrectly requested the generic
resolver-free Presence maintenance repository. It now reuses the existing
Onboarding-owned required-sources repository, which already carries the real
Onboarding Test Agent bindings and FDA settings-opening authority. The service
continues to receive only the narrow `PresenceScheduleRunMaintenance`
interface.

This preserves both boundaries:

- Presence remains independent of Onboarding and accepts only opaque runtime
  bindings;
- Onboarding owns and supplies its concrete Test Agent composition wherever
  its executable Schedule is reconstructed.

## Staging State

Read-only inspection after the failed manual attempt found:

- `macos_import_ss.db`: 137,379 messages, unchanged;
- `working_ss.db`: 137,379 messages, unchanged;
- no new Presence run was inserted because failure occurred during definition
  reconstruction before the run transaction;
- no derived database reset began.

The staging archive remains safe to retry after rebuilding and relaunching the
corrected binary.

## Regression Protection

An architecture regression requires Start Fresh to consume
`requiredSourcesReadinessRepositoryProvider` and prohibits regression to the
resolver-free maintenance provider. Existing runtime tests continue to prove
that missing bindings prevent executable Schedule loading, run creation, and
run advancement.
