---
tier: feature
scope: design
owner: agent-per-project
last_reviewed: 2026-04-17
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ../../50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/settings-menu-semantics.md
  - ../../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md
tests: []
feature: settings-menu-semantic-revision
status: proposed
created: 2026-04-17
---

# Design Notes - Settings Menu Semantic Revision

## Core Design Decision

The settings menu must stop being treated as a durable selection owner.

The durable part of the system is persistent settings context, and that context must live only in global flow state.

The temporary part of the system is transient action handling, and that behavior must exist only as an ephemeral projection in the cassette stack derived from dispatched intent.

## State Ownership Model

### Persistent Context

Persistent settings context is durable sidebar meaning.

It should:

- live as a first-class field in global flow state
- drive the closed-menu label through projection
- participate in restore or bookmark behavior if the broader sidebar system supports that
- remain intact when transient cassette projections are layered on top

It should not:

- be owned by the menu widget
- be inferred from the last clicked action
- be cleared simply because a transient settings flow appears

### Transient Action As Ephemeral Projection

Transient settings actions are not navigation state.

They are ephemeral projections in the cassette stack.

That means they should:

- be derived directly from the most recent dispatched transient intent
- be owned by dispatcher plus topology lifecycle
- render as temporary sidebar-local cassette expansion
- disappear on cancel or completion without mutating persistent context

They should not:

- create a stored selected-action field
- persist in global flow state
- depend on a stored transient flag in flow state
- be reconstructible from restored or bookmarkable state

## Why This Is Better Than Menu-Owned Selection

The current design smell is that the menu is too close to acting like a source of durable truth.

That creates several problems:

- transient commands look like durable context
- cassette title rules depend on menu chrome rather than semantics
- restoring sidebar state risks accidentally restoring one-off actions
- persistent and transient behaviors become hard to reason about because both are expressed through one selection model

Moving persistent meaning into global flow state and transient meaning into derived cassette projection removes that ambiguity.

## Layer Responsibilities

### Global Flow State

Owns persistent settings context only.

It should answer questions like:

- which durable settings context is currently active
- what label should the settings menu project when closed

It should not own temporary settings action lifecycle.

### Settings Menu

Owns display and dispatch only.

It should:

- render the current persistent context from flow state
- render the placeholder when no persistent context exists
- dispatch transient or persistent user intent according to row semantics

It should not:

- store durable selection state
- remember transient action progress
- decide transient cassette lifetime

### Dispatcher And Topology

Own transient lifecycle.

They should:

- receive the dispatched transient intent
- derive the corresponding cassette expansion
- layer that expansion over current persistent context
- clear the expansion on cancel or completion

They should not:

- rewrite persistent context unless the incoming intent is explicitly persistent
- rely on stored transient flow-state flags to rebuild temporary cassette state

### Transient Settings Cassettes

Own their own local explanatory context.

They should:

- render a heading
- render explanatory copy and choices
- remain self-contained

They should not depend on the closed-menu label to explain what they are.

## Layering Rule

Persistent context and transient projection are not peers.

Persistent context is the base layer.
Transient cassette expansion is an overlay layer.

The overlay may appear and disappear, but the base layer remains intact unless a new persistent intent explicitly changes it.

This rule is especially important for reset confirmation, which must appear as a temporary overlaying cassette rather than replacing durable context.

## Title Rule

Transient cassettes must carry their own heading because they are temporary projections rather than durable menu state.

Persistent context surfaces may omit redundant headings when the menu label already expresses the active durable context.

This is why the system needs explicit semantic classification rather than a generic action list.

## Recommended Implementation Shape

1. Add semantic classification to settings menu action rows.
2. Add a dedicated persistent settings context field to global flow state.
3. Make the menu read only from that persistent field for closed-label projection.
4. Route transient settings gestures into dispatcher-owned ephemeral projection.
5. Make transient cassette expansion derive directly from the latest dispatched transient intent.
6. Remove any remaining logic that stores transient settings action state.
7. Add self-contained headings to transient cassettes.

## Deferred Question

This planning pass intentionally does not require a new durable settings section such as `Appearance` to ship at the same time.

That follow-up may still be the right product move, but it should not be coupled to the state-ownership correction itself.