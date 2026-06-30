# Message Display Pipeline

## Why This Document Exists

The message surface is easy to misunderstand if it is described only as
"messages are rendered from a view." In reality there are multiple layers, and
they have to stay coordinated if evidence reading is going to be fast, stable,
and correct.

The current message surface is graph-backed and routes through the Message
Evidence Spine.

## The Four Layers

### Layer 1: Semantic Scope Layer

This layer answers:

`Which logical message universe should exist on screen at all?`

Inputs include:

- center-panel `ViewSpec`
- `MessagesSpec` meaning
- sidebar flow state
- selected contact / conversation / handle / search / recovered scope

Output:

- typed `MessageEvidenceScope`

The scope layer is driven by semantic navigation, not widget state.

If the scope layer is wrong, every downstream layer is wrong.

### Layer 2: Full Skeleton Layer

This layer answers:

`What is the full stable ordered message universe for this scope?`

The skeleton exists because timeline-like navigation cannot depend on fragile
page windows, latest-N batches, or shifting offsets.

Its job is:

- preserve the full selected logical message universe.
- provide stable graph `message_ss_id` ordering.
- support heatmaps, search matches, month/date jumps, latest positioning, and
  viewport anchoring.
- remain lightweight: no full-scope text/media hydration.

Hard rule:

> Pagination is not timeline navigation.

### Layer 3: Hydration, Provenance, And Attachment Evidence

This layer answers:

`Given a stable graph message id near the viewport, what evidence row should be rendered?`

Hydration resolves:

- message text and semantic flags.
- sender/display identity.
- attachment evidence.
- archive/live/missing availability state.
- search match highlights.
- developer diagnostics when enabled.

Hydration happens near the visible viewport or selected evidence window. Limits
apply to hydration windows, not to the selected logical scope.

### Layer 4: Shared Rendering Layer

This layer renders:

- `MessageEvidenceHeader`
- `MessageEvidenceTimelineView`
- shared evidence rows/media/link/fallback tiles

Rendering must not decide graph semantics, query databases directly, or repair
data. Source-specific scopes are allowed; source-specific evidence renderers
are not.

## Search As Scope Refinement

Search does not replace the evidence architecture.

Search returns graph message matches for the selected scope and feeds the same
skeleton/hydration/rendering path. The user should not experience search
results as a different species of message object.

## Attachment Handling Inside Evidence Hydration

Attachment availability is part of evidence hydration, not a UI hack.

Attachment evidence may carry:

- source path hints.
- source attachment identity.
- graph attachment identity.
- message/attachment graph edge identity.
- archive-resolved path when available.
- missing/unavailable state when not.
- media dimensions or link-preview metadata when available.

Widgets render resolved attachment evidence. They do not read Apple paths
directly or decide archive policy.

## Live And Archived Files Must Be The Same Message Semantically

An attachment message should remain the same evidence row whether its file is
currently sourced from:

- the live `~/Library/Messages/Attachments` path.
- the MessageLens archive.
- a deterministic historical import written into the archive.

The message meaning does not change. Only file provenance changes.

## Resolution Ownership

Attachment source policy belongs to the attachment resolver/archive layer.

The evidence row should expose a render-ready result such as:

- archive-backed available media.
- live-file pending archive ingestion.
- unavailable awaiting recovery.
- non-recoverable.

No attachment record may disappear merely because the file is unavailable.

## What Row Rendering Should Guarantee

A hydrated evidence row should guarantee:

- every message record still renders, even if text or attachment files are
  unavailable.
- attachment availability changes do not change which message row is displayed.
- grouping decisions depend on message semantics, not attachment lookup side
  effects.
- a row with a live image and a row with an archived image are equivalent at the
  evidence/timeline level.

## Architectural Violations

These failures should be considered architectural violations, not mere UI bugs:

- a message row disappearing because the live attachment file is missing.
- a graph-orphan/recovered row being omitted because it does not fit the normal
  conversation path.
- a timeline switching semantic meaning because a widget held stale scope
  assumptions.
- a source-specific message renderer that bypasses shared header/row/media
  evidence presentation.
- a timeline-like scope capped to latest-N rows instead of building a full
  skeleton.

## Unified Message-Surface Goal

The target system is:

- one semantic scope model.
- one full-skeleton contract.
- one hydration contract.
- one attachment provenance contract.
- one shared evidence renderer.

Different sources can select different scopes. Once the app is showing message
evidence, the presentation path must converge.
