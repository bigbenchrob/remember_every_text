# Conversations Feature Boundary

`features/conversations` is the canonical feature boundary for user-facing
Conversation behavior.

A Conversation is a canonical source-scoped graph entity. It may appear through
many lenses, including Search, Contacts, Favourites, Discovery, and message
context excerpts, but those appearances are manifestations of the same
Conversation object.

## Owns

- Conversation identity presentation.
- Conversation cards and glyph presentation.
- Conversation favourites and future user-intent overlays on conversations.
- Conversation collections, including browse/favourites/discovery lists.
- Conversation filters, sorts, and lenses.
- Conversation excerpt panels anchored around a message.
- Conversation navigation actions.

## Does Not Own

- Message evidence row rendering.
- Message text search semantics.
- Contact identity editing.
- Source-scoped graph projection.

## Current Migration State

This folder is the canonical boundary for Conversation presentation. The
canonical Conversation card, glyph rendering, favourite button, and signature
display read model live here.

The older `features/chats` boundary has been retired. Do not reintroduce
chat-named feature providers for user-facing Conversation behavior. New
production code should depend on
`features/conversations/feature_level_providers.dart` for Conversation-level
behavior.

Some Messages sidebar composition still consumes Conversation widgets and read
models while it owns the surrounding Messages sidebar route. Future slices
should continue moving Conversation collections and excerpt-panel ownership into
this feature without changing Message evidence rendering.
