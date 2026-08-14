Good. Slice 2 should do one thing only: **teach `presence.db` how to represent the ChoiceStep we just proved in the domain**.

Implement **ChoiceStep Slice 2 only** from:

`12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md`

and preserve the pure-domain contract documented in:

`13-CHOICESTEP-PURE-DOMAIN-IMPLEMENTATION.md`.

This slice is **additive persistence grammar only**.

Do not modify Scheduler choice submission.

Do not add presentation.

Do not extend the live Onboarding Schedule.

Do not make any production workflow invoke `ChoiceStep`.

The goal is simply:

> `presence.db` can store and reconstruct a generic `ChoiceStep` faithfully.

The approved persisted shape is:

```text
choice_step_definitions
    step_definition_id PK/FK -> step_definitions.id

choice_step_options
    step_definition_id FK -> choice_step_definitions.step_definition_id
    value TEXT
    position INTEGER
    label TEXT
    destination_trip_definition_id FK -> trip_definitions.id

    PK(step_definition_id, value)
    UNIQUE(step_definition_id, position)
```

This matches the settled proposal.

---

## 1. Schema migration

Add the next additive `presence.db` schema version.

Introduce:

```text
choice_step_definitions
choice_step_options
```

Use existing Presence schema conventions for:

- foreign keys;
- naming;
- migration style;
- integrity checks;
- schema-version tests.

Do not remove or rewrite existing Step subtype tables.

Do not alter existing active subtype semantics.

This slice must remain backward-compatible with all current persisted workflow definitions.

---

## 2. `choice_step_definitions`

This is the subtype marker table.

Conceptually:

```sql
choice_step_definitions(
    step_definition_id INTEGER PRIMARY KEY
        REFERENCES step_definitions(id)
)
```

Use the actual project ID types/schema conventions.

Its purpose is to state:

> this base Step definition is a ChoiceStep.

It contains no options itself.

Preserve the existing exactly-one-active-subtype integrity model.

A ChoiceStep marker must not coexist with another active subtype definition for the same base Step.

If exactly-one-subtype validation currently happens in repository reconstruction rather than a database constraint, extend that existing mechanism rather than inventing a new one.

---

## 3. `choice_step_options`

Store each option as a child row:

```text
step_definition_id
value
position
label
destination_trip_definition_id
```

Requirements:

### `value`

- persisted opaque text;
- must reconstruct as `ChoiceValue`;
- unique within one ChoiceStep;
- Presence must not parse or interpret it.

### `position`

- durable ordering;
- integer;
- unique within the containing ChoiceStep;
- reconstruct options ordered by this field.

### `label`

- persisted user-facing copy;
- no uniqueness requirement;
- do not treat as execution identity.

### `destination_trip_definition_id`

- required;
- FK to `trip_definitions`;
- two different options may point to the same Trip.

---

## 4. Minimum cardinality

A persisted ChoiceStep must reconstruct only if it has at least two option rows.

Do not use a SQLite trigger solely to enforce this cross-row rule.

Validate it in the same repository/workflow-definition reconstruction boundary used for other structural invariants.

The database can enforce:

```text
unique(step_definition_id, value)
unique(step_definition_id, position)
```

but repository reconstruction should reject:

```text
0 options
1 option
```

This preserves the approved rule.

---

## 5. Destination closure

Every `destination_trip_definition_id` must belong to the same loaded Schedule definition containing the ChoiceStep.

Reuse the existing route-closure validation used for `TestStep` and other configured destinations.

Do not let a ChoiceStep point outside its Schedule.

This is an architectural integrity rule, not workflow semantics.

---

## 6. Repository reconstruction

Extend the Presence definition repository so a persisted ChoiceStep reconstructs as:

```dart
ChoiceStep(
    id: ...,
    name: ...,
    options: [
        ChoiceOption(
            value: ChoiceValue(...),
            label: ...,
            destinationTripDefinitionId: ...,
        ),
        ...
    ],
)
```

Requirements:

- order strictly by persisted `position`;
- preserve exact `value`;
- preserve exact `label`;
- preserve required destination;
- fail explicitly on malformed/incomplete ChoiceStep persistence;
- rely on domain constructor invariants where appropriate rather than duplicating them unnecessarily.

Do not add presentation projections yet.

Do not add runtime choice submission.

---

## 7. Persistence write path / definition fixtures

Extend the existing workflow-definition persistence/writer path so it can write ChoiceStep definitions and their options.

If the project uses static fixture/bootstrap code to seed Schedule definitions, teach that layer how to emit ChoiceStep rows.

However:

> Do not add any ChoiceStep to the active Onboarding Schedule in this slice.

Use test-only definitions or isolated repository fixtures.

The writer must persist:

```text
Step base row
ChoiceStep marker row
N ordered option rows
```

and preserve value/label/destination faithfully.

---

## 8. Exactly-one-subtype integrity

Update the subtype accounting logic so `choice_step_definitions` participates in the same invariant as the existing Step subtype tables.

For one base Step definition:

```text
exactly one active subtype row
```

must remain true.

Prove that:

```text
ChoiceStep + TestStep subtype rows
```

for the same Step fail reconstruction/integrity validation.

Do not weaken existing subtype checks.

---

## 9. Round-trip tests

Add focused persistence tests proving:

### Basic round trip

Persist:

```text
value = "blue"
label = "Blue"
destination = Trip 12

value = "pink"
label = "Pink"
destination = Trip 15

value = "purple"
label = "Purple"
destination = Trip 19
```

Reconstruct and prove:

```text
destinationFor(ChoiceValue("pink"))
    -> Trip 15
```

### Ordering

Insert options in a database order different from `position`.

Prove repository reconstruction uses `position`, not row order.

### Mutable-label / durable-value distinction

Persist:

```text
value = "pause"
label = "That's good for now"
```

then update only the label to:

```text
"Finish for now"
```

and prove:

```text
ChoiceValue("pause")
```

still reconstructs and routes to the same destination.

### Duplicate labels

Prove two rows may use the same label.

### Shared destination

Prove two values may point to the same Trip.

### Duplicate values

Prove database or reconstruction fails.

### Duplicate positions

Prove database or reconstruction fails.

### Too few options

Prove persisted ChoiceStep with:

```text
0 options
1 option
```

fails reconstruction explicitly.

### Missing marker / orphan option cases

Test malformed persistence according to existing repository conventions.

### Outside-Schedule destination

Prove route-closure validation rejects it.

### Multiple subtype rows

Prove exactly-one-subtype validation still rejects contradictory Step definitions.

---

## 10. Migration tests

Add schema migration coverage from the immediately previous version to the new version.

Prove:

- old Presence databases migrate successfully;
- existing schedules/trips/steps/runs/trace remain intact;
- new tables exist;
- FK constraints behave correctly;
- existing workflows reconstruct exactly as before.

Do not rewrite old migrations.

Do not mutate historical migration evidence.

---

## 11. Existing fail-closed switch

Slice 1 added explicit fail-closed `ChoiceStep` cases in persistence/topology switches because the sealed hierarchy required compilation support.

For the **persistence** side, replace only the fail-closed behavior that this slice now legitimately supports.

For development topology or other runtime consumers not yet approved:

> keep them fail-closed.

Do not accidentally broaden Slice 2 into visualization or runtime support.

---

## 12. No selected choice persistence

Do not add any field such as:

```text
selected_value
current_choice
pending_choice
```

to definition or run tables.

The definition stores:

> what may be selected.

It does not store:

> what this run selected.

Runtime choice acceptance is a later slice.

Current Trip-granular restart semantics remain untouched.

---

## 13. No trace changes

Do not add `ChoiceValue` to execution trace yet.

The approved proposal explicitly defers that.

Trace remains unchanged in this slice.

---

## 14. No presentation metadata

Persist only:

```text
value
label
position
destination
```

Do not add:

- icon;
- control type;
- button/radio/menu/list hint;
- default;
- preferred;
- destructive;
- cancel;
- color;
- keyboard shortcut;
- arbitrary metadata.

Presentation styling remains outside persistence.

---

## 15. Architecture tripwires

Extend architecture tests if needed to protect these boundaries:

- Choice persistence may depend on Presence domain;
- Presence infrastructure must not depend on Onboarding;
- Choice persistence must not import Flutter/presentation;
- no Choice-specific workflow semantics in Presence;
- no value parsing such as checking for strings like `pause`, `recheck`, or `import_anyway`.

If useful, add a positive test confirming `choice_step_definitions` / `choice_step_options` reconstruct only generic Choice domain types.

Do not overbuild static-analysis machinery.

---

## 16. Documentation

Create:

`14-CHOICESTEP-ADDITIVE-PERSISTENCE-IMPLEMENTATION.md`

Document:

1. schema version;
2. final table definitions;
3. FK and uniqueness rules;
4. minimum-cardinality validation location;
5. ordering semantics;
6. exactly-one-subtype integration;
7. destination-closure validation;
8. repository reconstruction path;
9. writer/bootstrap path;
10. migration behavior;
11. tests run;
12. deviations from Document 12, if any.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

Do not rewrite Document 12.

---

## 17. Verification

Run:

- focused Choice persistence tests;
- Presence repository tests;
- migration tests;
- complete Presence tests;
- development-harness tests;
- Onboarding tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`.

No macOS build is required unless persistence changes unexpectedly affect compiled app integration.

---

## Hard constraints

Do not in Slice 2:

- modify Scheduler choice submission;
- modify Trip completion semantics;
- add runtime selection callbacks;
- add generic Presence presentation;
- change Onboarding presentation;
- extend the live Onboarding Schedule;
- add sparse-history ChoiceStep usage;
- add ActionStep;
- add generic interaction payloads;
- add selected-choice persistence;
- add trace fields;
- add presentation metadata;
- modify production workflow behavior.

If any of those appears necessary, stop and explain why.

---

## Success criterion

At the end of Slice 2:

`presence.db` can faithfully represent and reconstruct:

```text
ChoiceStep

    ("Blue", "blue")       -> Trip 12
    ("Pink", "pink")       -> Trip 15
    ("Purple", "purple")   -> Trip 19
```

with:

```text
durable value
mutable label
durable ordering
configured destination
```

while:

```text
Scheduler
presentation
Onboarding runtime
production workflow
```

remain completely unchanged.

Stop after Slice 2 and report back before runtime choice submission begins.
