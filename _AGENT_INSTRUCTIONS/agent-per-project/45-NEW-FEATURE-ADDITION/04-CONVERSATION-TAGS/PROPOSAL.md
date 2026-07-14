---
tier: project
scope: feature-proposal
owner: agent-per-project
last_reviewed: 2026-07-11
source_of_truth: draft
status: consolidated-exploratory
links:
  - ../05-CONVERSATION-INTENT-ARCHITECTURE/README.md
  - ../06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md
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

Tags are also the first major planned feature built on the broader
Conversation Intent seam. This package owns tag-specific product behavior; the
Conversation Intent package owns the general architecture for user-authored or
user-confirmed Conversation meaning.

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

## Tag-Specific Model

A Conversation may have zero, one, or many tags.

A Tag may apply to zero, one, or many Conversations.

Tags are durable **Meaning** intent. They describe what a Conversation
represents to the user.

The tag feature should support:

- creation of a tag;
- assigning a tag to a Conversation;
- removing a tag from a Conversation;
- renaming a tag;
- deleting a tag;
- listing Conversations with a tag;
- showing tags wherever the Conversation appears.

The storage, identity, overlay, and ownership rules for this model are inherited
from Conversation Intent rather than redefined here.

## Relationship To Existing Concepts

### Conversation Intent

Conversation Intent is the broader architectural model for user-authored or
user-confirmed metadata attached to stable Conversation identity.

Tags are one durable Conversation Intent type. They should be designed on top
of that seam rather than as a tag-only persistence or sidebar special case.

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

### Structured Conversation Retrieval And Search

Structured Conversation Retrieval may eventually consume tags as remembered
context tokens:

- Conversations tagged `Family`;
- Favourite Conversations tagged `Taxes`;
- Dormant Conversations tagged `Health`.

Message-content Search may also use tags as refinement context:

- search within tagged Conversations;
- tag Conversations found from message search results;
- surface tags in result context.

Search should not own the tag model. Search can request tag operations or filter
by tags through Conversation/user-intent boundaries.

### Discovery

Tags can make Discovery more personal.

Examples:

- Dormant conversations tagged `Family`.
- Forgotten conversations tagged `Health`.
- Old trip conversations tagged `Hawaii Trip`.

Tags should support discovery without forcing the user to build a rigid filing
system.

## Architectural Direction

Conversation Tags inherit their architectural direction from Conversation
Intent:

- Tags attach to canonical Conversation identity.
- Tags are persisted as overlay/user intent.
- Graph projection does not read or write tags.
- `features/conversations` owns user-facing tag workflows and presentation.
- Search, Messages, Contacts, and Discovery may consume tag state but do not own
  tag semantics.

This package should not redefine the broader intent architecture. It should
specify how tags behave as a user-facing feature.

## Non-Goals

Do not design implementation details in this package.

Do not decide table names, provider names, schema migrations, UI widget classes,
or exact database columns here.

Do not implement:

- AI-assisted tagging;
- tag synchronization;
- higher-order investigation workspace features;
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
5. Expose a tag as a future retrieval/lens scope, if doing so remains small.

This would prove the durable model without overbuilding Discovery,
message-content Search refinement, Working Sets, or AI assistance.

## Open Questions

- Should tags have colors in the first version, or should color be deferred?
- Should tags be globally ordered by user preference, recent use, or name?
- Should a deleted tag leave any audit/remnant, or disappear completely?
- Should Conversation Cards show all tags, a few tags, or only tags relevant to
  the current lens?
- Should tag creation happen inline from the Conversation Card, from a tag
  management surface, or both?
- Should duplicate tag names be prevented case-insensitively?
- Should tags support optional descriptions?
- Should tag filtering first appear as a Conversation sidebar affordance or as
  part of Structured Conversation Retrieval?
- Should tags be exportable as a user data file before any synchronization work?

## Acceptance Criteria For This Proposal

- Tags are defined as user-created semantic labels, not folders.
- Tags attach to stable Conversation identity.
- Tags belong to overlay/user intent.
- The proposal respects the One Conversation principle.
- The proposal distinguishes Tags from Favourites and Working Sets.
- The proposal supports future retrieval and discovery without designing those
  features in detail.
- The package depends on Conversation Intent instead of re-explaining it.
- The package remains exploratory and does not mandate implementation.
