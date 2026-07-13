---
tier: project
scope: architecture-package
owner: agent-per-project
last_reviewed: 2026-07-11
source_of_truth: doc
status: approved-architecture
links:
  - ../04-CONVERSATION-TAGS/README.md
  - ../04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/09-contact-tags.md
  - ./01-OPEN-QUESTION-EVALUATION/README.md
  - ./01-OPEN-QUESTION-EVALUATION/05-categories-of-conversation-intent.md
  - ../../40-FEATURES/conversations/README.md
  - ../../95-WALK-UI-TREE/00-STANDARDS/UX_PRINCIPLES.md
  - ../../10-DATABASES/07-overlay-database-independence.md
tests: []
---

# Conversation Intent Architecture

This package defines **Conversation Intent** as the broader architectural seam
under user-authored and user-confirmed meaning attached to canonical
Conversation identity.

Conversation Intent includes current and future concepts such as:

- Core Favourites
- Tags
- Working Sets
- Suppressed Conversations
- Notes
- AI-suggested but user-confirmed classifications

These are not separate containers for Conversations. They are user intent
attached to the one canonical Conversation.

Saved Investigations are related but outside the current Conversation Intent
scope. They are a higher-order workspace concept that may include
Conversations, messages, queries, notes, and navigation context.

## Package Contents

- [`PROPOSAL.md`](PROPOSAL.md) - purpose, rationale, conceptual model, and
  proposed architectural direction.
- [`DESIGN_NOTES.md`](DESIGN_NOTES.md) - ownership, retrieval, UX, storage,
  overlay, and feature-boundary considerations.
- [`CHECKLIST.md`](CHECKLIST.md) - phased planning and completion criteria.
- [`TESTS.md`](TESTS.md) - future validation strategy.
- [`01-OPEN-QUESTION-EVALUATION/`](01-OPEN-QUESTION-EVALUATION/) - decision
  record for the reasoning that produced this canonical architecture.

## Settled Decisions

The open-question evaluation cycle has approved these architectural decisions:

- Core Favourites are built-in Conversation Intent with specialized
  user-facing behavior.
- Conversation Intent supports durable, session-scoped, and explicitly
  persistable lifetimes.
- Working Sets are task context, not Tags.
- Suppressed Conversations are visibility intent, not deletion or graph
  absence.
- Conversation Intent has categories: Meaning, Importance, Visibility,
  Context, and Annotation.
- Conversation Notes are durable Annotation intent: one editable note per
  Conversation initially.

## Relationship To Conversation Tags

Conversation Tags remain their own focused feature package:

[`../04-CONVERSATION-TAGS/`](../04-CONVERSATION-TAGS/)

This Conversation Intent package does not replace the Tags package. It provides
the broader architectural model that Tags should be built on.

The Contact Tags evaluation records a deferred, related concept:
Contact-backed Conversation Tags as identity-backed retrieval coordinates
inside the Conversations namespace, rather than ordinary user-authored text
Tags:

[`../04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/09-contact-tags.md`](../04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/09-contact-tags.md)

This remains future work. It should not be treated as part of the current
Conversation Tags implementation slice.

## Status

Approved architectural reference for the Conversation Intent seam. This package
does not authorize implementation by itself; implementation still requires a
separate approved slice.
