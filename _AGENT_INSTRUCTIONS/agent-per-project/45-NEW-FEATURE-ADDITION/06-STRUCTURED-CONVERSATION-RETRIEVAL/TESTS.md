---
tier: project
scope: validation-plan
owner: agent-per-project
last_reviewed: 2026-07-11
source_of_truth: draft
status: exploratory
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
tests: []
---

# Structured Conversation Retrieval Validation Plan

This is a future validation plan. It is not an instruction to write tests now.

## Product Validation

Future UX validation should confirm that users understand:

- Conversation Retrieval finds Conversations, not message text;
- All Messages Search remains the place to search message content;
- selected tokens explain why the result list is narrowed;
- Conversation Lenses organize the retrieved set but do not define the set;
- Tags, Favourites, Working Sets, and visibility tokens keep their distinct
  meanings.

## Interaction Validation

Future UI tests or manual checks should cover:

- typing presents structured suggestions;
- selecting a candidate creates a token;
- input remains active after token creation;
- removing a token updates the Conversation results;
- clearing all tokens restores the expected unscoped Conversation list;
- empty states mention the active tokens rather than implying no data exists;
- keyboard navigation works through candidates and tokens.

## Retrieval Validation

Future implementation should prove:

- Contact token retrieves matching Conversations by stable identity;
- Favourite token retrieves favourited Conversations;
- Tag token retrieves tagged Conversations once Tags exist;
- Working Set token retrieves member Conversations once Working Sets exist;
- visibility token can include or isolate suppressed Conversations once
  visibility intent exists;
- group / one-to-one token retrieves by Conversation structure;
- multiple tokens combine according to the approved first-slice semantics.

## Ownership Validation

Future architecture tests or review should prove:

- retrieval consumes Conversation Intent without owning it;
- graph projection does not read or write retrieval state;
- Search does not own Conversation retrieval;
- widgets do not parse raw display labels to infer token meaning;
- retrieval operates on typed identities and token descriptors.

## Lens Validation

When retrieval combines with Conversation Lenses, validate:

- changing lens does not change selected tokens;
- changing tokens does not reset lens unless explicitly designed;
- highlighted comparison values still reflect the active lens;
- result ordering remains explainable.

## Regression Validation

When replacing the existing Conversation search field, verify:

- Favourites mode still works;
- Browse mode still works;
- Core Favourites remain global Conversation intent;
- Conversation Cards remain canonical entity presentation;
- Contact-derived Conversation lists are not broken;
- right-side Conversation excerpts are not broken.

## Non-Goals For Initial Validation

Do not validate until explicitly designed:

- saved retrievals;
- advanced Boolean query syntax;
- AI-generated token suggestions;
- tag creation from retrieval;
- Working Set creation from retrieval;
- syncing retrieval state across devices.
