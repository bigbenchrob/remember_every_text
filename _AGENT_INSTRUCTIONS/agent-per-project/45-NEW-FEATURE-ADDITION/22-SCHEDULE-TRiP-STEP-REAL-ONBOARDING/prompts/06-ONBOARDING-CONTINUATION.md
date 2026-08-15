Continue the real Presence onboarding implementation by discovering and appending the next actual onboarding blocker after Messages source readability.

Do not invent the next concern from the Presence experiment.

Inspect the current production onboarding/readiness implementation and determine what MessageLens actually checks next once chat.db is readable.

⸻

Read first

Review:

- 04-TRUTHFUL-MESSAGES-SOURCE-READINESS-IMPLEMENTATION.md
- the current production OnboardingGate
- onboardingEnvironmentReportProvider
- Environment Readiness presentation/actions
- any existing source probes/readiness readers for Contacts / Address Book / import readiness
- current onboarding documentation under the Production Readiness work

⸻

First task: establish the real production sequence

Answer, from code:

Once the Messages source is readable, what is the next actual condition that can prevent MessageLens from proceeding?

Trace the current production logic in order.

Do not assume the answer is Contacts.

Identify:

- each blocker checked after Messages readability;
- the order/precedence in which blockers are surfaced;
- the concrete reader/service that establishes each fact;
- what remediation, if any, the user currently sees;
- what happens after the blocker clears.

Produce a concise plain-English sequence such as:

Messages readable
-> check X
-> if X fails, show Y
-> when X succeeds, check Z

but derive the actual sequence from the repository.

⸻

Second task: choose exactly one next onboarding concern

Select the immediate next real blocker only.

Do not design the rest of onboarding yet.

For that one concern, write the user journey in ordinary language before discussing Trips or Steps.

Include:

- what fact MessageLens needs to establish;
- why that fact matters;
- what the user sees if it is already satisfied;
- what the user sees if it is not satisfied;
- whether the user can do anything to fix it;
- whether restart/retry is relevant;
- what fact is tested again afterward.

⸻

Third task: extend the existing Schedule

Starting from the real Schedule that currently ends at:

confirm_messages_source_readable

propose the smallest extension needed for this next concern.

Reassess whether confirm_messages_source_readable should remain as a separate Trip.

It may now be more natural to:

verify Messages
-> next concern

rather than:

verify Messages
-> confirmation Trip
-> next concern

Do not remove the confirmation Trip merely to reduce Trip count. Decide based on semantic/restart usefulness.

For each proposed new or revised Trip, document:

- purpose;
- ordered Steps;
- terminal Step;
- possible TripDefinitionId? results;
- default next;
- explicit alternate destination;
- restart suitability.

⸻

Fourth task: identify required Step capabilities

Reuse existing concrete Steps where they fit:

TellStep
FdaTestStep
OpenFdaSettingsStep
FixedDestinationStep

Do not force the next concern through FdaTestStep if that name/meaning no longer fits.

If the next concern requires a new Step type, propose only the narrow concrete type actually earned by the workflow.

For any new Step, state:

- its exact workflow job;
- persisted definition data;
- narrow specialist/authority dependency;
- result returned to Trip.

Do not build a generic test/action/Agent framework.

⸻

Specialist boundary rule

Preserve the pattern that has now worked in reality:

Step
owns workflow meaning and routing
narrow specialist
owns the factual/platform operation
Trip
remains ignorant
Scheduler
remains ignorant

If an existing production reader/service already performs the required factual check, prefer adapting to it rather than duplicating it inside Presence.

⸻

Important onboarding-copy rule

Keep the newly established principle:

Introduce technical/system terminology only when the user needs it for the next action.

If the next concern is already satisfied, avoid unnecessary explanations.

If remediation is required, explain only what the user needs in order to act.

⸻

Do not implement broad production onboarding

This remains in the development Presence host.

Do not:

- replace OnboardingGate;
- alter production startup;
- change production readiness behavior;
- move production data;
- change archive admission;
- change production preservation.

⸻

Deliverable

Create:

06-NEXT-REAL-ONBOARDING-CONCERN-PLAN.md

Structure:

1. Current production sequence after Messages readability
2. Immediate next blocker
3. Plain-English user journey
4. Existing production fact source
5. Proposed Schedule extension
6. Trip-by-Trip composition
7. Existing Steps reused
8. New Step types, if any
9. Specialist/authority boundary
10. Restart/retry semantics
11. Copy considerations
12. Manual test matrix
13. What can be implemented without changing Presence
14. What would require an architectural decision

⸻

Hard constraints

Do not add:

- generic Agent registry;
- generic condition engine;
- generic action Step;
- arbitrary result/context bags;
- current-Step persistence;
- new routing machinery;
- nested Journey concepts;
- production onboarding integration.

If the next real concern cannot fit the current model cleanly, document exactly where it fails instead of forcing it.

⸻

Success criterion

We should finish able to say:

“Messages readability is now proven. Production onboarding next checks X. Presence can express that concern with these Trips and Steps. If X is already satisfied, the user proceeds quietly. If not, this is the exact remediation path.”

And we should know whether the next slice can be implemented without changing:

Trip
Scheduler
routing semantics
ScheduleRun checkpoint semantics

That should keep us moving left-to-right through the actual onboarding rather than letting the architecture wander ahead of the product.
