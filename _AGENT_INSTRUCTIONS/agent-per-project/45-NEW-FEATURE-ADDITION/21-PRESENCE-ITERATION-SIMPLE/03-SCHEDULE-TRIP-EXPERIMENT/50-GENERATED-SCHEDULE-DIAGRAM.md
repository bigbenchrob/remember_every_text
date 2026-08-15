# Generated Schedule Diagram

## Status

Implemented as a read-only observability experiment on the `Ftr.prov-rules`
branch.

The experiment proves:

```text
persisted Presence definitions
    -> complete Schedule definition
    -> read-only Mermaid projection
```

The generated diagram is not routing authority. It contains no persisted edge,
runtime path, trace, or manually supplied fixture-specific route.

## Definition Loading

`PresenceScheduleRepository.loadDefinition(scheduleDefinitionId)` loads:

1. the Schedule definition;
2. its Trip occurrences ordered by position;
3. each canonical Trip definition;
4. each Trip's Step occurrences ordered by position;
5. each concrete Step subtype definition.

The method reads no `schedule_runs` row and performs no checkpoint. It reuses
the repository's existing discriminator-driven subtype reconstruction and
canonical identities rather than duplicating definition SQL in the inspector.

## Read-Only Renderer

The development-only `ScheduleMermaidRenderer` consumes the resulting
`ScheduleDefinition` directly. It does not create a second Presence model.

For every ordered Trip occurrence, it inspects only the terminal Step:

- terminal `TellStep`: resolve the next greater Schedule position, or Schedule
  completion when none exists;
- terminal `FixedDestinationStep`: resolve its canonical Trip definition ID in
  the inspected Schedule;
- terminal `FdaTestStep`: independently resolve its Present and Absent arms,
  using default-next for a null arm and canonical resolution for a non-null
  arm.

The renderer does not call `Step.complete()`. In particular, it never invokes
`FdaTestingAuthority`. It describes all possible alternatives rather than one
runtime path.

Malformed duplicate positions, duplicate canonical Trips, empty Trips, and
absent explicit destinations fail closed instead of producing a plausible
diagram.

## Mermaid Projection

Each node contains:

- canonical Trip identity;
- Trip name;
- concise Step composition.

One-Step Tell Trips include concise Tell text. Multi-Step Trips report their
Step count and subtype sequence. FDA-terminal Trips use a diamond presentation;
this is a rendering choice, not a specialized Trip category.

Edges distinguish:

- `default` batting-order progression;
- `explicit: Trip X` fixed routing;
- `Present: default` and `Absent: Trip X` condition-derived alternatives.

User-facing labels escape ampersands, quotes, angle brackets, and line breaks
before entering Mermaid syntax.

## Generated FDA Result

The checked development artifact is:

[`generated/fda_derived_routing_experiment.md`](generated/fda_derived_routing_experiment.md)

It is produced by:

```text
dart run tool/generate_presence_schedule_diagram.dart
```

The command creates a transient Presence database, persists the current FDA
fixture, reloads it through the repository, and writes the renderer's Markdown
output. The artifact is marked as generated and non-authoritative. A focused
test rejects drift between the fixture-derived output and the checked file.

The generated topology contains:

```text
batting order: 1 -> 2 -> 3 -> 4 -> 5 -> 7 -> 8

1 -> default 2
2 -> Present: default 3
2 -> Absent: Trip 5
3 -> default 4
4 -> explicit Trip 8
5 -> default 7
7 -> Present: default 8
7 -> Absent: Trip 2
8 -> complete
```

The `2 -> 5 -> 7 -> 2` loop therefore emerges mechanically even though
Presence stores no loop object.

The same projection reports simple topology facts that fall directly out of
the rendered edges:

- Trips: 7;
- default edges: 6;
- explicit edges: 3;
- conditional alternatives: 4;
- backward edges: 1;
- self-destinations: 0.

No cycle detector, path enumerator, reachability engine, or generalized graph
analysis was added.

## Development UI

The disposable experiment host now offers `Generate Schedule Diagram`. It
loads the diagram through the same repository definition seam, displays the
Mermaid source, and provides `Copy Mermaid`.

This is development UI only. Scheduler does not call the inspector, and
execution does not depend on it.

## Tests

Focused tests prove:

- linear Tell definitions render default edges through completion;
- a Fixed Destination edge replaces the otherwise adjacent default edge;
- the persisted FDA fixture renders both condition arms and the fixed route;
- null FDA arms resolve to actual default-next destinations rather than
  `null` or stop;
- the final default edge resolves to Schedule completion;
- rendering leaves `schedule_runs` and a runtime Trip unchanged;
- rendering never invokes the FDA authority;
- punctuation, quotes, line breaks, ampersands, and angle brackets are escaped;
- an absent explicit destination fails closed;
- the checked generated artifact matches current persisted fixture output.

Verification completed on August 8, 2026:

- 30 Presence tests passed;
- 353 architecture tripwires passed;
- `flutter analyze` reported no issues;
- the debug macOS application built successfully;
- formatting completed;
- `git diff --check` reported no whitespace errors.

## Hidden Execution Logic

No hidden execution logic had to be consulted.

The renderer does not inspect `PresenceScheduler`, runtime `Trip`, presentation
state, execution history, or trace. All effective routes follow from the same
ordered definitions and terminal Step configuration used by execution.

## What Proved Awkward

Producing a checked repository artifact directly from the running application
would mix runtime concerns with source-tree mutation. A small explicit
development command is clearer: it creates isolated transient storage, loads
through the real repository, and writes only the generated documentation file.

## Architectural Result

One genuine read-only boundary was added: complete Schedule definition loading
for inspection. No execution responsibility changed, no schema version changed,
and no graph metadata was persisted.

The Schedule can explain its own possible execution structure.
