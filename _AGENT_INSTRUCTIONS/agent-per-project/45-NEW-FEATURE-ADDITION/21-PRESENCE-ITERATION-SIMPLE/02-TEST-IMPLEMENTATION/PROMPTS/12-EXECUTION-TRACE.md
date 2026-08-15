> We have now proved that Presence can mechanically generate a Mermaid diagram of all possible Schedule routes directly from persisted definitions.
>
> The current architecture is documented in:
>
> - `03-SCHEDULE-TRIP-EXPERIMENT/10-DATABASE-SCHEMA-PROPOSAL.md`
> - `03-SCHEDULE-TRIP-EXPERIMENT/20-LINEAR-EXECUTION-IMPLEMENTATION.md`
> - `03-SCHEDULE-TRIP-EXPERIMENT/30-FIXED-DESTINATION-ROUTING-IMPLEMENTATION.md`
> - `03-SCHEDULE-TRIP-EXPERIMENT/40-FDA-DERIVED-ROUTING-IMPLEMENTATION.md`
> - `03-SCHEDULE-TRIP-EXPERIMENT/50-GENERATED-SCHEDULE-DIAGRAM.md`
> - `30-SYSTEM-BOUNDARIES.md`
>
> The generated-diagram experiment established:
>
> ```text
> definitions prescribe
> runtime state remembers the current checkpoint
> ```
>
> We now want to add the third layer:
>
> ```text
> trace records what happened
> ```
>
> **This experiment is observational only.**
>
> The trace must never become execution authority.
>
> ---
>
> ## Goal
>
> Add an append-only execution trace that records the actual path taken through a Schedule run.
>
> Given a run such as:
>
> ```text
> 1 -> 2 -> 5 -> 7 -> 2 -> 5 -> 7 -> 8
> ```
>
> we should be able to reconstruct that history afterward from trace events alone.
>
> However:
>
> **Scheduler, Trip, Step, and restart logic must not consult the trace to decide what happens next.**
>
> The durable execution checkpoint remains:
>
> ```text
> schedule_runs.current_trip_occurrence_id
> ```
>
> ---
>
> ## Read first
>
> Re-read the documents above before changing code.
>
> Preserve all current boundaries:
>
> - definitions are immutable routing authority;
> - `ScheduleRun` stores only the current Trip checkpoint;
> - `Trip` executes Steps and relays the terminal `TripDefinitionId?`;
> - `PresenceScheduler` resolves the next Trip;
> - concrete Steps own their own logic;
> - the generated diagram reads definitions only.
>
> The trace must sit beside those systems, not inside their decision logic.
>
> ---
>
> ## Schema
>
> Implement the previously approved:
>
> ```text
> execution_trace_events
> ```
>
> Advance `presence.db` to the next schema version.
>
> Use the approved conceptual fields:
>
> ```text
> id
> schedule_run_id
> sequence
> event_type
> trip_occurrence_id nullable
> step_occurrence_id nullable
> routing_result_trip_definition_id nullable
> selected_destination_trip_occurrence_id nullable
> occurred_at_utc_us
> ```
>
> Adapt names only if existing Drift conventions require it.
>
> Preserve:
>
> ```text
> UNIQUE(schedule_run_id, sequence)
> ```
>
> Use foreign keys to existing canonical/occurrence identities.
>
> The trace must remain append-only.
>
> Prefer SQLite triggers rejecting:
>
> ```text
> UPDATE
> DELETE
> ```
>
> on trace rows.
>
> Do not add analytics tables or derived projections.
>
> ---
>
> ## Initial event vocabulary
>
> Implement only:
>
> ```text
> schedule_run_started
> trip_started
> step_started
> step_completed
> trip_completed
> route_decision
> schedule_run_completed
> ```
>
> Keep the set closed and explicit.
>
> Do not add:
>
> - FDA-specific events;
> - Boolean-result events;
> - retry events;
> - loop events;
> - error taxonomies;
> - arbitrary JSON payloads.
>
> The trace records universal execution facts only.
>
> ---
>
> ## Event meaning
>
> ### schedule_run_started
>
> Record once when a new run begins.
>
> ### trip_started
>
> Record whenever a runtime Trip begins from Step 1.
>
> This includes:
>
> - first execution;
> - execution after default-next;
> - execution after explicit routing;
> - re-entry through a loop;
> - restart of an incomplete current Trip after app relaunch.
>
> ### step_started
>
> Record immediately before one Step begins its concrete work.
>
> ### step_completed
>
> Record when that Step successfully completes.
>
> Do not add generic outcome payloads.
>
> ### trip_completed
>
> Record when the terminal Step has completed and the Trip has produced its `TripDefinitionId?` result.
>
> ### route_decision
>
> Record both sides of the Trip/Scheduler boundary:
>
> ```text
> routing_result_trip_definition_id
> selected_destination_trip_occurrence_id
> ```
>
> Interpret:
>
> ```text
> routing_result = null
> selected destination = next Trip occurrence
> ```
>
> or:
>
> ```text
> routing_result = TripDefinitionId(X)
> selected destination = resolved occurrence of X
> ```
>
> If the Schedule completes:
>
> ```text
> selected_destination_trip_occurrence_id = null
> ```
>
> ### schedule_run_completed
>
> Record when the run checkpoint becomes complete.
>
> ---
>
> ## Critical separation
>
> The execution trace must never be queried by:
>
> ```text
> PresenceScheduler
> Trip
> Step
> ScheduleRun recovery
> route resolution
> default-next calculation
> generated Schedule diagram
> ```
>
> Restart must continue to do only:
>
> ```text
> load current_trip_occurrence_id
> reconstruct current Trip
> start at Step 1
> ```
>
> If trace rows are missing, corrupt, or incomplete, execution authority must still come from `schedule_runs` and definitions.
>
> ---
>
> ## Transaction boundaries
>
> Be explicit about how trace writes relate to checkpoint writes.
>
> For this experiment, prefer a coherent atomic boundary where possible.
>
> In particular, consider whether:
>
> ```text
> trip_completed
> route_decision
> checkpoint update
> ```
>
> should be committed in one transaction so the observed route and durable checkpoint cannot disagree.
>
> Likewise:
>
> ```text
> schedule_run_completed
> ```
>
> should correspond truthfully to the checkpoint becoming null.
>
> Do not invent distributed reliability machinery.
>
> If atomic trace + checkpoint introduces an architectural conflict, document it.
>
> ---
>
> ## Sequence numbering
>
> Each trace row must have a deterministic monotonically increasing:
>
> ```text
> sequence
> ```
>
> within one Schedule run.
>
> Do not use timestamps for ordering.
>
> Timestamps are observational metadata only.
>
> Choose the smallest safe mechanism for allocating the next sequence number inside the append transaction.
>
> Do not create a separate sequence-state table unless genuinely required.
>
> ---
>
> ## Restart semantics
>
> Trace a real restart correctly.
>
> Example:
>
> ```text
> Trip 5 started
> Step 501 started
> app terminates before Trip 5 completes
> ```
>
> After relaunch:
>
> ```text
> Trip 5 started
> Step 501 started
> ...
> ```
>
> again.
>
> That repetition is truthful and desirable.
>
> The trace should reveal that Trip 5 was entered twice.
>
> Do not attempt to “deduplicate” restart events.
>
> Do not use trace to decide that Step 501 had already started.
>
> Trip restart semantics remain at-least-once.
>
> ---
>
> ## FDA development fixture
>
> Use the existing FDA-derived routing fixture unchanged.
>
> Exercise at least these paths:
>
> ### FDA present
>
> ```text
> 1 -> 2 -> 3 -> 4 -> 8 -> complete
> ```
>
> ### FDA absent then granted
>
> ```text
> 1 -> 2 -> 5 -> 7 -> 8 -> complete
> ```
>
> ### repeated failure then escape
>
> ```text
> 1 -> 2 -> 5 -> 7 -> 2 -> 5 -> 7 -> 8 -> complete
> ```
>
> The trace should make those paths obvious without any special loop event.
>
> ---
>
> ## Read-only trace query
>
> Add the smallest read-only repository/query seam needed to load trace events for one Schedule run in `sequence` order.
>
> Prefer something literal such as:
>
> ```text
> loadExecutionTrace(runId)
> ```
>
> Do not add analytics APIs.
>
> Do not expose mutation methods beyond the narrow internal append mechanism required by execution.
>
> ---
>
> ## Development UI
>
> Extend the disposable Presence experiment UI with a small:
>
> ```text
> Show Execution Trace
> ```
>
> view.
>
> It should display events in sequence order, e.g.:
>
> ```text
> #01 Schedule started
> #02 Trip 1 started
> #03 Step 101 started
> #04 Step 101 completed
> #05 Trip 1 completed
> #06 Route: default -> Trip 2
> ...
> ```
>
> Keep this diagnostic, not polished.
>
> Do not build the blinking-lights visualization yet.
>
> Do not overlay trace on Mermaid yet.
>
> First prove that the historical record is truthful.
>
> ---
>
> ## Optional mechanically derived path summary
>
> If trivial, add a read-only helper that derives:
>
> ```text
> 1 -> 2 -> 5 -> 7 -> 2 -> 5 -> 7 -> 8
> ```
>
> from `trip_started` or `route_decision` events.
>
> This is presentation convenience only.
>
> Do not persist the summary.
>
> Do not use it for execution.
>
> ---
>
> ## Tests
>
> Add focused tests proving:
>
> ### Schema/migration
>
> - migration preserves existing Schedule definitions and active runs;
> - trace table exists after upgrade;
> - update/delete of trace rows is rejected;
> - sequence is unique per run.
>
> ### Linear execution
>
> For:
>
> ```text
> A -> B -> C -> complete
> ```
>
> prove the expected lifecycle event order.
>
> ### Fixed routing
>
> For:
>
> ```text
> A -> B -> D
> ```
>
> prove `route_decision` records:
>
> ```text
> routing result = D
> selected occurrence = D occurrence
> ```
>
> ### Default routing
>
> Prove `route_decision` distinguishes:
>
> ```text
> routing result = null
> selected occurrence = default-next
> ```
>
> ### FDA-derived route
>
> Prove the trace records the actual path taken but contains no Boolean field/event.
>
> ### Loop
>
> Prove repeated:
>
> ```text
> 2 -> 5 -> 7 -> 2
> ```
>
> appears as repeated ordinary Trip lifecycle and route-decision events.
>
> No loop-specific event should exist.
>
> ### Restart
>
> Close/reopen during an incomplete Trip and prove:
>
> - same Trip produces another `trip_started`;
> - Step execution begins again at Step 1;
> - existing trace history is preserved;
> - current checkpoint alone determines recovery.
>
> ### Completion
>
> Prove:
>
> ```text
> route_decision selected destination = null
> ```
>
> is followed truthfully by:
>
> ```text
> schedule_run_completed
> ```
>
> ### Purity
>
> Prove execution still works if trace is read never.
>
> Ensure route resolution does not query `execution_trace_events`.
>
> ### Diagram independence
>
> Existing generated Mermaid output must be unchanged by trace implementation.
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
> `03-SCHEDULE-TRIP-EXPERIMENT/60-EXECUTION-TRACE-IMPLEMENTATION.md`
>
> Document:
>
> - schema version change;
> - event table;
> - append-only enforcement;
> - sequence allocation;
> - transaction boundaries;
> - event emission points;
> - restart semantics;
> - FDA present path trace;
> - remediation-loop trace;
> - escape-from-loop trace;
> - UI/query seam;
> - tests and verification;
> - whether any execution code began depending on trace;
> - anything awkward;
> - any architectural rule that had to change.
>
> Update `30-SYSTEM-BOUNDARIES.md` with one explicit observational trace boundary if appropriate.
>
> ---
>
> ## Hard constraints
>
> Do not add:
>
> - trace-driven execution;
> - trace-driven restart;
> - generic event sourcing;
> - event replay;
> - snapshots;
> - analytics tables;
> - FDA-specific trace schema;
> - Boolean result columns;
> - arbitrary JSON event payloads;
> - loop/retry events;
> - current-Step persistence;
> - TripRun/StepRun state;
> - generalized logging framework;
> - Mermaid overlay/highlighting;
> - production telemetry transport;
> - network upload.
>
> If the task appears to require event sourcing or replay to work, stop: that would violate the model.
>
> ---
>
> ## Success criterion
>
> We should finish able to say:
>
> ```text
> Definitions tell Presence where it may go.
>
> ScheduleRun remembers where it is.
>
> Trace records where it went.
> ```
>
> And for a run like:
>
> ```text
> 1 -> 2 -> 5 -> 7 -> 2 -> 5 -> 7 -> 8
> ```
>
> the trace should simply show that path as ordinary repeated events.
>
> No component should ever need to understand:
>
> > "this is a loop"
>
> The strongest result would be:
>
> > Delete every trace row and Presence would still know exactly what to execute next.
>
> If that remains true, the observational boundary is clean.
