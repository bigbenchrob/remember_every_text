# Message Evidence Center Panel

This folder contains UI/UX reviews for the shared center-panel message evidence
surface.

The scope is the display of message evidence after a sidebar route has selected
a message scope. This includes message streams opened from:

- Conversations
- Contacts
- All Messages
- future search, recovery, archive, or working-set routes

The review area should focus on the user-facing presentation of message
evidence:

- header orientation
- search-within-scope controls
- message row readability
- attachment/media presentation
- evidence metadata
- empty/loading states
- scroll and new-message behaviour

The sidebar route may differ, but the center-panel message evidence surface
should feel like one coherent MessageLens reading environment.

## Reviews

- `shared_message_evidence_surface.md` — completed review of the shared
  message evidence surface, including header language, date/count formatting,
  metadata cleanup, search parity, message-context sidebar behaviour, and
  orange correspondence highlighting. Also records the right-side
  search-result context sidebar as a Conversation-through-Search lens using the
  canonical Conversation Card, temporal orientation, and highlighted
  correspondence message.
