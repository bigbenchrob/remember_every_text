---
tier: project
scope: generic-test-step-agent-resolution
owner: agent-per-project
last_reviewed: 2026-08-12
source_of_truth: proposal
links:
  - ./01-CURRENT-OWNERSHIP-INVENTORY.md
  - ./02-TARGET-OWNERSHIP-PROPOSAL.md
  - ./03-FIRST-MECHANICAL-MOVES.md
tests: []
---

# Generic TestStep And Opaque Agent Resolution Proposal

## 1. Problem Now Proven By The Repository

Presence currently reconstructs three specialist Steps by injecting three
specialist authorities into `DriftPresenceScheduleRepository`:

- `FdaTestStep` receives `MessagesSourceReadinessAuthority`;
- `ContactsSourceReadinessStep` receives
  `ContactsSourceReadinessAuthority`;
- `OpenFdaSettingsStep` receives `FdaSettingsOpeningAuthority`.

The database repeats those meanings through specialist Step type strings and
subtype tables. The repository repeats them in insertion, loading, subtype
integrity, equality, and definition-validation branches. The repository
provider consequently requires all three specialist capabilities.

This works, but generic workflow reconstruction now knows onboarding meaning.
Adding an Archive Folder test in the same style would require another Step
class, table, repository branch, provider dependency, and migration inside
Presence. The repetition is real and the boundary failure is now demonstrated.

## 2. Blank-Stare Invariant

> Ask Presence, “What does the FDA test do?” and Presence should look blank.

Presence may know that a `TestStep` invokes an opaque Test Agent and maps a
Boolean result to one of two destinations. It must not know what is tested,
which source is read, why one result is desirable, or what remediation follows.

An Agent identity may be human-readable for diagnostics. Readability does not
grant Presence permission to interpret it.

## 3. Why TestStep Is Now Earned

`FdaTestStep` and `ContactsSourceReadinessStep` have both been implemented,
persisted, reconstructed, tested, and manually exercised. Their mechanics are
identical:

```text
invoke one specialist
    -> receive Boolean fact
    -> true destination or false destination
```

Only the specialist and destination choices differ. A generic Boolean
`TestStep` removes proven duplication without predicting another result model.
No multi-valued test, retry policy, polling behavior, or result bag is earned.

## 4. What An Agent Means

An Agent is a specialist invoked by a Step to perform domain-specific work or
establish a fact.

For this proposal, a **Test Agent** has one responsibility:

```text
evaluate its fully configured factual question
    -> Future<bool>
```

The Agent owns or receives its specialist dependencies. It knows nothing about
Schedules, Trips, Steps, routing, destinations, or remediation. An adapter may
live with a workflow owner when that owner, rather than the underlying
specialist, owns the interpretation of specialist output as a Boolean fact.

“Agent” remains an architectural role. This proposal earns one narrow
`TestAgent` contract, not a general Agent framework.

## 5. Requirements Imposed By One Shared `presence.db`

The database may contain definitions contributed by Onboarding, Archive
Ingestion, and future workflow owners. Therefore:

1. Agent identity must be globally durable within the shared definition store.
2. A Test Agent may be reused by several Test Steps and Schedules.
3. Opening `presence.db` must not require this process to implement every Agent
   declared by every workflow.
4. A requested Schedule must not become executable unless all Test Agents it
   uses can be resolved by this process.
5. Specialist configuration such as file paths, SQL, privacy-pane identifiers,
   and Contacts discovery rules must remain outside `presence.db`.
6. Persisted identity and runtime implementation must remain distinct.

Resolution is therefore **Schedule-scoped**, not a global database-admission
test. An application may inspect or execute one known workflow without being
able to execute unrelated definitions stored beside it.

## 6. Candidate Persisted Agent Identity Designs

### Option A: Numeric `AgentDefinitionId`

```text
test_agent_definitions
    id INTEGER PRIMARY KEY
    diagnostic_name TEXT
```

**Strengths**

- stable across diagnostic renames;
- consistent with current numeric Schedule, Trip, and Step identities;
- compact foreign keys;
- straightforward typed Dart wrapper.

**Weaknesses**

- requires central allocation across independent workflow owners;
- `Agent 27` is poor evidence during database inspection;
- code and data need a second name to explain the number;
- accidental numeric collisions are discovered only at composition or insert.

### Option B: Stable String Key

```text
test_agent_definitions
    id TEXT PRIMARY KEY
```

Example owner-authored identities might be:

```text
onboarding.messages-source-readable
onboarding.contacts-source-readable
```

**Strengths**

- durable and directly diagnosable;
- owner qualification avoids a central numeric allocator;
- one value serves as persisted identity, resolver key, and test fixture key;
- easy to use across multiple Schedules.

**Weaknesses**

- the key must be treated as immutable identity, never editable display copy;
- careless renaming becomes a migration;
- a plain `String` would provide insufficient type safety.

### Option C: Scoped Or Versioned Composite Identity

```text
owner_scope + local_key + contract_revision
```

**Strengths**

- makes ownership and semantic revisions explicit;
- reduces cross-owner collision risk;
- can distinguish incompatible meanings over time.

**Weaknesses**

- introduces composite keys and foreign keys before owner-scoped queries or
  independent contract revisions have been required;
- asks Presence to carry fields it does not use;
- makes authoring and diagnostics more cumbersome than one opaque identity.

### Option D: Numeric Identity Plus Stable String Key

This combines rename safety with readability, but it creates two candidates for
authority and requires rules for disagreement. The current system does not need
both.

### Recommendation

Use a typed `TestAgentId` whose persisted representation is one stable,
owner-qualified string. Presence validates only that the value is present; it
does not parse owner, meaning, or version components.

The key is immutable. A materially different factual contract receives a new
identity rather than changing the implementation behind an old identity.
Explicit version suffixes may be used when a real semantic revision occurs;
they need not be mandatory syntax today.

This choice is more diagnosable than a global integer and less elaborate than a
composite identity. The Dart wrapper, rather than the storage primitive,
provides compile-time distinction from Schedule, Trip, Step, and Action Agent
identities.

## 7. Candidate Runtime Resolution Designs

### Candidate 1: Repository Resolution Through An Explicit Resolver

```text
application composition
    -> immutable TestAgentResolver
        -> Drift Presence repository
            -> persisted TestAgentId
                -> TestAgent
                    -> executable TestStep
```

The repository remains generic. It knows only the Test Agent contract and
opaque identity. Missing binding is detected while the requested executable
Schedule is reconstructed.

This is the recommended design.

### Candidate 2: Scheduler Resolution At Step Execution

```text
repository -> unbound TestStep
scheduler -> global Agent lookup -> execute
```

This delays configuration failure until the user reaches the Step, makes the
Scheduler inspect specialist Step mechanics, and encourages an ambient service
locator. It is rejected.

### Candidate 3: Pure Definition Load Followed By A Separate Binding Pass

```text
repository -> unbound Schedule definition
composition binder -> executable Schedule
```

This cleanly separates persistence from execution and may eventually benefit a
definition editor. Today it introduces parallel bound/unbound models and a new
invalid intermediate state solely for two Boolean tests. It is not recommended
for the first implementation.

### Candidate 4: Continue Specialized Constructor Injection

This is the current design. It is explicit, but every new factual test changes
Presence. It fails the blank-stare invariant and is rejected as the permanent
boundary.

## 8. Recommended Agent Contract

The smallest truthful contract is conceptually:

```dart
abstract interface class TestAgent {
  Future<bool> evaluate();
}
```

No Step, Trip, Schedule, context bag, destination, retry policy, or diagnostic
callback is supplied. Dependencies such as source paths or specialist
repositories are injected when the concrete Agent or adapter is composed.

`evaluate` is preferable to `run` because the proven role establishes a fact;
it does not imply general command execution.

The Agent identity does not need to be a property of the Agent. An explicit
binding associates one `TestAgentId` with one runtime `TestAgent` at application
composition.

## 9. Recommended Resolver And Composition Boundary

The generic Presence contract is conceptually:

```dart
abstract interface class TestAgentResolver {
  TestAgent resolve(TestAgentId id);
}
```

Resolution should be synchronous. Runtime Agents may contain asynchronous
dependencies, but those dependencies are prepared before constructing the
immutable resolver. Agent evaluation remains asynchronous.

The resolver should:

- be immutable after construction;
- reject duplicate IDs during construction;
- return only `TestAgent`, making wrong-kind resolution unrepresentable;
- fail with an explicit configuration error when an ID is absent;
- know no Schedule, Step, routing, or workflow-owner identities.

Application composition owns the set of bindings. Each workflow owner supplies
its bindings; the application combines them and injects one resolver into the
generic Presence repository. This is registry-like data, but no mutable global
registration API is required. **Resolver** is the more accurate permanent
name.

The repository resolves only Agents referenced by the requested Schedule. It
must not reject opening the shared database because an unrelated workflow's
Agent is unavailable.

For a new run, executable definition validation must occur before the run row
or `schedule_run_started` trace event is written. An unresolved Agent therefore
cannot create or advance a run.

## 10. Recommended Generic TestStep

A `TestStep` knows:

- its ordinary Step identity and name;
- one opaque `TestAgentId`;
- one already-resolved `TestAgent`;
- nullable true and false destination Trip identities.

Completion is mechanically:

```text
result = await agent.evaluate()
return result ? trueDestination : falseDestination
```

A null arm retains the current default-next routing semantics. The Test Step
must remain terminal within its Trip, matching both proven test types.

The runtime Agent is required when an executable `TestStep` is constructed.
There is no executable “unbound TestStep” state.

## 11. Recommended Database Schema

The bounded generic schema is:

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

Foreign keys should connect:

- `test_step_definitions.step_definition_id` to `step_definitions.id`;
- `test_step_definitions.test_agent_id` to `test_agent_definitions.id`;
- each non-null destination to `trip_definitions.id`.

`test_agent_definitions` is justified even though it initially contains only an
ID. One row means that a durable Boolean Agent identity has been declared in
the definition grammar. It provides reuse, inventory, and foreign-key
integrity. It does **not** claim that this process has a runtime implementation.

No specialist paths, SQL, platform settings, feature names, configuration
payloads, or runtime class names belong in these tables.

## 12. SQLite Versus Runtime Integrity

SQLite can enforce:

- allowed base Step type;
- one generic Test subtype row per Step identity;
- declared Test Agent identity exists;
- destination Trip definitions exist;
- primary-key and foreign-key integrity.

The repository must enforce:

- base type and subtype row agree;
- exactly one active subtype row exists;
- both destinations belong to the containing Schedule when non-null;
- a Test Step is terminal in its Trip;
- reused Step definitions are structurally identical;
- every Test Agent used by the requested executable Schedule resolves;
- executable validation precedes run creation or advancement.

Application composition must enforce:

- no duplicate runtime binding for one `TestAgentId`;
- each binding supplies a `TestAgent` of the required Boolean kind;
- the concrete Agent receives its truthful specialist dependencies.

SQLite cannot establish runtime implementation availability, and the resolver
must not pretend that a persisted declaration proves it.

## 13. Onboarding Walkthrough: Messages Test

```text
Conversation Graph specialist
    SqliteChatDbSourceProbeReader
        -> truthful protected-source query capability

Onboarding
    composes Messages-readability TestAgent adapter
    binds it to onboarding.messages-source-readable
    authors TestStep with true/false Trip destinations

Presence
    persists opaque Agent identity and routing geometry
    resolves the identity while loading this Schedule
    invokes TestAgent.evaluate()
    routes from the Boolean only
```

Presence cannot identify `chat.db`, SQLite, Full Disk Access, or the meaning of
`true`. Onboarding owns the decision that failure leads to FDA guidance.

## 14. Onboarding Walkthrough: Contacts Test

```text
Address Book feature
    AddressBookFolderRepository
        -> source discovery and readability result

Onboarding
    adapts that result to one Boolean TestAgent
    binds it to onboarding.contacts-source-readable
    authors TestStep with confirmation/remediation destinations

Presence
    persists the opaque identity
    resolves and invokes the TestAgent
    routes from the Boolean only
```

Presence cannot explain Address Book folders, viable-source selection, or the
meaning of an unavailable Contacts source.

## 15. Future Consumer Walkthrough: Archive Ingestion

Archive Ingestion could later contribute:

```text
TestAgentId
    archive-ingestion.archive-folder-exists

TestStep
    true  -> inspect archive
    false -> request folder
```

Its feature composes the Agent and authors the destinations. Presence requires
no new Step type, table, repository branch, provider parameter, or Scheduler
behavior. This is generalization by composition rather than by adding Archive
Ingestion knowledge to Presence.

## 16. OpenFdaSettingsStep And Why It Is Not Generalized

`OpenFdaSettingsStep` performs an action and returns no factual result. It is
not a Test Step and must not be forced into one.

One proven Settings-opening operation is insufficient evidence for a permanent
generic `ActionStep`, especially before action completion and failure semantics
are examined independently. `OpenFdaSettingsStep` should remain explicit
transitional debt for now.

Consequently, generic Test Step adoption removes Presence's knowledge of FDA
and Contacts **tests**, but does not yet make all of Presence domain-neutral.
Presence will still know the FDA Settings action until a separately approved
Action Step or another truthful ownership boundary is earned.

## 17. Migration Strategy For Existing Definitions And History

The safest executable migration is additive and identity-preserving:

1. Add the generic Test Agent and Test Step tables.
2. Declare stable Test Agent identities for the two existing factual tests.
3. In one explicit transaction, copy each FDA and Contacts test row into a
   generic Test row while preserving its `step_definition_id` and destinations.
4. Change those base Step type values to `test`.
5. Retain the old specialist subtype tables and rows as frozen migration
   evidence; stop writing or consulting them for active reconstruction.
6. Preserve Schedule, Trip, Step, occurrence, run, and execution-trace IDs
   unchanged.

This allows an active run to resume because all occurrence and checkpoint
references remain stable. It does not silently discard the former persisted
representation. The schema-version migration and retained rows document the
normalization.

Creating an entirely new Schedule while keeping the old specialized loader
would preserve rows but make onboarding-specific reconstruction permanent.
Deleting or rewriting the old subtype rows would unnecessarily erase evidence.
Both alternatives are rejected.

The one-time legacy mapping necessarily recognizes the former storage types.
That knowledge must be quarantined in the migration and must not survive in the
generic domain, resolver, active repository branches, or provider signature.

The retained `OpenFdaSettingsStep` remains outside this Test migration.

## 18. Failure Semantics

### Persisted Agent Has No Runtime Binding

Loading the requested executable Schedule fails with an explicit configuration
error naming the opaque Agent and affected Step. No new run or trace event is
created, and no existing run advances.

### Duplicate Runtime Bindings

Immutable resolver construction fails before the repository is used. “Last
registration wins” is prohibited.

### Wrong Agent Kind

The resolver accepts and returns only `TestAgent`. A non-Test Agent cannot be
registered through this contract.

### Agent Throws

The error propagates as Step execution failure. The Step is not recorded as
completed and the Trip is not checkpointed. Existing restart semantics retry
the Trip from its beginning. No general exception-routing language is added.

### Agent Returns Normally

The Test Step selects the configured true or false arm. A null arm delegates to
the existing default-next rule.

An unavailable runtime binding is a configuration defect. A specialist
truthfully returning `false` is an ordinary workflow fact. These must never be
collapsed into the same result.

## 19. Rejected Alternatives

### One Step Type Per Domain Fact

Rejected because every new fact changes generic Presence schema, code, and
provider dependencies.

### Persist A Runtime Class Or Provider Name

Rejected because runtime symbols are unstable implementation details and would
couple persistence to Flutter/Riverpod composition.

### Persist Specialist Configuration In Presence

Rejected because paths, SQL, privacy panes, and feature configuration belong to
specialist owners and may vary by environment.

### Mutable Global Agent Registry

Rejected because order-dependent registration, replacement, and ambient lookup
make authority difficult to reason about and test.

### Resolve Only When The Step Is Reached

Rejected because an invalid Schedule could start, checkpoint, and communicate
with the user before discovering that it cannot execute.

### Validate Every Agent In `presence.db` At Startup

Rejected because one shared database may contain workflows this process does
not execute. Only the requested Schedule must be executable here.

## 20. Proposed Permanent Ownership Map

```text
lib/essentials/presence/
    owns TestStep, TestAgentId, TestAgent, TestAgentResolver
    owns generic Test persistence and reconstruction
    owns Boolean-to-destination mechanics

lib/essentials/onboarding/
    owns onboarding Agent identities and runtime bindings
    owns onboarding Schedule composition, copy, and destinations
    owns adapters where onboarding defines the Boolean interpretation

specialist owners/
    own chat.db probing, Contacts discovery, platform operations,
    and other factual expertise

application composition/
    combines explicit Test Agent bindings
    constructs the immutable resolver
    injects it into Presence

presence_iteration_simple/
    remains a development client and inspection harness
```

The generic Presence provider accepts one `TestAgentResolver`, not an expanding
list of workflow-specific authorities.

## 21. Implementation Slices If Approved

1. **Generic contracts only:** add `TestAgentId`, `TestAgent`, immutable
   resolver behavior, and focused tests. No schema or Step change.
2. **Additive schema:** add generic Test Agent/Test Step tables and migration
   tests, including preserved IDs and legacy rows.
3. **Generic reconstruction:** add `TestStep`; replace the two active specialist
   repository branches and specialized provider parameters with the resolver.
   Ensure executable validation precedes run mutation.
4. **Onboarding composition:** define the two stable Agent identities, adapt
   current specialists, and author the existing Schedule with generic Test
   Steps without changing copy or routes.
5. **Retire active test-specific machinery:** remove the two specialized domain
   Steps and authority contracts from active code while retaining frozen
   migration evidence. Do not touch `OpenFdaSettingsStep`.
6. **Behavior verification:** rerun persistence, routing, restart, trace,
   Mermaid, live visualization, and both manual readiness loops.

Each slice should be independently reviewable. No slice should introduce an
Action Step or production onboarding cutover.

## 22. Questions Requiring Human Decision

1. Approve a typed, owner-qualified string `TestAgentId` rather than a global
   numeric ID?
2. Approve `test_agent_definitions` as a declaration/FK table even though its
   first version contains only identity?
3. Approve explicit immutable resolver composition and Schedule-scoped
   fail-fast resolution?
4. Approve the additive, identity-preserving migration that updates base type
   values while retaining old subtype rows as frozen evidence?
5. Accept `OpenFdaSettingsStep` as explicit transitional debt until a generic
   Action Step is independently earned?

## Concise Answers

**What does Presence know?**

It knows generic Test execution, opaque Agent identity, Boolean routing, and
definition integrity.

**What does a TestStep know?**

It knows which opaque Test Agent to invoke and where true or false routes.

**What does an Agent know?**

It knows how to establish one domain fact. It knows nothing about workflow
geometry.

**Who maps persisted Agent identity to runtime Agent?**

An immutable `TestAgentResolver`, populated explicitly by application
composition from workflow-owner bindings and injected into Presence.

**What happens when the Agent cannot be resolved?**

The requested Schedule cannot become executable or start/advance a run.

**Can Presence explain what an FDA test does?**

No.
