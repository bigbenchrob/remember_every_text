---
tier: project
scope: feature-package
owner: agent-per-project
last_reviewed: 2026-07-12
source_of_truth: draft
status: first-slice-implemented
links:
  - ./seed.md
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./CHECKLIST.md
  - ./TESTS.md
  - ../05-CONVERSATION-INTENT-ARCHITECTURE/README.md
  - ../04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/09-contact-tags.md
  - ../../95-WALK-UI-TREE/00-Registers/DESIGN_LANGUAGE_NOTES.md
tests: []
---

# Structured Conversation Retrieval

This is the exploratory work package for **Structured Conversation
Retrieval**.

Structured Conversation Retrieval is a product and interaction model for
finding Conversations by progressively describing the Conversation context the
user wants to work with.

It is not message-content search.

## Core Distinction

MessageLens has two different retrieval systems:

### All Messages Search

Answers:

> Where was this said?

It operates on message content and returns message evidence.

### Structured Conversation Retrieval

Answers:

> Which Conversation am I trying to work with?

It operates on Conversation identity, Conversation metadata, and Conversation
Intent. It returns Conversations.

## Package Contents

- [`seed.md`](seed.md) - original user-authored feature prompt.
- [`PROPOSAL.md`](PROPOSAL.md) - product goal, conceptual model, and proposed
  architectural direction.
- [`DESIGN_NOTES.md`](DESIGN_NOTES.md) - UX philosophy, ownership, token model,
  relationships to Intent/Search/Lenses, and risks.
- [`CHECKLIST.md`](CHECKLIST.md) - phased planning and completion checklist.
- [`TESTS.md`](TESTS.md) - future validation strategy.

## Relationship To Conversation Intent

Structured Conversation Retrieval consumes Conversation Intent. It does not own
it.

Intent concepts such as Tags, Core Favourites, Working Sets, visibility state,
notes, and confirmed classifications may eventually become retrieval tokens.
Those concepts remain owned by the Conversation Intent architecture and the
Conversations feature.

## Status

First vertical slice implemented.

Implemented scope:

- the Conversations sidebar Browse field now retrieves by known Tag tokens
  rather than free text;
- typing a partial tag name suggests matching existing Tags;
- accepting a suggestion converts it into a visible Tag token;
- multiple selected Tag tokens combine with simple AND semantics;
- selected Tag tokens filter the Conversation list through the Conversation
  signature read model;
- Organize by / Conversation Lenses remain independent of retrieval.

Still outside the implemented slice:

- Contact, Favourite, Working Set, visibility, Notes, AI, or free-text tokens;
- Boolean syntax, OR/NOT logic, saved retrievals, history, or retrieval
  persistence;
- message-content search. All Messages Search remains the message-content
  retrieval system.

## Deferred Contact Retrieval Coordinate

The Contact Tags evaluation records a likely future retrieval token type:
Contact-backed Conversation Tags. These are not ordinary text Tags; they would
refer to canonical Contact identity and resolve display labels through the
same identity system used elsewhere in MessageLens.

[`../04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/09-contact-tags.md`](../04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/09-contact-tags.md)

This remains explicitly deferred while Conversation Tags settle in real use.
