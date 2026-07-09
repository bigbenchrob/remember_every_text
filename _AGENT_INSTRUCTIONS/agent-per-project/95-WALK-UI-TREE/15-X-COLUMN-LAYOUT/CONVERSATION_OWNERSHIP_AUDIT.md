# Conversation Ownership Audit

## Purpose

This audit records the ownership correction made during the Search page
X-column layout work.

The triggering problem was not merely visual spacing. The right sidebar had
evolved from a Search-owned "message context" panel into a Conversation
workspace, but the implementation still treated Conversation UI as a Messages
subsurface. That violated the emerging product model:

Search -> Messages -> Conversation

These are coordinated peer lenses onto the graph. Search may request a
Conversation excerpt. Messages may render message evidence and expose an
"In conversation" affordance. Conversations owns the Conversation entity
presentation.

## Governing Rule

Search requests a Conversation excerpt. Conversation/evidence UI renders it.

A feature should not own another graph entity's UI manifestation.

Search may provide:

- `conversationId`
- `anchorMessageId`
- excerpt window size
- search-hit/correspondence state

Search should not own:

- Conversation Card construction
- Conversation signature/glyph presentation
- Conversation favourite controls
- Conversation sidebar/list presentation
- Conversation excerpt panel layout

Messages may provide the shared message evidence spine and hydrated message
rows, because a Conversation excerpt is still rendered as message evidence.
That does not make Messages the owner of the Conversation panel.

## Current Ownership Map

### `essentials/conversation_graph`

Owns graph primitives and graph infrastructure:

- source-scoped graph projection
- graph repositories/readers
- `Conversation` and `ConversationSignature` graph/read primitives
- graph-derived query surfaces used by features
- conversation favourite overlay infrastructure where identity is graph-keyed

Does not own user-facing Conversation widgets.

This is the correct boundary. `essentials/conversation_graph` supplies facts
and graph read primitives. It does not decide how a Conversation appears to the
user.

### `features/conversations`

Canonical owner of user-facing Conversation behavior:

- `ConversationsSpec`
- `ConversationsCassetteSpec`
- Conversation view-spec coordinator
- Conversation sidebar/cassette resolver and renderer
- Conversation signature display models
- Conversation filter/sort/lens preferences
- Conversation Card / signature card
- Conversation glyph month rendering
- Conversation favourite button
- Contact-scoped Conversation list/cards
- Conversation message view
- Conversation excerpt panel
- Conversation excerpt navigation action boundary

This is now the first-class feature boundary for Conversation as a graph
entity.

### `features/messages`

Owns message evidence behavior:

- Message Evidence Spine
- message evidence scopes
- skeleton/hydration coordination
- hydrated message rows
- attachment/media evidence rows
- message evidence header/stream widgets
- message text search within evidence scopes
- global/contact/handle/recovered message evidence views
- the "In conversation" affordance on a message row

Messages may consume the Conversations public seam when a message row needs to
request Conversation context or when a contact page embeds the Conversation
section. It must not define Conversation cards, glyphs, favourites, excerpt
panels, or Conversation collection read models.

### `features/chats`

Retired.

The old chat-named feature boundary no longer exists in active production code.
Apple `chat.db` concepts may still appear in source/import/graph internals, but
`features/chats` must not return as a user-facing feature or compatibility seam.

## Implemented Repair

### 1. First-class Conversation feature boundary

`features/conversations` was established as the canonical public seam for
Conversation behavior.

The feature exports only intentional Conversation surfaces through
`features/conversations/feature_level_providers.dart`.

### 2. Conversation presentation moved out of Messages/Essentials

Moved or re-homed under `features/conversations`:

- `ConversationSignatureCard`
- `ConversationSignatureCardData`
- `ConversationSignatureCardStyle`
- Conversation glyph/month rendering
- `ConversationFavouriteButton`
- Conversation signature card presentation/style adapter
- Conversation signature display providers
- Conversation sidebar/cassette coordinator, resolver, and widget
- Contact-scoped Conversation section
- Conversation evidence header context provider
- Conversation messages view
- Conversation excerpt panel

The card remains pure presentation: typed display data, style, callbacks, and
slots. It does not watch providers, query graph data, or know about navigation.

### 3. Messages no longer owns Conversation specs

`MessagesSpec.forConversation` and the old message-owned Conversation preview
route were removed.

Conversation message surfaces are now modeled as `ConversationsSpec` variants:

- `conversationMessages`
- `conversationExcerpt`

This matters because the type system now names the owner correctly. A panel
spec that asks for Conversation content is routed to the Conversations feature,
not interpreted by Messages.

### 4. PanelCoordinator dispatches Conversation specs to Conversations

`PanelCoordinator` now dispatches by `ViewSpec` owner:

- `ViewSpec.messages(...)` -> Messages feature coordinator
- `ViewSpec.conversations(...)` -> Conversations feature coordinator
- `ViewSpec.settings(...)` -> Settings feature coordinator
- etc.

The right sidebar Conversation excerpt is therefore fulfilled by:

`ViewSpec.conversations(ConversationsSpec.conversationExcerpt(...))`

Then:

`PanelCoordinator`
-> `features/conversations` `viewSpecCoordinatorProvider`
-> `ConversationExcerptPanelResolver`
-> `ConversationExcerptPanelView`

This is the core architectural correction. The end sidebar can be opened from a
message search result, but Search/Messages no longer own the Conversation panel
that appears there.

### 5. Messages consumes Conversations through the public seam

Remaining Messages-to-Conversations crossings are valid consumers:

- global message search result row uses
  `conversationExcerptNavigationActionsProvider` to request a Conversation
  excerpt
- contact heatmap sidebar embeds `ContactGraphConversationSection`

Both are imported through `features/conversations/feature_level_providers.dart`.
Messages no longer imports internal Conversation presentation paths.

### 6. `features/chats` retired

Deleted:

- `lib/features/chats/`
- `test/features/chats/`

Removed obsolete compatibility exports and old tripwires tied to
`ChatSelectionActions`, `ChatsViewModel`, `RecentChatSummary`, and
`recentChatsProvider`.

Added/updated architecture tests so the retired `features/chats` path cannot
return as an active feature boundary.

## Conformance With Project Guidelines

### DDD feature ownership

The repair aligns feature responsibilities with domain language:

- Messages owns message evidence.
- Search owns search.
- Conversations owns Conversation entity manifestations.
- Essentials owns routing infrastructure and graph primitives.

This avoids a feature using another feature's graph entity as a local
implementation detail.

### Public provider seams

External consumers now reach Conversation behavior through:

`lib/features/conversations/feature_level_providers.dart`

Internal Conversation files still import exact sibling files rather than their
own public barrel. Other features consume the public seam. This preserves the
project rule that `feature_level_providers.dart` is an outward-facing boundary,
not an internal convenience barrel.

### ViewSpec panel architecture

Panel routing now follows the ViewSpec owner:

- the sealed `ViewSpec` identifies the responsible feature
- the global `PanelCoordinator` dispatches to the correct feature coordinator
- the feature coordinator resolves and renders its own panel surface

There is no imperative "Search opens a widget" shortcut. Search/message rows
emit intent. Panel state stores a typed spec. The coordinator derives the panel
from that spec.

### Sidebar/center/right-panel determinism

The right sidebar is still derived from panel state and compatibility checks,
not manually patched or cleared by local widgets.

`effectiveRightPanelStackProvider` can hide incompatible stored panels by
derivation, but the right panel content itself remains a typed `ViewSpec`.

### Graph identity

Conversation excerpt navigation uses graph-native identity:

- `conversationId`
- `anchorMessageId`

It does not decode back to source row ids or recanonicalize through old
migration seams.

### Message Evidence Spine

The repair does not duplicate message rendering. Conversation views and
Conversation excerpts still use the shared Message Evidence Spine for message
rows, attachment/media evidence, search highlighting, and correspondence
animation.

The owner of the panel is Conversations. The renderer of message evidence is
still the shared message evidence system. That separation is intentional.

## Valid Remaining Crossings

### Messages -> Conversations

Allowed:

- message row/search result requests a Conversation excerpt
- contact message sidebar embeds a Conversation-owned contact Conversation
  section

Requirement:

- consume only the Conversations public seam
- do not construct Conversation cards, glyphs, favourites, or display models
  inside Messages

### Conversations -> Messages

Allowed:

- Conversation views use message evidence scopes and timeline widgets to render
  message evidence

Requirement:

- do not fork message evidence rendering
- do not create Conversation-specific message row widgets
- keep row hydration/search/media behavior in the shared Message Evidence Spine

### Conversations -> `essentials/conversation_graph`

Allowed:

- read Conversation graph facts and signatures
- use graph identity and graph repositories/read primitives

Requirement:

- do not move graph projection or source-scoped import semantics into the
  Conversations feature

## Architecture Tests / Verification

The current test suite guards the repair by checking:

- retired `features/chats` paths do not return
- Conversation signature cards remain pure presentation
- Conversation navigation action provider stays sidebar-owned
- Contact Conversation section uses display/action boundaries
- Conversation favourite button uses an action boundary
- Conversation message evidence uses the shared evidence spine
- `PanelCoordinator` dispatches Conversation specs through the Conversations
  coordinator

Recent verification:

- `flutter analyze`
- `flutter test test/architecture/forbidden_imports_test.dart`
- focused Conversations/Messages/navigation tests

## Remaining Watch Points

These are not current blockers, but they should be watched during future UI
work:

- Any new Conversation presentation added under `features/messages`.
- Any direct import of internal `features/conversations/application/...` or
  `features/conversations/presentation/...` from another feature instead of the
  public seam.
- Any attempt to reintroduce `features/chats` as a compatibility layer.
- Any Conversation excerpt route represented as a `MessagesSpec`.
- Any Conversation-specific message renderer that bypasses the Message Evidence
  Spine.

## Conclusion

The original concern was correct: the UI had outgrown its ownership structure.
Conversation had become a first-class product object while its presentation was
still scattered across Messages and graph essentials.

The implemented repair makes Conversation a first-class feature boundary:

- Essentials provides graph facts and panel routing.
- Messages provides message evidence.
- Conversations owns Conversation identity, collections, cards, favourites,
  and excerpt panels.

This gives the X-column layout work a sound architectural base. The right panel
can now be treated as a Conversation peer workspace rather than a Search-owned
context widget.
