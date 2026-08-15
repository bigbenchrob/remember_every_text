Implement **Slice 1 only** from:

`04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md`

This slice introduces the generic Test Agent contracts and resolver **without changing any existing workflow behavior**.

Do not change `presence.db`.

Do not add generic `TestStep` yet.

Do not modify existing FDA or Contacts Step classes.

Do not modify repository reconstruction.

Do not change Onboarding behavior, Trip, Scheduler, routing, checkpoints, trace, or production onboarding.

The goal is simply to make the Agent concept real in code, with focused tests, before it is connected to persisted Steps.

---

## Approved design

Implement the proposal’s recommended concepts:

```text
TestAgentId
TestAgent
TestAgentResolver
```

The governing boundary remains:

```text
Presence
    knows only opaque Test Agent identity
    and the Boolean Test Agent contract

Onboarding / other workflow owners
    choose which Agent identity a workflow uses

specialist owners
    provide the concrete expertise
```

Presence must remain unable to explain what any particular test means.

The blank-stare invariant remains:

> Ask Presence what the FDA test does. Presence should have no answer.

It may eventually say:

```text
TestAgentId = onboarding.messages-source-readable
```

but it must not interpret that string.

---

## 1. `TestAgentId`

Add a typed durable identity for Boolean Test Agents.

Use the approved persisted representation:

```text
owner-qualified stable string
```

Examples for tests may use forms such as:

```text
onboarding.messages-source-readable
onboarding.contacts-source-readable
```

Important:

- this is identity, not display copy;
- it is immutable once persisted;
- Presence does not parse owner, meaning, or version from it;
- the Dart type must prevent accidental interchange with raw strings, Trip IDs, Step IDs, etc.;
- do not introduce required version syntax yet.

Implement the smallest type that fits existing project conventions.

Include validation only for mechanical identity integrity that Presence can truthfully own, such as rejecting an empty value if appropriate.

Do not teach it domain-specific naming rules.

---

## 2. `TestAgent`

Add the smallest permanent Boolean Agent contract.

Conceptually:

```dart
abstract interface class TestAgent {
  Future<bool> evaluate();
}
```

Use `evaluate()` unless repository conventions strongly justify another name.

The Agent must not receive:

- Step;
- Trip;
- Schedule;
- destinations;
- retry state;
- context/result bags;
- routing information.

Its only responsibility is:

```text
establish its fully configured Boolean fact
-> Future<bool>
```

Concrete dependencies belong inside the runtime Agent/adaptor supplied by its owner.

---

## 3. Immutable `TestAgentResolver`

Implement the smallest explicit resolver required by the approved proposal.

Conceptually:

```dart
abstract interface class TestAgentResolver {
  TestAgent resolve(TestAgentId id);
}
```

Provide an immutable concrete implementation suitable for application composition and tests.

Requirements:

- bindings are fixed at construction;
- duplicate `TestAgentId` bindings are rejected;
- missing identity resolution fails explicitly;
- no “last registration wins” behavior;
- resolver returns only `TestAgent`;
- resolver knows nothing about Schedule, Trip, Step, routing, or workflow-owner semantics;
- no global mutable registry;
- no singleton ambient lookup;
- no Riverpod dependency inside the domain contract unless clearly required by existing architecture.

Prefer something mechanically simple such as construction from explicit bindings.

---

## 4. Binding shape

Choose the smallest readable binding representation.

For example, something conceptually equivalent to:

```text
TestAgentBinding
    id
    agent
```

may be useful, but do not introduce a class merely for ceremony if an immutable map or existing project pattern is clearer.

Whatever representation is chosen must make duplicate IDs mechanically detectable during resolver construction.

Document the reasoning briefly in code comments only where useful.

---

## 5. Failure semantics

Introduce explicit configuration failures for:

```text
duplicate TestAgentId binding
missing TestAgentId resolution
```

Use existing project error conventions where appropriate.

Do not add a general Presence error framework.

Do not treat a missing Agent as:

```text
false
```

These meanings must remain distinct:

```text
Agent missing
    -> configuration defect

Agent.evaluate() returns false
    -> ordinary workflow fact
```

The proposal explicitly requires that distinction.

---

## 6. No runtime integration yet

This slice must **not** change any current execution path.

In particular, do not modify:

```text
FdaTestStep
ContactsSourceReadinessStep
MessagesSourceReadinessAuthority
ContactsSourceReadinessAuthority
DriftPresenceScheduleRepository
presence_schedule_repository_provider
required_sources_readiness_schedule
```

The existing onboarding workflow must continue to use the current specialized authorities exactly as before.

After this slice the new Agent machinery may be completely unused by production/development execution. That is intentional.

We are proving the generic primitive independently before connecting it.

---

## 7. Ownership and file placement

Place these generic concepts under:

`lib/essentials/presence/`

Use the smallest logical domain/service organization consistent with the current package.

For example, assess whether the clean split is:

```text
domain/entities/test_agent_id.dart
domain/services/test_agent.dart
domain/services/test_agent_resolver.dart
```

but follow existing conventions rather than forcing these exact paths.

Do not put onboarding-specific constants or bindings into Presence in this slice.

---

## 8. Focused tests

Add focused unit tests proving at least:

### `TestAgentId`

- preserves a stable string identity;
- equality/hash semantics are correct;
- distinct identities remain distinct;
- invalid empty identity is rejected if that is part of the implementation contract.

### `TestAgent`

Use tiny test implementations to prove asynchronous Boolean evaluation can return:

```text
true
false
```

No workflow machinery is needed.

### Resolver

Prove:

```text
one ID -> correct Agent

several IDs -> correct independent Agents

missing ID -> explicit configuration failure

duplicate ID -> resolver construction failure

Agent false -> remains ordinary false result

Agent throws -> exception is not converted into false
```

Also prove resolver construction is immutable: no later registration/replacement API exists.

---

## 9. Architecture tripwire

Add or extend architecture protection if appropriate so future code cannot accidentally make the generic Test Agent contracts depend on:

- Onboarding;
- Conversation Graph;
- Address Book;
- Flutter presentation;
- specialist source paths or SQL.

Do not add brittle tests merely to inspect filenames.

Use existing architecture-test style.

---

## 10. Documentation

Create:

`05-GENERIC-TEST-AGENT-CONTRACTS-IMPLEMENTATION.md`

inside the consolidation package.

Record:

1. implemented types;
2. final file locations;
3. exact `TestAgentId` representation;
4. exact `TestAgent` contract;
5. resolver API;
6. duplicate/missing failure semantics;
7. why the resolver is immutable;
8. confirmation that nothing currently executes through it;
9. tests;
10. any deviation from proposal section 21, Slice 1.

Update:

- `00-START-HERE.md`
- package index if applicable;
- `DOCUMENTATION_PASS_LOG.md`

Do not rewrite the approved proposal.

---

## 11. Verification

Run:

- focused new Agent tests;
- complete Presence tests;
- Onboarding tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`.

A macOS build is optional unless the changes unexpectedly touch generated/app composition code.

---

## Hard constraints

Do not in this slice:

- change `presence.db`;
- add `test_agent_definitions`;
- add `test_step_definitions`;
- implement generic `TestStep`;
- migrate FDA or Contacts definitions;
- remove specialized Step classes;
- alter repository reconstruction;
- alter provider signatures;
- add onboarding Agent IDs;
- create runtime onboarding bindings;
- create a generic Action Agent;
- modify `OpenFdaSettingsStep`;
- change production onboarding.

If any of those appear necessary to implement these three generic primitives, stop and explain why.

---

## Success criterion

At the end of this slice we should have a small, permanent, generic Presence capability that can answer:

```text
Can an opaque TestAgentId be resolved to one Boolean TestAgent?
```

with explicit failure for bad composition.

But existing Presence execution should not yet use it.

The architecture should now contain:

```text
TestAgentId
    durable opaque identity

TestAgent
    Future<bool> evaluate()

TestAgentResolver
    explicit immutable mapping
```

and absolutely nothing about:

```text
FDA
chat.db
Contacts
Address Book
Onboarding
Archive Ingestion
```

inside those contracts.

Stop after Slice 1 and report back before schema or TestStep work begins.
