Implement **Slice 3 only** from:

`04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md`

Slices 1 and 2 are complete.

Current state:

```text
Slice 1
    TestAgentId
    TestAgent
    ImmutableTestAgentResolver

Slice 2
    presence.db v7
    test_agent_definitions
    test_step_definitions
    prepared migrated generic rows
```

The active repository still reconstructs:

```text
FdaTestStep
ContactsSourceReadinessStep
```

and the current v7 compatibility state deliberately leaves those specialized base discriminators active.

This slice performs the **generic runtime cutover**.

The goal is:

```text
persisted type = test
    -> repository reads opaque TestAgentId
    -> resolver returns TestAgent
    -> repository constructs generic TestStep
    -> TestStep evaluates Agent
    -> Boolean selects configured destination
```

without Presence learning what the Agent actually tests.

---

## Read first

Re-read:

- `04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md`
- `05-GENERIC-TEST-AGENT-CONTRACTS-IMPLEMENTATION.md`
- `06-GENERIC-TESTSTEP-ADDITIVE-SCHEMA-IMPLEMENTATION.md`

Inspect the current:

```text
step.dart
drift_presence_schedule_repository.dart
presence_schedule_repository_provider.dart
presence_database.dart
required_sources_readiness_schedule.dart
current FDA/Contacts authority contracts
current onboarding adapters/providers
```

Do not rely only on the proposal. Work from the current repository after Slices 1 and 2.

---

## 1. Add generic executable `TestStep`

Replace the duplicated Boolean test mechanics with one generic Presence Step.

Conceptually:

```dart
final class TestStep extends Step {
  final TestAgentId testAgentId;
  final TestAgent testAgent;
  final TripDefinitionId? trueDestinationTripDefinitionId;
  final TripDefinitionId? falseDestinationTripDefinitionId;

  @override
  Future<TripDefinitionId?> complete() async {
    final result = await testAgent.evaluate();

    return result
        ? trueDestinationTripDefinitionId
        : falseDestinationTripDefinitionId;
  }
}
```

Use project conventions for naming and file placement.

The runtime `TestStep` must know only:

```text
its ordinary Step identity/name
opaque TestAgentId
resolved TestAgent
true destination
false destination
```

It must know nothing about:

```text
FDA
Messages
chat.db
Contacts
Address Book
Onboarding
```

A null destination arm retains existing default-next behavior.

Keep the existing rule that a Test Step is terminal in its Trip.

---

## 2. Inject the resolver into generic Presence reconstruction

Update the Presence repository/provider boundary so generic persisted Test Steps are reconstructed using:

```text
TestAgentResolver
```

instead of workflow-specific authorities.

The intended dependency path is:

```text
application composition
    -> ImmutableTestAgentResolver
        -> Presence repository
            -> persisted TestAgentId
                -> TestAgent
                    -> executable TestStep
```

The repository may know:

```text
type = test
TestAgentId
TestAgentResolver
TestAgent
true/false destinations
```

It must not know:

```text
MessagesSourceReadinessAuthority
ContactsSourceReadinessAuthority
```

for generic test reconstruction.

---

## 3. Schedule-scoped fail-fast resolution

Preserve the approved rule:

> A requested Schedule must not become executable unless every Test Agent used by that Schedule can be resolved by this process.

Resolution should occur while reconstructing/validating the requested executable Schedule.

Do not:

```text
open presence.db
-> require every Agent in the database
```

Only Agents referenced by the requested Schedule matter.

Before a **new run** begins:

```text
load requested Schedule
resolve all Test Agents used by that Schedule
validate executable definition
only then create ScheduleRun / trace start
```

For an **existing run**:

```text
load its Schedule
resolve required Test Agents
validate executable definition
only then allow advancement
```

If an Agent is missing:

- fail with the explicit missing-binding configuration error;
- do not create a new ScheduleRun;
- do not append `schedule_run_started`;
- do not advance an existing run;
- do not reinterpret the failure as `false`.

---

## 4. Activate the prepared generic rows

Slice 2 already prepared:

```text
test_agent_definitions
test_step_definitions
```

for the existing FDA and Contacts tests while preserving their Step IDs and route arms.

Now perform the deferred discriminator cutover atomically with generic reconstruction.

Update the migrated existing test Step base types:

```text
fda_test
contacts_source_readiness
```

to:

```text
test
```

while preserving:

```text
Schedule IDs
Trip IDs
StepDefinition IDs
occurrence IDs
ScheduleRun IDs
currentTripOccurrenceId
trace IDs/sequences
true/false destinations
```

Do not create replacement Schedule definitions merely to avoid the migration.

---

## 5. Frozen legacy subtype rule

Retain:

```text
fda_test_step_definitions
contacts_source_readiness_step_definitions
```

as frozen migration evidence.

After cutover:

```text
step_definitions.type = test
    -> test_step_definitions is active truth
    -> old specialized subtype rows are inactive evidence
```

Implement discriminator-scoped subtype integrity exactly as documented in Slice 2.

Do not let retained legacy rows trigger:

```text
conflicting subtype
multiple active subtype
```

errors.

Do not delete or rewrite the frozen legacy rows.

---

## 6. Remove active specialized test reconstruction

Retire the **active** repository branches for:

```text
FdaTestStep
ContactsSourceReadinessStep
```

from ordinary reconstruction.

Do not leave fallback logic such as:

```text
if test -> generic
else if fda_test -> specialized
else if contacts_source_readiness -> specialized
```

as permanent active behavior after migration.

Legacy knowledge belongs only in migration/history compatibility.

After the cutover, the active generic repository should see:

```text
type = test
```

and nothing about the domain meaning of the test.

---

## 7. Provider signature cleanup

The generic Presence repository/provider should no longer require expanding workflow-specific test authorities.

Remove active generic Presence dependencies on:

```text
MessagesSourceReadinessAuthority
ContactsSourceReadinessAuthority
```

and replace them with:

```text
TestAgentResolver
```

Do not yet remove onboarding-owned adapters/providers if Slice 4 will need them to construct runtime TestAgents.

This slice should only remove them from the generic Presence execution boundary.

---

## 8. Do not do Slice 4 yet

This slice must not yet redesign Onboarding composition around final TestAgent bindings unless the minimum runtime test fixture requires explicit test bindings.

Do not yet perform the full production/development onboarding composition cleanup.

If tests need a resolver, supply tiny generic test bindings locally.

The real onboarding binding migration belongs to Slice 4.

---

## 9. Keep `OpenFdaSettingsStep` unchanged

Do not generalize:

```text
OpenFdaSettingsStep
```

It remains explicit transitional debt.

Presence will therefore become generic for **Boolean tests**, but not yet fully domain-neutral for all Step types.

Do not add:

```text
ActionStep
ActionAgent
Agent supertype
```

in this slice.

---

## 10. Repository integrity

Update validation so the generic Test Step obeys:

```text
base type = test
exactly one active test_step_definitions row
declared test_agent_id exists
destinations are valid
Test Step is terminal in containing Trip
all reused Step definitions are structurally identical
all required TestAgentIds resolve for requested Schedule
```

Remember:

```text
declared in database
!=
runtime Agent available
```

SQLite owns the former.

Resolver/application composition owns the latter.

---

## 11. Runtime behavior tests

Add focused tests proving:

### Generic TestStep

```text
Agent true
    -> true destination

Agent false
    -> false destination

true destination null
    -> null

false destination null
    -> null

Agent throws
    -> Step completion fails
```

No routing or checkpoint should occur after Agent failure.

### Repository reconstruction

Prove a persisted generic Test Step reconstructs with the Agent returned by the resolver.

### Missing Agent

For a Schedule referencing an unresolved TestAgentId:

```text
Schedule load/executable validation fails

new run is not created

schedule_run_started is not traced

existing run does not advance
```

### Schedule-scoped resolution

A database may contain:

```text
Schedule A -> Agent A
Schedule B -> Agent B
```

A resolver supplying only Agent A must:

```text
allow Schedule A
not reject presence.db globally
reject Schedule B if requested
```

This is important.

---

## 12. Migration continuity tests

Extend file-backed migration coverage.

Start from a pre-generic historical database with:

- FDA test Step;
- Contacts test Step;
- occurrences;
- active ScheduleRun;
- trace history.

After full runtime cutover prove:

```text
base Step types = test

generic test_step_definitions active

legacy specialist rows still physically present

same StepDefinition IDs

same occurrence IDs

same current ScheduleRun checkpoint

same trace history

same route destinations
```

Then reconstruct and execute the migrated Schedule using a resolver containing matching generic test Agents.

Prove an active historical run can continue after migration.

---

## 13. Blank-stare architecture protection

Add or strengthen architecture tests so generic Presence test execution cannot depend on:

```text
onboarding
conversation_graph
AddressBook
MacosFullDiskAccess
MessagesSourceReadinessAuthority
ContactsSourceReadinessAuthority
FDA terminology
chat.db SQL
```

Do not use brittle text scanning where import/dependency boundaries can prove the invariant more cleanly.

The desired active Presence path should be:

```text
TestStep
    -> TestAgent
```

not:

```text
TestStep
    -> onboarding-specific authority
```

---

## 14. Database teaching docs

Update the Presence database teaching guides from the Slice 2 compatibility state to the new active state.

Explain plainly:

```text
A Test Step names an opaque Test Agent.

The database says which Agent identity is required.

The running app supplies the actual Agent object through the resolver.

Presence does not know what the Agent does.
```

Clearly distinguish:

```text
test_agent_definitions
    declared durable identities

TestAgentResolver
    runtime implementations available in this process
```

Document the old FDA/Contacts subtype rows as retained migration evidence only.

---

## 15. Documentation record

Create:

`07-GENERIC-TESTSTEP-RUNTIME-CUTOVER-IMPLEMENTATION.md`

Record:

1. final `TestStep` API;
2. resolver injection point;
3. repository reconstruction path;
4. schedule-scoped fail-fast behavior;
5. discriminator cutover;
6. frozen legacy-row handling;
7. provider signature cleanup;
8. migration continuity evidence;
9. runtime tests;
10. architecture tripwire changes;
11. what specialized test code remains and why;
12. anything deferred to Slice 4.

Update:

- consolidation start/index;
- database guides;
- `DOCUMENTATION_PASS_LOG.md`.

---

## 16. Verification

Run:

- focused generic TestStep tests;
- resolver/reconstruction tests;
- file-backed migration tests;
- complete Presence tests;
- Onboarding tests;
- development harness tests;
- architecture tripwires;
- `flutter analyze`;
- code generation if required;
- formatting;
- macOS Debug build;
- generated Mermaid artifact;
- `git diff --check`.

---

## Hard constraints

Do not in Slice 3:

- add generic ActionStep;
- generalize OpenFdaSettingsStep;
- create Agent supertype;
- add Agent context/result bags;
- add polling/retry framework;
- change Schedule topology;
- change onboarding copy;
- integrate Presence into production OnboardingGate;
- remove historical subtype rows;
- rewrite historical IDs;
- add feature meaning to `TestAgentId`.

---

## Success criterion

After this slice, Presence should reconstruct persisted test Steps like this:

```text
presence.db:
    Step type = test
    Agent = onboarding.messages-source-readable
    true -> Trip X
    false -> Trip Y

Presence:
    sees opaque TestAgentId
    asks resolver for TestAgent
    evaluates Boolean
    returns configured destination
```

If asked:

> What does `onboarding.messages-source-readable` actually test?

Presence must still have only one correct answer:

```text
I don't know.
```

And the existing FDA/Contacts workflow identities, checkpoints, trace history, and route behavior must survive the cutover unchanged.

Stop after Slice 3 and report back before Onboarding runtime binding composition is generalized.
