I’d make the next Codex pass a **read-only live visualization experiment** that combines three already-proven sources without letting any of them bleed into execution:

> We have now proved three independent Presence layers:
>
> ```text
> definitions prescribe
> ScheduleRun remembers the current checkpoint
> trace records what happened
> ```
>
> We also proved that a Mermaid topology can be generated mechanically from persisted Schedule / Trip / Step definitions, and that execution trace records the actual path taken without influencing routing.
>
> The next experiment is to combine those two observational views into a **development-only live Schedule visualization**.
>
> This must remain read-only.
>
> Do not change execution semantics.
>
> Do not change Presence database schema.
>
> Do not modify Scheduler, Trip, Step, or route resolution.
>
> ---
>
> ## Goal
>
> Build a development-only visualization of one Schedule where:
>
> - persisted definitions determine the static topology;
> - `schedule_runs.current_trip_occurrence_id` identifies the currently active Trip;
> - execution trace identifies Trips and route transitions already traversed.
>
> Conceptually:
>
> ```text
> definitions
>     -> draw balls and rods
>
> trace
>     -> show where execution has been
>
> ScheduleRun
>     -> show which Trip is active now
> ```
>
> This should make the original Presence mental model visible:
>
> > a series of points in the database, with the active point lit and the traversed route visible behind it.
>
> ---
>
> ## Read first
>
> Re-read:
>
> - `03-SCHEDULE-TRIP-EXPERIMENT/10-DATABASE-SCHEMA-PROPOSAL.md`
> - `03-SCHEDULE-TRIP-EXPERIMENT/40-FDA-DERIVED-ROUTING-IMPLEMENTATION.md`
> - `03-SCHEDULE-TRIP-EXPERIMENT/50-GENERATED-SCHEDULE-DIAGRAM.md`
> - `03-SCHEDULE-TRIP-EXPERIMENT/60-EXECUTION-TRACE-IMPLEMENTATION.md`
> - `30-SYSTEM-BOUNDARIES.md`
>
> Preserve the existing separation exactly:
>
> - definitions remain routing authority;
> - ScheduleRun remains restart/checkpoint authority;
> - trace remains observational history;
> - visualization is an observer only.
>
> ---
>
> ## Architectural constraint
>
> The visualization must not derive or decide execution.
>
> It must not:
>
> - choose the next Trip;
> - invoke Steps;
> - invoke FDA testing;
> - mutate ScheduleRun;
> - append trace;
> - infer checkpoint state from trace;
> - simulate execution;
> - create alternate routing metadata.
>
> It only reads.
>
> If removing the visualization entirely would change execution behavior, the experiment has failed.
>
> ---
>
> ## Reuse the existing Schedule-definition projection
>
> Do not build a second graph model if the existing read-only Schedule inspection / Mermaid derivation can be reused.
>
> The static topology should still come from:
>
> ```text
> ScheduleDefinition
>     -> ordered Trip occurrences
>     -> terminal Step routing contracts
> ```
>
> Continue to derive:
>
> - default-next edges from Schedule order;
> - fixed destinations from `FixedDestinationStep`;
> - conditional alternatives from `FdaTestStep`.
>
> Do not store visual graph edges in the database.
>
> ---
>
> ## New visualization read model
>
> Add the smallest read-only model needed to render one Schedule run.
>
> Conceptually it may contain:
>
> ```text
> Schedule topology
> current Trip occurrence
> traversed Trip occurrences
> traversed route transitions
> visit counts
> ```
>
> This model is presentation/inspection data only.
>
> Do not turn it into a new execution-domain object.
>
> Do not persist it.
>
> Naming could be something literal such as:
>
> ```text
> PresenceRunVisualization
> ```
>
> or:
>
> ```text
> ScheduleRunInspection
> ```
>
> Prefer boring names over framework language.
>
> ---
>
> ## Current Trip
>
> Read:
>
> ```text
> schedule_runs.current_trip_occurrence_id
> ```
>
> If non-null:
>
> - mark that Trip as current/active.
>
> If null:
>
> - mark the Schedule as complete;
> - no Trip is current.
>
> Do not infer current Trip from the last trace event.
>
> ScheduleRun is authoritative for current position.
>
> ---
>
> ## Traversed Trips
>
> Use trace history to determine which Trip occurrences have actually started.
>
> For example:
>
> ```text
> 1 -> 2 -> 5 -> 7 -> 2 -> 5 -> 7 -> 8
> ```
>
> should reveal:
>
> - Trip 1 visited once;
> - Trip 2 visited twice;
> - Trip 5 visited twice;
> - Trip 7 visited twice;
> - Trip 8 visited once.
>
> Prefer `trip_started` as the basis for visit counts.
>
> Do not deduplicate repeated visits.
>
> Repeated visits are meaningful historical evidence.
>
> ---
>
> ## Traversed edges
>
> Use `route_decision` events to identify actual transitions taken.
>
> Each route-decision event already contains:
>
> ```text
> source Trip occurrence
> routing_result_trip_definition_id
> selected_destination_trip_occurrence_id
> ```
>
> Build presentation-only edge traversal information from those rows.
>
> For example:
>
> ```text
> 2 -> 5
> ```
>
> may have traversal count 3.
>
> Do not infer taken edges merely because both endpoint Trips appear in the trace.
>
> Use the explicit recorded route decision.
>
> ---
>
> ## Minimal visual design
>
> Create a development-only visual view of the Schedule topology.
>
> It does not need to be beautiful yet.
>
> But make these states visually distinct:
>
> - never visited Trip;
> - visited Trip;
> - current Trip;
> - completed Schedule.
>
> And for edges:
>
> - possible but never traversed;
> - traversed at least once.
>
> If simple, annotate repeated visits/edges with counts such as:
>
> ```text
> ×2
> ×3
> ```
>
> Do not use animation yet.
>
> Do not build blinking transitions yet.
>
> First prove static live state.
>
> ---
>
> ## Rendering approach
>
> Choose the smallest practical rendering strategy.
>
> Possible options:
>
> - generate Mermaid with class/style annotations;
> - render an in-app custom Flutter diagram from the same inspection model;
> - render SVG or another local read-only representation.
>
> Prefer the approach that:
>
> - reuses the already-proven topology derivation;
> - keeps execution untouched;
> - makes current/traversed state visually obvious;
> - remains easy to inspect and test.
>
> If Mermaid styling is too awkward for live highlighting inside the Flutter development UI, do not force it. A small Flutter-native visualization is acceptable.
>
> However:
>
> **do not create a generic graph-rendering framework.**
>
> This is one Presence Schedule visualization.
>
> ---
>
> ## First target: current FDA fixture
>
> Use the existing FDA development Schedule:
>
> ```text
> batting order:
> 1 -> 2 -> 3 -> 4 -> 5 -> 7 -> 8
> ```
>
> Suppose the actual trace is:
>
> ```text
> 1 -> 2 -> 5 -> 7 -> 2 -> 5 -> 7
> ```
>
> and current checkpoint is:
>
> ```text
> Trip 7
> ```
>
> The visualization should show:
>
> - Trips 1, 2, 5, 7 as visited;
> - Trips 2, 5, 7 with repeated visit counts;
> - Trip 7 as current;
> - Trips 3, 4, 8 as not yet visited;
> - traversed edges:
>   - 1 -> 2
>   - 2 -> 5
>   - 5 -> 7
>   - 7 -> 2
> - possible-but-not-yet-used edges still visible.
>
> After fake FDA switches to Present and the run reaches Trip 8:
>
> - the active marker should move appropriately;
> - the newly traversed 7 -> 8 edge should become marked;
> - previous traversal history should remain visible.
>
> When Schedule completes:
>
> - no Trip is current;
> - completion should be clearly indicated;
> - historical path remains visible.
>
> ---
>
> ## Development interaction
>
> Integrate this into the existing disposable Presence experiment UI with something like:
>
> ```text
> Show Schedule Map
> ```
>
> or a dedicated panel/tab.
>
> It should update when:
>
> - a Step completes;
> - routing changes Trip;
> - the fake FDA condition changes and subsequent execution takes a different route;
> - the run restarts;
> - the run completes.
>
> Prefer ordinary provider/state refresh rather than adding custom event buses.
>
> Do not make the visualization part of the execution pipeline.
>
> ---
>
> ## Restart behavior
>
> This is an important visual test.
>
> Suppose:
>
> ```text
> Trip 5 started
> app closes
> app reopens
> ```
>
> ScheduleRun says Trip 5 is current.
>
> Trace may show Trip 5 was previously started.
>
> On restart, the new `trip_started` event will make Trip 5's visit count increase.
>
> The visualization should truthfully show:
>
> - Trip 5 current;
> - Trip 5 visited more than once if appropriate;
> - previous traversed route history intact.
>
> Do not try to “clean up” duplicate starts caused by restart.
>
> They are truthful observations.
>
> ---
>
> ## Read-only query composition
>
> Prefer composing the visualization from existing read seams:
>
> ```text
> loadDefinition(scheduleDefinitionId)
> loadExecutionTrace(scheduleRunId)
> load ScheduleRun/current checkpoint
> ```
>
> If one small dedicated read query materially simplifies this, add it, but keep it read-only.
>
> Do not add write responsibilities to an inspector repository.
>
> ---
>
> ## Tests
>
> Add focused tests proving:
>
> ### Current authority
>
> - current Trip comes from `ScheduleRun`, not trace;
> - completed run has no current Trip.
>
> ### Visit history
>
> Given repeated `trip_started` events, visit counts are correct.
>
> ### Edge history
>
> `route_decision` events mark exactly the actual edges traversed.
>
> ### Untaken alternatives
>
> Possible edges derived from definitions remain visible even when never traversed.
>
> ### Loop
>
> A trace containing:
>
> ```text
> 2 -> 5 -> 7 -> 2 -> 5 -> 7
> ```
>
> produces repeated visit/edge counts without any loop-specific code.
>
> ### Restart
>
> Restarted current Trip produces another visit while current authority still comes from ScheduleRun.
>
> ### Completion
>
> Completed Schedule renders no active Trip and preserves path history.
>
> ### Purity
>
> Visualization:
>
> - does not execute Steps;
> - does not invoke FDA authority;
> - does not mutate ScheduleRun;
> - does not append trace;
> - does not change Mermaid topology generation;
> - does not affect routing.
>
> ### Regression
>
> Existing execution tests, generated Mermaid tests, and trace tests remain unchanged and passing.
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
> `03-SCHEDULE-TRIP-EXPERIMENT/70-LIVE-SCHEDULE-VISUALIZATION.md`
>
> Document:
>
> - data sources used;
> - visualization read model;
> - how current Trip is determined;
> - how visited Trips are determined;
> - how traversed edges are determined;
> - how possible topology remains definition-derived;
> - restart rendering;
> - completion rendering;
> - tests;
> - whether any execution dependency was introduced;
> - anything awkward;
> - any architectural rule that had to change.
>
> Update `30-SYSTEM-BOUNDARIES.md` only if the new read-only visualization boundary deserves explicit documentation.
>
> ---
>
> ## Hard constraints
>
> Do not add:
>
> - animation;
> - blinking effects;
> - editor/drag-and-drop behavior;
> - graph mutation;
> - trace-driven execution;
> - current-position inference from trace;
> - generic graph framework;
> - persisted visualization state;
> - analytics projections;
> - production telemetry;
> - route simulation;
> - Schedule rewriting;
> - production onboarding UI.
>
> If any of those seem necessary, stop and explain why.
>
> ---
>
> ## Success criterion
>
> We should be able to look at one development view and see:
>
> ```text
> what could happen        <- definitions
> what has happened        <- trace
> what is happening now    <- ScheduleRun
> ```
>
> without those three sources becoming confused.
>
> The strongest result would be a visualization where:
>
> - all possible rods come from definitions;
> - travelled rods come from trace;
> - the lit ball comes from the current checkpoint.
>
> And deleting the visualization code entirely would have zero effect on execution.
