# Review

---

## Surface

Shared Message Evidence Center Panel

---

## Purpose

Help the user read, search, inspect, and interpret message evidence after a
sidebar route has selected a message scope.

This is the common center-panel evidence surface used by Conversations,
Contacts, All Messages, recovered-message views, handle-scoped views, and
future evidence-selection routes.

The sidebar route may differ, but once the center panel is showing messages,
the user should experience one coherent MessageLens reading environment.

---

## User Goals

- Understand what message scope is currently being shown.
- Read messages comfortably without visual clutter.
- Search within the current message scope.
- See search results behave consistently across Contacts, Conversations, and
  All Messages.
- Inspect attachments, media, links, and context when needed.
- Preserve reading position and context while new messages arrive.
- Move from a broad search result to its original conversation context without
  losing the relationship between the two views.

---

## Current Behaviour Reviewed

- The message evidence header is shared across major message views.
- Message streams route through the shared message evidence spine.
- The shared header displays scope identity, date/message count summaries, and
  search controls.
- Message rows now use a common evidence row path across major graph-backed
  surfaces.
- Message metadata describes the counterpart relationship explicitly:
  incoming evidence reads `received from <sender>`, while outgoing evidence
  reads `from me to <Conversation>` using canonical Conversation identity.
- Messages in a self-conversation read simply `self`, regardless of source
  direction. Self-conversation identity is a graph/read-model fact derived
  from local account handles, not a display-title comparison.
- Eligible All Messages rows can open a right-side Conversation excerpt,
  whether or not a text query produced the row.
- The right context panel shows the selected message with nearby conversation
  messages.
- The center-panel search-result row and the right-panel context row now share
  an orange correspondence marker when they represent the same underlying
  message.
- The right context panel introduces the parent Conversation with the canonical
  Conversation Card before showing the bounded excerpt.
- The right context panel identifies the anchor message's month and year before
  the excerpt, so moving from broad Search results into Conversation
  context includes explicit temporal orientation.
- The month/year orientation uses a softened form of the established orange
  comparison accent. It identifies the temporal value organizing the excerpt;
  it does not mean warning, importance, or date in the abstract.

---

## What Works Well

- The unified header gives the surface a consistent identity across routes.
- The calm center-panel reading environment works across Conversations,
  Contacts, All Messages, recovered views, and handle-scoped views.
- Search within message scopes is now a common interaction pattern.
- Attachments and URL previews are shown through shared evidence presentation
  rather than route-specific renderers.
- Opening a search result in context now teaches the relationship between the
  search result and its original conversation.
- Orange correspondence chrome reinforces identity without stealing the blue
  selection/focus vocabulary.
- The right sidebar context panel reads as a Conversation viewed through the
  Search lens, rather than as a generic message-context drawer.

---

## Issues Found During Review

| Priority | Description | Resolution |
| -------- | ----------- | ---------- |
| High | Date-range summary wording was inconsistent and duplicated across message surfaces. | Centralized date range and date label formatting. |
| High | Count wording could produce awkward strings such as `1 messages`. | Added shared count-label formatting for singular/plural app terms. |
| High | Contact message search updated the metadata line but did not filter the displayed message list, unlike Conversations. | Fixed Contact search so the message list reflects the selected evidence scope. |
| High | Unfamiliar-source badges counted direct sender evidence while the center timeline required chat membership, producing nonzero badges with empty or incomplete message lists. | Unified standalone handle timeline, hydration, and search around canonical sender identity; sender-only evidence no longer depends on `chat_to_handle`. |
| High | All Messages had lost the ability to open a message in its original conversation context. | Restored the `In conversation` action for every eligible row carrying canonical Conversation identity, not only search results. |
| High | Opening conversation context displayed the message in the right panel but did not highlight the original center-panel row. | Center panel now derives its anchor from the active right-panel context and highlights the corresponding row. |
| Medium | The right context panel needed stronger parent-object identity. | Added the canonical Conversation Card as the right-sidebar excerpt header. |
| Medium | The first excerpt message felt visually attached to the Conversation Card. | Gave the card/header region ownership of the transition space before the message excerpt begins. An interim excerpt caption was later removed once temporal orientation made it redundant. |
| Medium | Opening an old Search result could silently move the user to another point in time. | Added a month/year orientation heading before the excerpt, derived from the exact anchor message. |
| Medium | The source-row `In conversation` action became redundant once its context panel was already open. | Suppressed the redundant action while the corresponding context is visible. |
| Medium | Developer status text such as `evidence skeleton • hydrate visible rows` was visible in user-facing headers. | Removed from message evidence headers. |
| Medium | Per-message semantic badges such as `rich_text`, `text`, `attributed body`, `summary info`, and `error 0` added noise without helping the user read evidence. | Removed from normal message row presentation. |
| Medium | Direction metadata used separators such as `received \| Claire` and reduced outgoing identity to `from me \| me`. | Shared evidence rows now state `received from <sender>` and `from me to <Conversation>`. |
| Medium | Context correspondence needed a stronger visual explanation than a static border. | Added a one-shot orange pulse plus persistent orange correspondence chrome. |
| Low | The phrase `Show in conversation` / `In conversation` should remain concise and action-oriented. | Current button label is `In conversation`. |

---

## UX Observations

### Header language

Scope summaries should be generated from shared logic rather than repeated in
each view.

Preferred date range behaviour:

- cross-year: `Jan 1, 2014 to Jul 4, 2026`
- same-year, different months: `Jan 18 to Apr 1, 2019`
- one message: `Mar 12, 2018`
- multiple messages in the same month: `May 2019`

Preferred count wording:

- `1 message`
- `56,810 messages`

The same count-label principle should apply app-wide to terms such as message,
user, handle, contact, attachment, and conversation.

### Header metadata

The header should orient the user, not expose implementation mechanics.

Internal phrases such as `evidence skeleton`, `hydrate visible rows`, and
`graph skeleton` are useful implementation concepts but should not be visible
in the normal user-facing header.

### Message metadata

The first metadata line should state both direction and counterpart in natural
language:

- incoming: `received from Claire`
- incoming from a canonical local-account handle outside a resolved
  Conversation: `received from me`
- outgoing: `from me to Claire`
- either direction in a self-conversation: `self`

Incoming evidence uses the resolved sender identity. Outgoing evidence uses
the canonical Conversation display title because sender metadata alone cannot
identify the recipient. Rows without canonical Conversation identity must fall
back honestly to `from me` rather than inventing a counterpart.

Self-conversation labeling is intentionally Conversation-level. Source import
identifies local account handles from Apple Messages account evidence, graph
projection preserves that fact, and Conversation read models determine whether
a one-to-one Conversation is with the MessageLens user. The row renderer
consumes that prepared identity; it must not infer self identity from names.
Historical source metadata is reconciled at startup, including canonical
matching of phone URI and formatted-number variants, so this grammar applies to
older Conversations without a message reimport. The canonical mechanism is
documented in
`../../../10-DATABASES/12-identity-model-contacts-handles-participants.md`.

The same first-person identity contract applies beyond message metadata. A
local-account participant is `Me` in participant titles and lists, while a
self-only Conversation is `self`. Evidence widgets consume these resolved
labels and must not reveal the user's imported personal name merely because an
AddressBook contact is linked to the local handle.

Recovered and unlinked evidence also resolves sender identity through this
shared contract. It must not bypass canonical local-account identity merely
because no Conversation relationship was recovered for the row.

Semantic provenance fields are useful for diagnostics, import validation, and
future investigative views, but they should not appear as a default badge row
under every message.

Default message presentation should privilege reading evidence. Diagnostic
metadata should be deliberately requested, not constantly visible.

### Search parity

Search controls in the shared header should operate against the selected
logical evidence scope, not merely update a label.

If a header says `122 of 29,118 messages match "kelowna"`, the displayed
message stream should reflect those matched messages. This must hold regardless
of whether the route came from Contacts, Conversations, All Messages, or a
future evidence source.

### Unfamiliar-source scope parity

An unfamiliar-source row represents messages received from one canonical
handle. Its sidebar badge, header count, timeline skeleton, hydrated rows, and
search results must therefore describe the same canonical sender scope.

Apple Messages can preserve a message sender without preserving or projecting
a corresponding `chat_to_handle` membership. That missing edge must not hide
the message. Conversation membership remains useful provenance when present,
but it is not the admission rule for standalone handle evidence.

Contact-scoped and Conversation-scoped evidence retain their own relationship
semantics. This sender rule applies specifically to standalone handle and
unfamiliar-source scopes.

### Conversation context

Opening a search result in context is not just navigation. It teaches the user:

> The message you clicked over here is this exact message over there.

The end sidebar should show the selected message inside nearby conversation
context, while the original center-panel message remains visibly connected to
that context row.

The right sidebar is a Conversation viewed through the Search lens. Its visual
hierarchy should use the same peer-panel bands as the Search and Messages
panels:

1. Panel title: `Conversation excerpt`.
2. Conversation Card: the parent Conversation identity.
3. Temporal orientation: the anchor message's month and year.
4. Excerpt timeline: nearby messages around the selected hit.
5. Highlighted message: the specific message corresponding to the chosen
   message.

The Conversation Card should use the canonical Conversation Card grammar
including title, metadata, timeline glyph, and Favourite state. It may be less
interactive than a browse-row manifestation, but Favourite remains global
Conversation intent and must update the same Conversation everywhere.

The card/header region owns the breathing room before the excerpt begins. The
message timeline fade/blur should begin at the boundary where the header region
ends, so the first excerpt message does not feel attached to the card.

For peer panels, extended task guidance should not introduce another band above
primary content. On the Search page, the visible Search sidebar orientation
should stay brief and establish scope, while post-content guidance below the
heatmap can explain how the sidebar leads into the Messages column and search
controls.

When the right sidebar is already showing the corresponding conversation
excerpt, the source message row should not keep showing a redundant `In
conversation` action.

### Motion as explanation

The orange correspondence pulse is not decorative. It is relationship
instruction.

Motion should be used sparingly to explain object identity, continuity, or
cause-and-effect. In this case, the pulse explains that two visible cards are
instances of the same underlying message.

The persistent orange outline/glow remains after the pulse to preserve the
correspondence. Blue remains reserved for selection, focus, and direct
interaction.

---

## Implemented Improvements

- Added shared date/count formatting utilities:
  - `DateRangeFormatter`
  - `DateLabelFormatter`
  - `CountLabelFormatter`
- Removed user-facing implementation status lines from message evidence
  headers.
- Removed default semantic provenance badge rows under messages.
- Replaced ambiguous sender separators with explicit incoming/outgoing
  counterpart language backed by canonical Conversation identity.
- Added a direction-independent `self` label for graph-derived
  self-conversations.
- Fixed Contact message search so search results and displayed rows stay in
  sync.
- Restored the `In conversation` action for every eligible All Messages row,
  including ordinary unfiltered evidence.
- Opened message context in the right panel through existing panel actions.
- Added the canonical Conversation Card to the right-sidebar context panel.
- Added explicit month/year orientation for bounded conversation excerpts and
  removed the redundant excerpt-count caption.
- Suppressed redundant `In conversation` actions while the matching context
  panel is already open.
- Derived center-panel message anchoring from active right-panel context state.
- Added persistent orange correspondence chrome to anchor rows.
- Added a one-shot orange pulse after context navigation settles.
- Respected reduced-motion settings by skipping the pulse while preserving the
  persistent correspondence marker.

---

## Acceptance Criteria

- [x] The center-panel message evidence surface is clearly scoped and named.
- [x] Conversations, Contacts, All Messages, and context views can be evaluated
      against the same presentation criteria.
- [x] Date-range summary wording is generated from shared logic.
- [x] Singular/plural message count wording is generated from shared logic.
- [x] User-facing header metadata does not expose implementation mechanics.
- [x] Default message rows do not show diagnostic semantic badge clutter.
- [x] Contact and Conversation message search both update the displayed message
      stream, not only the header metadata.
- [x] Eligible All Messages rows can open Conversation context in the end
      sidebar, with or without an active text query.
- [x] The right sidebar context panel identifies the parent Conversation using
      the canonical Conversation Card grammar.
- [x] The right sidebar context panel distinguishes Conversation identity from
      the bounded excerpt and highlighted search-hit message.
- [x] The original center-panel message and right-panel context message are
      visibly marked as the same underlying message.
- [x] Redundant `In conversation` actions are hidden when the matching context
      panel is already open.
- [x] Orange is used as correspondence/identity emphasis, distinct from blue
      selection/focus.
- [x] The correspondence pulse does not loop or replay merely because the row
      rebuilds.

---

## Deferred / Future Review Items

- Decide whether `In conversation` should remain the final button label or be
  revised during a broader action-language pass.
- Consider a diagnostics-only affordance for semantic provenance metadata if
  testers need to inspect message classification in the UI.
- Review end-sidebar width, density, and close affordance separately if the
  context panel becomes a major workflow.
- Revisit whether search-result context should show more or fewer neighbouring
  messages once real investigative workflows are tested.

---

## Notes

This review confirms the intended division:

- Sidebar routes select a message evidence scope.
- The center panel resolves and renders that scope through the shared evidence
  spine.
- Source-specific scopes are allowed.
- Source-specific message renderers are not.

---

## Status

- [ ] Not Started
- [ ] Under Review
- [ ] Ready for Codex
- [x] Implemented
- [x] Verified
