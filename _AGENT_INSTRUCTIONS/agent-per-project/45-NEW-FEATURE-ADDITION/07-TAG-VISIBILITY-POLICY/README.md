---
tier: project
scope: feature-package
owner: agent-per-project
last_reviewed: 2026-07-12
source_of_truth: draft
status: exploratory
links:
  - ../04-CONVERSATION-TAGS/README.md
  - ../04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/08-tag-visibility-policy.md
  - ../05-CONVERSATION-INTENT-ARCHITECTURE/README.md
  - ../06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md
  - ../../40-FEATURES/conversations/README.md
tests: []
---

# Tag Visibility Policy

This package defines the next feature seam for Conversation Tags: visibility
policy attached to Tag definitions.

The seed decision record is:

[`../04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/08-tag-visibility-policy.md`](../04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/08-tag-visibility-policy.md)

The core decision is:

> Visibility is policy attached to Tag definitions, not a separate
> Conversation-level suppression mechanism.

This lets users classify entire kinds of Conversations, such as `2FA`, `Spam`,
or `Delivery`, and then keep those classes out of ordinary browsing without
removing them from the graph, search, retrieval, or recovery.

## Package Contents

- [`PROPOSAL.md`](PROPOSAL.md) - product and architectural proposal.
- [`DESIGN_NOTES.md`](DESIGN_NOTES.md) - UX, retrieval, and interaction notes.
- [`CHECKLIST.md`](CHECKLIST.md) - phased implementation checklist.
- [`TESTS.md`](TESTS.md) - validation and regression strategy.

## Relationship To Conversation Tags

Conversation Tags remain the user-authored semantic labels attached to the one
canonical Conversation.

Tag Visibility Policy extends Tag definitions with browsing/discovery behavior.
It does not replace Tags, Favourites, Working Sets, or Structured Conversation
Retrieval.

The first implementation should be narrow: prove that a Tag can carry a
visibility policy and that ordinary Conversation Browse excludes Conversations
with suppressing Tags while explicit retrieval by that Tag still finds them.

## Governing Principles

- The graph remains complete.
- Source import and graph projection do not read or write visibility policy.
- Visibility policy belongs to overlay/user-intent storage with Tag
  definitions.
- Suppression is not deletion.
- Suppressed Conversations remain explicitly retrievable.
- Ordinary browsing should emphasize meaningful Conversations and reduce
  low-value noise.
- A generic hidden/suppressed system Tag may exist for one-off hiding, but the
  preferred model is semantic classification first.

## Status

Exploratory package created from the approved open-question evaluation.

No implementation has begun in this package.
