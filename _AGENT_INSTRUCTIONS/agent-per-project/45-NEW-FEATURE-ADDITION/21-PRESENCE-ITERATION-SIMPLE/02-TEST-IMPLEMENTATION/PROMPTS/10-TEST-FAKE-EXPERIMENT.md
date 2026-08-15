Here is the next Codex prompt. I’d keep this one narrowly focused on proving **calculated routing** with a fake FDA check, while leaving Scheduler and Trip essentially untouched.

> We have now proved two routing modes in the Schedule / Trip / Step experiment:
>
> ```text
> terminal null
>     -> default next Trip in Schedule order
>
> terminal TripDefinitionId(X)
>     -> canonical Trip X in the active Schedule
> ```
>
> The fixed-destination implementation is documented in:
>
> - `03-SCHEDULE-TRIP-EXPERIMENT/10-DATABASE-SCHEMA-PROPOSAL.md`
> - `03-SCHEDULE-TRIP-EXPERIMENT/30-FIXED-DESTINATION-ROUTING-IMPLEMENTATION.md`
> - `30-SYSTEM-BOUNDARIES.md`
>
> The current boundaries are:
>
> - one ordinary `Trip` runtime class;
> - Trip executes Steps in order;
> - only the terminal Step result crosses the Trip boundary;
> - Trip relays `TripDefinitionId?` unchanged;
> - Scheduler resolves `null` or canonical Trip identity;
> - durable runtime state remains only the current Trip occurrence.
>
> The next experiment is to prove that the routing result can be **calculated by a concrete Step** rather than stored as one fixed destination.
>
> ---
>
> ## Goal
>
> Add one concrete condition-derived Step:
>
> ```text
> FdaTestStep
> ```
>
> using a fake FDA-testing authority.
>
> Its job is:
>
> ```text
> invoke FDA test authority
>     -> receive bool
>     -> choose one configured canonical Trip destination
>     -> return TripDefinitionId?
> ```
>
> The Boolean must remain local to the Step.
>
> Neither `Trip` nor `PresenceScheduler` should know:
>
> - that FDA was tested;
> - that a Boolean existed;
> - which outcome was true or false;
> - why a particular destination was chosen.
>
> From the Trip/Scheduler boundary, this must look exactly like every other terminal Step:
>
> ```text
> null
> ```
>
> or:
>
> ```text
> TripDefinitionId(X)
> ```
>
> ---
>
> ## Read first
>
> Re-read:
>
> - `10-DATABASE-SCHEMA-PROPOSAL.md`
> - `30-FIXED-DESTINATION-ROUTING-IMPLEMENTATION.md`
> - `30-SYSTEM-BOUNDARIES.md`
>
> Preserve all currently approved responsibility boundaries.
>
> In particular, the fixed-destination experiment already proved that canonical routing may target an earlier or later Trip without any special loop state. 30\-FIXED\-DESTINATION\-ROUTING\-IMPLEMENTATION.md
>
> ---
>
> ## New concrete Step subtype
>
> Add:
>
> ```text
> FdaTestStep
> ```
>
> Its definition should contain the two possible routing results:
>
> ```text
> presentDestinationTripDefinitionId : TripDefinitionId?
> absentDestinationTripDefinitionId  : TripDefinitionId?
> ```
>
> `null` on either arm means:
>
> ```text
> default next Trip
> ```
>
> A non-null value means:
>
> ```text
> explicit canonical Trip destination
> ```
>
> The Step should:
>
> 1. invoke its FDA-testing authority;
> 2. receive a Boolean result;
> 3. choose the corresponding configured arm;
> 4. return only the resulting `TripDefinitionId?`.
>
> Do not return the Boolean to Trip or Scheduler.
>
> Do not add a generalized Boolean/result wrapper.
>
> ---
>
> ## Testing authority
>
> For this experiment, introduce the smallest concrete boundary needed to make FDA testing injectable.
>
> Prefer something narrow, e.g. conceptually:
>
> ```text
> abstract interface class FdaTestingAuthority {
>   Future<bool> hasFullDiskAccess();
> }
> ```
>
> or equivalent naming consistent with the project.
>
> Provide a fake implementation for tests and the development fixture.
>
> Do not create:
>
> - agent registries;
> - handler registries;
> - plugin systems;
> - generic test authorities;
> - generalized capability frameworks.
>
> This is one concrete FDA-testing dependency only.
>
> If existing project code already contains a suitable FDA-check boundary, reuse it rather than duplicating it.
>
> ---
>
> ## Schema change
>
> Advance `presence.db` to the next schema version and add:
>
> ```text
> fda_test_step_definitions
> ```
>
> with:
>
> ```text
> step_definition_id
> present_destination_trip_definition_id nullable
> absent_destination_trip_definition_id nullable
> ```
>
> Both destination columns reference canonical:
>
> ```text
> trip_definitions.id
> ```
>
> They must never store Schedule Trip occurrence IDs.
>
> Update the closed Step discriminator set to include:
>
> ```text
> fda_test
> ```
>
> Preserve existing v1/v2 data through migration.
>
> Add a file-backed migration test.
>
> ---
>
> ## Schedule closure validation
>
> Extend the existing closure validation only as much as required.
>
> For every `FdaTestStep` used in a Schedule:
>
> - every non-null `present` destination must occur exactly once in that Schedule;
> - every non-null `absent` destination must occur exactly once in that Schedule.
>
> SQLite already guarantees at most one canonical Trip occurrence per Schedule.
>
> Repository/domain validation must guarantee presence.
>
> A missing configured destination must fail closed before execution.
>
> Do not build a generalized graph validator.
>
> ---
>
> ## Trip boundary
>
> Do not change `Trip` responsibility.
>
> `Trip` should continue to know only:
>
> ```text
> execute Steps in order
> discard nonterminal routing results
> relay terminal TripDefinitionId?
> ```
>
> It must not distinguish:
>
> - TellStep;
> - FixedDestinationStep;
> - FdaTestStep.
>
> No subtype inspection belongs in `Trip`.
>
> ---
>
> ## Scheduler boundary
>
> Ideally, `PresenceScheduler` should require **no new routing logic at all**.
>
> It already understands:
>
> ```text
> null
>     -> default next
>
> TripDefinitionId(X)
>     -> resolve canonical destination in active Schedule
> ```
>
> An FDA-derived result should enter through exactly that existing boundary.
>
> If Scheduler needs to know anything about FDA or Boolean outcomes, treat that as evidence that the model has failed this experiment and document it.
>
> ---
>
> ## Experimental Schedule
>
> Replace or extend the development fixture to approximate the hand-designed FDA loop.
>
> Use:
>
> ```text
> Trip 1
>     Tell
>     -> default Trip 2
>
> Trip 2
>     terminal FdaTestStep
>         FDA present -> null
>         FDA absent  -> Trip 5
>
> Trip 3
>     Tell
>     -> default Trip 4
>
> Trip 4
>     FixedDestinationStep -> Trip 8
>
> Trip 5
>     Tell "guide user to grant FDA"
>     -> default Trip 7
>
> Trip 7
>     terminal FdaTestStep
>         FDA present -> null
>         FDA absent  -> Trip 2
>
> Trip 8
>     Tell "continue onboarding"
> ```
>
> Schedule batting order:
>
> ```text
> 1
> 2
> 3
> 4
> 5
> 7
> 8
> ```
>
> Expected paths:
>
> ### FDA already present
>
> ```text
> 1 -> 2 -> 3 -> 4 -> 8 -> complete
> ```
>
> ### FDA absent, then granted
>
> ```text
> 1 -> 2 -> 5 -> 7 -> 8 -> complete
> ```
>
> ### FDA remains absent
>
> ```text
> 1 -> 2 -> 5 -> 7 -> 2 -> 5 -> 7 -> ...
> ```
>
> No loop object, retry object, attempt counter, or specialized Trip type should be required.
>
> ---
>
> ## Fake FDA control
>
> Make the development experiment easy to observe manually.
>
> Provide the smallest development-only control that lets the fake FDA authority return:
>
> ```text
> present
> ```
>
> or:
>
> ```text
> absent
> ```
>
> This may be a simple toggle or equivalent.
>
> The goal is to manually demonstrate:
>
> - present path;
> - remediation path;
> - repeated loop;
> - eventual escape from the loop after changing fake FDA state.
>
> Do not add production FDA UI.
>
> ---
>
> ## Restart test
>
> Prove that restart semantics remain unchanged even inside the FDA loop.
>
> Example:
>
> ```text
> Trip 5 is current
> app closes
> app reopens
>     -> Trip 5 begins at Step 1
> ```
>
> Or:
>
> ```text
> Trip 7 routes back to Trip 2
> checkpoint commits
> app closes
> app reopens
>     -> Trip 2 begins at Step 1
> ```
>
> No Boolean, test result, or previous route decision should need to be persisted.
>
> Durable authority must remain:
>
> ```text
> current_trip_occurrence_id
> ```
>
> ---
>
> ## Tests
>
> Add focused tests proving:
>
> ### Persistence/schema
>
> - `FdaTestStep` persists and reloads correctly;
> - both canonical destination arms survive close/reopen;
> - nullable arms represent default-next;
> - migration preserves existing Tell and FixedDestination definitions/runs.
>
> ### Local Boolean ownership
>
> - fake FDA authority returns true/false;
> - `FdaTestStep` converts that result to the configured `TripDefinitionId?`;
> - no Boolean leaves the Step boundary.
>
> ### Present path
>
> ```text
> 1 -> 2 -> 3 -> 4 -> 8
> ```
>
> ### Absent then granted
>
> ```text
> 1 -> 2 -> 5 -> 7 -> 8
> ```
>
> ### Repeated failure loop
>
> ```text
> 2 -> 5 -> 7 -> 2
> ```
>
> for a finite number of transitions.
>
> ### Escape from loop
>
> Start fake FDA as absent, allow at least one loop, then switch fake authority to present and prove progression to Trip 8.
>
> ### Closure
>
> Reject a Schedule where either non-null FDA destination is absent.
>
> ### Restart
>
> Restart from a Trip reached through FDA-derived routing and prove that only the current Trip checkpoint matters.
>
> ### Boundaries
>
> Prove or inspect that:
>
> - `Trip` contains no FDA logic;
> - Scheduler contains no FDA logic;
> - no Boolean routing logic appears outside `FdaTestStep` or its narrow testing authority.
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
> ## Execution trace
>
> Do not implement execution trace in this pass.
>
> We already know trace is observational and not required for routing or restart.
>
> First prove the complete FDA loop using the existing tiny runtime contract.
>
> ---
>
> ## Documentation
>
> Create:
>
> `03-SCHEDULE-TRIP-EXPERIMENT/40-FDA-DERIVED-ROUTING-IMPLEMENTATION.md`
>
> Document:
>
> - schema version/migration;
> - `FdaTestStep`;
> - FDA testing authority boundary;
> - Boolean ownership;
> - Schedule closure validation;
> - present path;
> - absent/remediation path;
> - repeated loop;
> - escape from loop;
> - restart result;
> - whether Trip changed;
> - whether Scheduler changed;
> - tests and verification;
> - anything awkward;
> - any architectural rule that had to change.
>
> Update `30-SYSTEM-BOUNDARIES.md` only for boundaries that became concrete or genuinely changed.
>
> ---
>
> ## Hard constraints
>
> Do not add:
>
> - TestTrip;
> - RouterTrip;
> - specialized Trip subclasses;
> - Trip behavior enums;
> - generic route tables;
> - universal Boolean/outcome abstractions;
> - agent registries;
> - generalized test framework;
> - arbitrary Step-to-Step routing;
> - loop/retry machinery;
> - visit counters;
> - current-Step persistence;
> - context bags;
> - execution trace;
> - production onboarding integration;
> - production FDA permission-changing behavior.
>
> If implementation appears to require any of these, stop and document why.
>
> ---
>
> ## Success criterion
>
> The experiment succeeds if we can describe the entire new capability as:
>
> ```text
> FdaTestStep asks one question.
>
> It turns the answer into:
>     null
>     or TripDefinitionId(X).
>
> Trip relays that value unchanged.
>
> Scheduler does exactly what it already did.
> ```
>
> Most importantly:
>
> ```text
> class Trip
> ```
>
> should remain just as boring as before.
>
> If adding conditional routing requires Trip or Scheduler to understand Boolean logic, FDA semantics, retries, or loop state, treat that as evidence against the model rather than hiding the complexity.

This should be the strongest test yet. If the whole FDA loop drops in as **one new Step subtype plus a narrow fake testing dependency**, while Trip and Scheduler barely change, then the architecture has earned a lot of confidence.
