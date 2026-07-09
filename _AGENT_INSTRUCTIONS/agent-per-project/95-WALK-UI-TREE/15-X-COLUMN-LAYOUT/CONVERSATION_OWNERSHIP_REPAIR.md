# Conversation Ownership Repair

## Purpose

This document explains why the previous Conversation implementation was
architecturally wrong, what repair was implemented, and how the corrected
architecture conforms to MessageLens project rules.

It complements `CONVERSATION_OWNERSHIP_AUDIT.md`, which records the current
ownership map.

## What Was Wrong Before

The old implementation worked visually, but the ownership model was confused.
Conversation concerns were scattered across:

- `features/messages`
- `features/chats`
- `essentials/conversation_graph`

That created a feature that appeared to work while violating the project's
basic DDD and ViewSpec rules.

### 1. Messages owned Conversation UI

The Messages feature had accumulated:

- Conversation sidebar/list presentation
- Conversation signature display model composition
- Conversation Card style adapters
- Contact "By conversation" cards
- Conversation message view
- right-sidebar Conversation excerpt panel
- "In conversation" navigation details

This meant Conversation was effectively a mode inside Messages.

That was wrong because a Conversation is not a message-rendering detail. It is
a canonical graph entity that appears in many lenses:

- Conversations sidebar
- Contact page
- Search result context
- Favourites
- future discovery lenses

Messages should render message evidence. It should not own the user-facing
manifestation of Conversation.

### 2. Search context owned a Conversation panel

The right sidebar began life as a Search result context panel. As the UX
evolved, it became:

Conversation
-> Conversation Card
-> excerpt description
-> message excerpt centered on a chosen message

That is a Conversation lens anchored by a message, not a Search-owned widget.

The old path made the triggering surface responsible for the target entity's
UI. This is the wrong direction of ownership:

Wrong:

Search result -> render Search-owned context sidebar containing Conversation UI

Correct:

Search result -> request Conversation excerpt spec -> Conversations renders it

### 3. Graph essentials contained user-facing widgets

`essentials/conversation_graph` held user-facing Conversation presentation such
as:

- `ConversationSignatureCard`
- `ConversationFavouriteButton`

That was also wrong.

`essentials/conversation_graph` is an essential graph system. It may expose
facts, graph identity, repositories, and read primitives. It should not own
feature-level visual language.

Graph essentials answers:

What does the graph know?

Features answer:

What should the user see and do with that graph entity?

### 4. `features/chats` preserved stale terminology

The old `features/chats` folder was a transitional shell around legacy chat
concepts:

- recent chat summaries
- chat selection actions
- chat view model

But the product language had moved from Apple source `chat` records to
canonical graph `Conversation` entities.

Keeping `features/chats` as a compatibility seam invited a permanent naming
split:

- source-side Apple chats
- user-facing Conversations

The repair retired `features/chats` rather than letting stale terminology
remain as a semi-official feature boundary.

## Why This Was Dangerous

The previous arrangement risked several forms of architectural entropy.

### Authority leakage

Messages had authority over Conversation cards, filters, favourites, and
excerpt panels. That made it unclear which feature owned Conversation behavior.

### Projection incoherence

Conversation could appear in the sidebar, contact page, and right sidebar
through different code paths. That risked small differences in card styling,
favourite behavior, labels, and glyph rendering.

### ViewSpec owner mismatch

A panel displaying Conversation content could be represented as or fulfilled by
Messages. That undercut the ViewSpec system, where a spec should name the
feature responsible for interpreting it.

### Feature-local reconstruction

Messages could accidentally become a place that reconstructs Conversation
display state from message evidence instead of consuming Conversation read
models.

### UI layout drift

The right panel was being tuned as a Search sidebar widget, even though it was
actually a Conversation peer panel. Layout work was happening in the wrong
owner.

## Corrected Architecture

The repair established this rule:

There is one Conversation feature.

Conversation may appear in many lenses, but those appearances are
manifestations of the same canonical graph entity.

## New Ownership Boundaries

### Essentials

Essentials owns:

- source-scoped graph projection
- graph repositories/readers
- panel infrastructure
- sidebar infrastructure
- sealed `ViewSpec` transport
- PanelCoordinator dispatch

Essentials does not own Conversation presentation.

### Messages

Messages owns:

- message evidence scopes
- message evidence skeleton/hydration
- message rows
- message attachments/media evidence
- message evidence search
- global/contact/handle/recovered evidence views

Messages can request Conversation context for a message. It does not render
Conversation panels or cards as its own local UI.

### Conversations

Conversations owns:

- Conversation specs
- Conversation sidebar/cassette surfaces
- Conversation collection display models
- Conversation cards/glyphs
- Conversation favourite controls
- contact-scoped Conversation lists
- Conversation message views
- Conversation excerpt panels
- Conversation navigation/action boundaries

This makes Conversation a first-class feature rather than a Messages mode.

## Correct ViewSpec Flow

The repaired flow is:

1. A message row in Search/All Messages exposes an `In conversation` action.
2. The action calls the Conversations public action boundary:
   `conversationExcerptNavigationActionsProvider`.
3. The action stores a typed right-panel spec:
   `ViewSpec.conversations(ConversationsSpec.conversationExcerpt(...))`.
4. `PanelCoordinator` receives the active right-panel `ViewSpec`.
5. `PanelCoordinator` dispatches `ViewSpec.conversations(...)` to
   `features/conversations` `viewSpecCoordinatorProvider`.
6. The Conversations coordinator resolves the spec to
   `ConversationExcerptPanelView`.
7. The panel renders the Conversation Card and excerpt, while the message rows
   are rendered through the shared Message Evidence Spine.

This is the important correction:

PanelCoordinator no longer asks Messages to interpret the end sidebar
Conversation spec. It asks the Conversations feature.

## Why This Matches Project Guidelines

### DDD feature boundaries

Project rule:

Feature code should own its domain behavior and presentation. A feature should
not quietly own another feature's entity UI.

Repair:

Conversation UI moved to `features/conversations`. Messages no longer owns
Conversation entity presentation.

### Public feature seams

Project rule:

External consumers use `feature_level_providers.dart`. Internal code imports
exact sibling files rather than its own public barrel.

Repair:

Messages consumes Conversation surfaces through:

`features/conversations/feature_level_providers.dart`

Conversation internals remain behind the Conversations feature boundary.

### ViewSpec system

Project rule:

Panel content is selected by typed specs. Coordinators route specs to the
owning feature. Widgets do not imperatively push arbitrary local panel content.

Repair:

Conversation excerpt panels are represented as `ConversationsSpec`, wrapped in
`ViewSpec.conversations`, and fulfilled by the Conversations coordinator.

### Reader/integrator/orchestrator separation

Project rule:

Readers produce facts/read models. Coordinators route. Renderers render.
Widgets do not reconstruct semantics from unrelated data.

Repair:

Conversation display models live in the Conversations application layer.
Conversation widgets render typed Conversation display data. Message rows emit
navigation intent but do not reconstruct Conversation panels.

### Source-scoped graph semantics

Project rule:

Graph identity is canonical. GUID/source-row shortcuts should not reappear in
feature presentation paths.

Repair:

Conversation excerpt navigation uses:

- graph `conversationId`
- graph `anchorMessageId`

It does not decode back to source row ids or reroute through retired legacy
chat identity.

### Message Evidence Spine invariant

Project rule:

Source-specific scopes are allowed; source-specific message renderers are not.

Repair:

Conversation owns the panel, but message rows still render through the shared
Message Evidence Spine. The repair did not create a Conversation-only message
renderer.

## What Remains Intentionally Shared

Some crossings remain correct and intentional.

### Messages -> Conversations

Messages may ask Conversations to open a Conversation excerpt for a message.

Messages may embed the public `ContactGraphConversationSection` because the
Contacts/Message sidebar can offer a Conversation lens for a selected contact.

These are consumer relationships through the Conversations public seam.

### Conversations -> Messages

Conversations may use the Message Evidence Spine to render messages inside a
Conversation. That is not a reversal of ownership. It is reuse of the canonical
message evidence system.

The entity owner is Conversations. The row renderer is Messages.

### Conversations -> Graph Essentials

Conversations may read graph facts from `essentials/conversation_graph`.

That is the intended graph-to-feature direction:

graph facts -> feature read model -> presentation

## What Must Not Return

- `features/chats` as a user-facing feature.
- Conversation cards/glyphs/favourites under `features/messages`.
- Conversation cards/buttons under `essentials/conversation_graph/presentation`.
- Conversation excerpt panels represented as `MessagesSpec`.
- Search-owned context panels that render Conversation UI directly.
- Source-row/GUID reconstruction to open a graph Conversation.
- Conversation-specific message row renderers that bypass the Message Evidence
  Spine.

## Why This Matters For X-Column Layout

The X-column layout work depends on panel peers:

Search | Messages | Conversation

Before this repair, the right panel was structurally a Messages/Search widget
wearing Conversation language. That made layout tuning fragile because the
panel's conceptual owner was wrong.

After this repair:

- Search panel can be tuned as Search.
- Messages panel can be tuned as Messages.
- Conversation panel can be tuned as Conversation.

The page skeleton can now align peer panels by role rather than compensating
for mixed ownership inside one feature.

## Verification Expectations

Any future change touching this area should keep the following checks passing:

- `flutter analyze`
- `flutter test test/architecture/forbidden_imports_test.dart`
- focused Conversations tests
- focused Messages evidence tests
- navigation/panel coordinator tests

Manual smoke checks:

- Search All Messages -> click `In conversation`.
- Right panel opens as Conversation.
- Conversation Card appears in the right panel.
- Matching message is highlighted in both center and right panel.
- Favouriting the Conversation from any manifestation affects the same
  Conversation everywhere.
- Contact -> By conversation uses the same Conversation Card language.
