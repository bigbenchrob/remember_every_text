---
tier: project
scope: validation-plan
owner: agent-per-project
last_reviewed: 2026-07-11
source_of_truth: doc
status: approved-architecture
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
---

# Conversation Intent Validation Plan

This is a future validation plan. It is not an instruction to write tests now.

## Product Validation

Future UX validation should confirm that users understand:

- Favourites, Tags, Working Sets, Suppressed state, and Notes are different
  meanings;
- those meanings attach to the same underlying Conversation;
- adding meaning in one lens affects the same Conversation elsewhere;
- tags are not folders;
- Working Sets are not the same as durable tags;
- Suppressed state affects ordinary visibility, not existence.
- Conversation Notes are user-authored interpretation, not message evidence.

## Architectural Validation

Future implementation should prove:

- Conversation Intent attaches to stable Conversation identity;
- durable intent is persisted in overlay/user-intent storage;
- graph projection does not read or write intent;
- source import does not overwrite intent;
- sidebar state is not the source of truth for durable intent;
- widgets do not directly decide or persist intent;
- read models merge graph facts and intent at read time;
- non-Conversations features consume intent without owning it.

## Existing Feature Regression Validation

When intent architecture begins to affect existing features, verify:

- Core Favourites still appear consistently everywhere a Conversation appears;
- Conversation Card favourite toggles still update global user intent;
- Contact-derived Conversation lists show the same intent state as the
  Conversation browser;
- right-side Conversation excerpts show the same intent state as other
  Conversation manifestations;
- Search result actions can request intent operations without becoming intent
  owner.

## Tags-On-Intent Validation

When Tags are implemented:

- creating a tag creates durable user intent;
- assigning a tag attaches it to Conversation identity;
- removing a tag from a Conversation does not delete the tag globally;
- deleting a tag removes or retires it globally according to designed
  semantics;
- renaming a tag updates it everywhere;
- tag state survives graph rebuild;
- tag state appears consistently across Conversation lenses.

## Retrieval Validation

When structured Conversation retrieval is designed, validate:

- retrieval by participant identity;
- retrieval by tag;
- retrieval by Favourite state;
- retrieval by Working Set;
- retrieval by visibility state;
- retrieval by note presence;
- combinations of participant + tag + lens;
- clear distinction from message-content search.

Expected user mental model:

```text
Conversation retrieval:
Which Conversation context am I trying to work with?

Message search:
Where was this said?
```

## AI Suggestion Validation

If AI-assisted classification is introduced:

- unconfirmed AI suggestions are not durable intent;
- confirmed suggestions become user-confirmed intent;
- users can distinguish suggested from confirmed;
- users can reject, edit, or remove suggestions;
- AI cannot silently hide, tag, favourite, or classify Conversations.

## Notes Validation

When Conversation Notes are implemented:

- one editable note attaches to canonical Conversation identity;
- editing a note does not alter message evidence;
- deleting note text does not delete the Conversation;
- note state survives graph rebuild;
- note presence can be surfaced as Conversation Intent;
- note search, if implemented, is distinct from message-content search.

## Suppressed Visibility Validation

When Suppressed state is implemented:

- suppressed Conversations are excluded from ordinary browsing/discovery by
  default;
- suppressed Conversations still appear in direct retrieval when explicitly
  requested;
- All Messages Search can still find message evidence from suppressed
  Conversations;
- graph facts, source rows, attachments, and message evidence are not deleted
  or hidden by projection.

## Data Integrity Validation

Future tests should cover:

- graph rebuild does not remove intent;
- Conversation display-name changes do not disconnect intent;
- Conversation sort/list position changes do not affect intent;
- missing or temporarily unresolved Conversation identity is handled
  gracefully;
- export/import preserves intent references without duplicating or corrupting
  intent.

## Non-Goals For Initial Validation

Do not validate these until explicitly designed:

- exact database schema;
- sync conflict resolution;
- nested/hierarchical intent;
- AI-generated taxonomies;
- Saved Investigation internals;
- analytics over intent usage.
