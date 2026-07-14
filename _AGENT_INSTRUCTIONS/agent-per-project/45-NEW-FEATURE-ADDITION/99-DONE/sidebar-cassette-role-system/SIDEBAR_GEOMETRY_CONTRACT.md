---
tier: feature
scope: contract
owner: agent-per-project
last_reviewed: 2026-03-20
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./CHECKLIST.md
  - ./TESTS.md
  - ./seed.txt
tests: []
---

# Sidebar Geometry Contract

## Purpose

Define the authoritative horizontal geometry rules for sidebar cassettes so that:

- left and right rails are owned by `essentials/sidebar`
- feature code does not invent local width or padding systems
- role-specific shells and content contracts can rely on a shared geometry model
- trailing affordances such as dismiss actions use a sidebar-owned gutter rather than feature-local hacks

This contract is specifically about **horizontal structure**.

It works alongside the role system:

- role decides semantic grouping and default hierarchy
- geometry contract decides horizontal rails and permitted width behavior
- content contracts decide what a feature is allowed to return within those rails

## Core Principle

Sidebar geometry is a property of the sidebar system, not of individual cassettes.

Feature code may choose from approved body placement modes.

Feature code may not define new outer rails.

## Authoritative Geometry Model

The sidebar owns a single content envelope plus a small set of centrally owned geometry tokens.

Conceptually:

```text
| sidebar edge
| outer rail | fixed content envelope ............................ | outer rail |
```

The exact pixel values are implementation details owned centrally by essentials.

The important part is that the envelope and its internal placements are **centrally defined**, not recreated through ad hoc paddings inside cassettes.

## Geometry Tokens

The concrete values must be centrally owned tokens so layout can be tuned by changing essentials-owned constants rather than feature-local padding.

Examples of the token layer:

- `sidebarContentEnvelopeWidth`
- `sidebarBodyInset`
- `sidebarTrailingGutterWidth`
- `sidebarInteriorGap`

The names may change in implementation, but the architecture should preserve the idea that all cassette horizontal geometry comes from a small token set.

### `outerRailInset`

The standard left and right inset that establishes the sidebar's overall visual frame.

Used by:

- top-level full-width sidebar controls
- section wrappers
- any shell that should align with the sidebar's primary edge rhythm

### `contentEnvelopeWidth`

The fixed width within which cassette body content is rendered.

Rules:

- the outer cassette width does not change when placement mode changes
- the sidebar rails do not change when placement mode changes
- different cassette body placements must be explainable as different uses of the same content envelope

### `bodyInset`

The standard inset applied when content uses the inset placement.

Used by:

- info text
- explanatory body content
- compact supporting context

This is what creates the narrower readable line without each cassette inventing its own left/right padding.

### `actionGutterWidth`

The reserved trailing strip inside the same content envelope for gutter-approved affordances.

Examples:

- dismiss buttons
- row-level destructive or escape actions
- other compact trailing controls intentionally allowed to sit proud of the main content lane

The gutter is owned by the sidebar, not by the list or cassette body.

### `interiorGap`

Standard horizontal gap between content and an approved trailing affordance.

This prevents every cassette row from choosing a different spacing between text and trailing actions.

## Body Placement Modes

Features do not request raw paddings.

They request one of a small set of approved body placements owned by essentials.

### `fullWidth`

Content may occupy the full content envelope width.

Intended for:

- top menu
- full-width primary controls
- wide segmented or toggle controls that should align with the main sidebar envelope

### `inset`

Content is centered within the same content envelope using the standard inset owned by essentials.

Intended for:

- info text
- explanatory context
- supporting textual cassettes

### `insetWithTrailingGutter`

Content is shifted within the same content envelope to reserve a trailing gutter on the right for approved affordances.

Rules:

- content keeps the standard inset on the left
- a reserved trailing gutter is carved out on the right
- main content may not extend into the trailing gutter
- only approved trailing affordances may occupy the gutter

Intended for:

- list rows with dismiss buttons
- rows that need a sidebar-owned trailing action affordance
- gutter-aware textual or list content that should still align with the common readable lane

## Why Only Three Modes

The system should stay deliberately narrow.

These three placements are enough to express the current layout needs without turning geometry into a free-form styling API:

- `fullWidth`
- `inset`
- `insetWithTrailingGutter`

If a cassette cannot be expressed with one of these, the first question should be whether its body contract is wrong before a new placement mode is added.

## Relationship To Older Lane Language

Earlier discussion used terms such as `readable`, `control`, or gutter-aware lane variants.

For the authoritative contract, those ideas should collapse into the three placement modes above.

The role system and body contract still decide which placement is appropriate, but the actual horizontal rules should stay this small.

## Shell Responsibilities

Essentials-owned sidebar shells must:

- select the approved body placement mode
- translate that mode into concrete constraints and padding using centrally owned tokens
- reserve gutter space when the mode includes a trailing gutter
- enforce that non-gutter content does not render into gutter space
- provide child builders with the resulting geometry constraints

Feature code must not override these rails with local outer padding.

## Feature-Facing Constraint Contract

When a role/body type allows feature-owned widget content, essentials should pass down a constraint object.

Conceptual shape:

```text
SidebarGeometryConstraints
  placementMode
  contentEnvelopeWidth
  maxContentWidth
  hasTrailingGutter
  trailingGutterWidth
  trailingAffordanceMaxWidth
```

This gives the feature enough information to render appropriately without allowing it to renegotiate the sidebar's geometry.

## Tuning Model

The contract is intentionally token-driven.

That means the implementation goal is:

- adjust a small set of width constants in `essentials/sidebar`
- have those changes propagate automatically through sidebar shells
- have the derived feature-facing geometry constraints update automatically as well

The feature should not need to be rewritten to experiment with envelope width or gutter width. That tuning should occur by changing centrally owned constants.

## Allowed Return Shapes

### Textual Content

If a cassette returns text or structured textual payloads, essentials formats them within the selected body placement mode.

This is the preferred model for:

- info text
- explanatory body text
- supporting context elements

### Widget Content

If a cassette returns widget content, it must satisfy one of two approved forms:

1. **Envelope-filling or inset content**
  The widget must fit within the provided `maxContentWidth` for the selected placement mode.

2. **Inset content plus approved trailing gutter affordance**
  The main widget content fits inside the non-gutter portion of the envelope, while the trailing affordance occupies the gutter through a sidebar-owned API.

Feature code must not assume it can occupy the gutter simply because there is unused space on the trailing side.

## Gutter Ownership Rules

The action gutter is a sidebar-level affordance strip.

Rules:

1. Main content may not overflow into the gutter.
2. Only approved trailing affordances may appear there.
3. The gutter width is owned centrally.
4. Lists with dismiss buttons must use `insetWithTrailingGutter` instead of inventing a custom row width model.

## Relationship To Roles

Role does not by itself determine exact width treatment, but it sets defaults.

Expected defaults:

- `appControl` -> usually `fullWidth`
- `contextPrimary` -> usually `fullWidth` or `inset`, depending on approved body type
- `contextSecondary` -> usually `inset`
- `filter` -> usually `fullWidth` or `inset`, depending on the control design
- `action` -> may use any approved placement mode, including `insetWithTrailingGutter` where justified by the body contract

If a cassette needs a placement mode that is surprising for its role, that should be an explicit design decision rather than an incidental padding change.

## Current Examples Mapped To The Contract

### Top menu

- likely placement mode: `fullWidth`
- no trailing gutter

### Hero card

- likely placement mode: `fullWidth` or approved role-specific primary-content placement
- no cassette-local outer padding negotiation

### Chosen-contact info / explanatory card

- likely placement mode: `inset`
- textual payload preferred over arbitrary widget layout

### Message mode toggle

- likely placement mode: `fullWidth` or `inset`, depending on final control styling

### Handle filter menu

- likely placement mode: `fullWidth` or `inset`, depending on final control styling

### Heatmap

- likely placement mode: `fullWidth` or `inset` depending on final visual decision
- must still use centrally owned envelope rules rather than cassette-local paddings

### Unfamiliar-source handle list with dismiss buttons

- likely placement mode: `insetWithTrailingGutter`
- list content aligns to the inset content lane
- dismiss buttons occupy the sidebar-owned gutter

## Prohibited Patterns

- feature-local outer horizontal padding used to create a new rail
- cassette-local trailing padding used to simulate a gutter
- row content extending into the gutter region without an approved gutter-aware placement mode
- arbitrary widget content for constrained roles without receiving and respecting sidebar-owned geometry constraints
- widening the entire sidebar content frame just because one cassette needs trailing affordances

## Verification Targets

The geometry contract is working when:

- the same centrally defined content envelope explains the alignment of all major cassettes
- changing a small set of essentials-owned width tokens propagates through both shells and feature-facing constraints
- lists with trailing dismiss buttons no longer create their own competing width model
- text-heavy and control-heavy cassettes align cleanly without bespoke tuning
- new cassette content can fit by selecting an approved placement mode instead of negotiating custom margins
