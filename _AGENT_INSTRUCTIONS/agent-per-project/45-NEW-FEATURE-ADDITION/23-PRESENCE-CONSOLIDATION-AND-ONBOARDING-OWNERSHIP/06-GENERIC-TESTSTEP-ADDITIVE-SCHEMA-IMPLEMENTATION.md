---
tier: project
scope: presence-generic-test-schema
owner: agent-per-project
last_reviewed: 2026-08-12
source_of_truth: implementation
links:
  - 00-START-HERE.md
  - 04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md
  - 05-GENERIC-TEST-AGENT-CONTRACTS-IMPLEMENTATION.md
  - ../21-PRESENCE-ITERATION-SIMPLE/15-PRESENCE-DATABASE-IN-PLAIN-ENGLISH.md
  - ../21-PRESENCE-ITERATION-SIMPLE/16-PRESENCE-DATABASE-SCHEMA-WALKTHROUGH.md
tests:
  - ../../../../test/essentials/presence/infrastructure/presence_v7_generic_test_schema_migration_test.dart
---

# Generic TestStep Additive Schema Implementation

> Historical Slice 2 state. The prepared compatibility rows described here
> were activated by the Slice 3 runtime cutover recorded in
> [`07-GENERIC-TESTSTEP-RUNTIME-CUTOVER-IMPLEMENTATION.md`](07-GENERIC-TESTSTEP-RUNTIME-CUTOVER-IMPLEMENTATION.md).

## Scope

This record closes Slice 2 of the approved generic TestStep and opaque Agent
resolution proposal. It adds the persisted generic Boolean Test grammar while
leaving runtime reconstruction and current onboarding execution unchanged.

## Schema Version

`presence.db` advances from schema version 6 to version 7.

The base `step_definitions.type` constraint now permits `test`. Two tables are
added:

```text
test_agent_definitions
    id TEXT PRIMARY KEY

test_step_definitions
    step_definition_id INTEGER PRIMARY KEY
    test_agent_id TEXT NOT NULL
    true_destination_trip_definition_id INTEGER NULL
    false_destination_trip_definition_id INTEGER NULL
```

Foreign keys connect the Test subtype to its base Step, its declared Agent,
and each non-null destination Trip. No display copy, implementation identity,
provider name, version, configuration, or runtime availability is persisted.

## Migrated Agent Identities

The v6-to-v7 migration declares exactly:

```text
onboarding.messages-source-readable
onboarding.contacts-source-readable
```

The migration uses `TestAgentId` when translating these typed identities to
their persisted text representation.

## Identity-Preserving Preparation

For every existing FDA and Contacts readiness definition, the migration copies
the existing Step identity and route arms into `test_step_definitions`:

```text
FDA present       -> true destination
FDA absent        -> false destination

Contacts available   -> true destination
Contacts unavailable -> false destination
```

Schedule, Trip, Step, occurrence, ScheduleRun, current occurrence, trace-event
identity, trace sequence, and nullable destination values are not rewritten.

## Sequencing Correction

The active repository currently reconstructs Steps by switching on
`fda_test` and `contacts_source_readiness`. It has no `test` reconstruction
case and would reject a live generic discriminator. Changing the base types in
this slice would therefore require smuggling Slice 3 runtime work into Slice 2.

The approved stop condition applies. Version 7 prepares the generic Agent and
Test rows but leaves existing specialized base types active. The final base
type update is deferred until generic `TestStep` reconstruction and Agent
resolution can be introduced atomically.

## Legacy-Row And Active-Subtype Rule

Active subtype truth is selected by `step_definitions.type`:

```text
version 7 compatibility state
    specialized base type
        -> specialized row active
        -> prepared generic row inactive

future generic cutover
    base type = test
        -> generic row active
        -> retained specialized row frozen migration evidence
```

Rows in subtype tables not selected by the current base discriminator do not
count as additional active subtypes. The specialized rows are never deleted or
rewritten. Slice 3 must implement this same discriminator-scoped integrity rule
when it adds generic reconstruction.

## File-Backed Migration Evidence

The version 7 migration test starts from an on-disk v6 database containing:

- one FDA test definition;
- one Contacts-readiness definition;
- Schedule and Trip occurrences referencing both;
- an active ScheduleRun and current Trip occurrence;
- ordered execution trace history.

After opening through `PresenceDatabase`, it proves that all historical IDs,
the current checkpoint, trace sequences, legacy rows, and both destinations are
unchanged. It also proves that the two Agent declarations and generic Test rows
exist with the original Step IDs.

The same file then performs the deferred discriminator update in isolation. A
join selected by `type = test` finds exactly the two generic rows while both
legacy rows remain present. This proves the eventual cutover mechanics without
making the current runtime database unexecutable.

## Fresh-Schema Integrity Evidence

Independent schema tests prove that a generic fixture can:

- declare an opaque `sample.test-agent`;
- store a Test Step with one explicit and one null destination;
- reject an undeclared Agent identity;
- reject a nonexistent destination Trip;
- reject a duplicate Agent declaration;
- reject a duplicate Test subtype for one Step.

The fixture carries no onboarding or specialist meaning.

## Runtime Status

`TestAgentResolver` remains unused by active execution. No executable
`TestStep`, repository reconstruction branch, provider parameter, onboarding
binding, specialist authority migration, Schedule topology change, or
production onboarding change is part of this slice.

The one sequencing issue before Slice 3 is explicit: generic reconstruction
must be introduced in the same migration boundary that changes prepared base
types to `test`.
