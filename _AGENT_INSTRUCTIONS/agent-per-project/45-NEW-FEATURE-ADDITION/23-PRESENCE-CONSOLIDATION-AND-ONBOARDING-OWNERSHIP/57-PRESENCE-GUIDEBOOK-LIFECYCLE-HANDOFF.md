---
tier: project
scope: presence-guidebook-lifecycle-handoff
owner: agent-per-project
last_reviewed: 2026-08-15
source_of_truth: doc
links:
  - 00-START-HERE.md
  - 54-END-TO-END-PRODUCTION-ONBOARDING-VALIDATION.md
  - 56-OBSERVED-ONBOARDING-STEP-REDEFINITION-BLOCKER-IMPLEMENTATION.md
  - ../21-PRESENCE-ITERATION-SIMPLE/30-SYSTEM-BOUNDARIES.md
tests: []
---

# Presence Guidebook Lifecycle Handoff

## Purpose

Feature Addition 23 has reached a natural architectural boundary. It proved
the Presence execution grammar, separated generic workflow mechanics from
Onboarding expertise, and integrated production-shaped onboarding. It also
revealed that Presence lacks an explicit lifecycle for installing and replacing
the guidebook that its runtime executes.

This document closes the current package and transfers that unresolved question
to a new sibling feature. It records the evidence and agreed direction without
designing or implementing the lifecycle.

## Production Observation

Validation 54 corrected ordinary debug launches to use the real production-
shaped Onboarding route rather than the opt-in Presence development harness.
That correction exposed this failure against an existing development
installation:

```text
Unable to continue setup:
Bad state: Existing Step 6302 in Trip TripDefinitionId(303)
cannot be redefined.
```

This was useful production evidence. It was not a laboratory-harness artifact.
The immediate compatibility correction restored Step 6302's historically
persisted payload and preserved the current immutability guard. It did not
implement definition migration or reconciliation machinery, and it does not
answer the larger lifecycle question exposed by the failure.

## Assumption Challenged

The earlier model treated two complete representations as peers at runtime:

```text
persisted guidebook definitions in presence.db
        +
Dart-authored guidebook definitions built at launch
        |
        v
reconcile them record by record
```

Under that premise, changed meaning under an existing identity appears to call
for new IDs, definition revisions, historical preservation, and increasingly
capable reconciliation.

That direction is now stopped pending lifecycle design. The more fundamental
question is:

> Why is production runtime reconciling a second Dart-authored representation
> of the guidebook against `presence.db` at all?

Current immutability checks remain intact. This handoff introduces no new Step
IDs, definition revisions, workflow migrations, or reconciliation rules.

## Corrected Mental Model

> **Presence is a guidebook.**

`presence.db` may contain both the installed guidebook edition and convenient
state created while using that edition.

### The Current Guidebook Edition

```text
Schedule definitions
Trip definitions
Step definitions
Tell text
Agent IDs
Choice options
routing
occurrences
```

### State While Using That Edition

```text
current Schedule run
current Trip checkpoint
completion
execution trace
other Presence-local runtime state
```

Within one installed guidebook generation, this is ordinary durable state.
Quitting and reopening the same MessageLens edition may resume from it. That
useful same-generation continuity is distinct from preserving obsolete Presence
state across guidebook replacement.

## Generation Boundary

> **Presence state may be durable within one guidebook generation and
> disposable when the guidebook generation changes.**

The direction to investigate is deliberately simple:

```text
same guidebook generation
    -> keep presence.db
    -> resume normally

new guidebook generation
    -> old Presence guidebook and local execution state may be discarded
    -> create the current Presence database
    -> install the current guidebook edition
    -> begin fresh
```

A MessageLens upgrade may therefore discard the current Presence Trip, an
unfinished or completed Presence Schedule, execution trace, and old readiness-
guide position. Those facts describe progress through an obsolete guidebook
edition. Preserving them does not justify a chain of per-version workflow
migrations as the starting assumption.

The next feature must define how a generation is identified, how replacement
is admitted safely, and when same-generation continuity applies. This handoff
does not choose those mechanisms.

## Fresh Installation

On a new Mac, Drift can create the physical `presence.db` schema, but schema
creation does not supply the application-authored catalog:

```text
Schedules
Trips
Steps
occurrences
Tell text
Agent IDs
Choice configuration
routes
```

Unlike Messages and Contacts, there is no external authoritative source from
which this catalog can be imported. MessageLens must ship and install the
current Presence guidebook edition into a fresh database.

The authoring and serialization form remains open. JSON, Dart data, SQL, or
another catalog form are possible implementation choices, not conclusions of
this handoff.

## Runtime Source Of Truth

The desired runtime model is:

```text
presence.db
    -> sole runtime authority for installed guidebook geometry and content

Presence
    -> reads Schedules
    -> reads Trips
    -> reads Steps
    -> executes what the installed database says
```

Runtime should not need a second complete authored Schedule merely to ask
whether persisted Step text still matches Dart text. The installation boundary
may author and install a guidebook; normal execution should read the installed
edition.

The next feature must investigate how to reach that model while preserving a
clean guidebook-authoring and installation boundary.

## The Blank-Stare Ownership Boundary

The desired end state restores the established ownership rule:

```text
Presence
    reads the guidebook
    encounters an opaque Agent ID
        |
        v
Agent resolver
        |
        v
Onboarding specialist
    answers the domain question
```

Onboarding owns domain expertise such as Messages-source readability, explicit
access denial, history sufficiency, Contacts readiness, and other onboarding-
specific facts and actions.

Onboarding should not need runtime knowledge of Schedule IDs, Trip IDs, Step
IDs, Step text, occurrence positions, routing geometry, or `ChoiceStep`
placement.

Ask Onboarding, "What is Step 6302?" The desired answer is a blank stare. Ask
it, "Can the Messages source currently be read?" That is its business.

## Durable Meaning Versus Guidebook Position

Presence run and checkpoint machinery remains in `presence.db`. A fact should
survive wholesale guidebook replacement only when it has meaning independent
of the Presence geometry that elicited it.

Presence-local and disposable:

```text
the user is currently at Trip 308
Schedule 6 completed
ChoiceStep 6903 was displayed
```

Potentially durable human intent:

```text
I prefer detailed step-by-step guidance
Take care of most of it for me
```

The governing test is:

> **Would this fact still mean something if the entire Presence guidebook were
> replaced tomorrow?**

If yes, it may belong in `overlay.db` or another domain-owned durable store. If
no, Presence-local persistence is sufficient. This handoff adds no Overlay
field and moves no Presence state.

Even current accepted-readiness state may be disposable. If an upgrade replaces
the guidebook before import, asking a short readiness question again may be
acceptable. Presence Schedule completion must not be promoted to durable domain
intent without an independently justified meaning.

## What Remains Valid

The lifecycle question does not invalidate the proven Presence grammar:

```text
Schedule
    ordered batting order of Trip occurrences

Trip
    ordered sequence of Step occurrences

Step
    performs narrow concrete work

Scheduler
    interprets only terminal TripDefinitionId?
```

The following remain established:

- generic `TestStep` and opaque `TestAgentId`;
- generic `ChoiceStep`;
- `FixedDestinationStep`;
- Tell presentation;
- Trip-granular restart within one guidebook generation;
- Presence and Onboarding semantic ownership;
- the attachment-preservation invariant;
- the production Gate-to-Onboarding-host boundary.

The next feature concerns guidebook installation, generation, replacement,
runtime authority, and cross-version Presence-state policy. It is not a rewrite
of Presence execution grammar.

## Work Explicitly Stopped

Feature Addition 23 does not proceed with:

- per-record reconciliation as the assumed cross-version lifecycle;
- tactical Step-ID allocation for changed authored meaning;
- definition-revision or workflow-migration machinery;
- weakening definition immutability;
- moving Presence checkpoints or completion into Overlay;
- serialized guidebook selection;
- generation fields or database replacement behavior.

The existing Step 6302 observation remains architectural evidence. Its local
compatibility correction must not be mistaken for the long-term lifecycle.

## Questions Transferred

The next feature must answer:

1. How does MessageLens ship and install the current guidebook catalog into a
   fresh `presence.db`?
2. What identifies the installed guidebook generation?
3. How is a generation mismatch detected before Presence runtime begins?
4. How is wholesale replacement made safe and atomic?
5. Which local Presence state is retained within a generation and discarded at
   replacement?
6. How does normal runtime stop reconciling a second authored definition graph?
7. Where does authoring end and installed runtime authority begin?
8. Which rare human decisions have meaning independent of guidebook geometry
   and therefore merit domain-owned durability?

The central question is:

> **How should MessageLens install and replace Presence as a versioned guidebook
> whose local execution state is useful within one edition but need not survive
> replacement by a new edition?**

## Handoff Boundary

Feature Addition 23 is closed as the active home for this architectural work.
It may receive factual corrections, but guidebook installation, replacement,
generation policy, runtime authority, and removal of runtime reconciliation
belong to the next sibling feature addition.

No guidebook-lifecycle implementation is introduced here. No `presence.db` is
deleted or rewritten, and no runtime behavior changes as part of this handoff.
