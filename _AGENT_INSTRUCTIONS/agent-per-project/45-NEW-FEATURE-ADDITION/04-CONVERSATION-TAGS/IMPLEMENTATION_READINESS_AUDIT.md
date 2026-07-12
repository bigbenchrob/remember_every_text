---
tier: project
scope: implementation-readiness
owner: agent-per-project
last_reviewed: 2026-07-11
source_of_truth: draft
status: planning
links:
  - ./README.md
  - ./DESIGN_NOTES.md
  - ./01-OPEN-QUESTION-EVALUATION/07-tag-creation-and-management-workflow.md
  - ../05-CONVERSATION-INTENT-ARCHITECTURE/README.md
  - ../06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md
  - ../../40-FEATURES/conversations/README.md
  - ../../10-DATABASES/07-overlay-database-independence.md
tests: []
---

# Conversation Tags Implementation Readiness Audit

## Purpose

This audit maps the settled Conversation Tags product direction onto the
current MessageLens codebase.

It is not an implementation task. Its purpose is to identify the smallest safe
first slice and the seams that must be respected before source changes begin.

## Executive Recommendation

MessageLens is ready for a narrow first implementation slice of Conversation
Tags.

Do **not** build a broad generic Conversation Intent framework first. The
Conversation Intent model is architecturally useful, but the first tag slice can
share the same durable boundaries already used by Core Favourites:

- stable graph Conversation identity;
- overlay persistence;
- Conversation-owned semantic providers/actions;
- read-time merging into Conversation read models;
- pure Conversation presentation widgets that receive resolved data and action
slots.

However, Tags should not reuse the current Core Favourites storage shape.
Favourites are currently persisted as structured JSON under a single overlay
setting key. Tags have two durable concepts - tag definitions and Conversation
assignments - so they should receive first-class overlay storage rather than a
single settings blob.

## Current State Findings

### Core Favourites Persistence And Providers

Current files:

- `lib/essentials/conversation_graph/application/conversation_favourites/conversation_favourites_provider.dart`
- `lib/essentials/conversation_graph/application/conversation_favourites/conversation_favourite_actions_provider.dart`
- `lib/essentials/conversation_graph/application/conversation_favourites/conversation_favourites_store_provider.dart`
- `lib/essentials/conversation_graph/infrastructure/repositories/overlay_conversation_favourites_store.dart`
- `lib/features/conversations/presentation/widgets/conversation_favourite_button.dart`

Core Favourites are global user intent attached to `int conversationId`.
The persisted value is structured JSON under overlay setting key:

```text
conversation_favourites/core
```

The UI writes through `ConversationFavouriteActions`, and architecture tests
guard against bypassing that action boundary.

Readiness implication:

- Tags should copy the action-boundary pattern.
- Tags should not copy the single-settings-key storage model unless the first
  implementation is deliberately throwaway.
- A future cleanup may move semantic favourite providers from
  `essentials/conversation_graph` into `features/conversations`, but that is not
  required before implementing Tags.

### Overlay Database And Migration Conventions

Current file:

- `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`

The overlay database already owns user-authored state such as contact
favourites, participant display-name overrides, handle visibility, archive
metadata, and message intent.

Existing message tag storage includes:

- legacy GUID-keyed `message_user_tags`;
- graph-native `message_intent_tags` created through custom SQL.

There is no Conversation tag or Conversation intent table yet.

Readiness implication:

- Conversation Tags belong in overlay storage.
- Overlay schema version must increase when first-class Conversation tag tables
  are added.
- The physical database provider remains in `essentials/db`; semantic tag
  repositories/providers should live under `features/conversations`.
- Do not store Conversation Tags in graph projection tables.

### Canonical Conversation Identity

Current files:

- `lib/essentials/conversation_graph/application/conversations/conversation.dart`
- `lib/essentials/conversation_graph/application/conversation_signatures/conversation_signature.dart`
- `lib/features/conversations/domain/spec_classes/conversations_view_spec.dart`
- `lib/features/conversations/application/conversation_signatures/conversation_signature_display_provider.dart`

The stable app-level Conversation key used by read models and ViewSpecs is:

```text
int conversationId
```

Conversation Tags should attach to this identity and should never attach to:

- title text;
- participant labels;
- current row order;
- search results;
- contact page row position;
- source handle labels.

### Existing Conversation Read Models

Current read-model path:

- graph facts come from `essentials/conversation_graph`;
- display identities are resolved in `features/contacts`;
- Conversation display models are composed in
  `features/conversations/application/conversation_signatures/conversation_signature_display_provider.dart`;
- card data is adapted by
  `features/conversations/presentation/widgets/conversation_signature_card_presentation.dart`.

Readiness implication:

- Tags should be merged into Conversation display/read-model data before
  presentation.
- Widgets should receive resolved tag display data; widgets must not query or
  persist tag state.
- The first slice can add tag state to Conversation-owned display data without
  changing message evidence rendering.

### Canonical Conversation Card Surfaces

Current canonical card:

- `lib/features/conversations/presentation/widgets/conversation_signature_card.dart`

Current important surfaces:

- Conversations sidebar:
  `lib/features/conversations/application/sidebar_cassette_spec/widget_builders/conversation_signatures_widget.dart`
- Contact By Conversation section:
  `lib/features/conversations/presentation/widgets/contact_conversations/contact_graph_conversation_section.dart`
- Right Conversation excerpt panel:
  `lib/features/conversations/presentation/view/conversation_excerpt_panel_view.dart`

The card is pure presentation:

- typed card data;
- typed style;
- explicit callbacks;
- trailing slot;
- no provider watching.

Readiness implication:

- Preserve card purity.
- Tag display can be added to typed card data or supplied through a slot/adjacent
  Conversation-owned wrapper.
- Tag mutation controls should be supplied by the surface or a reusable
  Conversation-owned action widget, not embedded inside the pure card.

### Clean Tag Action Entry Point

Best first-slice entry point:

- Conversation-owned action from a canonical Conversation Card surface.

Most conservative initial surface:

- Conversations sidebar card, because it is the primary Conversation browser
  and already owns favourite actions.

Acceptable follow-up surfaces:

- Contact By Conversation cards;
- right Conversation excerpt panel card;
- future Structured Conversation Retrieval results.

Do not put the first tag workflow inside:

- message evidence rows;
- Search result rows;
- graph projection code;
- generic sidebar state.

### Provider Invalidation And Read-Time Overlay Merge

Favourites currently update their own controller state immediately and are read
directly by surfaces that need favourite mode/list state.

For Tags, the likely pattern should be:

- tag actions mutate overlay;
- tag controller/read provider exposes tag definitions and assignments;
- Conversation signature display providers merge graph facts with tag intent;
- affected Conversation display providers are invalidated or refreshed through
  the tag action boundary.

Readiness implication:

- The first slice must define explicit invalidation ownership.
- Do not rely on widgets to refresh lists manually.
- Do not let tag writes occur inside display providers.

### Test Infrastructure

Relevant existing tests:

- `test/essentials/conversation_graph/application/conversation_favourites/conversation_favourites_provider_test.dart`
- `test/essentials/conversation_graph/application/conversation_favourites/conversation_favourite_actions_provider_test.dart`
- `test/features/conversations/presentation/widgets/conversation_signature_card_test.dart`
- `test/features/conversations/application/conversation_signatures/conversation_signature_display_provider_test.dart`
- `test/features/conversations/presentation/view/conversation_excerpt_panel_view_test.dart`
- `test/architecture/forbidden_imports_test.dart`

Readiness implication:

- Unit tests should cover duplicate prevention and overlay persistence.
- Widget tests should preserve Conversation Card purity.
- Architecture tests should prevent tag action/provider leakage into unrelated
  features once the boundary exists.

## First Slice Plan

Goal:

> Create/select a Tag in Conversation context, apply/remove it, prevent basic
> duplicates, persist it in overlay, and display it quietly on one canonical
> Conversation-owned surface.

### Slice 1A - Overlay Storage Boundary

Add Conversation tag storage to the overlay database.

Conceptual storage:

- tag definitions;
- Conversation-to-tag assignments;
- timestamps for creation/update;
- uniqueness by normalized tag name;
- uniqueness by `(conversationId, tagId)` or equivalent.

Do not implement colors, descriptions, ordering, import/export, or sync fields
unless needed to avoid data loss.

### Slice 1B - Conversation-Owned Semantic Boundary

Add `features/conversations` providers/actions/repositories for:

- reading tag definitions;
- reading tags for Conversation IDs;
- creating a tag from display text;
- applying/removing a tag to/from a Conversation;
- preventing basic normalized duplicates.

Use overlay DB through the central `overlayDatabaseProvider`.

Do not expose physical DB details through public widgets.

### Slice 1C - Read-Time Merge

Extend Conversation display/read-model data to include quiet tag display data.

The merge belongs in Conversation application/read-model code, not in the
Conversation Card widget.

### Slice 1D - One Canonical Surface

Display tags quietly in one Conversation-owned surface first.

Recommended first surface:

- Conversations sidebar card.

Keep the card title and glyph dominant. Tags should be secondary semantic
context.

### Slice 1E - Minimal Tag Authoring UI

Add a small Conversation-context action for:

- choosing an existing tag;
- creating a new tag by typing;
- removing an applied tag.

This should be discoverable through the Conversation context, but should not
become a global Tag Manager.

### Slice 1F - Tests

Minimum tests:

- overlay migration creates tag storage;
- duplicate normalized tag names are prevented;
- duplicate Conversation/tag assignment is prevented;
- applying/removing a tag persists in overlay;
- Conversation display model reads tags from overlay;
- Conversation Card remains provider-free;
- tag action boundary owns writes.

## Explicit Deferrals

Do not include in the first slice:

- Structured Conversation Retrieval;
- tag colors;
- full tag maintenance screen;
- bulk tagging;
- import/export;
- sync;
- AI-suggested tags;
- search refinement by tag;
- Working Set integration;
- Saved Investigations.

## Risk Assessment

### Main Risk: Premature Generic Intent Framework

Conversation Intent is the correct conceptual seam, but building a broad
framework before one concrete intent type is implemented would add indirection
without proving value.

Mitigation:

- implement Tags as a Conversation-owned overlay feature;
- keep naming and storage compatible with future Conversation Intent;
- avoid collapsing Favourites, Tags, Notes, Working Sets, and Suppressed state
  into one UI or provider too early.

### Main Architectural Seam To Watch: Favourites Location

Core Favourites still live under `essentials/conversation_graph` application
code even though current documentation says Conversation user intent belongs to
`features/conversations`.

This should not block Tags, but new tag code should not extend this older
placement. If Favourites and Tags later need shared intent primitives, migrate
the semantic favourite boundary toward `features/conversations` rather than
moving Tags into `essentials/conversation_graph`.

## Readiness Conclusion

The codebase has the necessary seams for a narrow first implementation:

- stable Conversation identity;
- overlay database;
- pure canonical Conversation Card;
- Conversation-owned feature boundary;
- existing favourite action patterns;
- relevant test infrastructure.

The next implementation step should be the first narrow tag slice above, not a
general Conversation Intent framework and not Structured Conversation
Retrieval.
