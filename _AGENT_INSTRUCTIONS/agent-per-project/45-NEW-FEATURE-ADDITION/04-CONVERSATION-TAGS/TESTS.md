---
tier: project
scope: test-plan
owner: agent-per-project
last_reviewed: 2026-07-09
source_of_truth: draft
status: exploratory
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
---

# Conversation Tags Validation Plan

This document describes future validation. It is not an instruction to write
tests now.

## Product Validation

Validate that users understand:

- tags are labels, not folders;
- a Conversation can have multiple tags;
- removing a tag from one Conversation is not the same as deleting the tag;
- tags follow the Conversation across lenses;
- Favourites and Tags have different meanings.

## Architectural Validation

Future implementation should prove:

- tag persistence is overlay/user intent;
- graph projection does not read or write tag state;
- tags attach to stable Conversation identity;
- Conversation read models merge graph facts with tag overlay state at read
  time;
- Conversation widgets render typed tag display data rather than querying tag
  storage directly;
- Search and Messages can request tag-aware operations without owning tag
  semantics.

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
- preserve tags across app restart;
- preserve tags across graph rebuild;
- show tag state consistently across Conversation sidebar, Contact-derived
  Conversation lists, and right-side Conversation excerpts.

## UX Validation

Manual validation should cover:

- tag affordance is discoverable but not visually dominant;
- compact Conversation Cards remain readable with tags;
- tag editing does not feel like editing a local row;
- user can tell whether they are deleting a tag globally or removing it from a
  single Conversation;
- tag filter/lens makes it obvious why each Conversation is shown.

## Future Cross-Feature Validation

When Search/Discovery integrations are designed, validate:

- Search can refine by tag without becoming tag owner;
- Search results can expose source Conversation tag actions where appropriate;
- Discovery lenses can scope by tag;
- Working Sets and Tags remain distinct;
- Saved Investigations, if introduced, do not duplicate tag semantics.

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
