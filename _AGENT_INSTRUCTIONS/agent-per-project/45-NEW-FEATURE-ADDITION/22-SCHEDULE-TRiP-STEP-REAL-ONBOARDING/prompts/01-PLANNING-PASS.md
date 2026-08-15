Yes. I’d make the next Codex pass **planning-only**, focused on the real FDA slice and on discovering the first real Agent boundary rather than guessing a generalized agent framework.

> We are ready to stop inventing synthetic Presence workflows and begin modeling the **real MessageLens onboarding flow**, starting with Full Disk Access.
>
> This is still an **experimental planning pass**.
>
> Do not integrate Presence into production onboarding yet.
>
> Do not change `OnboardingGate`.
>
> Do not replace the development test host.
>
> Do not implement a generalized Agent system.
>
> The goal is to derive the first real onboarding Schedule from existing MessageLens behavior and identify the smallest concrete execution contracts required.
>
> ---
>
> ## Read first
>
> Read the current Presence documentation, especially:
>
> - `15-PRESENCE-DATABASE-IN-PLAIN-ENGLISH.md`
> - `16-PRESENCE-DATABASE-SCHEMA-WALKTHROUGH.md`
> - `03-SCHEDULE-TRIP-EXPERIMENT/10-DATABASE-SCHEMA-PROPOSAL.md`
> - `40-FDA-DERIVED-ROUTING-IMPLEMENTATION.md`
> - `50-GENERATED-SCHEDULE-DIAGRAM.md`
> - `60-EXECUTION-TRACE-IMPLEMENTATION.md`
> - `70-LIVE-SCHEDULE-VISUALIZATION.md`
> - `30-SYSTEM-BOUNDARIES.md`
>
> Then inspect the **actual existing onboarding/FDA implementation** in MessageLens.
>
> Identify:
>
> - where startup decides onboarding is required;
> - how FDA readiness is currently checked;
> - what UI currently explains FDA;
> - what action currently opens the relevant macOS System Settings pane, if one exists;
> - what currently happens when FDA is still absent;
> - what currently happens after FDA becomes available;
> - whether the current app already has an explicit “restart required” or “try again” model;
> - what code currently performs the FDA test versus merely presents its result.
>
> Do not infer or invent missing behavior. Document what actually exists.
>
> ---
>
> ## First deliverable: plain-English FDA onboarding story
>
> Before discussing Trips or Steps, write the current desired user experience in ordinary language.
>
> Something in this spirit:
>
> ```text
> Welcome the user.
>
> Explain that MessageLens needs access to protected Messages and Contacts data.
>
> Check whether Full Disk Access is already available.
>
> If FDA is present:
>     explain that access is available;
>     continue to the next onboarding concern.
>
> If FDA is absent:
>     explain why FDA is required;
>     guide the user to grant it;
>     perform whatever user-visible action is appropriate;
>     at the appropriate point, check FDA again.
>
> If FDA is still absent:
>     continue guiding/rechecking.
>
> If FDA is now present:
>     continue.
> ```
>
> But do not use that as authority. Derive the actual story from existing MessageLens behavior and the intended onboarding copy already documented in the Presence experiment.
>
> Explicitly identify:
>
> - what the user sees before the first FDA check;
> - what the user sees when FDA is already present;
> - what the user sees when FDA is absent;
> - what happens immediately before the app is restarted;
> - what the user should see after restart if FDA is now present;
> - what the user should see after restart if FDA is still absent.
>
> This restart experience is a primary design question.
>
> ---
>
> ## Second deliverable: proposed real FDA Schedule
>
> Only after writing the plain-English story, decompose it into semantic Trips.
>
> Use the current Presence rule:
>
> > A Trip is a meaningful, restartable semantic chunk of workflow.
>
> Do not make one Trip per screen merely because screens exist.
>
> Prefer imperative, purpose-based names.
>
> Examples may look like:
>
> ```text
> welcome_user
> explain_required_access
> determine_initial_fda_state
> guide_user_to_grant_fda
> verify_fda_assignment
> confirm_fda_available
> ```
>
> but these are examples only.
>
> Derive the actual Trip set from the real story.
>
> For each proposed Trip, document:
>
> - purpose;
> - ordered Steps;
> - terminal Step;
> - possible terminal `TripDefinitionId?` results;
> - default next Trip;
> - explicit alternate destinations;
> - whether repeating the Trip after restart is acceptable.
>
> ---
>
> ## Third deliverable: identify the real Step vocabulary
>
> Reuse existing Step types where they fit:
>
> ```text
> TellStep
> FixedDestinationStep
> FdaTestStep
> ```
>
> Identify every place where the real FDA flow requires a capability those Step types cannot honestly express.
>
> Likely candidates may include:
>
> - a user-controlled Continue/Next Step;
> - a Step that opens the Full Disk Access System Settings pane;
> - a Step that waits for or acknowledges a user action;
> - a Step that requests app restart;
> - another narrowly defined operation.
>
> Do not implement these yet.
>
> For each missing Step type, state:
>
> - exactly what job it would do;
> - what data it would need persisted in its Step definition;
> - what side effect or dependency it would invoke;
> - what it would return to Trip when complete.
>
> Do not create generic Steps merely because they sound reusable.
>
> ---
>
> ## Critical Agent question
>
> The current experimental `FdaTestStep` directly depends on a narrow:
>
> ```text
> FdaTestingAuthority
> ```
>
> We now want to examine whether real Step execution should instead use an external specialist/Agent.
>
> The intended principle is:
>
> > The Step owns workflow meaning and routing configuration.
> > The Agent owns specialized executable work.
>
> For example, conceptually:
>
> ```text
> FdaTestStep
>     knows:
>         which test to request
>         present destination
>         absent destination
>
> FdaTestingAgent
>     knows:
>         how to determine whether FDA is actually available
> ```
>
> The Step should not accumulate macOS-specific FDA probing implementation.
>
> However:
>
> **Do not build an Agent registry, generic Agent base class, or persisted `agent_id` system yet.**
>
> Instead, study the real FDA code and propose the **smallest concrete boundary** that separates:
>
> ```text
> workflow Step
> ```
>
> from:
>
> ```text
> specialist FDA execution code
> ```
>
> Answer:
>
> 1. What concrete code currently knows how to test FDA?
> 2. Can that logic sit behind the existing `FdaTestingAuthority` boundary?
> 3. If yes, is `FdaTestingAuthority` already effectively the first Agent contract, even if we do not call it Agent yet?
> 4. What would be gained or lost by introducing a more general `Agent` concept now?
> 5. What evidence would justify later replacing concrete Step dependencies with something like a persisted `testAgentId`?
>
> Prefer:
>
> ```text
> concrete Step
>     -> concrete narrow execution authority
> ```
>
> until real repetition proves a generic Agent mechanism is needed.
>
> ---
>
> ## Restart experiment design
>
> Design the exact experiment we should run manually.
>
> We want to be able to:
>
> 1. start with Full Disk Access disabled;
> 2. run the experimental real FDA Schedule;
> 3. follow the instructions to enable FDA;
> 4. restart MessageLens when macOS requires/recommends it;
> 5. observe where `ScheduleRun.currentTripOccurrenceId` resumes;
> 6. observe which Trip restarts from Step 1;
> 7. inspect the text the user sees immediately after restart;
> 8. confirm that the next FDA test observes the real changed system state;
> 9. verify the Schedule escapes the remediation path naturally;
> 10. repeat with FDA still absent and verify the guidance/check loop remains understandable.
>
> Explicitly recommend Trip boundaries that make restart repetition acceptable.
>
> If the user would be greeted after restart with confusing or redundant text, identify that as a Schedule-design problem before proposing new persistence machinery.
>
> ---
>
> ## Use the existing Presence development tools
>
> The proposed Schedule must be suitable for the tooling already proved:
>
> - generated Mermaid topology;
> - live Schedule map;
> - execution trace;
> - manual Step-by-Step execution;
> - run restart/checkpoint inspection.
>
> Include a proposed topology diagram or Mermaid for the real FDA slice.
>
> The diagram should be derived from the proposed Trips/Steps, not hand-wave around the branching.
>
> ---
>
> ## Important distinction
>
> We are no longer asking:
>
> > Can Presence implement branching?
>
> That has been proved.
>
> We are asking:
>
> > Can real MessageLens onboarding be naturally expressed as simple Trips and specialized Steps?
>
> Therefore, when something feels awkward, classify the problem before proposing architecture:
>
> ```text
> wrong Trip boundary?
> wrong Step responsibility?
> missing concrete Step type?
> missing narrow execution dependency?
> genuinely missing Presence capability?
> ```
>
> Do not automatically modify Presence because a first Schedule draft feels awkward.
>
> ---
>
> ## No production cutover
>
> Do not:
>
> - connect this Schedule to production startup;
> - modify `OnboardingGate`;
> - replace existing readiness UI;
> - alter production FDA permission flow;
> - change archive admission;
> - change database access policy;
> - modify production preservation behavior.
>
> This remains inside the Presence experimental path.
>
> ---
>
> ## Documentation
>
> Create:
>
> `03-SCHEDULE-TRIP-EXPERIMENT/80-REAL-FDA-ONBOARDING-PLAN.md`
>
> Structure it as:
>
> 1. **Existing FDA onboarding behavior**
> 2. **Plain-English desired user journey**
> 3. **Proposed Trip decomposition**
> 4. **Proposed Step composition**
> 5. **Existing Steps that can be reused**
> 6. **New Step types genuinely required**
> 7. **FDA execution/Agent boundary**
> 8. **Restart and resume experience**
> 9. **Proposed generated topology**
> 10. **Manual test matrix**
> 11. **Risks / awkward points**
> 12. **Questions that must be answered before implementation**
>
> End with:
>
> **What can be implemented without changing Presence architecture**
>
> **What, if anything, would require an architectural decision**
>
> ---
>
> ## Hard constraints
>
> Do not add:
>
> - generic Agent registry;
> - persisted arbitrary Agent IDs;
> - plugin/handler registry;
> - generic action Step;
> - generic condition engine;
> - new routing mechanism;
> - nested Journeys;
> - current-Step persistence;
> - production onboarding integration;
> - speculative retry/failure framework;
> - generalized context/result bags.
>
> If one of those seems necessary, document the concrete requirement that creates the need.
>
> ---
>
> ## Success criterion
>
> We should finish this planning pass able to answer, in plain English:
>
> > “The user starts here. If FDA is absent, these Trips guide them here. They restart here. MessageLens resumes at this Trip. This is the first text they see. This Step asks the real FDA specialist whether access is now present. If yes, the Schedule naturally continues here; if not, it naturally returns here.”
>
> And we should be able to look at the proposed generated map and understand the whole FDA onboarding story without reading Scheduler code.

This is exactly the kind of real-world pressure test we need now. The most interesting result may not be a new Presence feature at all—it may simply show us how to choose the right Trip boundaries so a macOS restart feels natural.
