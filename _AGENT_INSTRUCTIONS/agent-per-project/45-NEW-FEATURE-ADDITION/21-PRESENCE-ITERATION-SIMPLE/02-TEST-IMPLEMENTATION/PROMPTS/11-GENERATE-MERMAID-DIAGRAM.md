Absolutely. This one should be fun because it is **entirely read-only**: no schema changes, no executor changes, no new routing concepts. We are asking Presence to describe itself.

I’d give Codex this:

> We have now proved the Schedule / Trip / Step execution model through:
>
> - default-next routing;
> - fixed canonical destination routing;
> - condition-derived FDA routing;
> - backward routing;
> - repeated loops;
> - escape from a loop when the tested condition changes;
> - durable Trip-boundary restart.
>
> The current FDA development Schedule is sufficiently interesting that a manually written Mermaid diagram made its logic dramatically easier to understand.
>
> We now want to prove that such a diagram can be **generated mechanically from the persisted Presence definitions themselves**.
>
> **This is a read-only observability experiment.**
>
> Do not change execution semantics.
>
> Do not change the Presence database schema.
>
> Do not modify Scheduler, Trip, or Step behavior.
>
> ---
>
> ## Goal
>
> Given a Schedule definition, generate a truthful Mermaid flowchart directly from its persisted:
>
> ```text
> Schedule
>     ordered Trip occurrences
>         Trip definitions
>             ordered Step occurrences
>                 concrete Step definitions
> ```
>
> The resulting Mermaid must describe the **possible execution topology encoded by the database**.
>
> It must not be a manually maintained architectural diagram.
>
> It must not duplicate routing configuration in another model.
>
> It must be a projection of the actual executable definition.
>
> ---
>
> ## Read first
>
> Re-read:
>
> - `03-SCHEDULE-TRIP-EXPERIMENT/10-DATABASE-SCHEMA-PROPOSAL.md`
> - `03-SCHEDULE-TRIP-EXPERIMENT/20-LINEAR-EXECUTION-IMPLEMENTATION.md`
> - `03-SCHEDULE-TRIP-EXPERIMENT/30-FIXED-DESTINATION-ROUTING-IMPLEMENTATION.md`
> - `03-SCHEDULE-TRIP-EXPERIMENT/40-FDA-DERIVED-ROUTING-IMPLEMENTATION.md`
> - `30-SYSTEM-BOUNDARIES.md`
>
> Also inspect the manually created FDA Mermaid explanation if it exists in the experiment documentation.
>
> Treat that diagram as an example of desired comprehensibility, **not as a source of routing truth**.
>
> The source of truth must be the Presence definitions.
>
> ---
>
> ## Architectural test
>
> This experiment asks one important question:
>
> > Can Presence explain its possible execution paths entirely from its persisted definitions?
>
> The inspector must not need to inspect:
>
> - `PresenceScheduler` implementation;
> - runtime `Trip` implementation;
> - presentation code;
> - execution history;
> - manually maintained graph edges;
> - hard-coded knowledge of the FDA fixture.
>
> It may know the contracts of concrete Step subtypes because those definitions are themselves part of Presence's executable definition model.
>
> If generation requires reverse-engineering hidden routing logic from Scheduler or Trip code, stop and document that as an architectural problem.
>
> ---
>
> ## New read-only component
>
> Create the smallest development-side/read-only component that can:
>
> 1. load one complete Schedule definition;
> 2. inspect its ordered Trip composition;
> 3. inspect each Trip's ordered Steps;
> 4. determine the terminal Step;
> 5. derive all possible Trip-boundary destinations;
> 6. emit Mermaid flowchart text.
>
> Naming is open, but prefer something literal such as:
>
> ```text
> PresenceScheduleInspector
> ```
>
> or:
>
> ```text
> ScheduleMermaidRenderer
> ```
>
> Do not create a generalized graph framework.
>
> Do not create a second domain model representing Presence.
>
> The output should be derived directly from existing definitions.
>
> ---
>
> ## Routing derivation
>
> For each Trip occurrence, determine its possible outgoing routes from its **terminal Step**.
>
> ### TellStep
>
> A terminal `TellStep` produces:
>
> ```text
> null
> ```
>
> Therefore:
>
> ```text
> destination = next Trip in Schedule batting order
> ```
>
> If no later Trip exists:
>
> ```text
> destination = Schedule complete
> ```
>
> ### FixedDestinationStep
>
> A terminal `FixedDestinationStep` contains:
>
> ```text
> destinationTripDefinitionId
> ```
>
> Resolve that canonical Trip ID to its unique occurrence in the inspected Schedule.
>
> Emit one explicit edge.
>
> ### FdaTestStep
>
> A terminal `FdaTestStep` contains:
>
> ```text
> presentDestinationTripDefinitionId : TripDefinitionId?
> absentDestinationTripDefinitionId  : TripDefinitionId?
> ```
>
> Derive two possible edges:
>
> ```text
> Present
> Absent
> ```
>
> For either null arm, derive the Schedule's default-next Trip.
>
> For either non-null arm, resolve the canonical destination in the Schedule.
>
> Do **not** run the FDA test.
>
> This inspector describes **possible topology**, not one runtime path.
>
> ---
>
> ## Important rule
>
> Reuse the existing Schedule closure and canonical-resolution rules.
>
> Do not implement a second subtly different interpretation of routing.
>
> If possible, extract/reuse a small read-only definition-resolution helper already implied by the repository rather than duplicating SQL or rules.
>
> But do not broaden production abstractions merely to satisfy the inspector.
>
> If a little development-only read model is cleaner, use it.
>
> The inspector must fail closed on malformed definitions rather than drawing a plausible but incorrect graph.
>
> ---
>
> ## Mermaid output
>
> Generate valid Mermaid, conceptually:
>
> ```text
> flowchart TD
>
>     T1["Trip 1<br/>Tell: Begin experiment"]
>     T2{"Trip 2<br/>Test FDA"}
>     ...
>
>     T1 -->|"default next"| T2
>     T2 -->|"Present: default next"| T3
>     T2 -->|"Absent"| T5
>     ...
> ```
>
> Exact formatting and node shapes may differ, but optimize for human comprehension.
>
> Suggested visual convention:
>
> - ordinary/informational Trip: rectangular node;
> - condition-derived terminal Step: diamond node if convenient;
> - fixed-destination Trip: rectangular node;
> - Schedule complete: terminal rectangle.
>
> However:
>
> **node shape is presentation only.**
>
> Do not reintroduce TestTrip or RouterTrip domain categories just to choose Mermaid shapes.
>
> The shape may be selected by inspecting the terminal Step subtype.
>
> ---
>
> ## Node content
>
> Each Trip node should display enough information to understand it.
>
> At minimum:
>
> ```text
> Trip <canonical id or useful identity>
> Trip name
> ```
>
> Also include a concise description of its Step composition.
>
> For a one-Step Trip:
>
> ```text
> Trip 2
> Test FDA
> ```
>
> For a multi-Step Trip, something like:
>
> ```text
> Trip 12
> 3 Steps
> Tell → Ask → Tell
> ```
>
> Do not dump full database payloads into the graph.
>
> Keep labels readable.
>
> Mermaid escaping must be correct for user-facing text.
>
> ---
>
> ## Edge labels
>
> Make default and explicit routing visually understandable.
>
> Possible conventions:
>
> ```text
> default
> ```
>
> ```text
> Trip 8
> ```
>
> ```text
> Present: default
> Absent: Trip 5
> ```
>
> The output should make clear which edges are:
>
> - derived from batting order;
> - explicitly nominated by a Step;
> - condition-derived alternatives.
>
> Do not manufacture a separate persisted distinction.
>
> This is rendering terminology only.
>
> ---
>
> ## First target: current FDA fixture
>
> Generate Mermaid from the current FDA development Schedule.
>
> The resulting topology should be equivalent to:
>
> ```text
> batting order:
> 1 -> 2 -> 3 -> 4 -> 5 -> 7 -> 8
> ```
>
> with effective routes:
>
> ```text
> 1 -> default 2
>
> 2:
>     Present -> default 3
>     Absent  -> 5
>
> 3 -> default 4
>
> 4 -> explicit 8
>
> 5 -> default 7
>
> 7:
>     Present -> default 8
>     Absent  -> 2
>
> 8 -> complete
> ```
>
> This expected topology is a **test oracle only**.
>
> Do not hard-code Trip numbers, FDA behavior, or these edges into the renderer.
>
> They must emerge from loading the fixture definitions.
>
> ---
>
> ## Development UI
>
> Add the smallest development-only way to view or copy the generated Mermaid.
>
> Possibilities include:
>
> - a button in the existing Presence experiment UI;
> - a development inspector panel;
> - a generated `.md`/`.mmd` artifact written into the experiment folder;
> - some combination of those if still small.
>
> Prefer usefulness over polish.
>
> At minimum, I want to be able to inspect the generated Mermaid text and render it easily.
>
> If practical without broadening scope, show:
>
> ```text
> Generate Schedule Diagram
> ```
>
> and display/copy the resulting Mermaid.
>
> Do not build a visual Schedule editor yet.
>
> ---
>
> ## Generated documentation artifact
>
> Also generate a development artifact from the current FDA fixture, for example:
>
> ```text
> 03-SCHEDULE-TRIP-EXPERIMENT/generated/
>     fda_derived_routing_experiment.md
> ```
>
> containing:
>
> - Schedule name/identity;
> - batting order;
> - generated Mermaid block;
> - optionally a small mechanically generated Trip summary.
>
> Mark it clearly:
>
> ```text
> GENERATED FROM PRESENCE DEFINITIONS
> DO NOT EDIT AS ROUTING AUTHORITY
> ```
>
> If generation of repository files from runtime code is awkward or violates project conventions, document that and instead provide the generator as a test/development command. Do not contort architecture merely to create a markdown file.
>
> ---
>
> ## Static analysis / validation opportunities
>
> During generation, report simple facts that naturally fall out of the topology, but do not build a graph-analysis framework.
>
> Useful examples:
>
> ```text
> Trips: 7
> Default edges: N
> Explicit edges: N
> Conditional alternatives: N
> Backward edges: N
> ```
>
> If trivial to derive, identify:
>
> - Trips with no inbound edge other than Schedule entry;
> - Trips with multiple incoming edges;
> - backward destinations;
> - self-destinations.
>
> Do not yet implement:
>
> - general cycle detection;
> - reachability analysis;
> - infinite-loop warnings;
> - path enumeration;
> - graph optimization.
>
> Those may become useful later, but they are not required to prove truthful generation.
>
> ---
>
> ## Tests
>
> Add focused tests proving:
>
> ### Linear Schedule
>
> Given:
>
> ```text
> A -> B -> C
> ```
>
> with terminal Tell Steps, generated Mermaid contains default:
>
> ```text
> A -> B
> B -> C
> C -> complete
> ```
>
> ### Fixed destination
>
> Given:
>
> ```text
> A
> B -> D
> C
> D
> ```
>
> generator emits:
>
> ```text
> A -> B
> B -> D
> D -> complete
> ```
>
> and does not incorrectly draw B -> C as its effective route.
>
> ### FDA-derived routing
>
> Generate from the existing FDA fixture and prove:
>
> ```text
> 2 Present -> 3
> 2 Absent  -> 5
> 7 Present -> 8
> 7 Absent  -> 2
> 4         -> 8
> ```
>
> without hard-coded fixture-specific logic.
>
> ### Default-null resolution
>
> Prove that a null condition arm is rendered as the actual default-next destination, not as “null” or “stop.”
>
> ### Completion
>
> Prove terminal default-next with no subsequent batting-order occurrence produces Schedule complete.
>
> ### Purity
>
> Prove generation:
>
> - does not mutate `schedule_runs`;
> - does not invoke `FdaTestingAuthority`;
> - does not execute Steps;
> - does not alter current Trip;
> - does not require execution trace.
>
> ### Escaping
>
> Add at least one label containing punctuation/quotes/newlines as appropriate and prove valid Mermaid-safe output.
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
> ## Database
>
> **No Presence schema version change should be required.**
>
> This feature reads existing definition data only.
>
> If implementation appears to require new persisted graph edges or diagram metadata, stop and explain why.
>
> That would contradict the purpose of the experiment.
>
> ---
>
> ## Runtime boundaries
>
> Do not modify the responsibilities of:
>
> ```text
> PresenceScheduler
> Trip
> Step
> ScheduleRun
> ```
>
> The diagram generator is an observer of definitions.
>
> It is not part of execution.
>
> Scheduler must not call it.
>
> Execution must not depend on it.
>
> ---
>
> ## Documentation
>
> Create:
>
> `03-SCHEDULE-TRIP-EXPERIMENT/50-GENERATED-SCHEDULE-DIAGRAM.md`
>
> Document:
>
> - what reads the definitions;
> - how default-next is derived;
> - how canonical destinations are resolved;
> - how condition-derived alternatives are represented;
> - Mermaid generation;
> - generated FDA result;
> - tests;
> - whether any hidden execution logic had to be consulted;
> - anything awkward;
> - any architectural rule that had to change.
>
> Update system boundaries only if a genuine new boundary deserves recording, probably as a read-only development/inspection boundary.
>
> ---
>
> ## Hard constraints
>
> Do not add:
>
> - persisted graph edges;
> - Mermaid fields to Presence tables;
> - specialized Trip categories;
> - TestTrip or RouterTrip;
> - graph-engine abstractions;
> - runtime path simulation;
> - execution trace;
> - editor/drag-and-drop authoring;
> - automatic Schedule rewriting;
> - production UI;
> - FDA execution during inspection;
> - Scheduler dependencies on inspection.
>
> If any of these seems necessary, stop and document why.
>
> ---
>
> ## Success criterion
>
> The experiment succeeds if:
>
> ```text
> Presence definitions
>     ↓
> read-only inspector
>     ↓
> Mermaid
> ```
>
> reproduces the actual FDA topology without manually supplied routing edges.
>
> In particular, the generated diagram should make the loop:
>
> ```text
> 2 -> 5 -> 7 -> 2
> ```
>
> visible even though **no loop object exists anywhere in Presence**.
>
> The strongest possible result would be:
>
> > The diagram contains no knowledge that the execution engine does not already derive from the same definitions.
>
> If that is true, we have demonstrated that the Schedule can explain its own structure.

This may be my favourite experiment yet, because there are only two possible outcomes and both are useful: either the graph falls straight out of the definitions—which is an extremely strong validation of the design—or the generator discovers some hidden piece of routing knowledge that we have accidentally buried elsewhere. Either way, we learn something important.
