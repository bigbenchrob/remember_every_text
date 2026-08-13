# Live Schedule Visualization

## Status

Implemented development-only experiment.

The live Schedule map combines three already-proven read authorities without
allowing any of them to substitute for another:

```text
definitions -> what could happen
trace       -> what has happened
ScheduleRun -> what is happening now
```

Removing the provider, inspection model, and map would have no effect on
execution.

## Data Sources

The visualization provider composes existing read seams only:

```text
loadDefinition(scheduleDefinitionId)
loadRun(scheduleRunId)
loadExecutionTrace(scheduleRunId)
```

It introduces no database schema, write repository, event bus, persisted
projection, or alternate routing metadata.

## Shared Definition Projection

`ScheduleTopologyProjector` is now the one read-only derivation of possible
Schedule topology. It projects:

- ordered Trip occurrences as points;
- default-next edges from Schedule batting order;
- fixed destinations from `FixedDestinationStep`;
- condition-derived alternatives from `FdaTestStep`;
- Schedule completion as a null destination.

Both `ScheduleMermaidRenderer` and the live map consume this projection. The
Mermaid output remains byte-for-byte unchanged. There is no second graph
interpretation and no stored edge table.

## Visualization Read Model

`PresenceRunVisualization` is presentation/inspection data. It contains:

- the shared `ScheduleTopologyProjection`;
- the Schedule run identity;
- the current Trip occurrence from the run;
- immutable visit counts by Trip occurrence;
- immutable traversal counts by recorded route transition.

`PresenceRunVisualizationBuilder` combines already-loaded values. It performs
no I/O and calls no execution authority.

## Current Trip

The current point comes exclusively from:

```text
schedule_runs.current_trip_occurrence_id
```

A non-null value identifies the highlighted Trip. A null value means the
Schedule is complete and no Trip is highlighted. The builder never examines
the final trace event to infer current position.

## Visited Trips

Each `trip_started` event increments the visit count for its Trip occurrence.
Counts are not deduplicated. Re-entry through routing and reconstruction after
restart therefore remain visible as ordinary repeated visits.

The FDA remediation path:

```text
1 -> 2 -> 5 -> 7 -> 2 -> 5 -> 7
```

naturally shows Trips 2, 5, and 7 as visited twice. No loop vocabulary or
cycle analysis is involved.

## Traversed Routes

Each `route_decision` event contributes one traversal using all three recorded
facts:

```text
source Trip occurrence
routing result Trip definition, nullable
selected destination Trip occurrence, nullable
```

The live map does not infer a route because both endpoint Trips were visited.
Possible but unused definition edges remain visible with neutral styling;
recorded transitions use the application accent and repeated traversals show a
count.

## Development Rendering

`Show Schedule Map` reveals a small Flutter-native view in the disposable
experiment host. It renders:

- neutral points for never-visited Trips;
- visited points and rods using the existing selection/accent language;
- the current point with the existing warning/orientation accent;
- completion with the existing success color;
- visit and repeated-edge counts;
- a compact route key preserving labels from the definition projection.

The drawing is intentionally specific to this experiment. It is not a generic
graph renderer and has no animation, editing, simulation, or production role.

The provider refreshes after every completed Step. A Trip transition,
completion, and any later route selected after changing the fake FDA condition
therefore appear on the next render. Starting a fresh development run changes
the provider's run identity and loads a new map without altering ordinary
restart semantics.

## Restart And Completion

On restart, Scheduler reconstructs the checkpointed Trip and records another
`trip_started`. The visualization therefore shows:

- the current Trip from the unchanged run checkpoint;
- one additional visit from trace;
- all prior visits and route transitions.

When the Schedule completes, the run checkpoint is null. The active highlight
disappears, completion is shown explicitly, and the historical path remains.

## Verification

Focused tests prove:

- current authority comes from `ScheduleRun`, even when trace ends elsewhere;
- repeated `trip_started` events produce exact visit counts;
- route-decision events produce exact transition counts;
- untaken definition alternatives remain in the topology with zero traversals;
- the `2 -> 5 -> 7 -> 2 -> 5 -> 7` path needs no loop-specific code;
- restart adds a visit without changing checkpoint authority;
- completed runs have no current Trip and retain history;
- topology projection and inspection do not invoke FDA testing;
- generated Mermaid remains byte-for-byte unchanged.

The full Presence suite, architecture tripwires, analyzer, debug macOS build,
formatting, and `git diff --check` remain completion gates.

## Architectural Result

No execution dependency or architectural rule changed.

The visualization is a terminal observer:

```text
possible rods  <- definitions
travelled rods <- trace
lit point      <- ScheduleRun
```

One deliberate limitation remains. If two private condition outcomes produce
the same universal routing result and selected destination, the trace cannot
distinguish those private outcomes. The visualization truthfully treats them
as the same observed transition rather than inventing condition-specific
evidence that the universal trace intentionally does not record.
