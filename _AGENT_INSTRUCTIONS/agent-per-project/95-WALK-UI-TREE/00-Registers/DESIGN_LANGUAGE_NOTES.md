# Design Language Notes

This register captures reusable design-language ideas that emerge during the
UI walk. These are not implementation tasks by themselves. They are principles
to revisit when similar surfaces are reviewed.

---

## Conversation Lenses

This section documents an internal design concept. It is not necessarily
user-facing terminology.

### Conversation Lens

A Conversation Lens is a particular way of organizing and emphasizing the same
underlying collection of conversations.

A lens may change:

- ordering
- highlighted metric
- glyph annotations
- metadata emphasis

The underlying conversations do not change.

Examples:

- `Most recently updated`
- `Most total messages`
- `Date of creation`
- `Started longest ago`
- `Longest first-to-last span`
- `Dormant`

A lens is therefore more than a sort order.

It is a presentation strategy.

### User Terminology

Internally, use the term:

> Conversation Lens

Externally, in the UI, the control should be labelled:

> Organize by

This wording better reflects that the selected option affects the presentation
of each conversation card, not merely its ordering.

Avoid exposing "Lens" in the UI at this stage.

### Modes of Interaction

MessageLens should distinguish three broad modes of interaction.

Search:
Find something already known.

Examples:

- Search All Messages
- Search Contacts

Browse:
Navigate a collection that the user broadly understands.

Examples:

- Browse Conversations
- Browse Contacts
- Browse Attachments

Discovery:
Surface interesting information the user did not know to look for.

Examples:

- Dormant conversations
- Date of creation
- Started longest ago
- Longest span

Discovery views should encourage curiosity without creating confusion.

### Operational vs Exploratory Lenses

Operational lenses support day-to-day work.

Examples:

- `Most recently updated`
- `Most total messages`

Exploratory lenses encourage rediscovery of message history.

Examples:

- `Dormant`
- `Date of creation`
- `Started longest ago`
- `Longest span`

Future exploratory lenses may include:

- Rekindled conversations
- Brief but intense
- Seasonal conversations
- Forgotten conversations

### Sort-Driven Emphasis

When a collection is organized by a particular attribute, the corresponding
value should be visually emphasized within each card.

The interface should answer the user's implicit question:

> Why is this conversation here?

Examples:

- `Most recently updated` -> highlight latest activity.
- `Most total messages` -> highlight message count.
- `Longest span` -> highlight duration.
- `Dormant` -> highlight the final active month with the glyph ring.

### Orange Highlight

Orange represents the primary comparison value for the current Conversation
Lens.

Orange does not inherently mean:

- recent
- warning
- important
- date

Instead it means:

> This is the value that explains why this row appears where it does.

### Curiosity Without Confusion

MessageLens should eliminate confusion, but preserve curiosity.

Discovery-oriented Conversation Lenses are successful when they surface
forgotten, surprising, or intriguing conversations while still making it
immediately obvious why those conversations have appeared.

This principle should guide future Conversation Lens design.
