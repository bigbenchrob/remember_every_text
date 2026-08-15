Yes. I would make the **first implementation prompt** deliberately narrow: build the real FDA slice in the experimental Presence host, using the existing real FDA check and one new `OpenFdaSettingsStep`, but do not touch production onboarding.

Use this:

> We have approved the planning document:
>
> `03-SCHEDULE-TRIP-EXPERIMENT/80-REAL-FDA-ONBOARDING-PLAN.md`
>
> We are now ready for the **first real FDA onboarding implementation slice**.
>
> This remains experimental.
>
> Do **not** integrate Presence into production onboarding yet.
>
> Do **not** modify `OnboardingGate`, the production Environment Readiness flow, archive admission, database access policy, or production preservation behavior.
>
> The goal is to replace the fake FDA development workflow with a real FDA-backed Presence Schedule inside the existing development Presence host.
>
> ---
>
> ## Read first
>
> Re-read:
>
> - `80-REAL-FDA-ONBOARDING-PLAN.md`
> - `70-LIVE-SCHEDULE-VISUALIZATION.md`
> - `60-EXECUTION-TRACE-IMPLEMENTATION.md`
> - `50-GENERATED-SCHEDULE-DIAGRAM.md`
> - `40-FDA-DERIVED-ROUTING-IMPLEMENTATION.md`
> - `30-SYSTEM-BOUNDARIES.md`
> - `15-PRESENCE-DATABASE-IN-PLAIN-ENGLISH.md`
> - `16-PRESENCE-DATABASE-SCHEMA-WALKTHROUGH.md`
>
> Also inspect the existing production FDA implementation:
>
> ```text
> FullDiskAccess
> MacosFullDiskAccess
> canReadMessagesDatabase()
> openSettings()
> ```
>
> The approved plan found that the real FDA test is operationally:
>
> ```text
> can this process read ~/Library/Messages/chat.db?
> ```
>
> and that the existing Settings action opens the macOS Full Disk Access pane. [oai_citation:0‡80-REAL-FDA-ONBOARDING-PLAN.md](sediment://file_00000000c9ac81fda0f054c7d3f478b8)
>
> ---
>
> ## Safety verification already performed
>
> System Settings shows separate Full Disk Access entries for:
>
> ```text
> MessageLens
> MessageLens Development
> ```
>
> Treat the development identity as the test target.
>
> Do not change or disable the production MessageLens FDA entry.
>
> Do not broaden this into new archive-safety work.
>
> ---
>
> ## Implement the five-Trip real FDA Schedule
>
> Implement the approved semantic Trips:
>
> ```text
> 1. introduce_message_lens
> 2. determine_initial_fda_state
> 3. guide_user_to_grant_fda
> 4. verify_fda_assignment
> 5. confirm_fda_available
> ```
>
> The proposed structure is already documented and should be implemented faithfully unless real code makes one detail impossible. 80\-REAL\-FDA\-ONBOARDING\-PLAN.md
>
> ### Trip 1 — `introduce_message_lens`
>
> Ordered Steps:
>
> ```text
> Tell
> Tell
> Tell
> Tell
> ```
>
> Use the already-approved onboarding copy from the Presence experiment:
>
> - Welcome to MessageLens.
> - Explain that MessageLens needs to inspect local Messages and Contacts databases.
> - Explain Full Disk Access and preserve the approved Apple quotation.
> - Explain the specific need for `chat.db` and Address Book data.
>
> Terminal result:
>
> ```text
> null
> ```
>
> Default-next:
>
> ```text
> determine_initial_fda_state
> ```
>
> ---
>
> ### Trip 2 — `determine_initial_fda_state`
>
> One terminal:
>
> ```text
> FdaTestStep
> ```
>
> Configure:
>
> ```text
> FDA present
>     -> TripDefinitionId(confirm_fda_available)
>
> FDA absent
>     -> null
>     -> default guide_user_to_grant_fda
> ```
>
> Use the **real development FDA testing authority**, not the fake toggle.
>
> ---
>
> ### Trip 3 — `guide_user_to_grant_fda`
>
> Ordered Steps:
>
> ```text
> Tell
> OpenFdaSettingsStep
> ```
>
> The Tell Step should explain:
>
> - how to add/enable MessageLens Development in Full Disk Access;
> - that macOS may ask the user to quit and reopen the app.
>
> The terminal `OpenFdaSettingsStep` must:
>
> - request opening the real Full Disk Access pane;
> - return `null` only after that open request succeeds;
> - not claim FDA has been granted;
> - not test FDA itself.
>
> Default-next:
>
> ```text
> verify_fda_assignment
> ```
>
> This Trip boundary is intentionally the durable restart handoff. The plan explicitly places the checkpoint at verification after Settings has been opened. 80\-REAL\-FDA\-ONBOARDING\-PLAN.md
>
> ---
>
> ### Trip 4 — `verify_fda_assignment`
>
> Ordered Steps:
>
> ```text
> Tell
> FdaTestStep
> ```
>
> The first Tell should orient the returning user with copy suitable both after restart and after returning from System Settings without restart.
>
> Use provisional text in the spirit of:
>
> ```text
> Welcome back. I'll check whether MessageLens can now read the protected Messages database.
> ```
>
> Keep the wording easy to revise.
>
> Configure the terminal FDA test:
>
> ```text
> FDA present
>     -> null
>     -> default confirm_fda_available
>
> FDA absent
>     -> TripDefinitionId(guide_user_to_grant_fda)
> ```
>
> This Trip must remain the restart checkpoint. On relaunch, it starts again at Step 1. 80\-REAL\-FDA\-ONBOARDING\-PLAN.md
>
> ---
>
> ### Trip 5 — `confirm_fda_available`
>
> One Tell Step.
>
> Use provisional confirmation copy that says the protected Messages source is now readable without implying all onboarding is complete.
>
> Terminal result:
>
> ```text
> null
> ```
>
> For this bounded experiment:
>
> ```text
> no later Trip -> FDA slice complete
> ```
>
> ---
>
> ## New concrete Step type
>
> Add exactly one new Step subtype:
>
> ```text
> OpenFdaSettingsStep
> ```
>
> This is the only new concrete Step type approved by the plan. 80\-REAL\-FDA\-ONBOARDING\-PLAN.md
>
> Its job is only:
>
> ```text
> ask a narrow specialist to open the Full Disk Access System Settings pane
> ```
>
> Add the smallest corresponding narrow contract, conceptually:
>
> ```text
> FdaSettingsOpeningAuthority
>     Future<void> openSettings()
> ```
>
> or an equivalent signature that truthfully reports failure.
>
> Do not add:
>
> - generic Agent;
> - Agent registry;
> - persisted agent ID;
> - generic action Step;
> - arbitrary command execution.
>
> ---
>
> ## Real FDA specialist boundary
>
> Preserve the approved separation:
>
> ```text
> FdaTestStep
>     owns workflow meaning and routing arms
>
> FdaTestingAuthority
>     owns how FDA/readability is determined
>
> OpenFdaSettingsStep
>     owns workflow meaning of opening Settings
>
> FdaSettingsOpeningAuthority
>     owns how macOS Settings is opened
> ```
>
> The plan concluded that `FdaTestingAuthority` already functions as the first specialist/Agent-like boundary and that a generic Agent system is not yet justified. 80\-REAL\-FDA\-ONBOARDING\-PLAN.md
>
> Prefer an adapter in the experimental client that delegates to the existing real `FullDiskAccess` implementation.
>
> Presence itself must not import production onboarding presentation/business orchestration merely to reach the FDA implementation.
>
> Keep the adapter boundary explicit.
>
> ---
>
> ## Database/schema
>
> Extend `presence.db` only as required for the new concrete `OpenFdaSettingsStep`.
>
> Follow the existing class-table-inheritance pattern:
>
> ```text
> step_definitions
>     type = open_fda_settings
>
> open_fda_settings_step_definitions
>     step_definition_id PK/FK
> ```
>
> If no additional persisted payload is required, do not invent one.
>
> Advance schema version with an explicit migration preserving:
>
> - existing definitions;
> - Schedule runs;
> - execution trace.
>
> Add a file-backed migration test.
>
> ---
>
> ## Development host
>
> Replace the synthetic fake-FDA fixture with the real five-Trip FDA Schedule, or provide an explicit switch between fixtures if that is materially cleaner.
>
> The active real FDA experiment must use:
>
> ```text
> MessageLens Development
> ```
>
> FDA state.
>
> Remove the fake Present/Absent toggle from the real experiment path.
>
> Keep:
>
> - manual `Complete Step`;
> - generated Mermaid;
> - live Schedule map;
> - execution trace;
> - `Run Again`.
>
> We want to walk the real experience one Step at a time.
>
> ---
>
> ## Do not automate verification too aggressively
>
> Opening System Settings proves only that MessageLens requested the pane.
>
> It does **not** prove FDA changed.
>
> The plan explicitly notes that the Settings-opening process may return before the user has acted. 80\-REAL\-FDA\-ONBOARDING\-PLAN.md
>
> Therefore, in this experimental host:
>
> - checkpoint Trip 4 after `OpenFdaSettingsStep` completes;
> - do not immediately auto-run the verification FDA test;
> - retain deliberate/manual Step completion so the user can grant FDA and then continue/relaunch.
>
> Do not introduce wait timers, polling, or lifecycle automation yet.
>
> ---
>
> ## Restart semantics
>
> Preserve existing Presence restart behavior unchanged.
>
> The critical real experiment is:
>
> ```text
> Trip 3
>     Tell guidance
>     OpenFdaSettingsStep
>         completes
>
> checkpoint becomes Trip 4
>
> macOS/user quits MessageLens Development
>
> relaunch
>
> ScheduleRun.currentTripOccurrenceId
>     -> Trip 4
>
> Trip 4 starts at Step 1
>     -> orientation Tell
>     -> real FDA test
> ```
>
> No restart flag.
>
> No saved Boolean.
>
> No current-Step persistence.
>
> No trace replay.
>
> The approved restart semantics are already defined in the plan. 80\-REAL\-FDA\-ONBOARDING\-PLAN.md
>
> ---
>
> ## Manual test targets
>
> Implement enough to manually perform these scenarios:
>
> ### A — FDA already present
>
> Expected:
>
> ```text
> 1 -> 2 -> 5 -> complete
> ```
>
> ### B — FDA absent, then granted with restart
>
> Expected:
>
> ```text
> 1 -> 2 -> 3 -> 4
> [restart]
> 4 -> 5 -> complete
> ```
>
> Verify:
>
> - same ScheduleRun survives restart;
> - Trip 4 is current after relaunch;
> - Trip 4 begins at Step 1;
> - first text is the return/re-check orientation;
> - real FDA test sees changed macOS state.
>
> ### C — FDA remains absent
>
> Expected:
>
> ```text
> 1 -> 2 -> 3 -> 4 -> 3 -> 4 -> ...
> ```
>
> No retry object or loop state.
>
> ### D — Settings open fails
>
> Verify:
>
> - `OpenFdaSettingsStep` does not complete;
> - checkpoint remains Trip 3;
> - no false route decision to Trip 4 is recorded.
>
> The full manual matrix is already specified in the plan. 80\-REAL\-FDA\-ONBOARDING\-PLAN.md
>
> ---
>
> ## Generated topology
>
> The resulting definition topology should mechanically produce:
>
> ```text
> Trip 1 -> Trip 2
>
> Trip 2:
>     Present -> Trip 5
>     Absent  -> default Trip 3
>
> Trip 3 -> default Trip 4
>
> Trip 4:
>     Present -> default Trip 5
>     Absent  -> Trip 3
>
> Trip 5 -> complete
> ```
>
> Do not hard-code this in Mermaid or the live map.
>
> It must emerge from the persisted Step definitions and batting order, as before. 80\-REAL\-FDA\-ONBOARDING\-PLAN.md
>
> ---
>
> ## Tests
>
> Add focused tests for:
>
> - `OpenFdaSettingsStep` persistence/reconstruction;
> - migration to the new schema version;
> - narrow Settings authority invocation;
> - authority failure leaves Step/Trip incomplete;
> - real FDA adapter mapping to `FdaTestingAuthority`;
> - five-Trip Schedule definition and closure validation;
> - present route;
> - absent remediation route;
> - repeated absent loop;
> - restart at Trip 4;
> - no Scheduler or Trip FDA-specific logic;
> - Mermaid and live topology generation from the real Schedule;
> - trace remains observational only.
>
> Run:
>
> - all Presence tests;
> - architecture tripwires;
> - `flutter analyze`;
> - debug macOS build;
> - formatting;
> - `git diff --check`.
>
> ---
>
> ## Documentation
>
> Create:
>
> `03-SCHEDULE-TRIP-EXPERIMENT/90-REAL-FDA-ONBOARDING-IMPLEMENTATION.md`
>
> Record:
>
> - schema change;
> - new Step subtype;
> - narrow Settings-opening authority;
> - real FDA adapter;
> - final five-Trip fixture;
> - actual copy used;
> - generated topology;
> - test results;
> - restart semantics;
> - manual experiment instructions;
> - anything that proved awkward;
> - whether Trip changed;
> - whether Scheduler changed;
> - any deviation from `80-REAL-FDA-ONBOARDING-PLAN.md`.
>
> Update `30-SYSTEM-BOUNDARIES.md` only for boundaries that became concrete.
>
> ---
>
> ## Hard constraints
>
> Do not add:
>
> - generic Agent system;
> - Agent registry;
> - persisted Agent IDs;
> - generic condition engine;
> - generic action Step;
> - restart Step;
> - current-Step persistence;
> - polling;
> - automatic foreground verification;
> - production onboarding integration;
> - changes to `OnboardingGate`;
> - production FDA permission changes;
> - new routing machinery.
>
> If implementation seems to require any of these, stop and document why.
>
> ---
>
> ## Success criterion
>
> We should be able to manually do this with **MessageLens Development**:
>
> ```text
> FDA off
>     ↓
> real Presence introduction
>     ↓
> real FDA test fails
>     ↓
> real guidance
>     ↓
> Open System Settings
>     ↓
> Presence durably checkpoints verification
>     ↓
> enable FDA / restart
>     ↓
> MessageLens Development relaunches
>     ↓
> same ScheduleRun resumes at verification
>     ↓
> first text makes sense
>     ↓
> real FDA test now succeeds
>     ↓
> confirmation
> ```
>
> And through all of this:
>
> ```text
> Trip remains one boring class.
> Scheduler remains ignorant of FDA.
> ```
>
> If that remains true, the first real onboarding slice has fit the existing Presence architecture without modification.

That’s the prompt I’d use now. The especially interesting checkpoint will be **after System Settings opens**: if we relaunch and land on Trip 4 with sensible copy, the Trip-as-restart-unit idea has survived its first genuinely hostile real-world event.
