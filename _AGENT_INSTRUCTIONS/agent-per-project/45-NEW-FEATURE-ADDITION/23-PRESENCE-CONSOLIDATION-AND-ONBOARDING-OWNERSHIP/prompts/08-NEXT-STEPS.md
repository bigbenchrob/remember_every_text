Continue the real Presence workflow by discovering the next actual onboarding or ingestion concern after required Messages and Contacts source readiness.

Do not assume what the next concern is.

Do not design ActionStep.

Do not generalize OpenFdaSettingsStep.

Do not extend Presence merely because a future abstraction seems attractive.

The goal is to continue the same implementation-led method that has worked so far:

inspect the real production workflow, identify the next concrete requirement, model only that requirement, and see what new pressure it places on Presence.

⸻

Read first

Read the current consolidation package, especially:

- 09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md
- 08-ONBOARDING-TEST-AGENT-COMPOSITION-IMPLEMENTATION.md
- 07-GENERIC-TESTSTEP-RUNTIME-CUTOVER-IMPLEMENTATION.md
- the current required-sources onboarding Schedule
- current production Onboarding / Environment Readiness logic
- current Production Readiness / ingestion documentation
- current archive/import/graph readiness implementation

Inspect code as the source of truth.

⸻

Current proven state

The development Presence Schedule now truthfully establishes:

Messages source readable?
false -> FDA remediation -> verify again
true -> Contacts source readable?
Contacts source readable?
false -> Contacts guidance -> retry
true -> combined required-sources confirmation

The generic Boolean Test architecture is complete.

Presence knows only:

TestStep
TestAgentId
TestAgent
Boolean result
true/false destinations

It does not know what those tests mean.

The sole remaining active domain-specific Step in Presence is:

OpenFdaSettingsStep
-> FdaSettingsOpeningAuthority

Do not solve that debt in this pass.

⸻

First task: determine what production actually does next

Answer from the current repository:

Once required Messages and Contacts source readiness is established, what is the next real condition, user decision, or operation that can prevent MessageLens from reaching its normal usable state?

Trace the current production sequence in order.

The previous analysis showed later concerns such as source sparsity, import state, graph readiness, persisted failures, and initial import readiness. Re-evaluate the current code rather than relying on that earlier list.

Produce a concise sequence such as:

required sources ready
-> check X
-> if X...
-> otherwise Y

For every next-stage item identify:

- the actual fact or operation;
- current owner;
- current reader/service/repository;
- blocker precedence;
- current user-facing remediation/action;
- whether it is a test, action, user decision, or long-running operation.

⸻

Second task: select exactly one next concern

Choose only the immediate next independent concern.

Do not design the remainder of onboarding or ingestion yet.

Write its real user journey in ordinary language first.

Answer:

1. What must MessageLens establish or accomplish?
2. Why does it matter?
3. If everything is already satisfactory, what should the user see?
4. If it is not satisfactory, what does the user need to do?
5. Does MessageLens itself perform work?
6. Does a specialist perform work?
7. Is there a user decision?
8. Can the world change externally and be retested?
9. Is restart relevant?
10. Is this genuinely still onboarding, or are we crossing into an ingestion workflow?

⸻

Third task: classify the Step shapes required

For the selected concern, identify the mechanical jobs required from Presence.

Classify each as one of:

Tell
Fixed destination
Boolean Test
existing OpenFdaSettings operation
new operation shape
user-choice shape
long-running work shape
other

Reuse generic TestStep wherever the actual need is:

ask specialist Boolean question
-> true/false destination

Do not create a specialized Boolean Step.

If the workflow requires an operation that is not a Test, describe it precisely but do not immediately generalize it.

For example, if reality requires:

ask specialist to perform work
await completion
continue

record that as evidence for later comparison with OpenFdaSettingsStep.

Do not call it ActionStep merely because that name is available.

⸻

Important ActionStep evidence question

One purpose of continuing the real workflow is to discover whether we obtain a second genuine example of the same mechanical pattern as:

OpenFdaSettingsStep
-> specialist performs operation
-> await success/failure
-> continue

For every operation-shaped Step encountered, compare it to OpenFdaSettingsStep:

What does the Step know?
What does the specialist know?
What is returned?
What constitutes completion?
What constitutes failure?
Does completion affect routing directly?
Does the operation require persisted configuration?

At the end state whether:

No second operation shape appeared.

or:

A second operation shape appeared and provides real evidence for a generic abstraction.

Do not implement that abstraction in this pass.

⸻

Fourth task: determine workflow ownership

Explicitly decide whether the next concern belongs under:

lib/essentials/onboarding/

or whether it represents the beginning of another workflow owner such as:

lib/essentials/archive_ingestion/

or another existing essential.

Do not force all pre-normal-app work into Onboarding.

Use the question:

Who owns the meaning of this workflow?

Presence should remain only the execution grammar.

⸻

Fifth task: propose the smallest Schedule extension

Starting from the current required-sources Schedule, propose only the minimum extension required for this next concern.

Reassess the current combined confirmation Trip:

confirm_required_sources_readable

Now that another real concern may follow, determine whether it still deserves to exist independently.

As before, do not remove it merely to reduce Trip count.

Ask whether it still has:

- useful user meaning;
- restart/checkpoint value;
- a natural transition role.

For each proposed Trip document:

- purpose;
- ordered Steps;
- terminal Step;
- result/destination semantics;
- default next;
- explicit alternate destinations;
- restart suitability.

⸻

Sixth task: specialist / Agent boundaries

For every factual test, identify the specialist that owns the expertise.

If a generic TestStep can use it, specify:

TestAgentId
workflow-owned TestAgent adapter
specialist dependency

Do not put specialist logic into Presence.

For non-Boolean operations, identify the narrow specialist boundary but do not create a generic Agent family yet.

⸻

Seventh task: long-running work consideration

If the next real concern is import, graph building, attachment archival, or another long-running operation, describe the actual current behavior carefully.

Distinguish:

start operation
operation running
operation complete
operation failed
user may quit/restart
durable progress owned elsewhere
Presence checkpoint

Do not assume Presence should own operation progress.

Ask:

Should Presence merely sequence and present a specialist-owned durable operation, while the specialist/workflow owner retains its own progress state?

Document the answer from current architecture.

Do not add progress bags, polling, or current-Step persistence unless a real requirement proves them necessary.

⸻

Eighth task: no production cutover

This remains a development Presence experiment.

Do not:

- replace OnboardingGate;
- alter production Environment Readiness;
- change production import behavior;
- change graph build orchestration;
- change archive preservation;
- change source data;
- change presence.db schema;
- add ActionStep;
- add Agent supertype.

This is planning/discovery only.

⸻

Deliverable

Create:

10-NEXT-REAL-WORKFLOW-CONCERN-PLAN.md

Structure:

1. Current production sequence after required-source readiness
2. Immediate next concern
3. Plain-English user journey
4. Current implementation owner
5. Current factual/operational specialist
6. Is this still Onboarding?
7. Required Step shapes
8. Generic TestStep usage
9. Operation-shaped Step evidence
10. Comparison with OpenFdaSettingsStep
11. Proposed Schedule extension
12. Trip-by-Trip composition
13. Restart/checkpoint implications
14. Long-running work/progress ownership, if relevant
15. Manual test possibilities
16. What can be implemented with current Presence
17. What would require a new architectural decision
18. Recommended next implementation slice

End with explicit answers:

What is the next real concern?
Who owns its meaning?
What does Presence need to know?
Did this concern produce a second genuine operation-shaped Step?
Has ActionStep now earned a design pass?

For the last question, answer only from the evidence.

⸻

Hard constraints

Do not:

- implement new application code;
- change schema;
- create ActionStep;
- create ActionAgent;
- create generic operation/result models;
- add polling;
- add workflow progress state to Presence;
- add current-Step persistence;
- integrate production onboarding;
- implement Archive Ingestion.

If the next concern cannot be naturally expressed by current Presence, describe exactly where the model fails rather than solving it speculatively.

⸻

Success criterion

We should finish knowing the next real piece of MessageLens workflow in plain language and be able to say either:

Current Presence already expresses it.

or:

Reality has now produced this specific new mechanical requirement.

If a second operation-shaped Step appears, we should have enough concrete evidence to compare it with OpenFdaSettingsStep before deciding whether a generic Action abstraction has finally been earned.

Stop after the planning document and report back before implementation.
