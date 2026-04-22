# Guided Overview

## TL;DR

Read this folder in layers.

* Start with the canonical architecture docs to understand the system as a whole.
* Use the reference docs only when you need additional detail on a particular subsystem.
* Do not infer architectural freedom from older or narrower documents without first checking the canonical layer.

## What this documentation set is for

The spec system is one of the core organizing ideas of the app. It governs how state, intent, feature logic, and rendering interact across multiple surfaces.

The architecture can be misunderstood if read only in fragments. Sidebar cassette specs, panel view specs, feature coordinators, ephemeral projections, and cross-surface flow are all part of one system. They make the most sense when read together.

This guide gives that system a deliberate reading order.

## Reading paths

### Path A: I am new to this architecture

Read in this order:

1. [CANONICAL-ARCHITECTURE/00-overview.md](CANONICAL-ARCHITECTURE/00-overview.md)
2. [CANONICAL-ARCHITECTURE/10-cross-surface-model.md](CANONICAL-ARCHITECTURE/10-cross-surface-model.md)
3. [CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md](CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md)
4. [CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md](CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md)
5. [CANONICAL-ARCHITECTURE/40-feature-responsibilities.md](CANONICAL-ARCHITECTURE/40-feature-responsibilities.md)
6. [CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md](CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md)

That path gives the full mental model.

### Path B: I know the app, but I need to place a change correctly

Read:

1. [CANONICAL-ARCHITECTURE/00-overview.md](CANONICAL-ARCHITECTURE/00-overview.md)
2. [CANONICAL-ARCHITECTURE/40-feature-responsibilities.md](CANONICAL-ARCHITECTURE/40-feature-responsibilities.md)
3. [CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md](CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md)

Then consult the specific canonical document for the surface you are changing.

### Path C: I am working on sidebar behavior

Read:

1. [CANONICAL-ARCHITECTURE/00-overview.md](CANONICAL-ARCHITECTURE/00-overview.md)
2. [CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md](CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md)
3. [CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md](CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md)

Then use:

* [REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/](REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/)
* [REFERENCE/55-EPHEMERAL-SPEC-HANDLING/](REFERENCE/55-EPHEMERAL-SPEC-HANDLING/)

### Path D: I am working on panel content or view selection

Read:

1. [CANONICAL-ARCHITECTURE/00-overview.md](CANONICAL-ARCHITECTURE/00-overview.md)
2. [CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md](CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md)
3. [CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md](CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md)

Then use:

* [REFERENCE/56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/](REFERENCE/56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/)
* [REFERENCE/58-COORDINATED-SPEC-DRIVEN-CONTENT-SYSTEM/](REFERENCE/58-COORDINATED-SPEC-DRIVEN-CONTENT-SYSTEM/)

### Path E: I am trying to understand feature ownership and boundaries

Read:

1. [CANONICAL-ARCHITECTURE/00-overview.md](CANONICAL-ARCHITECTURE/00-overview.md)
2. [CANONICAL-ARCHITECTURE/40-feature-responsibilities.md](CANONICAL-ARCHITECTURE/40-feature-responsibilities.md)
3. [CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md](CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md)

Then use:

* [REFERENCE/52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/](REFERENCE/52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/)

## Core mental model

The architecture is a controlled pipeline, not a loose collaboration of widgets and providers.

```text
User intent / global flow state
→ Spec
→ Coordinator
→ Resolver
→ Payload / ViewModel
→ Rendering
```

This preserves:

* deterministic behavior
* reconstructable UI state
* cross-surface consistency
* clean app/feature boundaries
* freedom for features to provide content without taking over orchestration

## How to think about the folders

### CANONICAL-ARCHITECTURE/

This is the curated layer. It is the primary statement of how the spec system works and what constraints must be preserved.

Use it when:

* starting new work
* deciding where logic belongs
* resolving ambiguity
* checking whether a proposed pattern is architecturally valid

### REFERENCE/

This is the deep-dive layer. It contains valuable detailed material and subsystem-specific treatment, including historical reasoning and focused rules.

Use it when:

* you need finer detail on one topic
* the canonical docs point you there
* you are auditing a subsystem
* you need the original narrower framing of a rule

## How to use reference docs safely

Do not treat a narrow reference document as permission to violate the broader system model.

If a reference document appears to contradict the canonical architecture, treat it as legacy or transitional unless explicitly stated otherwise.

Always check:

* whether the behavior is stable or ephemeral
* whether the rule is local to one surface or global across surfaces
* whether a feature is interpreting an approved spec variant or taking over app-level orchestration
* whether a document is describing current architecture, historical context, or a caveat under active cleanup

## Mistakes this folder prevents

This doc set exists partly to prevent recurring architectural drift:

* features returning widgets or subtrees across data-only coordinator boundaries
* coordinators taking on rendering responsibility
* procedural reconstruction of topology outside the approved spec system
* ephemeral actions accidentally becoming stable state
* surface-specific implementations drifting away from a shared cross-surface model
* developers reading one narrow document and missing system-level invariants

## Non-negotiable reading rule

Before implementing a change to the spec system, read at least:

* [CANONICAL-ARCHITECTURE/00-overview.md](CANONICAL-ARCHITECTURE/00-overview.md)
* the relevant surface-specific canonical document
* [CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md](CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md)

That minimum reading requirement prevents most category errors.

## Canonical docs

* [00-overview.md](CANONICAL-ARCHITECTURE/00-overview.md): end-to-end system and why it exists
* [10-cross-surface-model.md](CANONICAL-ARCHITECTURE/10-cross-surface-model.md): sidebar, panel, onboarding, and related surfaces as one coordinated model
* [20-sidebar-cassette-system.md](CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md): sidebar cassette specs, stable projection, and ephemeral behavior
* [30-panel-viewspec-system.md](CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md): panel content selection and rendering through view specs
* [40-feature-responsibilities.md](CANONICAL-ARCHITECTURE/40-feature-responsibilities.md): feature boundaries and app-level orchestration ownership
* [90-invariants-and-contracts.md](CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md): hard rules, anti-patterns, and enforcement expectations

## Closing guidance

When in doubt, prefer:

* explicit specs over implicit reconstruction
* durable flow state over widget-derived meaning
* data-only coordinator boundaries over widget transport
* local topology rules over procedural branch assembly
