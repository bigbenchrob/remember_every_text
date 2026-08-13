# Execution Trace Implementation

## Status

Implemented experimental slice.

This slice adds the third independent authority to the Schedule / Trip model:

```text
definitions prescribe
ScheduleRun remembers the current checkpoint
trace records what happened
```

Trace is observational only. Scheduler, Trip, Step, route resolution, restart,
and generated Schedule diagrams do not read it.

## Schema Version 4

Schema version 4 adds `execution_trace_events` with:

- one owning Schedule run;
- deterministic sequence within that run;
- one closed event type;
- optional Trip and Step occurrence provenance;
- optional route-result Trip definition and selected destination occurrence;
- a UTC observation timestamp.

`UNIQUE(schedule_run_id, sequence)` prevents duplicate positions. Foreign keys
reference the existing canonical and occurrence identities. Row checks keep
Schedule, Trip, Step, and route event shapes distinct and prohibit routing
fields on non-route events.

The v3-to-v4 migration creates only the trace table and its append-only
triggers. Existing definitions and active runs remain unchanged.

## Closed Event Vocabulary

The implemented events are:

```text
schedule_run_started
trip_started
step_started
step_completed
trip_completed
route_decision
schedule_run_completed
```

There are no FDA, Boolean, loop, retry, error-taxonomy, or arbitrary payload
events. Repeated ordinary events are enough to expose re-entry and restart.

## Append-Only Enforcement

SQLite triggers reject every `UPDATE` and `DELETE` against trace rows. Runtime
code exposes typed append operations for lifecycle observations and one
read-only `loadExecutionTrace(runId)` query. There is no general trace mutation
API.

The development `Run Again` action therefore no longer deletes the completed
run. It keeps that run and its trace, then creates a new active run with a new
`schedule_run_started` event. Ordinary launch still resumes the latest run and
does not reset completed work automatically.

## Sequence Allocation

Each append transaction selects the maximum sequence for its Schedule run and
inserts the next integer. This is the smallest mechanism that keeps ordering
deterministic under the experiment's single database authority. Timestamps are
recorded only as observational metadata.

No sequence-state table was introduced.

## Emission Points

The implementation emits:

- `schedule_run_started` when a run row is created;
- `trip_started` whenever Scheduler constructs the current Trip at Step 1;
- `step_started` immediately before concrete Step work;
- `step_completed` immediately after successful Step work;
- `trip_completed` when the terminal Step has supplied its routing result;
- `route_decision` after the repository resolves that result to an occurrence;
- `schedule_run_completed` when the checkpoint becomes null.

Scheduler requests lifecycle observations but never loads them. Concrete Steps
remain unaware that trace exists.

## Atomic Trip Boundary

The repository resolves the terminal `TripDefinitionId?` from definitions and
then commits the following in one database transaction:

```text
trip_completed
route_decision
schedule_runs.current_trip_occurrence_id update
schedule_run_completed, when the selected destination is null
```

The trace is not used to choose the checkpoint. Requiring these observations
to append successfully merely prevents committed checkpoint history from
disagreeing with the recorded route.

## Restart Semantics

Restart remains checkpoint-driven:

```text
load schedule_runs.current_trip_occurrence_id
reconstruct that Trip from definitions
start at Step 1
```

Reconstructing an incomplete Trip emits another `trip_started`, followed by
another `step_started` for Step 1. Existing events are preserved. The repeated
observations truthfully expose at-least-once Trip execution; they are not
deduplicated and do not alter recovery.

## Observed FDA Paths

The existing fixture was not changed. Tests prove these paths from ordinary
`trip_started` events:

```text
FDA present
1 -> 2 -> 3 -> 4 -> 8

FDA absent, then granted
1 -> 2 -> 5 -> 7 -> 8

Repeated absence, then escape
1 -> 2 -> 5 -> 7 -> 2 -> 5 -> 7 -> 8
```

The remediation cycle contains no loop event. Each pass is represented by the
same normal Trip, Step, and route-decision vocabulary. The trace contains no
Boolean result from either FDA test.

## Read And Development Presentation

`loadExecutionTrace(runId)` returns immutable domain events in sequence order.
A generated Riverpod family exposes that query to the disposable experiment
host. `Show Execution Trace` renders a small textual diagnostic; it cannot
advance work, select routes, mutate the run, or feed observations back into
execution.

No persisted path summary, diagram overlay, analytics API, or visualization
framework was added.

## Verification

Focused tests prove:

- v3-to-v4 migration preserves definitions and the active run;
- update and delete triggers reject trace mutation;
- sequence is unique per run;
- linear lifecycle ordering, including completion;
- the distinction between default-next and fixed canonical routing;
- all three FDA paths above;
- repeated ordinary events across the remediation cycle;
- repeated Trip and Step starts after restart;
- execution remains correct after trace rows are removed under explicit test
  authority;
- the generated Mermaid artifact remains byte-for-byte unchanged.

The full Presence suite, architecture tripwires, analyzer, debug macOS build,
formatting, and `git diff --check` are the completion gates for this slice.

## Architectural Result

No execution rule changed and no execution code began deriving authority from
trace. The resulting boundary is:

> Delete every trace row under explicit external authority and Presence still
> knows exactly what to execute next.

The only awkward consequence is deliberate: append-only trace history is
incompatible with deleting a completed run for the development `Run Again`
control. Retaining completed runs is the truthful resolution and does not
change normal restart semantics.
