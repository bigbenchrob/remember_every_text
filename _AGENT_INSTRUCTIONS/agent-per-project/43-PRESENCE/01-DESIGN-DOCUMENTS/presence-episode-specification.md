# Presence Episode Specification

## Status

This document defines the architectural contract of a Presence Episode.

It does not define the canonical Episode families. Those protocol
specializations belong in `10-EPISODE-MODEL.md`.

## Definition

A Presence Episode is the single active interaction protocol through which a
Journey communicates with the user at a particular point in its durable
progress.

An Episode represents:

- what the user should presently understand;
- whether the user has a present responsibility;
- what kind of evidence can truthfully complete the interaction;
- the semantic facts Presence may present while the interaction remains
  active.

An Episode is a projection of durable Journey state and current feature facts.
It is not itself the durable authority for either.

An Episode is not:

- a screen or widget;
- an operational task;
- a business workflow;
- a database record merely because an implementation may persist related
  state;
- a progress calculation;
- an arbitrary collection of controls;
- a substitute for feature-owned facts or decisions.

## Relationships

### Journey

A Journey is the complete durable undertaking.

The Journey records enough semantic and operational state to determine where
the undertaking currently stands. The Active Episode expresses the interaction
that follows from that state.

The Foreground Journey has exactly one Active Episode. A Journey may contain
many Episodes over time, but they do not compete for current authority.

### Moment

A Moment is transient, subordinate content presented within a suitable Active
Episode.

A Moment may illuminate the work, but it cannot:

- alter the Active Episode;
- advance or complete the Journey;
- request a domain decision;
- become durable Journey truth.

### Journey Coordinator

The Journey Coordinator derives the appropriate Episode from durable Journey
state and feature-supplied facts.

It determines whether completion evidence is valid, commits the corresponding
Journey transition, and derives the next Episode.

The Coordinator does not render.

### Renderer

The Renderer presents the Active Episode and any permitted Moments.

It may return a user interaction to the Journey Coordinator through the
Episode's declared contract. Every such interaction carries Provenance. The
Renderer cannot decide that an Episode or Journey has completed.

The Renderer does not perform operational work, interpret business facts, or
invent interaction protocols.

### Provenance

Provenance is the identity chain accompanying every interaction from the
Renderer to the Coordinator:

- Journey identity;
- Journey revision;
- Episode identity;
- activation occurrence;
- interaction occurrence.

Episode identity identifies the logical interaction obligation. Activation
occurrence identifies one grant of foreground rendering authority. Interaction
occurrence identifies one semantic interaction and permits duplicate
rejection.

The Coordinator accepts an interaction only while its Provenance remains
current and the interaction remains declared by the Active Episode.

### Feature Operation

A feature operation performs the actual work and publishes truthful facts about
its state.

The operation does not define Presence rendering. Presence does not perform the
operation.

The Episode relates the operation's current facts to the user without becoming
the source of those facts.

## Responsibilities

An Episode is responsible for declaring:

- its stable identity within a Journey;
- its relationship to that Journey;
- its canonical protocol family;
- its constrained semantic purpose;
- the semantic content and feature facts available for presentation;
- the authority capable of truthfully completing it;
- the form of user response, operational evidence, or external condition that
  its protocol permits.

An Episode is explicitly not responsible for:

- executing feature operations;
- coordinating the feature workflow;
- storing business rules;
- querying databases or external systems;
- calculating operational truth;
- deciding the next Journey state;
- selecting or constructing rendering technology;
- persisting built presentation;
- defining application navigation;
- replacing durable Journey state.

## Lifecycle

### Creation

An Episode is derived when durable Journey state and current feature facts
identify one presently valid interaction.

Creation does not mean that a Renderer has built or displayed anything. It
means the Journey Coordinator can describe the current interaction through a
canonical Episode contract.

### Activation

The derived Episode becomes the Active Episode when the Coordinator recognizes
it as the sole current interaction for the Foreground Journey.

Its stable identity identifies the same logical Episode occurrence across
reconstruction and application restart. A later recurrence of similar content
is not necessarily the same Episode.

Each activation has a separate activation occurrence. Episode identity may
survive restart. Activation authority does not.

### Presentation

The Renderer projects the Active Episode into the current presentation
environment.

Presentation may change without changing the Episode. Different renderers may
present the same Episode differently while preserving its protocol, semantic
content, completion authority, and permitted response.

Presentation does not activate, advance, or complete the Episode.

### Completion

An Episode becomes complete only when the Journey Coordinator receives and
accepts evidence from the authority declared by the Episode protocol.

A Renderer interaction does not make itself authoritative. The Coordinator
validates its Provenance, declared Completion Authority, durable Journey state,
and current feature facts.

Completion is recorded through a durable Journey transition. It is not merely
stored as mutable presentation state on the Episode.

### Replacement

After committing the transition, the Coordinator derives the next truthful
Episode.

Replacement is a consequence of changed Journey truth. Renderers do not dismiss
one Episode and choose another.

An Episode that is no longer compatible with the Journey cannot remain the
effective interaction simply because an old presentation still exists.

### Re-derivation After Restart

After application restart, the Coordinator re-examines durable Journey state
and current feature facts.

If the same logical interaction remains current, the same Episode identity and
contract are re-derived. If the underlying truth has changed, a different
Episode is derived.

Restart reconciliation always issues a new activation occurrence before
rendering. Outputs from the earlier activation cannot affect current Journey
truth.

The application does not depend on reconstructing meaning from previously
rendered UI state.

## Completion Authority

Completion authority is the source capable of truthfully establishing that the
interaction represented by an Episode has finished.

The Episode family is determined by that authority, not by visual appearance,
button labels, narrative tone, or the feature that requested the interaction.

Examples:

- If the interaction exists to ensure the user has acknowledged an
  explanation, acknowledgement may be the completion authority.
- If the interaction requires the user to choose one candidate, a validated
  typed user response is the completion authority.
- If an import is running, operational evidence from the importer is the
  completion authority. A progress animation or elapsed time is not.
- If Full Disk Access is required, independently verified permission state is
  the completion authority. Clicking "Open System Settings" is not.
- If an external drive is disconnected, observed drive availability is the
  completion authority. Clicking "I reconnected it" is not when the condition
  can be checked.

This distinction prevents user assertions, renderer events, and incidental UI
state from replacing observable truth.

## Interaction Contract

The canonical direction is:

```text
Feature operation
    publishes operational and domain facts

Journey Coordinator
    interprets durable Journey state and those facts

Episode
    declares the current interaction protocol

Renderer
    presents that protocol

User
    may respond only through the declared interaction contract

Journey Coordinator
    validates the response or other completion evidence
    commits the durable transition
    derives the next Episode
```

Accordingly:

- operations publish facts;
- features retain domain meaning and operational ownership;
- Presence derives the current interaction;
- Episodes declare the permitted protocol;
- renderers present but never advance Journeys;
- user assertions never replace independently observable evidence;
- Journey transitions occur only through the Coordinator.

## Invariants

Every Presence implementation must preserve these invariants:

1. The Foreground Journey has exactly one Active Episode.
2. Durable Journey state and current feature facts are authoritative.
3. The Active Episode is derived from that authority.
4. An Episode family is determined by truthful completion authority.
5. An Episode cannot complete itself.
6. A Renderer cannot complete an Episode or advance a Journey.
7. A feature operation cannot use presentation state as operational truth.
8. A user assertion cannot replace independently observable evidence.
9. Moments cannot alter Episode or Journey state.
10. Episode families are canonical project-wide protocols and cannot be
    invented by individual features.
11. Feature-specific content cannot be used to create a private interaction
    protocol or custom screen outside Presence.
12. Built presentation is never durable Journey meaning.
13. Application restart cannot erase the information required to re-derive the
    truthful Active Episode.
14. An incompatible prior Episode cannot remain effective after Journey truth
    changes.
15. Presentation technology may change without changing the Episode contract.
16. Every Coordinator-bound Renderer interaction carries Provenance.
17. Episode identity may survive restart, but activation authority does not.
18. An interaction from an obsolete activation occurrence cannot affect
    Journey truth.
19. An interaction occurrence may be accepted at most once.

## Non-goals

Episodes must never acquire responsibility for:

- performing imports, scans, repairs, or other operational work;
- containing feature business rules;
- querying databases or inspecting the environment directly;
- coordinating feature workflows;
- selecting the next application action;
- owning navigation or application topology;
- storing arbitrary feature state;
- becoming feature-specific screens;
- constructing rendering technology;
- manufacturing progress, certainty, or completion;
- acting as a generic escape hatch for interaction designs that do not fit the
  canonical model.

If a proposed Episode requires one of these responsibilities, the ownership
boundary is wrong or the behaviour is not an Episode.

## Relationship to Episode Families

`Episode` is the abstract interaction contract.

The canonical Episode families are protocol specializations. The proposed
vocabulary is:

- `Inform`;
- `Ask<T>`;
- `Work`;
- `Await`.

Each family defines its permitted completion authority, response contract,
operational relationship, and durable resumption requirements.

Those definitions belong in `10-EPISODE-MODEL.md`. This specification does not
classify their variants or presentation.

## Design Test

Before introducing Presence behaviour, ask:

1. Does this describe an interaction, or is it actually an operation?
2. What source can truthfully complete the interaction?
3. Is that completion authority represented by the proposed Episode protocol?
4. Could the Active Episode be re-derived from durable Journey state after
   restart?
5. Has the feature supplied facts and domain meaning while Presence supplies
   interaction?
6. Could the Renderer be replaced without changing the Episode contract?
7. Does any Moment, widget, or user assertion accidentally control Journey
   state?
8. Is an individual feature inventing interaction machinery that belongs in
   the canonical Presence model?

If these questions cannot be answered cleanly, the proposed behaviour is not
ready to become a Presence Episode.
