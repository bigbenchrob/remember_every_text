I’d make this a production-flow validation exercise, not another edge-case architecture audit. And I’d put the gate/harness distinction right at the top so Codex cannot accidentally validate the laboratory apparatus instead of the product.

54 — End-to-End Production Onboarding Validation

Perform an end-to-end production onboarding validation pass for MessageLens.

This prompt is authorization to perform the validation. Do not stop to ask for plan confirmation.

Create:

54-END-TO-END-PRODUCTION-ONBOARDING-VALIDATION.md

Continue using the 50- document-number series.

Critical prerequisite: validate the real onboarding flow

Before doing anything else, verify the production application wiring.

The production Onboarding Gate must lead into the actual Onboarding flow, not the Presence development/test harness.

The intended production path is conceptually:

production app shell
-> OnboardingGate
-> production Onboarding Presence host/composition
-> PresenceScheduler / PresenceRunner
-> authored Onboarding Schedule

The Presence development harness is diagnostic tooling only.

It must not be:

production app shell
-> OnboardingGate
-> Presence test/development harness

Check the actual current composition and routing in code.

Explicitly identify:

- what macos_app_shell.dart mounts;
- what receives OnboardingGate state;
- what production host runs the real onboarding Schedule;
- where the Presence development harness is reachable;
- whether any development/test switch can accidentally substitute the harness for production onboarding.

Hard invariant

The Gate under validation is the production Onboarding Gate connected to the actual authored onboarding workflow. The Presence harness is not the onboarding experience.

If current production wiring violates this, stop the broader validation, correct only that wiring if the fix is small and unambiguous, verify it, document it, and then continue.

Do not redesign Presence.

⸻

Purpose

We have reached diminishing returns from anticipating increasingly theoretical edge cases.

For this pass, change the governing question from:

What else could theoretically go wrong?

to:

What actually happens when a person uses onboarding?

The goal is to exercise the realistic production journeys, observe actual behavior, and distinguish:

OBSERVED DEFECT
-> investigate
-> understand
-> smallest correction later
THEORETICAL POSSIBILITY ONLY
-> record if useful
-> do not create work for it

Do not invent new architecture merely because an edge case can be imagined.

⸻

1. Read the current settled architecture first

Read the current canonical documentation and relevant recent consolidation records, including at minimum:

- canonical Onboarding Gate documentation;
- attachment-preservation invariant;
- current Presence/Onboarding ownership documentation;
- sparse-history / ChoiceStep production onboarding documentation;
- completion presentation;
- stable failure presentation;
- automatic recovery presentation;
- process-local preparationFailed;
- automatic-recovery mutation-busy deferral.

Use current code as source of truth where documents and code differ.

Do not reopen settled architectural questions unless observed behavior demonstrates a real problem.

⸻

2. Establish the real production journey map

From current production code, write the actual high-level onboarding journey in ordinary language.

At minimum identify:

launch
-> Gate/environment evaluation
-> production onboarding flow if required
-> source readiness
-> Contacts readiness
-> Messages-history sufficiency
-> sparse-history guidance/choice if applicable
-> confirmation
-> Import My Messages
-> Preparing setup…
-> import / Conversation Graph build
-> completion
-> normal application

Include the real branches for:

- FDA unavailable;
- Contacts unavailable;
- Messages source unavailable;
- sparse history;
- Re-check;
- Import Anyway;
- existing ready environment;
- incomplete derived browsing data requiring automatic recovery;
- process-local preparation failure;
- established controller/build failure.

Do not expand this into speculative branches that current production code cannot actually reach.

⸻

3. Verify production Presence composition

Confirm that the authored production onboarding Schedule contains the expected real workflow components.

Verify that the production runner resolves:

- real Onboarding TestAgents;
- real ChoiceStep;
- real TellSteps;
- real FDA-settings exception where still applicable.

Confirm that development substitutions/harness facilities are not accidentally used in production composition.

Document the boundary:

Production onboarding
real authored Schedule
real Onboarding Agents
generic Presence runtime/presentation
Presence development harness
observation
substitutions
diagnostics
trace/map tools

Do not merge these responsibilities.

⸻

4. Build a realistic validation matrix

Use realistic human journeys, not a combinatorial state matrix.

At minimum validate these journeys where current fixtures/test infrastructure make them safely reproducible.

Journey A — already ready

launch
-> environment already ready
-> no onboarding obstruction
-> normal app

Confirm the Gate does not unnecessarily launch Presence or recovery.

Journey B — fresh onboarding, normal source history

launch
-> onboarding required
-> readiness checks pass
-> sufficient Messages history
-> confirmation
-> Import My Messages
-> Preparing setup…
-> build
-> MessageLens is ready
-> Get Started

Journey C — FDA unavailable then restored

Exercise the real FDA prerequisite path.

Verify:

- correct human guidance;
- no destructive reset before admission/prerequisite truth allows it;
- successful continuation after access is restored.

Do not redesign FDA behavior during this pass.

Record the existing cached-FDA concern separately if still present.

Journey D — sparse Messages history

Exercise:

history test false
-> sparse guidance
-> ChoiceStep

Test:

Re-check

and verify it performs a fresh source-history evaluation.

Test:

Import Anyway

and verify the durable accepted-readiness handoff reaches the existing import action.

Journey E — automatic recovery

Using disposable derived stores, produce the existing supported incomplete-browsing-data condition.

Verify the human sees:

Preparing MessageLens to try again
MessageLens found incomplete browsing data and is preparing for another setup attempt. Please wait.

Confirm recovery:

- runs only after mutation admission;
- uses the existing allow-listed reset;
- returns to fresh environment truth;
- normally exposes Import My Messages afterward;
- does not automatically rerun setup.

Journey F — preparation/reset failure

With a safe injected/test failure:

Preparing setup…
-> reset failure
-> preparationFailed

Verify:

MessageLens couldn't finish setup
MessageLens couldn't finish preparing your browsing data.
You can try again.
[Try Again]
[Send Report To Developer]

Then verify Try Again starts a fresh ordinary attempt.

Journey G — controller/build failure

Use the existing controlled failure seam.

Verify the established stable failure surface appears and remains distinct from preparationFailed.

Journey H — quit/relaunch at meaningful boundaries

Do not attempt every conceivable instruction boundary.

Choose a small number of human-relevant restart points, such as:

1. before import begins;
2. after a completed onboarding acceptance but before import;
3. after successful build/completion before pressing Get Started;
4. after a failed/preparation state where process-local truth is expected to disappear.

Verify restart reconstructs from the correct durable authorities.

⸻

5. Use disposable/test data only

Do not perform destructive validation against the production archive.

Use:

- test fixtures;
- development data folders;
- disposable import/working databases;
- existing dependency substitution seams.

The production data folder and archived attachment payloads are not experimental material.

⸻

6. Attachment preservation is non-negotiable

Throughout every tested reset/recovery journey, verify the existing invariant:

AUTHORITATIVE EXTERNAL SOURCES
Apple Messages
Apple Contacts
locally available source attachments
NEVER deletion targets
REBUILDABLE MESSAGELENS DERIVED STORES
import database
Conversation Graph / working stores
resettable
PRESERVATION DATA
archived attachment payloads
NEVER ordinary reset/recovery targets

Do not weaken this language.

Do not say “all MessageLens data is rebuildable.”

For any reset/recovery test, use the existing preservation tripwires.

If any observed code path can touch archived attachment payloads as a reset/recovery side effect, stop immediately and report that as a priority safety defect.

⸻

7. Observe the human reading order

For each journey, record what an ordinary user actually sees.

Ask only:

Do I know what is happening?
Do I know whether I need to act?
If I need to act, is the action obvious?
Does the UI claim anything the system does not know?

Do not penalize the UI for omitting diagnostics that belong in support tooling.

The intended presentation philosophy remains:

Ordinary reading order contains only information that changes human understanding or next action.

⸻

8. Observe transitions, not just isolated screens

Pay particular attention to transitions such as:

readiness -> Presence onboarding
Presence completion -> readiness/import
Import My Messages -> Preparing setup…
Preparing setup… -> active build
build -> completion
recovery -> ready to import
failure -> retry
retry -> new preparation attempt

Look for actual defects such as:

- screen flashes;
- apparent no-op button presses;
- contradictory states;
- stale content surviving a transition;
- spinner remaining after operation ended;
- button appearing before action is valid;
- multiple overlays competing;
- production flow unexpectedly entering development harness.

Do not invent defects from code possibilities alone.

⸻

9. Pay special attention to Gate ownership

Verify the Gate is acting as an admission/orchestration boundary rather than becoming a semantic workflow engine.

The desired division remains:

OnboardingGate
operational admission
environment/recovery/bootstrap coordination
Production Onboarding Presence flow
authored human onboarding journey
Presence
generic execution grammar
Specialists
factual/platform operations

The Gate must point to and admit the actual onboarding flow.

It must not make the Presence harness the production onboarding destination.

⸻

10. Verify the sparse-history ChoiceStep as a real user journey

Do not merely inspect ChoiceStep unit tests.

Confirm production composition really reaches:

sparse guidance
-> ChoiceStep
Re-check
Import Anyway

Verify:

- labels are human-facing;
- durable option values remain opaque;
- Re-check loops through the configured Trip topology;
- Import Anyway reaches the existing confirmation/import route;
- Presence itself remains ignorant of what those choices mean.

If this works, leave ChoiceStep alone.

⸻

11. Verify completion as a handoff, not authority

Confirm the completion surface remains:

MessageLens is ready
Your local browsing data is prepared.
Get Started

or current equivalent.

Verify:

- completion metrics are absent from ordinary UI;
- quitting before Get Started does not make the successful build disappear;
- next launch derives readiness from the populated durable stores;
- Get Started is merely the human handoff.

Do not add completion persistence.

⸻

12. Verify stable failure as a human surface

Confirm settled failure UI contains only the intended primary message/actions.

Do not reopen previously removed components:

- Environment Summary;
- What to check;
- raw error;
- transport explanation;
- technical phase details.

Verify support evidence remains available separately.

If this surface works in real transition context, declare it done.

⸻

13. Verify automatic recovery as a real transition

Confirm the current Slice 52 invariant:

Recovery presentation appears only after mutation authority is admitted.

Exercise the normal recovery journey with no competing owner.

If practical with existing deterministic tests, exercise busy deferral too—but do not create new theoretical contention scenarios merely for this validation pass.

The purpose is to confirm the implemented behavior works coherently in context.

⸻

14. Do not implement Audit 53 / proposed Slice 54 merely because it exists

The previous user-initiated mutation-busy audit documented a theoretically correct behavior.

Do not implement it during this validation pass unless an actual validation journey demonstrates that this contention case is a meaningful production defect.

Audit 53 remains useful documentation.

It is not automatically an implementation backlog item.

Apply this principle to other outstanding speculative concerns as well.

⸻

15. Classify every finding

For every observation, assign exactly one category:

A. Observed production defect

Something actually produced incorrect, confusing, unsafe, or misleading behavior during a realistic validation journey.

B. Observed polish issue

Real but non-blocking presentation issue.

C. Known architectural debt, not exercised

Previously documented concern that was not demonstrated during this validation.

D. Theoretical edge case

Possible from reasoning, but no evidence from the realistic journeys.

Only A and meaningful B findings should normally generate immediate follow-up work.

Do not turn categories C/D into implementation tasks merely because they exist.

⸻

16. Rank findings by production importance

Use:

P0 — preservation/data safety
P1 — onboarding cannot complete / user stranded
P2 — misleading or materially confusing state/action
P3 — polish
DEFERRED — theoretical/unobserved

Do not use severity inflation.

⸻

17. If an obvious tiny defect blocks validation

If a small, clearly local defect prevents the validation pass from continuing—for example the production Gate is accidentally wired to the Presence harness instead of the real onboarding host—you are authorized to make the smallest necessary correction.

Requirements:

1. explain the blocking defect;
2. keep the edit tightly scoped;
3. add/update focused tests;
4. document it in the validation record;
5. continue validation afterward.

Do not use this authorization for opportunistic refactoring.

For any nontrivial defect, record it and continue other validation where possible rather than beginning an implementation project.

⸻

18. No speculative architecture work

Do not introduce:

- new failure taxonomies;
- new Gate states;
- new Presence Step types;
- new persistence;
- job queues;
- retry schedulers;
- timers;
- generic busy frameworks;
- broad coordinator changes;
- new recovery abstractions.

If the validation does not require them, they do not belong in this task.

⸻

19. Test and execution strategy

Begin with existing automated seams to prove the production topology and state transitions.

Then, where the repository’s existing development/test setup safely supports it, run the actual macOS development application against disposable/test data, not the production archive.

If true GUI interaction cannot be reliably automated, clearly distinguish:

CODE/TEST VERIFIED

from:

MANUAL VISUAL VALIDATION STILL REQUIRED

Do not claim to have visually observed something that was only established from widget tests.

⸻

20. Produce a compact journey table

Include something like:

Journey Result Human state/action Durable authority Finding
Already ready
Fresh normal onboarding
FDA unavailable/restored
Sparse → Re-check
Sparse → Import Anyway
Import/build success
Preparation failure/retry
Controller failure/retry
Automatic recovery
Selected relaunch points

Keep this grounded in executed tests/inspection.

⸻

21. Answer the production-readiness questions

At the end, answer plainly:

Can a new user get through onboarding?

Yes / No / Not fully demonstrated

Does the Gate point to the real production onboarding flow?

Yes / No

Can the user understand what MessageLens is doing during long work?

Yes / No / issue

Can the user recover from the realistic failures exercised?

Yes / No / issue

Are archived attachment payloads protected throughout?

Yes / No

Did validation reveal any P0/P1/P2 defect requiring immediate work?

Yes -> list only observed defects
No

Which previously documented concerns remain merely theoretical/unobserved?

List them without turning them into tasks.

⸻

22. Recommend at most one next implementation task

This is important.

At the end of validation:

- If there is a real P0/P1/P2 observed defect, recommend the single highest-value next correction.
- If there is no meaningful observed defect, say:

No implementation slice is currently earned. Continue production/manual validation.

Do not manufacture a “next slice” merely to continue the numbered sequence.

⸻

23. Documentation output

Create:

54-END-TO-END-PRODUCTION-ONBOARDING-VALIDATION.md

Record:

1. verified production Gate → actual onboarding wiring;
2. distinction from Presence harness;
3. production journey map;
4. executed validation journeys;
5. automated versus manually observed evidence;
6. journey table;
7. attachment-preservation result;
8. UX/transition observations;
9. findings classified A/B/C/D;
10. production severity;
11. deferred theoretical concerns;
12. at most one genuinely earned next implementation task.

Update:

- package 00-START-HERE.md
- Feature Addition INDEX.md
- DOCUMENTATION_PASS_LOG.md

Do not bump version/changelog for documentation-only validation unless project conventions explicitly require it.

⸻

Hard constraints

Do not:

- validate the Presence development harness as though it were production onboarding;
- route the production Gate to the Presence harness;
- implement Audit 53 automatically;
- chase theoretical edge cases;
- create work merely because a state is imaginable;
- change reset semantics;
- change attachment archival;
- change Presence grammar;
- add persistence;
- add new Gate states unless an actually observed blocking defect proves one necessary;
- launch destructive validation against the production archive.

Success criterion

This task succeeds when we can stop reasoning about onboarding in the abstract and say:

Here is the actual production journey.
Here is what happened when we exercised it.
Here are the things that genuinely worked.
Here are the defects we actually observed.
Here are the theoretical concerns we deliberately did not chase.

Most importantly:

The production Onboarding Gate must be validated against the actual onboarding workflow, never the Presence test harness.

If the realistic journeys work cleanly, that is evidence to stop changing the architecture, not an invitation to search for a more obscure failure mode.
