Yes. Next should be **Slice 2: additive schema only**.

The point is to teach `presence.db` the generic grammar:

```text
Test Agent declaration
Test Step -> opaque Agent ID
true destination
false destination
```

without yet changing runtime reconstruction.

Implement **Slice 2 only** from:

`04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md`

Slice 1 is complete and has introduced:

```text
TestAgentId
TestAgent
TestAgentResolver
ImmutableTestAgentResolver
```

No current runtime execution uses them yet.

This slice adds the **generic persisted grammar** for Boolean Test Agents and Test Steps.

Do not yet change active Step reconstruction.

Do not yet replace `FdaTestStep` or `ContactsSourceReadinessStep`.

Do not yet wire onboarding Agent bindings into runtime execution.

Do not change Trip, Scheduler, routing, checkpoints, trace, production onboarding, or existing Schedule behavior.

---

## Goal

Advance `presence.db` so it can persist, generically:

```text
TestAgent definition
    opaque TestAgentId

TestStep definition
    TestAgentId
    true destination
    false destination
```

The target schema from the approved proposal is:

```text
step_definitions
    id
    name
    type = test

test_agent_definitions
    id TEXT PRIMARY KEY

test_step_definitions
    step_definition_id INTEGER PRIMARY KEY
    test_agent_id TEXT NOT NULL
    true_destination_trip_definition_id INTEGER NULL
    false_destination_trip_definition_id INTEGER NULL
```

This slice must prove that this generic representation can coexist with the current specialized representation before runtime reconstruction is changed.

---

## Read first

Re-read:

- `04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md`
- `05-GENERIC-TEST-AGENT-CONTRACTS-IMPLEMENTATION.md`
- Presence database plain-English/schema walkthrough documentation
- current `presence_database.dart`
- current Drift repository persistence tests and migration tests

Pay particular attention to the current subtype integrity model and schema-version migration conventions.

---

## 1. Schema version

Advance `presence.db` by exactly one schema version.

Add:

```text
test_agent_definitions
test_step_definitions
```

and extend the base Step discriminator so:

```text
type = test
```

is valid.

Do not remove existing specialized subtype tables.

Do not change active repository reconstruction yet.

---

## 2. `test_agent_definitions`

Add:

```text
test_agent_definitions
    id TEXT PRIMARY KEY
```

One row means:

> This opaque Boolean Test Agent identity is declared in the workflow-definition grammar.

It does **not** mean:

> This process currently has a runtime Agent implementation for it.

Presence must store the identity exactly as supplied.

Do not add:

- display name;
- implementation class;
- provider name;
- feature owner column;
- SQL/path/configuration;
- version column;
- runtime availability state.

The proposal deliberately keeps this first table identity-only.

---

## 3. `test_step_definitions`

Add:

```text
test_step_definitions
    step_definition_id
    test_agent_id
    true_destination_trip_definition_id nullable
    false_destination_trip_definition_id nullable
```

Integrity:

```text
step_definition_id
    PK/FK -> step_definitions.id

test_agent_id
    FK -> test_agent_definitions.id

true destination
    FK -> trip_definitions.id when non-null

false destination
    FK -> trip_definitions.id when non-null
```

Do not invent additional persisted fields.

A null route arm must retain the established default-next meaning.

---

## 4. Migrate the two proven test definitions

Perform the approved identity-preserving migration for the current:

```text
FdaTestStep
ContactsSourceReadinessStep
```

Map them to stable Agent IDs:

```text
onboarding.messages-source-readable
onboarding.contacts-source-readable
```

Unless existing code/documentation establishes a materially better spelling, use these exact IDs.

The migration must:

1. insert the two `test_agent_definitions` rows;
2. copy each existing FDA/Contacts test definition into `test_step_definitions`;
3. preserve the existing `step_definition_id`;
4. preserve both route destinations exactly;
5. change the corresponding base `step_definitions.type` to `test`;
6. preserve Schedule, Trip, Step, occurrence, ScheduleRun, and trace identities.

This is a persistence normalization, not a new workflow definition.

---

## 5. Frozen legacy subtype rows

The old specialized rows should remain as **frozen migration evidence**:

```text
fda_test_step_definitions
contacts_source_readiness_step_definitions
```

Do not delete or rewrite them.

However, explicitly solve the integrity question:

> After the base type becomes `test`, how do retained legacy subtype rows avoid being mistaken for additional active subtype rows?

Define and test the rule that:

```text
active subtype integrity
    considers only subtype tables valid for the current base Step type

retained legacy rows
    are migration evidence only
    and are not active reconstruction candidates
```

or another equally explicit rule.

Do not leave this ambiguous.

The future generic repository must not interpret retained legacy rows as conflicting active subtypes.

---

## 6. No generic runtime reconstruction yet

This is crucial.

Do **not** yet:

- add executable `TestStep`;
- resolve `TestAgentId`;
- inject `TestAgentResolver` into the repository;
- change current FDA/Contacts runtime authority injection;
- remove current specialized Step classes;
- remove specialized provider parameters.

If current runtime reconstruction cannot tolerate changing the base Step types to `test` without also changing reconstruction, stop and report the exact constraint.

Do not smuggle Slice 3 into Slice 2 merely to keep tests green.

If necessary, distinguish:

```text
schema migration proven
runtime cutover deferred
```

and propose the safest sequencing correction.

---

## 7. Historical preservation test

Create a file-backed migration test beginning from the current pre-migration schema containing:

- at least one FDA test Step;
- at least one Contacts readiness Step;
- Schedule/Trip occurrences that reference them;
- an active ScheduleRun;
- execution trace history.

After migration prove:

```text
same Schedule IDs
same Trip IDs
same StepDefinition IDs
same occurrence IDs
same ScheduleRun IDs
same current Trip occurrence
same trace IDs/sequences
```

and additionally:

```text
generic Test Agent declarations exist
generic Test Step rows exist
base Step type is test
legacy specialized subtype rows still exist
destinations are unchanged
```

This migration test is the most important artifact in the slice.

---

## 8. Generic fresh-insert schema tests

Independently of the migrated legacy definitions, prove the new schema can represent a completely generic Test Agent/Test Step.

For example:

```text
TestAgentId:
    sample.test-agent

TestStep:
    true -> some Trip
    false -> null
```

Verify:

- valid insertion succeeds;
- undeclared Agent identity is rejected by FK;
- nonexistent Trip destination is rejected;
- duplicate Agent declaration is rejected;
- duplicate Test subtype for one Step is rejected;
- nullable route arms are accepted.

Do not attach domain meaning to this fixture.

---

## 9. Typed ID conversion

Where persistence code needs to translate between:

```text
TEXT
<->
TestAgentId
```

use the new `TestAgentId` type.

Do not let generic persistence APIs spread raw strings where a typed identity can be used.

But do not widen public repository APIs unnecessarily in this slice if generic runtime loading is not yet active.

---

## 10. Repository behavior

Keep active runtime repository behavior unchanged unless schema compatibility requires a narrowly documented transitional adjustment.

Do not add new onboarding-specific branches.

If you need migration-only code that recognizes legacy:

```text
fda_test
contacts_source_readiness
```

quarantine it inside the schema migration.

The approved proposal explicitly allows one-time legacy knowledge there, but it must not become new permanent active repository logic.

---

## 11. Update database documentation

Update the two Presence database explainer documents so they describe:

```text
test_agent_definitions
test_step_definitions
```

in ordinary language.

Preserve the established teaching order:

> concept first, architectural/database name second.

Explain clearly:

```text
Test Agent definition
    = an opaque declared specialist identity

Test Step definition
    = a Step that names one Test Agent and two Boolean routing arms
```

Also explain that a declared Agent identity does **not** prove that the running app can execute that Agent. Runtime availability belongs to the resolver.

Document retained legacy subtype rows as migration evidence, not current Test Step truth.

---

## 12. Documentation record

Create:

`06-GENERIC-TESTSTEP-ADDITIVE-SCHEMA-IMPLEMENTATION.md`

under the consolidation package.

Record:

1. schema version change;
2. new tables;
3. exact Agent IDs introduced for migrated definitions;
4. identity-preserving migration;
5. legacy-row preservation rule;
6. active subtype-integrity rule;
7. file-backed migration evidence;
8. generic fresh-insert tests;
9. confirmation that runtime Agent resolution is still unused;
10. any sequencing problem discovered before Slice 3.

Update package start/index and documentation log.

---

## 13. Verification

Run:

- focused Presence database tests;
- file-backed migration tests;
- complete Presence tests insofar as this slice can truthfully preserve them;
- Onboarding tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`.

Run code generation if Drift schema changes require it.

A macOS app build is optional unless generated/schema changes affect compilation in a way unit/analyzer checks do not cover.

---

## Hard constraints

Do not in this slice:

- implement generic runtime `TestStep`;
- inject `TestAgentResolver` into repository/provider;
- create onboarding runtime Agent bindings;
- remove current specialized Step classes;
- remove current specialized authority contracts;
- generalize `OpenFdaSettingsStep`;
- add ActionStep;
- change Schedule topology or copy;
- rewrite historical IDs;
- delete legacy subtype rows;
- change production onboarding.

---

## Stop condition

There is one important possibility:

If changing the existing FDA/Contacts base Step types to `test` necessarily breaks current runtime reconstruction until Slice 3 is implemented, **do not force an artificial half-migrated runtime**.

Instead:

1. implement the additive generic tables;
2. prove migration mechanics in isolated/file-backed tests;
3. document why live type cutover must be atomic with Slice 3;
4. leave the live database migration/cutover deferred.

The goal is architectural correctness, not checking a box called “Slice 2.”

---

## Success criterion

At the end of this slice, the persistence grammar should be capable of saying:

```text
Test Agent:
    onboarding.messages-source-readable

Test Step:
    use that opaque Agent
    true -> Trip X
    false -> Trip Y
```

without storing or knowing what the Agent actually does.

And historical FDA/Contacts test identities and run/trace evidence must remain preserved.

Runtime execution may still use the old specialized Step machinery until Slice 3.

Stop and report back before generic TestStep reconstruction begins.
