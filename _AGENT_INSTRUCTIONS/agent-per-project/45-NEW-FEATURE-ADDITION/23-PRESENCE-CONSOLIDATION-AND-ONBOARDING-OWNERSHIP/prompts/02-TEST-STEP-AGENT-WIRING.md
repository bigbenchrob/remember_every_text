Create:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md`

This is a **design-only architectural pass**.

Do not implement the generic `TestStep` yet.

Do not change `presence.db`, Step classes, repositories, providers, migrations, routing, Trip, Scheduler, or production onboarding.

The purpose of this pass is to solve the one remaining load-bearing boundary exposed by the ownership consolidation:

> How can Presence persist and reconstruct a generic Test Step that invokes an opaque Agent, while remaining completely ignorant of what that Agent actually does?

---

## Read first

Read the current consolidation package in order:

- `00-START-HERE.md`
- `01-CURRENT-OWNERSHIP-INVENTORY.md`
- `02-TARGET-OWNERSHIP-PROPOSAL.md`
- `03-FIRST-MECHANICAL-MOVES.md`

Then inspect the current implementation involved in specialist Step reconstruction, especially:

```text
lib/essentials/presence/domain/entities/step.dart

lib/essentials/presence/domain/services/
    messages_source_readiness_authority.dart
    contacts_source_readiness_authority.dart
    fda_settings_opening_authority.dart

lib/essentials/presence/infrastructure/data_sources/local/presence_database.dart

lib/essentials/presence/infrastructure/repositories/
    drift_presence_schedule_repository.dart

lib/essentials/presence/application/
    presence_schedule_repository_provider.dart
```

Also inspect the current onboarding-owned Schedule and adapters under:

```text
lib/essentials/onboarding/
```

and the specialist implementations currently used by the two proven factual tests:

```text
ChatDbSourceProbeReader / SqliteChatDbSourceProbeReader

AddressBookFolderRepository
```

The current ownership work established that Presence still contains onboarding-specific Step and reconstruction knowledge, while the rest of the workflow ownership has moved cleanly to Onboarding.

---

## Governing invariant: the blank-stare test

Use this as a hard architectural test:

> Ask Presence, “What does the FDA test do?” and Presence should look blank.

Permanent Presence may know:

```text
This is a TestStep.
It invokes Agent 27.
If the result is true, route here.
If the result is false, route there.
```

Presence must not know:

```text
Agent 27 reads chat.db.
Agent 31 discovers Address Book sources.
This Step is about FDA.
This Step is about Contacts.
This test means source readiness.
```

Those meanings belong outside Presence.

The current target boundary is:

```text
Presence owns execution grammar.
Onboarding owns onboarding meaning.
Specialists own factual expertise and operations.
```

---

## Proven evidence for generic TestStep

We now have two real, implemented, manually tested Step types with the same mechanical structure:

```text
FdaTestStep
    ask specialist for Boolean
    true  -> configured destination
    false -> configured destination

ContactsSourceReadinessStep
    ask specialist for Boolean
    true  -> configured destination
    false -> configured destination
```

These are no longer speculative examples.

The design pass should determine whether this evidence is sufficient to replace them with one generic:

```text
TestStep
```

whose persisted data is conceptually:

```text
step_definition_id
agent_definition_id
true_destination_trip_definition_id nullable
false_destination_trip_definition_id nullable
```

Do not assume these exact column names or table shapes are correct; evaluate them.

---

## Agent architectural role

Start from this definition:

> An Agent is a specialist invoked by a Step to perform domain-specific work or establish a fact.

For this proposal, focus only on the kind of Agent needed by a Boolean `TestStep`.

Conceptually, the smallest contract may be something like:

```dart
abstract interface class TestAgent {
  Future<bool> run();
}
```

But do not accept that shape automatically.

Evaluate what the smallest truthful permanent Agent contract should be.

Important:

- concrete Agent implementations remain with the feature/essential that owns the expertise;
- Presence may own the generic concept or interface needed to invoke them;
- Presence must not import the specialist implementation;
- an Agent must know nothing about Trips, Schedules, routing, or destinations.

Current specialist candidates include the Messages source probe and Address Book repository.

---

## Single database requirement

Treat this as an explicit architectural requirement:

> `presence.db` is one shared workflow-definition database for Onboarding, Archive Ingestion, and future Presence consumers.

It is acceptable and desirable for it to contain definitions contributed by several workflow owners.

That does **not** make Presence the semantic owner of those workflows.

Presence owns the persistence grammar and reconstruction machinery.

A generic persisted Test Step therefore needs enough stored information to say:

```text
This Step is a test.
Use Agent X.
True goes here.
False goes there.
```

without encoding what Agent X means.

---

## Core design question: opaque Agent identity

Determine the smallest durable identity model that lets a persisted Test Step refer to the specialist it needs.

Evaluate at least these possibilities:

### Option A — numeric `AgentDefinitionId`

For example:

```text
agent_definitions
    id
```

and:

```text
test_step_definitions
    step_definition_id
    agent_definition_id
    true_destination_trip_definition_id
    false_destination_trip_definition_id
```

The application composition layer maps the opaque Agent ID to a runtime implementation.

### Option B — stable string key

For example:

```text
agent_key = "messages-source-readable"
```

Presence persists and transports the opaque key but does not interpret it.

Application composition resolves the key.

### Option C — typed/scoped identity pair

For example, a generic opaque persisted identity with some namespace/version mechanism.

### Option D — another design you judge cleaner

Compare the designs against:

- persistence stability;
- readability/debuggability;
- rename safety;
- migration cost;
- compile-time safety;
- missing registration behavior;
- future multiple workflow owners;
- testability;
- ability to preserve Presence semantic ignorance.

Do not choose based on aesthetic preference alone.

---

## Where Agent identity should be resolved

This is the most important part of the proposal.

Today, the Presence repository directly injects specialized authorities when reconstructing specialized Step types.

That must disappear if Presence becomes generic.

Evaluate where the resolution should happen.

Possible shapes include:

```text
Presence repository
    reconstructs TestStep definition
    asks AgentResolver for opaque Agent ID
    receives TestAgent
```

or:

```text
Presence repository
    reconstructs persisted generic Step data

higher composition layer
    binds runtime Agent before execution
```

or another arrangement.

For each candidate, answer:

- Does Presence remain ignorant of domain meaning?
- Does the repository stay generic?
- Can reconstruction fail mechanically when the Agent is unavailable?
- Is the failure visible before execution?
- Can tests provide deterministic Agents?
- Does application composition retain ownership of specialist registration?
- Does this create hidden service-locator behavior?

Prefer explicit dependency flow over ambient global lookup.

---

## Agent Resolver / Registry question

We previously avoided a registry because it was speculative.

Now a persisted generic TestStep creates a real requirement:

> Given opaque persisted Agent identity X, obtain the corresponding runtime Agent.

Determine whether that genuinely earns a small permanent mechanism such as:

```text
TestAgentResolver
```

or:

```text
AgentRegistry
```

Do not use the word “registry” unless the behavior actually warrants it.

Evaluate the smallest interface.

For example:

```dart
abstract interface class TestAgentResolver {
  TestAgent resolve(AgentDefinitionId id);
}
```

or asynchronous/error-returning equivalent.

Consider:

- what happens when no Agent is registered;
- whether duplicate registrations are possible;
- whether validation should occur when a Schedule is loaded rather than when the Step executes;
- whether the resolver is app-lifetime composition;
- whether the resolver should know Schedule/Step identities;
- whether Agent implementations may require their own dependencies.

The resolver must not know routing semantics.

---

## Persistence model

Evaluate a generic schema that removes onboarding meaning from Presence.

Current boundary pressure includes:

- specialized Step classes;
- specialized subtype tables;
- specialized repository branches;
- specialized provider dependencies.

Propose what the generic schema would look like.

At minimum discuss:

```text
step_definitions
test_step_definitions
agent identity persistence
```

Questions:

1. Is an `agent_definitions` table actually necessary?
2. If yes, what does one row mean?
3. Does it contain anything besides opaque identity and perhaps a diagnostic name?
4. Should Agent definitions be reusable across many Test Steps?
5. Can one Agent appear in onboarding and archive-ingestion Schedules?
6. Does Presence ever need to load Agent metadata other than identity?
7. What prevents a non-Test Step from referring to a Test Agent?
8. What integrity can SQLite enforce?
9. What integrity must repository/composition validation enforce?

Do not persist specialist configuration in Presence unless there is a demonstrated generic need.

For example, SQL paths, Contacts paths, FDA pane identifiers, etc. must not enter `presence.db` merely because an Agent uses them.

---

## Workflow-owner contribution

Explain how Onboarding would define a generic Test Step after this change.

Conceptually:

```text
Onboarding authors:
    Step definition:
        type = test
        agent = Messages Source Readiness Agent
        true destination = Contacts readiness Trip
        false destination = FDA guidance Trip
```

Presence stores and executes the generic geometry.

The Messages specialist remains outside Presence.

Do the same walkthrough for Contacts.

Then briefly show how Archive Ingestion could someday define:

```text
TestStep
    agent = Archive Folder Exists Agent
```

without any Presence architecture change.

This is important evidence that the design generalizes by composition rather than by adding workflow-specific code to Presence.

---

## `OpenFdaSettingsStep`

Do not solve this by forcing it into `TestStep`.

Analyze it separately.

Ask:

> Is `OpenFdaSettingsStep` evidence for another generic Step family such as ActionStep, or should it remain an onboarding-specific Step for now?

Do not implement or fully design a generic ActionStep unless the current evidence genuinely requires it.

It is acceptable to conclude:

```text
TestStep is now earned.
Generic ActionStep is not yet earned.
```

If `OpenFdaSettingsStep` remains onboarding-specific temporarily, explain how that affects the goal of making Presence completely domain-neutral.

---

## Migration and historical preservation

Current `presence.db` has historical definitions and runs using:

```text
FdaTestStep
ContactsSourceReadinessStep
OpenFdaSettingsStep
```

The proposal must explain how a future implementation can migrate toward generic Test Steps without destroying or silently rewriting historical evidence.

Evaluate options such as:

- migrate subtype rows to generic Test rows while preserving StepDefinition IDs;
- preserve old subtype tables as historical compatibility;
- create new Schedule definitions only and leave old definitions loadable;
- explicit schema migration of old definitions to generic semantics.

Remember the established rule:

> Definitions and run history are historical evidence and should not be casually rewritten.

Recommend the safest approach.

No migration should be implemented in this design pass.

---

## Failure and validation semantics

The permanent design needs a truthful answer to:

```text
presence.db says:
    TestStep -> Agent 27

runtime says:
    Agent 27 is unavailable
```

Determine what should happen.

Consider:

- Schedule load failure;
- run start failure;
- Step execution failure;
- explicit invalid-definition state.

Prefer mechanical rejection over delayed surprises where practical.

Also consider:

```text
Agent exists but wrong kind
Agent registered twice
Agent throws
Agent returns normally
```

Keep this bounded. Do not design a general workflow exception language.

---

## Compare candidate architectures

Present at least 2–3 credible concrete architectures and compare them.

For each, include a simple diagram.

Evaluate them using the project principles:

```text
Who should be blissfully ignorant of this?

Can an invalid state be made mechanically impossible?

Does complexity remain local?

Is the global execution model still simple?

Does the abstraction exist because real repetition earned it?

Can a developer understand the dependency path six months from now?
```

Reject designs explicitly where appropriate.

---

## Desired likely end-state

Do not treat this as predetermined, but assess whether the clean target resembles:

```text
lib/essentials/presence/
    domain/
        entities/
            schedule.dart
            trip.dart
            step.dart
            test_step.dart
            agent_definition_id.dart

        services/
            test_agent.dart
            test_agent_resolver.dart

    infrastructure/
        presence_database.dart
        drift_presence_schedule_repository.dart

    application/
        presence_scheduler...
        repository provider...
```

while:

```text
lib/essentials/onboarding/
    owns Schedule composition
    owns onboarding copy
    chooses which Agent identity each TestStep uses

specialist owners/
    provide concrete TestAgent implementations or adapters
```

The exact file layout is secondary to the ownership.

---

## Explicit non-goals

Do not design or implement:

- generic result bags;
- multi-valued Test outcomes beyond Boolean;
- asynchronous event subscriptions;
- polling;
- retry framework;
- nested workflows;
- child Journey notification;
- current-Step persistence;
- distributed Agent discovery;
- plugin loading;
- dynamic code loading;
- network Agent marketplace;
- arbitrary reflection;
- production onboarding cutover;
- Archive Ingestion implementation.

If some future capability might need these, note it briefly without solving it.

---

## Deliverable structure

Create:

`04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md`

with these sections:

1. **Problem now proven by the repository**
2. **Blank-stare invariant**
3. **Why TestStep is now earned**
4. **What an Agent means**
5. **Requirements imposed by one shared presence.db**
6. **Candidate persisted Agent identity designs**
7. **Candidate runtime resolution designs**
8. **Recommended Agent contract**
9. **Recommended resolver/composition boundary**
10. **Recommended generic TestStep**
11. **Recommended database schema**
12. **SQLite versus runtime integrity**
13. **Onboarding walkthrough: Messages test**
14. **Onboarding walkthrough: Contacts test**
15. **Future consumer walkthrough: Archive Ingestion**
16. **OpenFdaSettingsStep and why it is or is not generalized**
17. **Migration strategy for existing definitions and history**
18. **Failure semantics**
19. **Rejected alternatives**
20. **Proposed permanent ownership map**
21. **Implementation slices if approved**
22. **Questions requiring human decision**

End with concise answers to:

```text
What does Presence know?

What does a TestStep know?

What does an Agent know?

Who maps persisted Agent identity to runtime Agent?

What happens when the Agent cannot be resolved?

Can Presence explain what an FDA test does?
```

The final answer to the last question should be:

```text
No.
```

If your proposed architecture cannot honestly give that answer, reject it.

---

## Verification for this pass

This is documentation/design only.

Do not modify application source, generated files, tests, databases, or build configuration.

Run only documentation/link checks and `git diff --check` as appropriate.

Stop after the proposal and report back for human review before implementation.
