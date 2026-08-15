---
tier: project
scope: feature
owner: agent-per-project
last_reviewed: 2026-07-19
source_of_truth: doc
links:
  - ../../01-PROJECT/05-CURRENT-STATE.md
  - ../../95-WALK-UI-TREE/00-STANDARDS/UX_PRINCIPLES.md
  - ../../95-WALK-UI-TREE/15-X-COLUMN-LAYOUT/CONVERSATION_OWNERSHIP_AUDIT.md
  - ../../55-READERS-INTEGRATORS-ORCHESTRATORS/69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md
  - ../../10-DATABASES/12-identity-model-contacts-handles-participants.md
tests: []
---

# Conversations Feature

`features/conversations` is the canonical user-facing feature boundary for
Conversation presentation.

## Ownership

Conversations owns:

- Conversation cards and signature card data/style adapters
- timeline/month glyph rendering for Conversation identity
- Conversation Favourite/Core Favourite controls
- Conversation collections and list manifestations
- Conversation excerpt panels, including right-side panels opened from Search
  results or message context actions
- user-facing Conversation terminology and identity presentation

Conversations does not own:

- graph projection or graph database lifecycle
- physical database provider construction
- global search indexing
- message evidence row rendering
- message attachment evidence hydration
- sidebar rack or panel stack orchestration

## Boundary With Essentials

`essentials/conversation_graph` provides graph facts, source-scoped identity,
projection/build behavior, and graph read primitives. It should not define
user-facing Conversation widgets.

`essentials/navigation` and `essentials/sidebar` own top-level surface routing,
panel stack policy, and cassette topology. They may route a request to the
Conversations feature, but they do not own Conversation presentation.

## Boundary With Messages

`features/messages` owns message evidence surfaces:

- `MessageEvidenceScope`
- timeline skeleton and visible-row hydration
- message evidence header/search controls
- message row and attachment evidence presentation

Messages may request or embed Conversation presentation where the user needs to
understand the Conversation that contains a message. It should not define
Conversation cards, glyphs, favourites, or Conversation excerpt panel structure.

## Boundary With Search

Search can request a Conversation excerpt by providing a graph-native
Conversation identity, an anchor message identity, excerpt-window intent, and
opaque provenance identifying the investigation that originated the request.
Conversations may carry that provenance but does not generate it, inspect its
components, or own its lifecycle.

Search does not own the Conversation panel. The governing rule is:

```text
Search requests a Conversation excerpt.
Conversations renders the Conversation lens.
Messages renders the message evidence rows inside that lens.
```

## Terminology

Use `Conversation`, not `chat`, for user-facing graph conversation entities.

Older `chats` feature docs are historical context for source/legacy
terminology. They must not be used as current ownership guidance.

## One Conversation Principle

There is only one Conversation.

The same Conversation can appear in the Conversation sidebar, Contact-derived
conversation lists, Favourites, Search result excerpts, Discovery views, and
future Working Sets. These appearances are lenses onto the same graph entity,
not local copies.

User intent attached to a Conversation, such as Favourite state, must be read
and written through the shared overlay identity so the state appears
consistently everywhere.

## Self-Conversation Identity

A one-to-one Conversation whose canonical endpoint is marked as belonging to
the local Messages account is a self-conversation. Conversations consumes this
projected graph fact and exposes it through its read models. It does not compare
display names or inspect individual message direction to decide that a
Conversation is with the user.

Message evidence may render either direction in that Conversation as `self`.
Conversation presentation uses `Me` when the local user is one participant in
a multi-participant title or list, and uses `self` when the local user is the
only participant. A self-only Conversation Card does not expose the local
endpoint as a chat-hook disambiguator. These labels come from the shared
display identity resolver, not widget-local formatting.

The source derivation, historical reconciliation, and endpoint normalization
rules are owned by the identity and graph lifecycle documented in
`../../10-DATABASES/12-identity-model-contacts-handles-participants.md`.
