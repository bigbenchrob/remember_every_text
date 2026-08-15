---
tier: project
scope: presence-choice-step-persistence
owner: agent-per-project
last_reviewed: 2026-08-13
source_of_truth: implementation
links:
  - 12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md
  - 13-CHOICESTEP-PURE-DOMAIN-IMPLEMENTATION.md
  - 00-START-HERE.md
tests:
  - test/essentials/presence/infrastructure/choice_step_persistence_test.dart
  - test/essentials/presence/infrastructure/presence_v9_choice_schema_migration_test.dart
  - test/architecture/forbidden_imports_test.dart
---

# ChoiceStep Additive Persistence Implementation

## Scope

This is Slice 2 of the approved `ChoiceStep` proposal. Schema version 9 teaches
`presence.db` to store and reconstruct the generic finite-choice grammar proven
in Slice 1. It does not add choice submission, Scheduler or Trip behavior,
presentation, active Onboarding usage, selected-choice state, or trace data.

## Schema Version 9

The migration is additive. It extends the base Step discriminator with
`choice` and creates two tables without removing or rewriting any existing
subtype table:

```text
choice_step_definitions
    step_definition_id PK/FK -> step_definitions.id

choice_step_options
    step_definition_id FK -> choice_step_definitions.step_definition_id
    value TEXT
    position INTEGER CHECK position >= 0
    label TEXT
    destination_trip_definition_id FK -> trip_definitions.id

    PK(step_definition_id, value)
    UNIQUE(step_definition_id, position)
```

The marker table states that the base definition is a `ChoiceStep`. Option rows
hold only the approved generic grammar: opaque durable value, durable ordering,
user-facing label, and required configured destination. The destination index
supports the existing route-integrity work; no presentation or run-state
metadata was added.

## Integrity Boundaries

SQLite enforces:

- the marker-to-base-Step foreign key;
- the option-to-marker foreign key;
- the option destination-to-Trip foreign key;
- unique values within one Choice definition;
- unique positions within one Choice definition; and
- non-negative option positions.

Repository reconstruction retains the structural rules which cannot be
truthfully expressed as isolated row constraints:

- a Choice marker participates in the existing exactly-one-active-subtype
  count;
- options without a marker fail explicitly;
- constructing zero or one options is rejected by the existing `ChoiceStep`
  domain invariant;
- every configured destination must be a Trip in the same loaded Schedule; and
- `ChoiceStep` must be terminal in its containing Trip.

No trigger was introduced for minimum cardinality.

## Repository Paths

### Write

`insertDefinition` validates the complete Schedule definition before starting
the existing transaction. For each `ChoiceStep`, the repository writes:

1. the base `step_definitions` row with type `choice`;
2. one `choice_step_definitions` marker row; and
3. one `choice_step_options` row per option, assigning `position` from the
   domain list order.

The same immutable-definition comparison used by other Step types now compares
Choice identity, name, and ordered options. No active Onboarding fixture was
changed; Choice definitions exist only in focused test fixtures in this slice.

### Load

The repository loads the base Step and all possible active subtype rows. It
loads Choice options with an explicit ascending `position` ordering, verifies
the marker/subtype structure, and constructs:

```text
ChoiceStep
    -> ChoiceOption
        -> ChoiceValue(exact persisted value)
        -> exact persisted label
        -> configured TripDefinitionId
```

The repository does not parse values or infer workflow meaning from labels.
The reconstructed domain object remains the authority for finite cardinality
and duplicate-value invariants.

## Migration Behavior

The v8-to-v9 migration alters only the base Step discriminator constraint and
creates the two Choice tables. A file-backed migration fixture proves that an
existing Schedule, Trip, Tell Step, active run checkpoint, and append-only
trace survive unchanged. It also proves the new marker and option foreign keys
are active after migration.

Older migration fixtures continue to describe their original source versions;
only their expected current destination version is now 9.

## Preserved Boundaries

- The Scheduler still cannot accept a selected `ChoiceValue`.
- Trip completion and checkpoint semantics are unchanged.
- The development topology projector remains explicitly fail-closed for
  `ChoiceStep`.
- The active Onboarding Schedule contains no Choice definition.
- `schedule_runs` contains no pending or selected choice.
- execution trace contains no choice payload.
- persistence contains no control, icon, default, color, or other presentation
  metadata.

## Verification

Focused tests cover exact round-trip reconstruction, position ordering,
label-only revision, duplicate labels, shared destinations, database uniqueness,
minimum cardinality, marker integrity, foreign keys, Schedule-local closure,
terminal placement, contradictory subtype rows, and v8-to-v9 preservation.

- 34 focused Choice domain, persistence, and migration tests passed.
- All 63 Presence infrastructure tests passed.
- All 109 Presence and development-harness tests passed.
- All 82 Onboarding tests passed.
- All 364 architecture tripwires passed.
- `flutter analyze` completed with no issues.
- Code generation, formatting, and `git diff --check` completed cleanly.
- No macOS build was required because compiled application integration did not
  change.

## Deviations From Document 12

None. The implementation uses the approved relational shape and preserves all
deferred runtime and presentation boundaries.
