---
tier: project
scope: feature-package
owner: agent-per-project
last_reviewed: 2026-07-12
source_of_truth: draft
status: first-slice-implemented
links:
  - ../05-CONVERSATION-INTENT-ARCHITECTURE/README.md
  - ../06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md
  - ../../40-FEATURES/conversations/README.md
  - ../../95-WALK-UI-TREE/00-STANDARDS/UX_PRINCIPLES.md
  - ../../95-WALK-UI-TREE/00-Registers/DESIGN_LANGUAGE_NOTES.md
tests: []
---

# Conversation Tags

This is the focused feature package for introducing Conversation Tags.

Conversation Tags are user-created semantic labels attached to canonical
Conversation entities. They are intended to help users retrieve, organize, and
rediscover meaningful parts of their communication history without turning
MessageLens into a folder hierarchy.

Tags are one durable **Meaning** form of broader Conversation Intent:

[`../05-CONVERSATION-INTENT-ARCHITECTURE/`](../05-CONVERSATION-INTENT-ARCHITECTURE/)

This package remains focused on tag-specific product behavior and UX. The
Conversation Intent package owns the general architectural seam shared by
Favourites, Tags, Working Sets, Suppressed state, Notes, and future
user-confirmed classifications. Structured Conversation Retrieval owns the
future retrieval grammar that may consume tags as tokens.

This package defines product and architectural direction for Conversation Tags.
The first vertical slice has been implemented: a Tag can be created and applied
from a Conversation in the Conversations sidebar, persisted in overlay storage,
merged into Conversation signature read models, and displayed quietly on the
canonical Conversation card in that first surface. A first Structured
Conversation Retrieval slice now consumes those existing Tags as retrieval
tokens; retrieval does not own Tag definitions or assignments.

## Package Contents

- [`PROPOSAL.md`](PROPOSAL.md) - product goal, rationale, scope, and proposed
  tag-specific direction.
- [`DESIGN_NOTES.md`](DESIGN_NOTES.md) - tag-specific UX and product design
  considerations.
- [`CHECKLIST.md`](CHECKLIST.md) - phased planning and completion checklist.
- [`TESTS.md`](TESTS.md) - future validation strategy.
- [`IMPLEMENTATION_READINESS_AUDIT.md`](IMPLEMENTATION_READINESS_AUDIT.md) -
  repository-aware audit of current seams and the recommended first
  implementation slice.
- [`FIRST_SLICE_IMPLEMENTATION_PLAN.md`](FIRST_SLICE_IMPLEMENTATION_PLAN.md) -
  concrete vertical-slice plan for the first approved implementation pass.

## Governing Principles

- Tags are not folders.
- Tags are durable user-authored Meaning intent.
- Tags describe what a Conversation means to the user.
- Tags should remain distinct from Favourites, Working Sets, Suppressed state,
  and Notes.
- Tags should support retrieval and discovery.
- Tags should appear consistently wherever the Conversation appears.

## Status

First vertical slice implemented.

Implemented scope:

- first-class overlay tag definitions and Conversation tag assignments;
- Conversation-owned repository, read providers, and action provider;
- tag display data merged into `ConversationSignatureDisplayModel`;
- provider-free `ConversationSignatureCard` support for supplied tag labels;
- Conversation-sidebar tag affordance for create/apply/remove;
- tests for overlay migration, repository behavior, action invalidation,
  read-model merge, and provider-free card rendering.
- first Structured Conversation Retrieval consumer: known Tags can be accepted
  as tokens that filter the Conversations Browse list with AND semantics.

Still outside the implemented slice:

- additional Structured Conversation Retrieval token types;
- Tag Manager / cleanup surface;
- tag colors, descriptions, ordering, merge, import/export, sync, AI-assisted
  suggestions, Working Set integration, Notes integration, and broad
  cross-surface tag display.
