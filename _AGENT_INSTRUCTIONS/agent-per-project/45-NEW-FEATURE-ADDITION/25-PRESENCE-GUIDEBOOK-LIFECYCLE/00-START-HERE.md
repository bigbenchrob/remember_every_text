---
tier: project
scope: presence-guidebook-lifecycle
owner: agent-per-project
last_reviewed: 2026-08-15
source_of_truth: doc
links:
  - 01-PRESENCE-GUIDEBOOK-LIFECYCLE-ARCHITECTURE-AUDIT.md
  - 02-PRESENCE-GUIDEBOOK-CATALOG-CONTRACT-IMPLEMENTATION.md
  - 03-FEATURE-SUSPENSION-HANDOFF.md
  - ../23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/57-PRESENCE-GUIDEBOOK-LIFECYCLE-HANDOFF.md
tests: []
---

# Presence Guidebook Lifecycle

> **SUSPENDED — architecture retained; implementation to resume later.**
>
> Feature 25 is parked, not abandoned or superseded. Resume from the
> [suspension handoff](03-FEATURE-SUSPENSION-HANDOFF.md).

## In Ordinary Language

Presence is like a guidebook. While someone is using one edition,
MessageLens may remember their bookmark and reading history. When MessageLens
ships a new edition, it is acceptable to replace the old guidebook and start
the new edition fresh.

That is the durability boundary explored by this package:

```text
same guidebook generation
    -> keep presence.db
    -> resume its local run and trace

new guidebook generation
    -> replace presence.db as one unit
    -> install the current guidebook
    -> begin the new edition fresh
```

## Why Feature 25 Exists

Production-shaped Onboarding exposed a conflict around Step 6302. An existing
`presence.db` contained one Tell payload while the current Dart-authored
Schedule supplied another payload under the same Step identity. Runtime tried
to reconcile the two complete guidebook representations and correctly rejected
the redefinition.

The conflict was evidence of a missing lifecycle, not merely a missing Step
migration. Feature 25 asks how MessageLens installs one guidebook edition,
recognizes it later, replaces it when obsolete, and lets normal runtime read it
without comparing it to a second authored graph.

## Governing Direction

### Installed Runtime Authority

After installation, `presence.db` is the sole runtime authority for guidebook
content and geometry. The source shipped with MessageLens is installation
input, not a competing runtime definition.

### Generation Boundary

Runs, checkpoints, completion, and trace remain durable within one installed
generation. They may be discarded with an obsolete generation. Mild repetition
after an upgrade is acceptable; loss of MessageLens user data is not involved.

### Durable Human Intent

Human meaning that remains valuable independently of every Schedule, Trip, and
Step identity belongs to its owning domain, potentially in Overlay. Overlay is
not a refuge for obsolete Presence runs, trace, or geometry.

Use this test:

> Would this fact still mean something if every Presence Schedule, Trip, and
> Step ID were replaced tomorrow?

### Blank-Stare Consumer Boundary

Presence reads the installed guidebook and asks domain Agents opaque questions.
Consumers such as Onboarding provide specialist facts and actions. They should
not need to know Schedule IDs, Trip IDs, Step IDs, text, occurrence positions,
or routing geometry.

Ask Onboarding what Step 6302 says and the desired response is a blank stare.
Ask whether the Messages source can currently be read and that is Onboarding's
business.

## Explicit Safety Boundary

> The replaceability of `presence.db` must never be generalized to archived
> attachment payloads.

Presence is reproducible application-supplied content plus edition-local state.
Archived attachments may be irreplaceable preservation data. A future
replacement implementation must keep these categories mechanically separate.

## Status

This package now establishes architecture and implements the first bounded
slice: one pure, deterministic catalog contract and structural validator for
the complete guidebook shipped by the current build. Authored Schedule 6
geometry and opaque capability declarations now originate in generic Presence;
Onboarding continues to bind the executable specialist capabilities.

Current runtime still materializes the catalog through
`installOrExtendDefinition()`. This package does not yet implement generation
metadata, fresh installation, replacement, serialization, database deletion,
or runtime reconciliation removal.

Further implementation is temporarily suspended while the higher-priority
Production Archive Recovery feature investigates a known March 2026 donor
archive. The accepted lifecycle architecture and completed catalog boundary
remain the resumption point.

Read the
[architecture audit](01-PRESENCE-GUIDEBOOK-LIFECYCLE-ARCHITECTURE-AUDIT.md)
for the current mechanism, table classification, safety constraints, minimum
architecture, and recommended first implementation slice.

Read the
[catalog contract implementation](02-PRESENCE-GUIDEBOOK-CATALOG-CONTRACT-IMPLEMENTATION.md)
for the pure data boundary, validator, ownership transfer, deterministic
evidence, and deliberately unchanged runtime lifecycle.
