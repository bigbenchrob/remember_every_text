# Message Display Pipeline

## Why this document exists

The message surface is easy to misunderstand if it is described only as
"messages are rendered from a view." In reality there are multiple layers, and
they have to stay coordinated if the timeline is going to be fast, stable, and
correct.

The cleanest way to think about the message surface is as a three-layer model.

## The three layers

### Layer 1: Semantic scope layer

This layer answers the question:

`Which message set should exist on screen at all?`

Its main inputs are:

- center-panel `ViewSpec`
- `MessagesSpec` meaning
- `MessageTimelineScope`

Current scope variants are:

- global timeline
- contact timeline with optional handle filter
- chat timeline
- recovered timeline

This layer should be driven by semantic navigation, not widget state.

Examples:

- `MessagesSpec.forContact(contactId: 42, filterHandleId: 7)` means the scope
  is contact 42 with handle 7 filter
- `MessagesSpec.recoveredUnlinkedMessages(contactId: 42)` means the scope is
  recovered-deleted candidates for contact 42
- `MessagesSpec.globalTimeline(...)` means a global scope regardless of contact

If the scope layer is wrong, every downstream layer is wrong.

### Layer 2: Ordinal access layer

This layer answers the question:

`Given the current scope, what is the stable ordering of messages and how do we jump around it?`

This layer exists because the timeline cannot depend on fragile page windows or
shifting offsets.

Its job is:

- provide stable ordinals inside a scope
- give total item count
- support `jumpToLatest()`, `jumpToMonth(...)`, and `jumpToDate(...)`
- keep viewport anchoring stable while the user navigates

For normal scopes, this is provided by scope-specific ordinal strategies such
as:

- global ordinal strategy
- contact ordinal strategy
- filtered contact ordinal strategy
- chat ordinal strategy

Recovered timelines are currently a special case:

- they do not use the working DB ordinal strategy path directly
- they are turned into an in-memory `RecoveredListOrdinalStrategy`

That means recovered timelines are functionally integrated into the same
timeline API, but not yet fully unified underneath.

### Layer 3: Hydration, provenance, and row rendering layer

This layer answers the question:

`Given a scope and an ordinal, what concrete message row do we render, with what attachments, and from what file provenance?`

This is where a timeline row becomes a `MessageListItem` and eventually a
`MessageCard`.

The current shape is:

1. The UI asks for a row by scope and ordinal
2. The ordinal strategy resolves the message ID for that ordinal
3. A joined query loads the message and participant rows
4. `MessageRowMapper` constructs a `MessageListItem`
5. Attachments are loaded and enriched with archive resolution information
6. The row is rendered as a `MessageCard`

This layer should not decide what timeline the user is in. It should only
hydrate and render the row for the scope it is given.

## Search as a side lane, not a different architecture

Search does not replace the timeline architecture. It uses a side lane.

Current flow:

- search queries return message IDs quickly
- individual result rows are then hydrated by message ID

That means search is a different retrieval path, but it should converge on the
same hydrated message-row semantics.

The user should not experience search results as a different species of message
object.

## Attachment handling inside message hydration

Attachment availability is part of message hydration, not a separate UI hack.

The current model already points in the right direction.

`AttachmentInfo` can carry:

- the original Messages local path
- the import attachment ID
- the message GUID
- an archive-resolved path when available
- media dimensions

That means attachment provenance can be folded into the same message row.

## Live and archived images must be the same message semantically

This is a critical objective.

An image message should remain the same message whether its file currently comes
from:

- the live `~/Library/Messages/Attachments` path
- the MessageLens archive
- a deterministic historical import written into the archive

The message meaning does not change. Only the file provenance changes.

## Provenance resolution order

The runtime attachment resolver currently follows the correct high-level order:

1. Try the live Messages local path
2. Try the MessageLens archive using overlay metadata plus archive directory
3. If neither exists, report `cloudOnly` or `missing`

That order matters.

It preserves these semantics:

- use the freshest live file when available
- fall back to the app-owned archive when Apple has evicted the original file
- never pretend an attachment is absent just because the live path vanished

## On-demand archive reinforcement

One subtle but important behavior in the current implementation is on-demand
archiving.

If a file reappears at the live Messages path and has not yet been archived,
the resolver can trigger archive capture in the background.

That means the system can recover from Apple re-downloading an attachment later.

This is a good fit for the target model because it keeps archive durability as a
side effect of file availability, not as a separate manual rescue step.

## What row rendering should guarantee

A hydrated message row should guarantee:

- every message record still renders as a message row, even if attachment files
  are unavailable
- attachment availability changes do not change which message row is being
  displayed
- message grouping decisions depend on message semantics, not attachment lookup
  side effects
- a row with a live image and a row with an archived image are equivalent at
  the timeline level

## What should never happen

These failures should be considered architectural violations, not mere UI bugs:

- a message row disappearing because the live attachment file is missing
- a recovered row being omitted because it does not fit the "normal" hydration
  path
- a timeline switching semantic meaning because a widget held onto stale scope
  assumptions
- a contact timeline and recovered-deleted timeline sharing enough plumbing to
  reuse stale rows while still meaning different things

## The long-term unified message-surface goal

The ideal system is:

- one semantic scope layer
- one ordinal contract
- one hydration contract
- one attachment provenance contract

Under that model, recovered timelines are not a bespoke side universe. They are
just another scope with a different upstream source of ordered message IDs.

That is not fully true yet, but it is the right evaluation standard.