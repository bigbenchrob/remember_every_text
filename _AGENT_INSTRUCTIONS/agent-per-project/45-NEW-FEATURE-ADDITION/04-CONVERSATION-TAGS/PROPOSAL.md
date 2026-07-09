---
tier: project
scope: feature-proposal
owner: agent-per-project
last_reviewed: 2026-07-09
source_of_truth: draft
status: exploratory
links:
  - ./README.md
  - ./DESIGN_NOTES.md
  - ../../40-FEATURES/conversations/README.md
  - ../../95-WALK-UI-TREE/00-STANDARDS/UX_PRINCIPLES.md
---

# Conversation Tags Proposal

## Purpose

Introduce Conversation Tags as durable user-created semantic labels attached to
canonical Conversation entities.

Tags help users remember, retrieve, and rediscover the meaning of conversations
over time. They should become part of the user's personal interpretation of
their communication history, not a separate storage hierarchy.

Examples:

- Family
- Work
- Hawaii Trip
- Canucks
- Taxes
- Neighbours
- Vacation Planning
- Photography
- Health

## Product Rationale

MessageLens is not merely an interface to Apple Messages. It is a memory
exploration and rediscovery application.

Conversations already support recognition through title, participants, glyphs,
activity shape, Favourites, and lenses such as Dormant or Most Recently
Updated. Tags add a user-authored semantic layer:

> This Conversation means something to me, and I want to name that meaning.

Tags support two complementary modes:

- **Retrieval**: "Show me conversations tagged Taxes."
- **Discovery**: "What old Health conversations did I forget about?"

The tag system should therefore serve both known-item lookup and future
exploratory surfaces.

## Product Philosophy

Tags are not folders.

Folders imply containment, single location, and hierarchy. Tags imply meaning,
overlap, and reuse. A Conversation may belong to several meaningful contexts at
once.

Examples:

- A conversation with a sibling might be tagged `Family`, `Estate`, and
  `Health`.
- A vacation planning thread might be tagged `Family`, `Hawaii Trip`, and
  `Photography`.
- A contractor thread might be tagged `House`, `Work`, and `Taxes`.

Tags should feel lightweight enough that users will apply them, but durable
enough that applying a tag feels like preserving meaning.

## Core Model

A Conversation may have zero, one, or many tags.

A Tag may apply to zero, one, or many Conversations.

Tags are user intent. They should be stored in overlay and resolved against
stable Conversation identity. The graph projection should not consult tags, and
tags should not be written into graph projection tables.

The model should support:

- creation of a tag;
- assigning a tag to a Conversation;
- removing a tag from a Conversation;
- renaming a tag;
- deleting a tag;
- listing Conversations with a tag;
- showing tags wherever the Conversation appears.

## Relationship To Existing Concepts

### Favourites

Favourites are a special global user-intent signal for important Conversations.

Tags are broader semantic labels. A Favourite Conversation may also have tags,
but tags do not replace Favourites.

The first tag system should not re-implement Favourites as a tag unless the
product explicitly decides to make Core Favourites a special tag-like overlay
later.

### Conversation Lenses

Tags should become available to Conversation Lenses.

Examples:

- Browse Conversations tagged `Family`.
- Organize `Family` conversations by Dormant.
- Show most recently updated `Work` conversations.
- Discover old `Vacation Planning` conversations.

Tags should filter or scope lenses without changing the underlying Conversation
entity.

### Working Sets

Working Sets are temporary investigation collections. Tags are durable semantic
labels.

They may eventually interact:

- convert a Working Set into a tag;
- add tagged Conversations to a Working Set;
- apply a tag to several Conversations found during an investigation.

Do not implement Working Sets as tags by default. They have different
lifetimes.

### Search

Search may eventually use tags as refinement context:

- search within tagged Conversations;
- tag Conversations found from message search results;
- surface tags in result context.

Search should not own the tag model. Search can request tag operations or
filter by tags through Conversation/user-intent boundaries.

### Discovery

Tags can make Discovery more personal.

Examples:

- Dormant conversations tagged `Family`.
- Forgotten conversations tagged `Health`.
- Old trip conversations tagged `Hawaii Trip`.

Tags should support discovery without forcing the user to build a rigid filing
system.

## Architectural Direction

Conversation Tags should be treated as user overlay intent attached to canonical
Conversation identity.

High-level ownership:

- `features/conversations` owns user-facing tag workflows, presentation, and
  Conversation/tag lenses.
- Overlay storage owns persisted user intent.
- `essentials/conversation_graph` owns source-scoped Conversation identity and
  graph facts, not tag meaning.
- `features/messages` may display or request tag affordances where a message
  belongs to a Conversation, but it should not own the tag model.
- Search and future Discovery can consume tags as scope/refinement inputs.

## Non-Goals

Do not design implementation details in this package.

Do not decide table names, provider names, schema migrations, UI widget classes,
or exact database columns here.

Do not implement:

- AI-assisted tagging;
- tag synchronization;
- saved investigations;
- complex tag hierarchies;
- tag folders;
- nested tags;
- bulk import/export format;
- full tag analytics.

This package should establish the architectural capability and product meaning.

## Proposed First Product Slice

The first implementation slice, when approved later, should likely be small:

1. Create a tag.
2. Rename/delete a tag.
3. Add/remove a tag from a Conversation Card.
4. Show assigned tags on a Conversation detail/card surface in a restrained way.
5. Filter Browse Conversations by one tag.

This would prove the durable model without overbuilding Discovery, Search
refinement, or AI assistance.

## Open Questions

- Should tags have colors in the first version, or should color be deferred?
- Should tags be globally ordered by user preference, recent use, or name?
- Should a deleted tag leave any audit/remnant, or disappear completely?
- Should Conversation Cards show all tags, a few tags, or only tags relevant to
  the current lens?
- Should tag creation happen inline from the Conversation Card, from a tag
  management surface, or both?
- Should Core Favourites eventually be represented through the same user-intent
  infrastructure as tags while remaining user-facing as Favourites?
- How should tags behave if a Conversation identity is rebuilt or recanonicalized?
- Should tags be exportable as a user data file before any synchronization work?

## Acceptance Criteria For This Proposal

- Tags are defined as user-created semantic labels, not folders.
- Tags attach to stable Conversation identity.
- Tags belong to overlay/user intent.
- The proposal respects the One Conversation principle.
- The proposal distinguishes Tags from Favourites and Working Sets.
- The proposal supports future retrieval and discovery without designing those
  features in detail.
- The package remains exploratory and does not mandate implementation.
