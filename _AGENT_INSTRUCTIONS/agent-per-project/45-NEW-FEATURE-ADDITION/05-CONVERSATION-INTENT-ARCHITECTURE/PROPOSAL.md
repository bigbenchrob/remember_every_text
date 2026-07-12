---
tier: project
scope: architecture-proposal
owner: agent-per-project
last_reviewed: 2026-07-11
source_of_truth: doc
status: approved-architecture
links:
  - ./README.md
  - ./DESIGN_NOTES.md
  - ../04-CONVERSATION-TAGS/README.md
  - ./01-OPEN-QUESTION-EVALUATION/01-core-favourites-status.md
  - ./01-OPEN-QUESTION-EVALUATION/02-durable-vs-session-scoped.md
  - ./01-OPEN-QUESTION-EVALUATION/03-working-sets.md
  - ./01-OPEN-QUESTION-EVALUATION/04-hidden.md
  - ./01-OPEN-QUESTION-EVALUATION/05-categories-of-conversation-intent.md
  - ./01-OPEN-QUESTION-EVALUATION/06-conversation-notes.md
  - ../../40-FEATURES/conversations/README.md
---

# Conversation Intent Proposal

## Purpose

Define Conversation Intent as a durable architectural seam for user-authored or
user-confirmed metadata attached to stable Conversation identity.

Conversation Intent is not imported source data, graph projection, sidebar-local
state, or a folder hierarchy. It is the set of things the user decides, curates,
or confirms about a Conversation.

The key rule:

> Favourites, Tags, Working Sets, Suppressed state, Notes, and future
> user-confirmed classifications are not separate containers for Conversations.
> They are user intent attached to the one canonical Conversation.

## Why This Package Exists

The Conversation Tags package correctly identifies tags as semantic labels
attached to canonical Conversation identity. That insight generalizes.

Without a broader Conversation Intent model, every future user-authored
Conversation concept risks becoming its own special case:

- a separate sidebar mode;
- a separate list type;
- a separate persistence path;
- a separate filter model;
- a separate "kind" of Conversation.

That would make MessageLens harder to understand as it grows.

Conversation Intent prevents this by giving new user-authored Conversation
meaning one shared architectural home.

## Conceptual Model

### What Conversation Intent Is

Conversation Intent is user-authored or user-confirmed interpretation attached
to a canonical Conversation. Different intent types may have different
persistence lifetimes.

Examples:

- "This Conversation is a Favourite."
- "This Conversation is tagged Family and Taxes."
- "This Conversation belongs to my current Working Set."
- "This Conversation should be suppressed from ordinary browsing."
- "This Conversation has a note: ask Cathie about this later."
- "The AI suggested this is about Health, and I confirmed it."

### What Intrinsic Conversation State Is

Intrinsic Conversation state is what makes the Conversation itself identifiable
as a source-scoped graph entity:

- stable Conversation identity;
- participant topology;
- source-scoped message membership;
- source-scoped provenance;
- canonical graph relationships.

Intrinsic state answers:

> What Conversation is this?

### What Imported Source State Is

Imported source state comes from external sources such as Apple Messages and
AddressBook:

- raw message rows;
- chat membership;
- handle rows;
- attachment references;
- AddressBook identities;
- source timestamps and identifiers.

Imported source state answers:

> What did the source systems contain?

### What Derived Graph State Is

Derived graph state is MessageLens' deterministic projection over source data:

- Conversations;
- message/conversation edges;
- participant relationships;
- Conversation signatures;
- activity months;
- source-scoped identity mappings.

Derived graph state answers:

> What graph facts follow from source data?

### What User-Authored Or User-Confirmed State Is

User-authored or user-confirmed state is Conversation Intent:

- Favourites;
- Tags;
- Suppressed visibility state;
- Notes;
- Working Sets;
- confirmed AI suggestions;

It answers:

> What does the user want to remember, curate, suppress, collect, or confirm about
> this Conversation?

## Why The Distinction Matters

MessageLens can rebuild imported and graph-derived state from sources.
It cannot rebuild user intent unless that intent is preserved.

Therefore:

- source import must not overwrite Conversation Intent;
- graph projection must not read or write Conversation Intent;
- sidebar state must not become the source of truth for Conversation Intent;
- widgets must not locally persist Conversation Intent;
- read models may merge graph facts and intent at read time.

This keeps user meaning durable while allowing graph projection to remain
deterministic.

## Architectural Direction

Conversation Intent should be modeled as overlay/user-intent state attached to
stable Conversation identity.

High-level ownership:

- overlay/user-intent storage persists Conversation Intent;
- `features/conversations` owns user-facing Conversation Intent workflows and
  presentation;
- `essentials/conversation_graph` owns source-scoped graph identity and facts;
- Search, Messages, Contacts, and Discovery may consume Conversation Intent as
  read-model inputs;
- no non-Conversations feature should own the general intent model.

## Product Philosophy

Conversation Intent supports MessageLens as a memory exploration and
rediscovery application.

It helps users separate meaningful communication history from noise without
forcing rigid folders.

The user should be able to ask:

- Which Conversations are important to me?
- Which Conversations did I classify as Family?
- Which Conversations am I working with right now?
- Which Conversations should stay out of normal browsing?
- Which Conversations contain meaningful notes or confirmed topics?

This is not message-content search. It is Conversation retrieval by meaning.

## Categories Of Conversation Intent

Conversation Intent has shared architectural principles, but intent types do
not all express the same kind of user decision.

The approved categories are:

- **Meaning** - what this Conversation represents, such as Tags or
  user-confirmed AI classifications.
- **Importance** - how significant this Conversation is to the user, such as
  Core Favourite.
- **Visibility** - whether the Conversation should participate in ordinary
  browsing and discovery, such as Suppressed.
- **Context** - what the user is actively working with, such as Working Sets.
- **Annotation** - what the user wants to remember about the Conversation, such
  as Conversation Notes.

Shared architecture does not imply shared semantics or shared user experience.
See
[`01-OPEN-QUESTION-EVALUATION/05-categories-of-conversation-intent.md`](01-OPEN-QUESTION-EVALUATION/05-categories-of-conversation-intent.md)
for the decision record.

## Lifetimes

Conversation Intent supports at least three lifetime classes:

- **Durable intent** - persisted user meaning, such as Core Favourites, Tags,
  Suppressed state, Conversation Notes, and confirmed classifications.
- **Session-scoped intent/state** - temporary working context such as current
  filters, selected retrieval tokens, unconfirmed suggestions, and unsaved
  Working Sets.
- **Persistable working intent** - Working Sets that begin temporary and become
  durable only after explicit user action.

Temporary state must never silently become durable. Durable intent must never
be lost merely because it began during exploration.

## Relationship To Conversation Tags

Tags are one durable Meaning intent type built on top of Conversation Intent.

Tags should remain a focused feature package. Conversation Intent owns the
general model:

```text
Conversation Intent
  -> Favourites
  -> Tags
  -> Working Sets
  -> Suppressed state
  -> Notes
  -> Confirmed AI classifications
```

The Tags package should explain tag-specific UX and product behavior. This
package should explain why tags belong to a broader intent seam.

## Saved Investigations Are Out Of Scope

Saved Investigations are a higher-order workspace concept, not simply
Conversation Intent attached to one Conversation.

They may eventually combine:

- message search queries;
- selected messages;
- selected Conversations;
- retrieval tokens;
- date ranges;
- notes;
- navigation context.

They should receive their own architecture package if and when they are
designed.

## Non-Goals

Do not implement anything from this package directly.

Do not choose:

- database table names;
- provider names;
- widget classes;
- exact schema migrations;
- specific UI components;
- exact retrieval query syntax.

Do not collapse Favourites, Tags, Working Sets, Suppressed state, Notes, and
confirmed classifications into one UI concept prematurely.

The architecture may share a seam; the user experience may still present these
concepts differently.

## Proposed First Architectural Slice

When implementation is eventually approved, the first slice should likely be:

1. Name and document the Conversation Intent boundary.
2. Audit existing Favourites and future Tags against that boundary.
3. Define a minimal read-model shape for "Conversation plus intent summary."
4. Route Core Favourites through the shared seam without preserving legacy
   favourite records if doing so adds complexity.
5. Build Tags on that same seam rather than a separate special-case system.

## Acceptance Criteria For This Proposal

- Conversation Intent is defined as user-authored/user-confirmed state attached
  to stable Conversation identity.
- The proposal distinguishes imported source state, derived graph state, and
  user intent.
- The proposal preserves overlay ownership.
- The proposal preserves the One Conversation principle.
- The proposal positions Tags as a feature built on top of Conversation Intent.
- The proposal avoids collapsing all intent concepts into one UI prematurely.
- The proposal explains how Conversation retrieval can consume intent tokens.
- The proposal treats Saved Investigations as future out-of-scope workspace
  architecture.
