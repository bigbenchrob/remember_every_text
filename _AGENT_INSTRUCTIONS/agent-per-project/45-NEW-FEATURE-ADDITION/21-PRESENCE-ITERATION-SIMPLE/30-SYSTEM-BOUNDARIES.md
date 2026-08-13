# Presence Iteration System Boundaries

## Purpose

This document prevents responsibility creep in the current implementation-led
Presence experiment.

It answers one question:

> What does each part know, and what must it never know?

## Status

This document is the current architectural authority for the iterative
Presence implementation.

The historical `43-PRESENCE` package is not authoritative for this experiment.
The approved Schedule / Trip / Step model is documented in
[`03-SCHEDULE-TRIP-EXPERIMENT/10-DATABASE-SCHEMA-PROPOSAL.md`](03-SCHEDULE-TRIP-EXPERIMENT/10-DATABASE-SCHEMA-PROPOSAL.md).

Implementation discoveries may change these boundaries only through an
explicit architectural decision. Silent exceptions are prohibited.

## Boundary Philosophy

1. Each part owns one responsibility.
2. Every part knows only enough to perform that responsibility.
3. Definitions prescribe; runtime state remembers the current checkpoint;
   trace records what happened.
4. Trace is an append-only observer. It never supplies execution, routing, or
   recovery authority.
5. Complexity belongs inside the specialist that understands it.
6. The current implementation proves default-next, fixed canonical, and one
   condition-derived canonical destination.

## Physical Database Authority

### Shared database infrastructure

Knows:

- the physical filename `presence.db`;
- admitted archive-root path resolution;
- long-lived database open and close lifecycle.

It constructs the physical executor and supplies `PresenceDatabase` through
the central database-provider boundary.

It knows nothing about:

- Schedule order;
- Trip execution;
- Step behavior;
- presentation.

Production backup, health-inventory, and reset policy remain intentionally
undecided. `presence.db` must not be added to destructive lifecycle operations
until production-preservation policy is explicitly approved.

### PresenceDatabase

Knows:

- the normalized Presence schema;
- relational keys and row constraints;
- schema creation and foreign-key activation.

It knows nothing about:

- which Schedule should run;
- Trip or Step execution;
- default-next behavior;
- presentation.

The schema receives an executor. It does not choose or open its physical file.

## Definition And Persistence Authority

### DriftPresenceScheduleRepository

Knows:

- how to validate and store Schedule, Trip, and Step definitions;
- how to load one complete Schedule definition for read-only inspection;
- how to reconstruct the five approved concrete Step subtypes and supply the
  source-readiness and Settings Steps' narrow authorities;
- how to load ordered Schedule Trip and Trip Step occurrences;
- how to create or load a Schedule run;
- how to explicitly replace the sole experimental run at the first Trip;
- how to resolve a terminal canonical Trip destination within the active
  Schedule;
- how to atomically checkpoint one completed Trip to the resolved occurrence;
- how to represent completion with a null current Trip occurrence.
- how to append closed, typed Schedule, Trip, Step, and route observations;
- how to load one run's trace in deterministic sequence order.

It knows nothing about:

- presentation;
- transient current-Step position;
- production FDA probing or permission-changing behavior;
- other feature logic or future condition-derived Step implementations.

Trace appends surrounding one completed Trip are part of the checkpoint
transaction, but the trace does not determine the checkpoint. The repository
first resolves the destination from definitions and the terminal Step result,
then atomically appends `trip_completed` and `route_decision`, updates the run
checkpoint, and, when appropriate, appends `schedule_run_completed`.

Definition validation requires every routing-capable Step to be terminal and
every configured canonical destination to occur exactly once in the containing
Schedule. SQLite enforces at most one occurrence; the repository enforces
presence. An unexpected missing destination also fails closed during
checkpoint resolution.

### ScheduleDefinition

Knows:

- its identity and name;
- its ordered Trip occurrences.

It contains no runtime state and performs no execution.

### TripDefinition

Knows:

- its identity and name;
- its ordered reusable Steps.

It contains no runtime state and performs no execution.

## Runtime Authority

### ScheduleRun

Knows:

- the active Schedule identity;
- the current Trip occurrence and definition, or that the Schedule is complete.

It does not store current-Step progress. Its durable authority is exactly the
current Trip checkpoint.

### PresenceScheduler

Knows:

- which Schedule definition it is executing;
- the current durable Schedule run;
- the transient Trip instance for the current occurrence;
- when a Trip has produced its terminal routing result;
- when to ask the repository for an atomic Trip-boundary checkpoint;
- that `null` requests default-next and a `TripDefinitionId` requests the
  matching occurrence in the active Schedule.

It does not execute concrete Step behavior, inspect Step subtypes, persist
current-Step position, infer progress from presentation, or read execution
trace.

### Trip

There is one ordinary runtime `Trip` class.

It knows:

- one reusable Trip definition;
- its transient current-Step index;
- how to execute Steps from first to last;
- that only the terminal Step's routing result crosses the Trip boundary.

It discards results from nonterminal Steps. It does not resolve routes, inspect
concrete Step subtypes, mutate a Schedule run, or persist its current position.

### Step

A concrete Step knows how to perform its own narrow work and return a possible
canonical Trip destination.

The implemented subtypes are:

- `TellStep`, which owns its text and completes with `null`;
- `FixedDestinationStep`, which owns one canonical `TripDefinitionId` and
  returns it unchanged;
- `FdaTestStep`, which asks one narrow readiness authority whether the protected
  Messages source can be read and converts the private Boolean answer into one
  configured `TripDefinitionId?` arm;
- `ContactsSourceReadinessStep`, which asks one narrow readiness authority
  whether a viable local Contacts source can be discovered and read, then
  converts the private Boolean answer into one configured
  `TripDefinitionId?` arm;
- `OpenFdaSettingsStep`, which asks one narrow Settings-opening authority to
  open the FDA pane and returns `null` only after that request succeeds.

A Step does not navigate the Schedule, select an occurrence, mutate durable
runtime state, or know whether it is terminal.

### MessagesSourceReadinessAuthority

Knows only how to answer whether MessageLens can perform the protected Messages
database read it requires. It does not claim to inspect the macOS Full Disk
Access switch.

It does not select a destination, navigate a Schedule, persist the answer, or
change system permission. The permanent Presence subsystem owns only this
narrow operational-readiness contract.

### FdaSettingsOpeningAuthority

Knows only how to request opening the macOS Full Disk Access pane.

It does not claim FDA was granted, test readability, select a destination,
navigate a Schedule, or persist workflow progress. Failure remains failure and
prevents the owning `OpenFdaSettingsStep` from completing.

Onboarding supplies one adapter that delegates both narrow FDA contracts to
its existing real `FullDiskAccess` service. Presence does not import
onboarding to reach that implementation. The disposable experiment host only
consumes the onboarding composition.

### ContactsSourceReadinessAuthority

Knows only how to answer whether MessageLens can currently discover and read a
viable local Contacts source. It does not expose Address Book paths, schema,
candidate ranking, or failure diagnostics to Presence.

It does not select a destination, navigate a Schedule, persist the answer, or
perform remediation. Onboarding supplies an adapter that delegates every
request to the existing
`AddressBookFolderRepository.getFinalFolderAggregate()` operation. Each retry
therefore performs fresh specialist-owned discovery and readability work.

Presence does not import the Address Book feature. The client owns the adapter
and the Address Book dependency.

## Presentation And Fixture Boundaries

### Required-sources onboarding Schedule

Knows:

- the onboarding-owned seven-Trip required-sources Schedule;
- stable identities, positions, approved copy, Messages and Contacts tests,
  remediation, and routing decisions used by the development experiment.

It knows nothing about database paths, run state, or presentation.

### LinearPresenceExperimentHost

Knows:

- how to observe the experimental Scheduler;
- how to display the current Schedule, Trip, and Step;
- how to request completion of the current Step;
- how to request an explicit fresh run after the experiment completes;
- how to report a Step failure without advancing the workflow.

It does not open databases, load definitions, advance indexes, choose the next
Trip, persist progress, or reset runs during ordinary initialization. Its
manual completion and `Run Again` controls exist only to make the routing
experiment repeatable and observable.

### ScheduleMermaidRenderer

Knows:

- one already loaded Schedule definition;
- Schedule batting order;
- the routing contracts encoded by the concrete terminal Step subtypes;
- how to render those possible Trip-boundary destinations as Mermaid text.

It does not inspect Scheduler or runtime Trip implementation, execute Steps,
invoke FDA testing, read or mutate Schedule runs, persist graph edges, or serve
production UI. It is a replaceable, development-only observer of executable
definitions.

The generated diagram is not routing authority. The repository-loaded
definition remains the source of truth.

### ScheduleTopologyProjector

Knows:

- one already loaded Schedule definition;
- Schedule batting order;
- the routing contracts encoded by terminal Step subtypes;
- how to project possible Trip nodes and edges as read-only inspection data.

It is the common definition projection used by both generated Mermaid and the
development live map. It does not read a Schedule run or trace, execute a Step,
invoke FDA testing, or mutate anything.

### PresenceRunVisualization

Knows only how to combine three read authorities for presentation:

- `ScheduleTopologyProjection` supplies what could happen;
- `ScheduleRun.currentTripOccurrenceId` supplies what is current;
- execution trace supplies visits and route transitions that happened.

It does not infer the current Trip from trace, select a route, invoke Steps,
append observations, or persist visualization state. The provider that builds
it calls only the existing definition, run, and trace read seams. The
Flutter-native map is a replaceable development renderer of this model.

### Execution trace

Knows:

- the closed universal event vocabulary;
- the Schedule run to which each observation belongs;
- monotonically increasing sequence within that run;
- optional canonical Trip and Step occurrence provenance;
- both sides of a route decision: the terminal routing result and the selected
  destination occurrence.

It knows nothing about:

- what should execute next;
- how a canonical destination resolves;
- whether a repeated Trip entry is a loop, retry, or restart;
- how an incomplete run recovers;
- FDA's private Boolean result.

Trace rows are append-only. SQLite rejects row update and deletion. Sequence is
allocated inside each append transaction from the current per-run maximum;
timestamps are metadata and never establish order.

`loadExecutionTrace(runId)` is a read-only diagnostic seam. The disposable
experiment UI may render it, but Scheduler, Trip, Step, run recovery, route
resolution, and generated diagrams must not call it.

## Restart Invariant

The Trip is the checkpoint and restart unit.

On restart:

1. the repository loads the Schedule run's current Trip occurrence;
2. it reconstructs that occurrence's Trip definition and ordered Steps;
3. the Scheduler creates a fresh runtime Trip;
4. that Trip begins at Step 1.

Completed Trips are not replayed. Incomplete current-Step progress is not
resumed. No trace or presentation state participates in recovery.

## Current Proven Result

Scheduler knows which Trip is current.

Trip runs its Steps from first to last.

Terminal Tell Step returns `null`.

Scheduler advances to the next Trip in Schedule order.

Terminal Fixed Destination Step returns a canonical `TripDefinitionId`.

Scheduler resolves that identity to the unique occurrence in the active
Schedule. The destination may be later or earlier than the current occurrence.

Trip remains unaware of which routing result it relays.

Terminal FDA Test Step awaits its testing authority, keeps the Boolean local,
and returns only its configured `TripDefinitionId?`. Trip and Scheduler contain
no FDA branch.

Terminal Open FDA Settings Step awaits its Settings-opening authority and
returns `null` only after the request succeeds. Failure leaves the transient
Step and durable Trip checkpoint unchanged.

The real five-Trip experiment proves both paths:

```text
FDA present:  introduce -> determine -> confirm -> complete
FDA absent:   introduce -> determine -> guide -> verify -> guide -> ...
```

The remediation cycle contains no loop or retry state. `Trip` and Scheduler
remain unchanged and ignorant of FDA.

The database remembers the current Trip across restart.

The complete possible topology can be projected from persisted definitions
without executing a Step or consulting hidden Scheduler logic. The generated
diagram exposes the `2 -> 5 -> 7 -> 2` loop even though no loop object exists.

The execution trace records the actual route taken as ordinary lifecycle and
route-decision events. Re-entry and restart produce repeated ordinary
`trip_started` and `step_started` observations. No Boolean, loop, retry, or
FDA-specific trace vocabulary is required.

The same definition projection can be combined read-only with one run and its
trace. This makes possible topology, actual path history, and the current
checkpoint visible together without merging their authority.

## Deliberately Unimplemented

- additional condition-derived routing Steps;
- production onboarding integration;
- generalized graph analysis, cycle detection, and path enumeration;
- current-Step persistence;
- specialized Trip classes;
- nested Journeys;
- generalized workflow infrastructure;
- production preservation, backup, health, and reset policy for `presence.db`.
