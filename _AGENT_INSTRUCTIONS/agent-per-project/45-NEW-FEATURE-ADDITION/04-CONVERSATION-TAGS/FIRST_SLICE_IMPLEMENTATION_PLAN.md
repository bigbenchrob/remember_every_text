---
tier: project
scope: implementation-plan
owner: agent-per-project
last_reviewed: 2026-07-12
source_of_truth: draft
status: implemented
links:
  - ./README.md
  - ./IMPLEMENTATION_READINESS_AUDIT.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
  - ../05-CONVERSATION-INTENT-ARCHITECTURE/README.md
  - ../../40-FEATURES/conversations/README.md
  - ../../10-DATABASES/07-overlay-database-independence.md
tests: []
---

# Conversation Tags First Slice Implementation Plan

## Implementation Outcome

Implemented on 2026-07-12.

The first vertical slice follows this plan with one deliberately narrow display
scope: tags are authored and shown in the Conversations sidebar only. The
underlying read model now carries tag display data, but other Conversation Card
surfaces opt in later so cross-surface display can be reviewed deliberately.

Implemented:

- overlay schema version 7 with tag definitions and Conversation tag
  assignments;
- overlay-backed Conversation tag repository;
- Conversation-owned tag read providers and action provider;
- tag merge into Conversation signature display models;
- provider-free Conversation card support for supplied tag labels;
- Conversations-sidebar tag affordance for create/apply/remove;
- repository, action, read-model, widget, overlay migration, analyzer, and
  targeted test coverage.

Final design choices:

- tag names are trimmed and repeated internal whitespace is collapsed;
- duplicate tag names compare case-insensitively through `normalizedName`;
- the first-created display spelling/casing is preserved;
- empty normalized names are rejected with `FormatException`;
- tag definitions are separate from Conversation assignments;
- removing a tag from one Conversation removes only the assignment;
- broad cross-surface tag display is opt-in through `includeTags` so the first
  slice remains limited to the Conversations sidebar.

Primary implementation files:

- storage:
  - `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
  - `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.g.dart`
- domain/application/infrastructure:
  - `lib/features/conversations/domain/conversation_tags/conversation_tag_display.dart`
  - `lib/features/conversations/application/conversation_tags/conversation_tag_repository.dart`
  - `lib/features/conversations/application/conversation_tags/conversation_tag_repository_provider.dart`
  - `lib/features/conversations/application/conversation_tags/conversation_tags_provider.dart`
  - `lib/features/conversations/application/conversation_tags/conversation_tag_actions_provider.dart`
  - `lib/features/conversations/infrastructure/repositories/overlay_conversation_tag_repository.dart`
  - `lib/features/conversations/application/conversation_signatures/conversation_signature_display_provider.dart`
- presentation:
  - `lib/features/conversations/presentation/widgets/conversation_tag_button.dart`
  - `lib/features/conversations/presentation/widgets/conversation_signature_card.dart`
  - `lib/features/conversations/presentation/widgets/conversation_signature_card_presentation.dart`
  - `lib/features/conversations/application/sidebar_cassette_spec/widget_builders/conversation_signatures_widget.dart`
- tests:
  - `test/essentials/db/infrastructure/data_sources/local/overlay/overlay_database_test.dart`
  - `test/features/conversations/infrastructure/repositories/overlay_conversation_tag_repository_test.dart`
  - `test/features/conversations/application/conversation_tags/conversation_tag_actions_provider_test.dart`
  - `test/features/conversations/application/conversation_signatures/conversation_signature_display_provider_test.dart`
  - `test/features/conversations/presentation/widgets/conversation_signature_card_test.dart`
  - `test/architecture/forbidden_imports_test.dart`

Verification results:

- `flutter analyze` passed.
- Focused Conversation Tags, Conversation signature, card, and overlay
  migration tests passed.
- Architecture test is tag-clean after adding the named action-boundary
  invalidation allowance, but the full architecture suite currently reports one
  unrelated pre-existing layout debug color literal in
  `lib/config/theme/widgets/layout/vertical_column_bands.dart`.

Manual verification procedure:

1. Open MessageLens to the Conversations sidebar.
2. Choose a Conversation card.
3. Click the tag affordance beside the favourite star.
4. Type a new tag name such as `Family` and choose `Create & Apply`.
5. Confirm the tag appears quietly on that Conversation card.
6. Reopen the tag sheet, remove the tag assignment, and confirm it disappears
   from that card.
7. Reapply the existing tag from the available-tags list.
8. Quit and relaunch the app.
9. Confirm the applied tag remains visible on the same Conversation card.

Deferred:

- Structured Conversation Retrieval;
- global tag cleanup/management;
- tag colors/descriptions/order/merge;
- bulk operations, import/export, sync, AI suggestions;
- broad tag display in Contact, Search, and right Conversation excerpt lenses.

## Objective

Implement the smallest complete vertical slice that proves Conversation Tags
fit the approved Conversation Intent architecture.

The slice validates one full workflow:

1. User opens a Conversation from the Conversations sidebar.
2. User invokes a Tag affordance on that Conversation.
3. User creates a new Tag.
4. The Tag is attached to the canonical Conversation.
5. The Tag is persisted in overlay storage.
6. Conversation read models merge the Tag at read time.
7. The canonical Conversation presentation displays the Tag.
8. Restarting the application preserves the Tag.

This is not the full Tags feature.

## First-Slice Surface

Use the Conversations sidebar as the first implementation surface.

Reason:

- it is the primary Conversation browser;
- it already displays the canonical Conversation Card;
- it already hosts Conversation-owned favourite intent;
- it keeps the first workflow entirely inside `features/conversations`;
- it avoids creating premature Search, Contacts, or right-sidebar integration.

The first slice should not add tag controls to:

- Contact By Conversation cards;
- the right Conversation excerpt panel;
- Search result rows;
- message evidence rows;
- Structured Conversation Retrieval.

Those surfaces can consume the same read model in later slices after the
storage/action/read path has been proven.

## Affected Areas

### `essentials/db`

Owns physical overlay database schema and migration.

Expected changes:

- add first-class Conversation tag storage to
  `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`;
- increment overlay schema version;
- add migration for existing overlay databases;
- keep physical DB construction behind `overlayDatabaseProvider`.

No other feature should construct or own the overlay database.

### `features/conversations`

Owns user-facing Conversation tag semantics, actions, read models, and
presentation.

Expected changes:

- add tag domain/read-model types;
- add overlay-backed repository boundary;
- add provider(s) for reading tag definitions and assignments;
- add action provider for creating/applying/removing tags;
- merge tag display data into Conversation signature display models;
- add one tag affordance to the Conversations sidebar card workflow;
- render applied tags quietly on the canonical Conversation presentation.

### `essentials/conversation_graph`

No graph projection changes.

The graph provides the canonical `conversationId`, but does not read, write, or
derive tag state.

### `features/messages`, `features/search`, `features/contacts`

No first-slice changes except incidental compile-time import adjustments if
Conversation display data signatures change.

These features must not own tag semantics.

## Overlay Additions

Use first-class overlay tables rather than an `overlay_settings` JSON blob.

Conceptual tables:

### Tag definitions

Represents the user's durable Tag vocabulary.

Minimum fields:

- stable tag id;
- display name;
- normalized name;
- created timestamp;
- updated timestamp.

Required constraints:

- normalized name must be unique;
- empty names must not be stored;
- display name should preserve user casing after normalization trims/collapses
  whitespace.

### Conversation tag assignments

Represents Tag membership on canonical Conversation identity.

Minimum fields:

- conversation id;
- tag id;
- created timestamp;
- updated timestamp.

Required constraints:

- duplicate assignment for the same Conversation and Tag must be prevented.

Do not add:

- colors;
- descriptions;
- sort order;
- sync metadata;
- AI provenance;
- import/export metadata.

Those are explicitly outside the first slice.

## Providers, Repositories, And Actions

### Repository Boundary

Create a Conversation-owned repository abstraction under
`features/conversations`.

Responsibilities:

- read all tag definitions;
- read tags for one or more Conversation IDs;
- create a tag if needed;
- assign a tag to a Conversation;
- remove a tag from a Conversation;
- enforce basic duplicate prevention through normalized names and unique
  assignments.

The repository may use `OverlayDatabase`, but only through a provider that
receives the centralized `overlayDatabaseProvider`.

### Read Providers

Add providers that expose typed Conversation tag data:

- all tag definitions;
- tag assignments for requested Conversation IDs;
- tags for a single Conversation if needed by the popover/editor.

The read providers should return display-ready tag data without exposing drift
rows to widgets.

### Action Provider

Add a Conversation-owned action provider for mutations.

First-slice actions:

- create and assign tag to Conversation;
- assign existing tag to Conversation;
- remove tag from Conversation.

Action provider responsibilities:

- call the repository;
- invalidate/refresh affected tag read providers;
- invalidate/refresh affected Conversation signature display providers if
  needed;
- keep write behavior out of widgets.

Widgets may call the action provider; widgets must not write directly to the
repository or overlay database.

## Read-Model Changes

Extend Conversation display data with quiet tag display data.

Affected model:

- `ConversationSignatureDisplayModel`

Add a minimal field such as a list of display tag objects.

The merge should happen in
`conversation_signature_display_provider.dart`, where graph signature facts are
already converted into display models.

Rules:

- tags are merged by `conversationId`;
- graph facts remain authoritative for Conversation structure;
- overlay tags are authoritative for user meaning;
- missing tag rows should not prevent Conversation display;
- tag state must not be inferred from title, participants, search result, or
  list mode.

## Conversation UI Changes

### Canonical Card Purity

`ConversationSignatureCard` remains a presentation widget.

Allowed changes:

- extend `ConversationSignatureCardData` with optional display tags;
- render a quiet tag row/chip area from passed data;
- keep callbacks, style, and action slots explicit.

Forbidden changes:

- watching providers inside the card;
- constructing actions inside the card;
- querying overlay or graph storage inside the card;
- making the card decide tag semantics.

### First-Slice Tag Affordance

Add one small affordance in the Conversations sidebar card workflow.

Recommended placement:

- near the existing favourite star, using a Conversation-owned trailing/action
  cluster supplied by the sidebar caller.

Behavior:

- opens a small editor/popover/sheet scoped to the selected Conversation;
- lets user type a tag name;
- creates the tag if it does not exist;
- applies it to the Conversation;
- lists existing tags for selection if practical within the small slice;
- lets user remove an already-applied tag from this Conversation.

Keep visual language quiet:

- title and glyph remain primary;
- tags are secondary semantic context;
- no color system in this slice.

## Migration Considerations

Overlay schema migration must be safe for existing user data.

Migration requirements:

- increment overlay schema version;
- create new Conversation tag tables on upgrade;
- preserve existing overlay data, including Core Favourites, contact
  favourites, display-name overrides, handle overrides, message intent, archive
  metadata, and settings;
- no migration from Core Favourites into Tags;
- no migration from message tags into Conversation Tags.

Because there is currently only one active user and existing tag data does not
exist, no data backfill is required.

## Test Strategy

### Overlay / Repository Tests

Add focused tests for:

- overlay migration creates Conversation tag storage;
- creating a tag persists display and normalized names;
- duplicate normalized tag names do not create duplicate definitions;
- assigning a tag to a Conversation persists the assignment;
- duplicate assignments are prevented;
- removing a tag from a Conversation removes only that assignment.

### Provider / Action Tests

Add tests for:

- action provider creates and assigns a tag;
- action provider assigns an existing tag;
- action provider removes a tag;
- read providers return display-ready tags;
- provider invalidation causes Conversation display data to reflect mutations.

### Conversation Read-Model Tests

Extend existing Conversation signature display tests to prove:

- graph signature data still loads without tags;
- tag data merges by `conversationId`;
- tag display survives ordering/filtering/lens changes;
- tag display does not alter graph facts.

### Widget Tests

Update or add tests to prove:

- `ConversationSignatureCard` renders passed tag data;
- card remains provider-free;
- the first-slice sidebar tag affordance calls the action boundary rather than
  writing directly.

### Architecture Tests

Add or extend tripwires only where directly useful:

- tag persistence must not be owned by graph projection;
- tag action provider should not be consumed by unrelated features in the first
  slice;
- `ConversationSignatureCard` must remain provider-free.

Do not add broad architectural hardening unrelated to this release slice.

## Implementation Order

1. Add overlay schema and repository-level persistence tests.
2. Add Conversation tag repository and providers.
3. Add action provider and invalidation behavior.
4. Merge tags into `ConversationSignatureDisplayModel`.
5. Extend canonical card data/rendering for quiet tag display.
6. Add the first sidebar tag affordance.
7. Run targeted tests.
8. Run analyzer.
9. Manually verify:
   - create tag;
   - tag appears on the Conversation card;
   - restart app;
   - tag remains visible.

## Explicit Non-Goals For This Slice

Do not implement:

- Structured Conversation Retrieval;
- Tag Manager;
- tag colors;
- tag descriptions;
- bulk tagging;
- tag merge;
- import/export;
- synchronization;
- AI-assisted tagging;
- message-search refinement;
- Working Set integration;
- Notes integration;
- multiple Conversation presentation surfaces.

## Review Questions Before Coding

This plan assumes:

1. The first surface is the Conversations sidebar card.
2. First-slice storage uses first-class overlay tables, not an
   `overlay_settings` JSON blob.
3. Tag definitions and Conversation assignments are separate concepts from the
   beginning.
4. The first authoring UI may be small and Conversation-local; no global tag
   management surface is included.

If those assumptions are approved, implementation can begin with the overlay
schema and repository tests.
