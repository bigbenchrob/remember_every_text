---
tier: project
scope: feature-proposal
owner: agent-per-project
last_reviewed: 2026-07-11
source_of_truth: draft
status: exploratory
links:
  - ./README.md
  - ./DESIGN_NOTES.md
  - ../05-CONVERSATION-INTENT-ARCHITECTURE/README.md
  - ../../95-WALK-UI-TREE/00-Registers/DESIGN_LANGUAGE_NOTES.md
tests: []
---

# Structured Conversation Retrieval Proposal

## Purpose

Define Structured Conversation Retrieval as the interaction model for finding
Conversations by known Conversation identity, metadata, and user-authored
Conversation Intent.

The goal is to help the user progressively narrow the Conversation universe
until the desired Conversation becomes obvious.

This feature does not search message text. It retrieves Conversation contexts.

## Product Philosophy

MessageLens is a memory exploration and rediscovery application.

Users often do not begin with a literal phrase they want to search for. They
begin with partial context:

- a person;
- a family or work category;
- a remembered project;
- an important favourite;
- a temporary Working Set;
- a suppressed/noisy class they want to exclude;
- a Conversation type such as group or one-to-one.

Structured Conversation Retrieval should let the user assemble those fragments
as recognizable tokens instead of typing into a generic search box.

The experience should encourage recognition:

> Yes, that is the tag I meant.

> Yes, that is the person.

> Yes, restrict this to favourites.

This is different from query construction. The user is not writing syntax. The
user is selecting known Conversation descriptors.

Structured Conversation Retrieval is not a query language. It is a language for
describing remembered context.

## Core Principle

There are two fundamentally different retrieval systems:

```text
All Messages Search
  -> Where was this said?
  -> message content
  -> message evidence

Structured Conversation Retrieval
  -> Which Conversation am I trying to work with?
  -> Conversation metadata and Conversation Intent
  -> Conversations
```

These systems may cooperate, but they must remain conceptually distinct.

## Proposed Interaction Model

Structured Conversation Retrieval uses tokenized typeahead.

The user types into a retrieval field. The field suggests structured
Conversation descriptors. Selecting a suggestion converts it into a badge.
Typing continues after each accepted badge.

Example:

```text
Type: cla
Suggests: Person: Claire
Accept:

[Claire] _

Type: fam
Suggests: Tag: Family
Accept:

[Claire] [Family] _

Type: fav
Suggests: Favourite
Accept:

[Claire] [Family] [Favourite] _
```

The resulting Conversation list is scoped by the selected tokens.

## Candidate Token Types

Initial design should consider tokens such as:

- Contact identity;
- Tag;
- Core Favourite;
- Working Set;
- Group Conversation;
- one-to-one Conversation;
- visibility/suppressed state;
- has notes;
- future confirmed AI classification.

This list is not complete. The architecture should allow new Conversation
metadata and Conversation Intent types to become retrieval tokens without
inventing another sidebar mode.

## Relationship To Conversation Intent

Conversation Retrieval consumes intent.

It may retrieve by:

- Tags;
- Favourites;
- Working Sets;
- visibility state;
- Notes;
- confirmed classifications.

It must not define or persist those concepts. They belong to Conversation
Intent and user-intent/overlay ownership.

## Relationship To Conversation Lenses

Retrieval and Conversation Lenses are orthogonal.

Retrieval answers:

> Which Conversations?

Lenses answer:

> How should those Conversations be viewed?

Examples:

```text
Retrieval tokens:
  Claire + Family

Lens:
  Dormant

Result:
  Dormant Conversations involving Claire tagged Family
```

or:

```text
Retrieval token:
  Canucks

Lens:
  Most recently updated

Result:
  Canucks Conversations organized by latest activity
```

## Relationship To All Messages Search

Structured Conversation Retrieval must not silently become message-content
search.

Typing `Hawaii` should not search every message body for `Hawaii`.

Instead, retrieval may suggest known metadata or intent such as:

- Tag: Hawaii Trip;
- Conversation title/participant: Hawaii Travel Group;
- Working Set: Hawaii booking investigation.

If the user wants to know where `Hawaii` was said, they should use All Messages
Search.

## Architectural Direction

Structured Conversation Retrieval should be implemented, when approved, as a
Conversation-facing retrieval model over graph facts plus Conversation Intent.

High-level ownership:

- `features/conversations` should own the user-facing Conversation retrieval
  experience.
- Conversation Intent owns durable user-authored/reviewed meaning.
- The graph owns canonical Conversation identity and derived Conversation
  facts.
- Search may send users toward Conversation retrieval, but Search should not
  own the retrieval model.
- Message evidence may expose affordances that add a source Conversation to an
  intent scope, but message rows are not Conversation retrieval tokens.

## Non-Goals

Do not implement in this package.

Do not choose:

- database schema;
- provider names;
- exact widget classes;
- exact typeahead engine;
- persistence strategy;
- AI classification workflow.

Do not replace All Messages Search.

Do not collapse Conversation Retrieval, Conversation Lenses, Tags, Favourites,
and Working Sets into one UI concept.

## Acceptance Criteria For This Proposal

- The package clearly distinguishes Conversation Retrieval from message-content
  search.
- The package defines retrieval as tokenized narrowing over Conversation
  metadata and Conversation Intent.
- The package preserves Conversation Intent ownership.
- The package keeps retrieval and Conversation Lenses orthogonal.
- The package explains why this avoids accumulating more sidebar modes.
- The package stays exploratory and does not prescribe implementation details.
