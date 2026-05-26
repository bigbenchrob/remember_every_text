---
tier: feature
scope: design
owner: agent-per-project
last_reviewed: 2026-05-24
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ./TESTS.md
  - ./seed.md
tests: []
feature: conversation-topology-presentation
status: proposed
created: 2026-05-24
---

# Design Notes - Conversation Topology Presentation

## Core Design Decision

Conversations mode should present:

```text
sidebar: conversation signatures and navigation
center panel: selected conversation messages
```

The center panel must not remain the default conversation-selection surface.

## Design Reference

Use `experiments/conversation_shape_sandbox/` as a visual reference for compact signatures only.

Do not copy:

- HTML architecture
- JavaScript state model
- CSS token structure
- all controls
- synthetic-data assumptions

Do preserve:

- compact signature rows
- Trace as the canonical signature mode
- temporal density texture
- recognizable conversation shape
- quiet participant-count cue
- selected-row affordance
- sidebar as navigation surface
- center as resolved message stream

Hybrid should remain an experimental diagnostic overlay only. It is not the default visual language for conversation recognition.

## Existing Center Browser Reference Path

The current center-panel Conversations implementation should not be deleted immediately.

It should be preserved as:

- diagnostic reference
- comparison surface
- fallback for implementation debugging
- source of reusable message-list logic if needed

It should not remain:

- the default Conversations surface
- the owner of conversation navigation
- the place where filters and selection controls accumulate

Do not move or rename this path before the sidebar signature path works unless that is necessary to keep routing clear.

## Sidebar Signature Semantics

The signature row is a visual projection of graph facts.

It should answer, at a glance:

- who is in the conversation
- whether it is single or group
- roughly how active it is
- whether the activity is continuous, bursty, sparse, dormant, or revived
- whether the conversation has a recognizable rhythm

It should not try to answer every question.

The first version should avoid controls and let the list itself establish the visual vocabulary.

## Canonical Signature Mode

Trace is the baseline and canonical topology signature.

The Trace is not a miniature timeline widget. It is a compressed topological signature intended to support pre-attentive recognition of conversational structure.

Trace should carry the primary pre-attentive recognition burden:

- temporal density
- cadence
- burstiness
- silence
- revival
- continuity

Hybrid may remain useful for diagnostics, tuning, and comparison, but it must not become the default visual grammar. The user should learn one compact visual language first.

## Participant Count Cue

Participant count is topology context, not metadata decoration.

In Trace mode, include a subtle participant-count indicator without adding a large metadata label.

Preferred shape:

- small muted dots or tiny initials
- placed near the conversation title or at the left edge of the trace frame
- cap visible marks at five
- show `+N` for additional participants
- keep low contrast
- survive blur enough to distinguish one-to-one, small group, and large group
- do not compete with the temporal trace

Examples:

```text
one-to-one:   ●
small group:  ● ● ●
large group:  ● ● ● ● ● +3
```

This cue answers "how many voices are inside the shape" without turning participant count into another metadata pill.

## Candidate Signature Primitives

### Required First-Pass Signals

- participant labels
- message count
- latest message date
- compact temporal density trace
- quiet participant-count dots or initials
- selected/hover state

### Candidate Later Signals

- participant rails
- Hybrid diagnostic overlay
- dominance bands
- participant alternation rhythm
- dominance asymmetry
- silence corridors
- attachment rainfall
- revival markers
- seasonal recurrence hints

These should not be added until the basic sidebar navigation pattern works.

## Layer Responsibilities

### Infrastructure

Owns SQL and graph read implementation.

If temporal density bins require new data access, add a named repository method in infrastructure.

### Application / Read Model

Owns typed conversation signature models and semantic preparation for rendering.

This layer can shape raw graph facts into:

- bins
- counts
- labels
- selection-ready IDs

Conversation signature facts must be computed here or below, not in widgets.

### Sidebar Cassette / Presentation

Owns visual rendering only.

Widgets may choose layout and drawing primitives, but must not decide graph semantics, compute signature facts, or query data directly. Widgets render only typed signature data.

### Center Panel

Owns message evidence rendering for the selected conversation.

It should not own conversation browsing or selection.

## State Flow

Expected first-pass flow:

```text
Conversations mode selected
-> sidebar renders conversation signature cassette
-> user selects conversation signature
-> sidebar flow state or selected conversation state updates
-> effective center projection derives MessagesSpec.forConversation(...)
-> center panel renders selected conversation messages
```

No direct center push, `clear()`, `reset()`, or force-refresh logic should be added.

## Conversation Favourites

Conversation favourites are global user intent attached to canonical conversation identity.

They are not local ordering state for one sidebar list.

The default first-pass group is:

- Favourites: Core

Rules:

- favourite state belongs in the overlay database
- favourite rows are keyed by stable conversation identity
- favourite state must appear consistently wherever the conversation is projected
- sidebar and contact-derived conversation lists may lift Core favourites into a separate section
- normal result lists should not duplicate conversations already shown in a Favourites/Core section
- future user-defined groups should extend the same model rather than introducing list-local state

## Visual Rules

- Use theme providers and existing app tokens.
- Keep sidebar rows compact.
- Treat Trace as canonical.
- Keep Hybrid diagnostic-only.
- Keep color restrained.
- Use participant-count marks as topology cues, not metadata pills.
- Avoid rainbow participant coloring.
- Avoid card-heavy or dashboard-like center composition.
- Avoid large persistent control panels in the center panel.
- Do not add production-visible visual tuning panels; tuning controls must be dev/experimental-only.
- Keep text small and readable.
- Prefer weak layered signals over one overpowering visual cue.

## Experimental Boundaries

This branch is exploratory, but production architecture still applies.

Experimental components should be:

- isolated
- clearly named
- removable
- non-authoritative
- limited to the Conversations sidebar/presentation path

## Open Design Questions For Later

These are intentionally deferred:

1. Which sort order becomes canonical for conversation signatures?
2. Should signature rows support inline search/filter later?
3. How many temporal bins should the production sidebar support?
4. How should selected conversation state persist across app relaunch?
5. Should diagnostic/reference browser remain accessible after the experiment stabilizes?
6. How should conversation signatures interact with contact-centered mode later?
7. Should the signature eventually become partially user-learned rather than fully standardized?
