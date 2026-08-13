Implement **Slice 4 only** from:

`04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md`

Slices 1–3 are complete.

Current generic execution path is now:

```text
type = test
    -> test_step_definitions
    -> opaque TestAgentId
    -> TestAgentResolver
    -> TestAgent
    -> TestStep
    -> true / false destination
```

Presence no longer knows the meaning of the Messages or Contacts tests.

This slice should clean up **Onboarding-owned runtime composition** so the permanent ownership boundary becomes explicit.

Do not change the generic TestStep execution model.

Do not change `presence.db`.

Do not change Trip, Scheduler, routing, checkpoints, trace, Schedule topology, onboarding copy, or production `OnboardingGate`.

---

## Goal

Replace the temporary Slice-3 bridge with clear permanent composition:

```text
Onboarding
    owns stable TestAgentIds
    owns TestAgent bindings for its workflow
    adapts specialist capabilities where needed

application composition
    gathers explicit bindings
    constructs ImmutableTestAgentResolver

Presence
    receives only TestAgentResolver
```

The end state should make it obvious that Presence never asks a feature for an Agent.

Presence simply receives one already-constructed resolver.

---

## Read first

Re-read:

- `04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md`
- `05-GENERIC-TEST-AGENT-CONTRACTS-IMPLEMENTATION.md`
- `06-GENERIC-TESTSTEP-ADDITIVE-SCHEMA-IMPLEMENTATION.md`
- `07-GENERIC-TESTSTEP-RUNTIME-CUTOVER-IMPLEMENTATION.md`

Inspect the current Slice-3 temporary bridge mentioned in the implementation record:

> The onboarding-owned Schedule builder now creates generic Test Steps and provides a small resolver-construction bridge from the existing readiness authorities.

Also inspect all current onboarding-owned adapters/providers and the generic Presence repository provider.

---

## 1. Make Onboarding own its TestAgent identities

Define the stable onboarding-owned Test Agent identities in `lib/essentials/onboarding/`.

Use the already persisted IDs exactly:

```text
onboarding.messages-source-readable
onboarding.contacts-source-readable
```

Do not duplicate these literals in multiple files.

Create the smallest clear owner for these identities.

Presence must not define them.

Do not parse or interpret them inside Presence.

---

## 2. Convert current onboarding adapters into TestAgents

Inspect the existing adapters used for:

```text
Messages source readiness
Contacts source readiness
```

Refactor their role so they directly satisfy:

```dart
TestAgent
```

where appropriate.

Conceptually:

```text
MessagesSourceReadinessTestAgent
    -> existing truthful Messages source specialist
    -> evaluate() -> bool

ContactsSourceReadinessTestAgent
    -> existing Address Book specialist
    -> evaluate() -> bool
```

Do not duplicate specialist logic.

The concrete Agent/adaptor should continue to delegate to:

```text
ChatDbSourceProbeReader / existing onboarding FullDiskAccess boundary
AddressBookFolderRepository
```

as already established.

The Agent must not know:

```text
Trip
Schedule
destinations
routing
TestStep
```

It only establishes its Boolean fact.

---

## 3. Remove obsolete readiness-authority indirection where earned

Review the current transitional contracts:

```text
MessagesSourceReadinessAuthority
ContactsSourceReadinessAuthority
```

Now that `TestAgent` is the generic Step-facing Boolean contract, determine whether these interfaces still add a distinct architectural responsibility.

If they are now only aliases for:

```text
Future<bool> ...
```

with no independent ownership value, retire them from active runtime code.

If one still protects a meaningful boundary, retain it and document why.

Do not delete merely for tidiness.

The desired simplification is:

```text
before:
TestStep
    -> TestAgent
        -> readiness authority
            -> specialist

if unnecessary:

after:
TestStep
    -> TestAgent adapter
        -> specialist
```

But only make that change where the intermediate contract has genuinely become redundant.

---

## 4. Explicit onboarding binding contribution

Add one onboarding-owned composition seam that produces its Test Agent bindings.

Conceptually:

```dart
List<TestAgentBinding> buildOnboardingTestAgentBindings(...)
```

or an equivalent provider/value object consistent with project conventions.

It should contribute exactly:

```text
onboarding.messages-source-readable
    -> Messages TestAgent

onboarding.contacts-source-readable
    -> Contacts TestAgent
```

Do not construct the global resolver inside a specialist feature.

Onboarding owns its contribution; application composition owns combining contributions.

---

## 5. Global resolver composition

Identify the correct existing application-composition point that constructs the resolver supplied to Presence.

Do not create a new global service-locator layer if an existing composition/provider boundary can own this naturally.

The intended shape is:

```text
Onboarding bindings
    +
future Archive Ingestion bindings
    +
future other workflow-owner bindings
        ↓
application composition
        ↓
ImmutableTestAgentResolver
        ↓
Presence repository
```

For this slice, only Onboarding may contribute bindings.

But the composition shape must allow future consumers to add bindings without modifying generic Presence.

Do not make Presence import Onboarding to obtain them.

---

## 6. Remove the temporary Slice-3 bridge

Once permanent composition is in place, remove the temporary resolver-building bridge introduced solely to preserve onboarding during Slice 3.

The final dependency direction must be:

```text
Onboarding / application composition
    -> TestAgentBinding
    -> ImmutableTestAgentResolver
    -> Presence
```

not:

```text
Presence
    -> ask Onboarding for authorities
```

Update provider signatures accordingly.

---

## 7. Required-sources Schedule ownership

Keep:

`required_sources_readiness_schedule.dart`

under Onboarding.

It should author generic persisted TestSteps using onboarding-owned TestAgentIds and route destinations.

It must not construct or know the concrete specialist implementation used by the Agent at runtime unless current project composition requires a narrow explicit seam.

Prefer separating:

```text
workflow definition
```

from:

```text
runtime Agent composition
```

if this can be done without speculative abstraction.

---

## 8. Development source substitution

Preserve the development Contacts-source substitution harness.

The disposable real/unavailable Contacts test mode must still affect the Contacts TestAgent through development composition.

Do not put development mode knowledge into:

```text
TestStep
TestAgentId
Presence repository
presence.db
```

The development harness may substitute the concrete runtime Agent/binding or one of its specialist dependencies.

The manual test behavior already proven must remain intact.

---

## 9. Presence cleanup

After permanent binding composition is established, generic Presence should not actively depend on:

```text
MessagesSourceReadinessAuthority
ContactsSourceReadinessAuthority
onboarding-specific providers
onboarding-specific TestAgent IDs
```

The generic repository/provider should receive only:

```text
TestAgentResolver
```

plus the still-transitional FDA Settings-opening dependency needed by `OpenFdaSettingsStep`.

Do not touch `OpenFdaSettingsStep` in this slice.

---

## 10. Tests

Add focused tests proving:

### Onboarding Agent IDs

```text
Messages ID is exact persisted identity
Contacts ID is exact persisted identity
IDs remain distinct
```

### Messages TestAgent

- delegates to the existing truthful source-read capability;
- returns true on readable source;
- returns false on unreadable source;
- preserves specialist exceptions according to the current contract.

### Contacts TestAgent

- delegates to Address Book readiness;
- returns true/false correctly;
- performs a fresh read on repeated evaluation;
- development source substitution still works.

### Binding contribution

Prove Onboarding contributes exactly one binding for each required Agent ID.

### Resolver composition

Prove the global resolver can resolve both onboarding Agents.

Also prove duplicate contributions fail mechanically.

### Architecture

Prove:

```text
Presence does not import Onboarding
Onboarding may import generic Presence TestAgent contracts
specialist owners do not import Presence routing machinery
```

---

## 11. Regression behavior

Run the existing real workflow tests and prove unchanged routing:

```text
Messages readable
    -> Contacts test

Messages unreadable
    -> FDA remediation
    -> verification
    -> Contacts test

Contacts unavailable
    -> Contacts guidance
    -> retry

Contacts restored
    -> combined confirmation
```

No Schedule IDs, Trip IDs, Step IDs, Agent IDs, route arms, copy, checkpoint behavior, or trace semantics should change.

---

## 12. Manual validation preservation

Do not require a new manual FDA experiment unless code changes actually affect the FDA Agent composition.

Do verify that the development harness can still:

```text
use real Contacts source
use disposable unavailable Contacts source
switch back
fresh retry succeeds
```

If practical through automated harness/provider tests, prefer that.

---

## 13. Documentation

Create:

`08-ONBOARDING-TEST-AGENT-COMPOSITION-IMPLEMENTATION.md`

Record:

1. final owner of onboarding TestAgentIds;
2. final Messages TestAgent implementation;
3. final Contacts TestAgent implementation;
4. whether old readiness-authority interfaces were retained or retired;
5. onboarding binding contribution API;
6. application resolver-composition point;
7. removal of temporary Slice-3 bridge;
8. development source-substitution path;
9. final dependency diagram;
10. tests and verification;
11. anything still preventing Presence from being fully domain-neutral.

Update:

- `00-START-HERE.md`
- package index
- relevant Onboarding ownership docs
- `DOCUMENTATION_PASS_LOG.md`

---

## 14. Final dependency diagram

The implementation record should be able to show something like:

```text
Conversation Graph
    -> Messages TestAgent
        \
         \
Address Book
    -> Contacts TestAgent
          \
           \
        Onboarding TestAgent bindings
                 |
                 v
        application composition
                 |
                 v
      ImmutableTestAgentResolver
                 |
                 v
              Presence
                 |
                 v
             TestStep
```

Presence must not know which feature supplied any resolved Agent.

---

## Hard constraints

Do not in Slice 4:

- change `presence.db`;
- change generic TestStep mechanics;
- change TestAgentId representation;
- change resolver semantics;
- add Agent supertype;
- add ActionStep;
- generalize OpenFdaSettingsStep;
- change onboarding Schedule topology;
- change onboarding copy;
- integrate Presence into production `OnboardingGate`;
- extend onboarding with another blocker;
- add Archive Ingestion bindings.

---

## Success criterion

At the end of this slice:

```text
Onboarding
    owns:
        onboarding TestAgentIds
        onboarding TestAgent implementations/adapters
        onboarding binding contribution
        onboarding Schedule meaning

application composition
    owns:
        combining TestAgentBinding contributions
        constructing ImmutableTestAgentResolver

Presence
    owns:
        generic resolver use
        generic TestStep execution
```

And if Presence is asked:

> Which feature supplies `onboarding.contacts-source-readable`?

its correct answer remains:

```text
I don't know.
```

Stop after Slice 4 and report back before any ActionStep work or production onboarding cutover.
