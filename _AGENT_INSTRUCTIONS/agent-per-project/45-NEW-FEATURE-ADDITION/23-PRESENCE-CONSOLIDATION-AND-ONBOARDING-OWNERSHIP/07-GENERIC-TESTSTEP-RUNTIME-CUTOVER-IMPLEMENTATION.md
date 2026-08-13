---
tier: project
scope: presence-generic-test-runtime
owner: agent-per-project
last_reviewed: 2026-08-12
source_of_truth: implementation
links:
  - 00-START-HERE.md
  - 04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md
  - 05-GENERIC-TEST-AGENT-CONTRACTS-IMPLEMENTATION.md
  - 06-GENERIC-TESTSTEP-ADDITIVE-SCHEMA-IMPLEMENTATION.md
tests:
  - ../../../../test/essentials/presence/infrastructure/generic_test_step_runtime_test.dart
  - ../../../../test/essentials/presence/infrastructure/presence_v7_generic_test_schema_migration_test.dart
---

# Generic TestStep Runtime Cutover Implementation

## Scope

This record closes Slice 3 of the generic TestStep proposal. Persisted Boolean
tests now execute through one generic Presence path:

```text
type = test
    -> test_step_definitions
    -> opaque TestAgentId
    -> TestAgentResolver
    -> TestAgent
    -> TestStep
    -> true or false destination
```

Presence does not know what an Agent tests.

## TestStep API

`TestStep` owns its ordinary Step identity and name, opaque `TestAgentId`,
resolved `TestAgent`, and nullable true/false Trip destinations. `complete()`
evaluates the Agent once and returns the selected destination. A null arm keeps
the existing default-next meaning. Agent exceptions propagate; they are never
reinterpreted as `false`.

A Test Step remains terminal in its Trip. `Trip` and `PresenceScheduler` remain
unaware of concrete test meaning.

## Resolver Injection And Reconstruction

`presenceScheduleRepositoryProvider` and
`DriftPresenceScheduleRepository` now receive `TestAgentResolver` instead of
Messages- and Contacts-specific readiness authorities. The active repository
loads the persisted Agent ID, asks the resolver for its runtime implementation,
and constructs `TestStep`.

The repository still accepts the narrow FDA Settings-opening authority because
`OpenFdaSettingsStep` is deliberately unchanged in this slice.

## Schedule-Scoped Fail-Fast

Loading an executable Schedule reconstructs every Trip and Step in that
Schedule. Every referenced Agent must resolve before:

- a new run is created or `schedule_run_started` is traced;
- a completed experimental run is replaced;
- an existing run is loaded for execution; or
- an existing run records or checkpoints advancement.

Missing bindings raise `MissingTestAgentBindingException`. Resolution is
Schedule-scoped: an unrelated Schedule may reference an unavailable Agent
without preventing a fully bound Schedule from loading.

## Schema Version 8 Cutover

The v7 migration prepared generic Agent and Test rows while retaining the old
base discriminators. Version 8 atomically changes the migrated
`fda_test` and `contacts_source_readiness` base rows to `test` when a matching
generic subtype row exists.

Schedule, Trip, Step, occurrence, run, checkpoint, trace, and route identities
are unchanged.

## Frozen Legacy Rows

`fda_test_step_definitions` and
`contacts_source_readiness_step_definitions` remain physically present as
frozen migration evidence. The active repository counts only currently active
subtype tables selected by the base discriminator. Therefore a retained legacy
row does not conflict with the generic row for `type = test`.

There is no active fallback reconstruction for `fda_test` or
`contacts_source_readiness`. Legacy meaning is confined to migration.

## Integrity And Evidence

The active path now proves:

- `type = test` has exactly one active generic subtype row;
- the Agent identity is durably declared through SQLite foreign keys;
- the runtime Agent is available through the injected resolver;
- configured destinations belong to the Schedule;
- Test Steps are terminal;
- reused definitions agree on identity, Agent ID, and both route arms;
- missing bindings cannot create or advance runs;
- Agent failure cannot produce a completion or route checkpoint.

The file-backed migration test starts with specialized v6 rows, occurrences,
an active run, and trace history. After migration it verifies the v8 generic
discriminators and frozen rows, reconstructs through generic Agents, and
continues the same active run from its preserved checkpoint.

## Historical Temporary Client Bridge

Slice 3 temporarily let the onboarding-owned Schedule builder create generic
Test Steps and construct a resolver from the existing readiness authorities.
That bridge preserved the proven onboarding and development-harness behavior
during the runtime cutover.

Slice 4 has removed that bridge. Onboarding now contributes explicit Agent
bindings and the current application-composition provider constructs the
immutable resolver. See
[`08-ONBOARDING-TEST-AGENT-COMPOSITION-IMPLEMENTATION.md`](08-ONBOARDING-TEST-AGENT-COMPOSITION-IMPLEMENTATION.md).
No Action Step or Agent supertype was introduced.
