Implement the next bounded Onboarding TestAgent slice only from:

10-NEXT-REAL-WORKFLOW-CONCERN-PLAN.md

Do not extend the Schedule yet.

Do not design or implement ChoiceStep yet.

Do not add ActionStep.

Do not change presence.db, Trip, Scheduler, routing, checkpoints, trace, production OnboardingGate, or onboarding presentation.

The goal is to establish the factual specialist boundary for:

Is the local Messages history sufficiently populated for initial onboarding purposes?

The planning document identifies this as the immediate next concern after required-source readiness.

⸻

1. Settle the measurement contract first

Production currently treats a non-null count of 10 or fewer rows in chat.db.message as sparse/possibly unsynced.

Before implementing the Agent, inspect the current production code and tests and explicitly decide whether this development Presence slice should preserve:

COUNT(\*) FROM message

or intentionally adopt some other existing count such as importable-message rows.

Do not silently substitute ChatDbSourceProbeReader.readImportableMessageCount() merely because it already exists; the planning pass established that this measures a different fact.

Default expectation: preserve current production semantics unless there is concrete evidence they are wrong.

Document the decision.

⸻

2. Add one stable Onboarding TestAgentId

Under lib/essentials/onboarding/, add the stable opaque ID:

onboarding.messages-source-history-sufficient

Use the existing Onboarding TestAgent ID ownership seam.

Do not define this ID in Presence.

Do not parse its meaning in Presence.

⸻

3. Implement the Onboarding-owned TestAgent

Add a concrete Boolean TestAgent whose responsibility is exactly:

obtain the agreed local Messages row-count fact
apply the Onboarding sufficiency threshold
return true or false

Expected semantics if current production behavior is preserved:

count >= 11
-> true
count <= 10
-> false

The Agent owns the Onboarding interpretation of the threshold.

The low-level specialist owns the database read.

The Agent must not know:

- Trip;
- Schedule;
- destinations;
- routing;
- remediation copy;
- user choice;
- Presence checkpointing.

⸻

4. Reuse existing read-only specialist infrastructure

Prefer the existing OnboardingDatabaseProbeReader.readTableCount() path if that is the truthful current owner of the production fact.

Do not duplicate SQLite open/query code.

Do not put:

chat.db path
SQL implementation
SQLite connection mechanics

inside the TestAgent if an existing specialist boundary already owns them.

The intended dependency shape is:

Onboarding MessagesHistorySufficiencyTestAgent
-> existing read-only Messages count specialist
-> count fact
-> threshold interpretation
-> bool

Presence should remain unaware of all of this.

⸻

5. Failure semantics

This is important.

The planning document identified that current production behavior can produce an unavailable/unknown count, while a Boolean TestAgent cannot truthfully collapse “unknown” into either sufficient or sparse.

Define a truthful contract for count-read failure.

Preferred rule:

count obtained
-> evaluate threshold
-> true/false
count unavailable / read fails
-> Agent evaluation fails
-> do not fabricate a Boolean

Use existing error conventions where possible.

Do not turn failure into:

true
false
0

unless current production semantics provide a compelling, explicitly documented reason.

This slice does not need a new Presence error model.

An Agent exception should remain an Agent/Step failure under the already-established generic TestStep semantics.

⸻

6. Bind the new Agent through Onboarding composition

Extend the existing Onboarding TestAgent binding contribution so it now contributes:

onboarding.messages-source-readable
onboarding.contacts-source-readable
onboarding.messages-source-history-sufficient

The global/application resolver composition should require no Presence changes.

Do not change TestAgentResolver.

Do not change generic TestStep.

⸻

7. Do not add the Agent to the active Schedule yet

This slice intentionally stops before workflow integration.

Do not add a new TestStep to:

required_sources_readiness_schedule.dart

Do not allocate new Schedule/Trip/Step identities.

Do not change Mermaid topology.

Do not add sparse-history guidance or Import Anyway.

We first want a proven factual Agent before designing the user-choice grammar.

⸻

8. Focused tests

Add tests proving the exact threshold boundary.

At minimum:

0 rows -> false
1 row -> false
10 rows -> false
11 rows -> true
larger count -> true

Use small disposable SQLite fixtures or the narrowest existing test seam that proves the real counting contract.

Also prove:

count read failure
-> Agent evaluation failure
-> not true/false coercion

If the specialist returns an optional/missing count rather than throwing, explicitly test how the Agent turns that into failure.

⸻

9. Fresh evaluation

Prove repeated evaluate() calls perform fresh factual reads.

For example:

first count = 10
-> false
underlying test source changes to 11
second evaluate()
-> true

No Boolean result should be cached in:

- Agent;
- Onboarding;
- Presence;
- presence.db.

⸻

10. Binding tests

Extend Onboarding binding tests to prove:

- the exact new ID is contributed;
- exactly one binding exists for that ID;
- all three onboarding TestAgent IDs are distinct;
- ImmutableTestAgentResolver resolves the new Agent;
- duplicate contribution remains rejected mechanically.

⸻

11. Architecture boundary tests

Protect:

Presence
does not import this Agent or its ID
Messages-history TestAgent
may import generic TestAgent contract
may use Onboarding/specialist read boundary
does not import Trip/Scheduler/routing machinery
low-level database specialist
does not depend on Presence

Do not add brittle source-text tests if import/dependency checks express the invariant more cleanly.

⸻

12. Production parity

Compare the new Agent result to the current production sparse-history classifier.

Add focused parity coverage if practical so:

production says sparse
<=> Agent returns false
production says sufficiently populated
<=> Agent returns true

for the known 10/11 boundary.

Do not modify production classification behavior.

If the new truthful failure semantics differ from production’s current “count unavailable” treatment, document that discrepancy explicitly rather than changing production in this slice.

⸻

13. Documentation

Create:

11-MESSAGES-SOURCE-HISTORY-SUFFICIENCY-TESTAGENT-IMPLEMENTATION.md

Record:

1. selected count semantics;
2. why that measurement was chosen;
3. stable TestAgentId;
4. concrete Agent implementation;
5. specialist dependency;
6. exact threshold;
7. failure semantics;
8. fresh-read behavior;
9. binding contribution;
10. production-parity result;
11. tests;
12. confirmation that no Schedule change occurred.

Update:

- 00-START-HERE.md
- package index
- relevant Onboarding ownership docs
- DOCUMENTATION_PASS_LOG.md

⸻

14. Verification

Run:

- focused new Agent tests;
- Onboarding binding tests;
- complete Onboarding tests;
- complete Presence tests;
- development harness tests;
- architecture tripwires;
- flutter analyze;
- formatting;
- code generation only if required;
- git diff --check.

A macOS build is optional unless composition/provider changes affect app compilation.

⸻

Hard constraints

Do not:

- change presence.db;
- change TestStep;
- change resolver semantics;
- extend the Schedule;
- add ChoiceStep;
- add ActionStep;
- add user-choice UI;
- change onboarding copy;
- change production sparse-history policy;
- modify real chat.db;
- add polling or retry machinery;
- integrate production Presence onboarding.

If implementing the TestAgent requires any of those, stop and explain the concrete blocker.

⸻

Success criterion

At the end of this slice, Onboarding should have one proven reusable factual Agent:

TestAgentId:
onboarding.messages-source-history-sufficient
evaluate():
fresh read of agreed Messages row count
-> <= 10 => false
-> >= 11 => true
-> read unavailable => evaluation failure

Presence should know only that this opaque Agent can return a Boolean.

The active Schedule should still be unchanged.

Stop and report back before designing the now-earned two-destination user-choice Step.
