---
tier: project
scope: test-plan
owner: agent-per-project
last_reviewed: 2026-07-12
source_of_truth: draft
status: first-slice-implemented
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ../05-CONVERSATION-INTENT-ARCHITECTURE/TESTS.md
---

# Conversation Tags Validation Plan

This document describes tag-specific validation. The first vertical slice now
has focused tests; broader cross-lens and management validation remains future
work. General Conversation Intent validation is owned by
[`../05-CONVERSATION-INTENT-ARCHITECTURE/TESTS.md`](../05-CONVERSATION-INTENT-ARCHITECTURE/TESTS.md).

## Implemented First-Slice Tests

Implemented tests currently cover:

- overlay migration from schema v6 creates Conversation tag storage;
- tag creation persists display and normalized names;
- empty tag names are rejected;
- duplicate normalized names reuse the existing tag definition;
- Conversation tag assignments persist by canonical Conversation identity;
- duplicate assignments are prevented;
- removing an assignment does not delete the tag definition;
- Conversation tag actions mutate the repository and invalidate affected reads;
- Conversation signature display models merge tag display data by
  `conversationId`;
- `ConversationSignatureCard` renders supplied tag labels without provider
  dependencies.

## Product Validation

Validate that users understand:

- tags are labels, not folders;
- a Conversation can have multiple tags;
- removing a tag from one Conversation is not the same as deleting the tag;
- tags follow the Conversation across lenses;
- Favourites and Tags have different meanings.

## Architectural Validation

Future implementation should prove:

- tag behavior conforms to the Conversation Intent overlay/identity rules;
- Conversation widgets render typed tag display data rather than querying tag
  storage directly;
- Search and Messages can request tag-aware operations without owning tag
  semantics.
- Structured Conversation Retrieval can consume tag tokens without owning tag
  semantics, if tag retrieval is included.

## Functional Validation

Future tests should cover:

- create tag;
- rename tag;
- delete tag;
- assign tag to Conversation;
- remove tag from Conversation;
- apply multiple tags to one Conversation;
- apply one tag to multiple Conversations;
- prevent or resolve duplicate tag names;
- handle tag name casing and whitespace normalization;
- preserve tags across app restart;
- preserve tags across graph rebuild;
- show tag state consistently across Conversation sidebar, Contact-derived
  Conversation lists, and right-side Conversation excerpts.
- show tag state consistently when the same Conversation appears in Favourites,
  Browse, and retrieval/lens contexts.

## UX Validation

Manual validation should cover:

- tag affordance is discoverable but not visually dominant;
- compact Conversation Cards remain readable with tags;
- tag editing does not feel like editing a local row;
- user can tell whether they are deleting a tag globally or removing it from a
  single Conversation;
- tag filter/lens makes it obvious why each Conversation is shown.
- tag chips or labels do not compete with Conversation title, glyph, or
  favourite star.

## Future Cross-Feature Validation

When Search/Discovery integrations are designed, validate:

- Search can refine by tag without becoming tag owner;
- Search results can expose source Conversation tag actions where appropriate;
- Structured Conversation Retrieval can include tag tokens without becoming
  message-content search;
- Discovery lenses can scope by tag;
- Working Sets and Tags remain distinct;

## Data Integrity Validation

Future implementation should test:

- tag state survives graph projection rebuild;
- tag state is not lost when Conversation display title changes;
- tag state is not keyed by list position or raw participant label;
- tag state handles missing or temporarily unresolved Conversation identity
  gracefully;
- export/import, if implemented, preserves assignments without duplicating tags.

## Non-Goals For Initial Tests

Do not test the following until those features are explicitly designed:

- AI tag suggestions.
- Multi-device sync conflicts.
- Nested tags.
- Tag analytics.
- Saved investigations.
