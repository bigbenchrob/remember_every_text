42-SPEC-SYSTEM exists to explain the app’s spec-driven architecture as a coherent system rather than as a collection of isolated mechanisms.

This folder is the authoritative home for documentation about:

* cross-surface specs
* sidebar cassette specs
* panel/view specs
* feature handling of specs
* coordinated rendering across sidebar, panel, and other surfaces
* stable vs ephemeral projection rules
* architectural invariants that keep these systems clean

How to use this folder

Start here if you need to understand:

* how the spec system works end to end
* where a new behavior belongs
* which layer owns a given decision
* what a feature is allowed to return
* how a sidebar or panel change should propagate through the app

Recommended reading order

1. GUIDED-OVERVIEW.md
    Read this first for a short map of the documentation set and the intended reading path.
2. CANONICAL-ARCHITECTURE/00-overview.md
    This is the primary architecture document. It explains the spec system as a unified pipeline.
3. The rest of CANONICAL-ARCHITECTURE/
    Read the focused documents for cross-surface flow, sidebar cassette handling, panel/view-spec handling, feature responsibilities, and invariants.
4. REFERENCE/
    Use these documents as deep-dive supporting material. They preserve important detail and historical nuance, but they are not the best entry point for first understanding.

Folder structure

* GUIDED-OVERVIEW.md
    Short navigational guide to this documentation set.
* CANONICAL-ARCHITECTURE/
    The curated and authoritative explanation of the spec system. This is the preferred source when making implementation decisions.
* REFERENCE/
    Legacy and deep-dive documents organized by topic. These remain valuable, but should be read in support of the canonical architecture docs rather than instead of them.

Interpretation rule

When a reference document and a canonical architecture document overlap, implementation should follow the canonical architecture layer unless the canonical document explicitly defers to the reference material for a more specific rule.

Core architectural idea

The app is organized around a spec-driven pipeline. User intent and global state do not flow directly into arbitrary feature-built widget trees. They flow through explicit specs, coordinators, resolvers, payloads, and view models into rendering surfaces.

Canonical pattern:

Spec → Coordinator → Resolver → Payload / ViewModel → Rendering

This pattern exists to preserve:

* ownership boundaries
* cross-surface consistency
* deterministic reconstruction from state
* testability
* resistance to architectural drift

What this folder is not

This folder is not:

* a generic feature-planning area
* a backlog or implementation scratchpad
* a substitute for feature-specific charters under 40-FEATURES
* a place for temporary exceptions unless they are being documented as explicit architectural caveats

If you are designing or changing a feature, use this folder to understand the governing rules, then apply those rules within the appropriate feature documentation under 40-FEATURES or the relevant feature work area.

Authoritative intent

All new work touching the spec system should align with the rules and boundaries described here. The purpose of this folder is not merely to describe the architecture, but to keep the architecture legible and stable as the app evolves.

GUIDED-OVERVIEW.md

TL;DR

Read this folder in layers.

* Start with the canonical architecture docs to understand the system as a whole.
* Use the reference docs only when you need additional detail on a particular subsystem.
* Do not infer architectural freedom from older or narrower documents without first checking the canonical layer.

What this documentation set is for

The spec system is one of the core organizing ideas of the app. It governs how state, intent, feature logic, and rendering interact across multiple surfaces.

The problem this documentation set solves is that the architecture can be understood incorrectly if read only in fragments. Sidebar cassette specs, panel view specs, feature coordinators, ephemeral projections, and cross-surface flow are all part of one system. They make the most sense when read together.

This folder gives that system a deliberate reading order.

Reading paths

Path A: I am new to this architecture

Read in this order:

1. CANONICAL-ARCHITECTURE/00-overview.md
2. CANONICAL-ARCHITECTURE/10-cross-surface-model.md
3. CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md
4. CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md
5. CANONICAL-ARCHITECTURE/40-feature-responsibilities.md
6. CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md

That path should give you the full mental model.

Path B: I know the app, but I need to place a change correctly

Read:

1. CANONICAL-ARCHITECTURE/00-overview.md
2. CANONICAL-ARCHITECTURE/40-feature-responsibilities.md
3. CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md

Then consult the specific architecture document for the surface you are changing.

Path C: I am working on sidebar behavior

Read:

1. CANONICAL-ARCHITECTURE/00-overview.md
2. CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md
3. CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md

Then use:

* REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/
* REFERENCE/55-EPHEMERAL-SPEC-HANDLING/

Path D: I am working on panel content or view selection

Read:

1. CANONICAL-ARCHITECTURE/00-overview.md
2. CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md
3. CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md

Then use:

* REFERENCE/56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/
* REFERENCE/58-COORDINATED-SPEC-DRIVEN-CONTENT-SYSTEM/

Path E: I am trying to understand feature ownership and boundaries

Read:

1. CANONICAL-ARCHITECTURE/00-overview.md
2. CANONICAL-ARCHITECTURE/40-feature-responsibilities.md
3. CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md

Then use:

* REFERENCE/52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/

The core mental model

The architecture should be understood as a controlled pipeline, not as a loose collaboration of widgets and providers.

The essential model is:

User intent / global flow state
→ spec selection
→ coordinator handling
→ resolver-produced payload
→ view model shaping
→ rendering on the appropriate surface

This matters because the architecture is trying to preserve several things at once:

* deterministic behavior
* reconstructable UI state
* cross-surface consistency
* clean app/feature boundaries
* freedom for features to provide content without taking over orchestration

How to think about the folders

CANONICAL-ARCHITECTURE/

This is the curated layer. It should be read as the primary statement of how the spec system works and what constraints must be preserved.

Use it when:

* starting new work
* deciding where logic belongs
* resolving ambiguity
* checking whether a proposed pattern is architecturally valid

REFERENCE/

This is the deep-dive layer. It contains valuable detailed material and subsystem-specific treatment, including historical reasoning and focused rules. It is important, but it is not the ideal first stop for understanding the system end to end.

Use it when:

* you need finer detail on one topic
* the canonical docs point you there
* you are auditing a subsystem
* you need the original narrower framing of a rule

How to use the reference docs safely

Do not treat a narrow reference document as permission to violate the broader system model.

Always check:

* whether the behavior you are reading about is stable or ephemeral
* whether the rule is local to one surface or global across surfaces
* whether a feature is being allowed to interpret a spec or is incorrectly being allowed to own orchestration
* whether a document is describing current architecture, historical context, or a caveat under active cleanup

What kinds of mistakes this folder is meant to prevent

This doc set exists partly to prevent recurring architectural drift, especially:

* features returning widgets or subtrees across boundaries
* coordinators taking on rendering responsibility
* procedural reconstruction of topology outside the approved spec system
* ephemeral actions accidentally becoming stable state
* surface-specific implementations drifting away from a shared cross-surface model
* developers reading one narrow document and missing the system-level invariants

Non-negotiable reading rule

Before implementing a change to the spec system, read at least:

* CANONICAL-ARCHITECTURE/00-overview.md
* the relevant surface-specific canonical document
* CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md

That minimum reading requirement will prevent most category errors.

Suggested intent of the canonical docs

00-overview.md
The end-to-end system and why it exists.

10-cross-surface-model.md
How sidebar, panel, onboarding, and other surfaces fit into one coordinated model.

20-sidebar-cassette-system.md
How sidebar cassette specs work, including stable and ephemeral behavior at the sidebar layer.

30-panel-viewspec-system.md
How panel content selection and rendering are driven by view specs and related orchestration.

40-feature-responsibilities.md
What features may do, what they must not do, and where the app-level orchestration boundary sits.

90-invariants-and-contracts.md
The hard rules, anti-patterns, and enforcement expectations that keep the system clean.

Closing guidance

When in doubt, prefer:

* explicit specs over implicit reconstruction
* app-level orchestration over feature-level takeover
* data payloads over widget return values
* deterministic flow over convenient shortcuts
* canonical architecture docs over piecemeal interpretation

The purpose of this folder is not just to explain the architecture, but to make the correct architectural path the easiest one to see.