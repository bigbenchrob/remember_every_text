# 69-MESSAGE-EVIDENCE-SPINE-INVARIANT

## Purpose

The Message Evidence Spine is the canonical presentation path for message evidence in MessageLens.

Different sidebar routes may select different message scopes, but once a surface means:

```text
show these messages as evidence
```

the path must converge onto the shared evidence spine.

This prevents source-specific renderers, duplicated attachment behavior, stale timeline logic, and inconsistent evidence presentation.

---

# Canonical Flow

The canonical flow is:

```text
MessageEvidenceScope
→ messageEvidenceTimelineSkeletonProvider
→ MessageEvidenceTimelineSkeleton
→ messageEvidenceRowProvider
→ MessageEvidenceRowData
→ messageEvidenceAttachmentsProvider
→ MessageAttachmentEvidence
→ MessageEvidenceTimelineView
→ MessageEvidenceRow
→ TextMessageTile / MessageAttachmentEvidenceTiles
```

Meaning:

- `MessageEvidenceScope` defines the selected logical message set.
- `messageEvidenceTimelineSkeletonProvider` builds the lightweight full-scope skeleton for timeline-like scopes.
- `MessageEvidenceTimelineSkeleton` carries stable message IDs, date ordering, month keys, and optional anchor identity.
- `messageEvidenceRowProvider` hydrates visible rows by stable message ID.
- `MessageEvidenceRowData` is the neutral hydrated row carrier used by the spine; graph repositories may still return graph-specific models, but they are converted at the evidence boundary.
- `messageEvidenceAttachmentsProvider` hydrates render-ready attachment evidence outside widgets.
- `MessageEvidenceTimelineView` owns timeline scrolling, day dividers, month anchoring, and visible-row hydration.
- `MessageEvidenceRow` owns shared message evidence row composition.
- `TextMessageTile` and `MessageAttachmentEvidenceTiles` own shared text/media evidence rendering.

Widgets may render typed evidence data and callbacks. They must not query source databases, reconstruct topology, resolve provenance, or invent source-specific evidence semantics.

---

# Current Surfaces Using the Spine

The following graph-backed evidence surfaces now use the Message Evidence Spine:

- Contact / All Messages
- Contact / handle-filtered messages
- Contact text-match overlay
- Conversation messages
- Conversation text-match navigation
- Search All Messages
- Search result context windows
- Handle messages
- Recovered deleted messages
- Recovered no-handle outgoing messages
- Message attachment/media evidence inside message rows

As new message-bearing surfaces are added, they should enter the same spine by defining a typed `MessageEvidenceScope` or by reusing an existing scope.

---

# What Remains Source-Specific

Source-specific selection is allowed.

Examples:

- contact all messages
- contact + selected handle
- conversation
- global timeline
- global text search
- search result context window
- recovered deleted-message candidate pool
- recovered no-handle outgoing pool
- future theme/tag/favourite projections

These scopes may differ in:

- how the logical message set is selected
- what header title and subtitle are shown
- what search/filter controls are available
- whether the surface is a full timeline or bounded context window
- what empty-state copy explains the scope
- whether recovered evidence carries special diagnostic wording

These differences belong at the typed scope, resolver, provider, or header-configuration level.

They do not justify a separate message renderer.

---

# Contact Naming Invariant

Known contacts must be referred to by the user-assigned name everywhere user-facing message evidence or conversation navigation names a person.

There is exactly one user-defined contact name override:

```text
participant_overrides.display_name_override
```

This is written only by the contact hero-card pencil rename action. Other name-like fields are imported or derived metadata, not user intent.

Name precedence is:

```text
user display-name override
→ app-known contact/display identity
→ imported AddressBook display name
→ raw handle only when no known contact identity exists
```

Imported AddressBook names are source facts, not final user-facing identity when the user has assigned a different name.

Short-name, nickname, and name-mode variants are retired as app-facing identity
concepts. If a physical compatibility column remains in storage, it is not part
of message evidence naming precedence.

Raw handles must not be used as the primary label for a known contact in:

- conversation signatures
- conversation message headers
- message evidence headers
- contact-derived conversation lists
- search result context labels
- recovered-message context labels

Handles may be shown for known contacts only when the surface is explicitly handle-oriented, such as:

- a contact sidebar scope menu where the user chooses one phone number or email address
- developer diagnostics
- metadata that explains why a specific handle-filtered scope is active

This preserves the distinction between:

```text
person identity
≠
handle metadata
```

Graph-backed surfaces must resolve participant handles through the same preferred-contact-name boundary used by contact surfaces, rather than formatting handle strings directly.

---

# Where Visual Changes Belong

Most visual evidence changes should be made in one of these shared locations:

- `lib/features/messages/presentation/widgets/message_evidence/message_evidence_timeline_view.dart`
  - timeline layout
  - scroll anchoring
  - day dividers
  - skeleton-to-row hydration
  - header placement

- `lib/features/messages/presentation/widgets/message_evidence/message_evidence_header.dart`
  - shared evidence header typography, spacing, controls placement

- `lib/features/messages/presentation/widgets/message_evidence/message_evidence_row.dart`
  - per-message evidence composition
  - sender line
  - semantic badges
  - attachment section placement

- `lib/features/messages/presentation/view_model/shared/display_widgets/new_display_widgets.dart`
  - text message tile appearance
  - message bubble/body treatment

- `lib/features/messages/presentation/widgets/message_evidence/message_attachment_evidence_tiles.dart`
  - image/video/link/fallback attachment evidence presentation

Source-specific views should pass typed data and configuration into these shared widgets. They should not fork the row renderer to make local visual changes.

---

# Timeline Navigation Invariant

Pagination is not timeline navigation.

For timeline-like MessageLens evidence surfaces:

```text
full lightweight skeleton first
→ timeline/heatmap/jump controls coordinate with skeleton indices
→ row bodies and media hydrate near the viewport
```

Timeline-like evidence scopes must preserve the full logical selected message universe even when row hydration and media loading are windowed or incremental.

Limits may apply to hydration windows, not to the selected logical message scope.

The skeleton is not merely performance infrastructure. It is semantic timeline infrastructure, heatmap coordination infrastructure, jump/navigation infrastructure, and temporal orientation infrastructure.

Heatmaps, month jumps, selected anchors, next/previous match navigation, and context orientation must operate against the full skeleton for that scope.

Ad hoc batch loading must not replace skeleton-based timeline navigation.

---

# Hard Rules

## No Source-Specific Message Renderer Without Review

Do not add a new contact-only, conversation-only, search-only, recovered-only, handle-only, or theme-only message renderer without explicit architectural review.

If a new surface needs to show messages, it should define or reuse a `MessageEvidenceScope` and flow through the shared evidence spine.

## Source-Specific Scopes Are Allowed

Source-specific scopes are the correct place to express:

- where the message set came from
- what logical constraints selected it
- what title/subtitle/control context should explain it
- what semantic caveats apply

## Source-Specific Evidence Presentation Is Not Allowed

Source-specific evidence presentation is an architectural defect unless explicitly approved.

Bad pattern:

```text
ContactMessageRenderer
ConversationMessageRenderer
SearchResultMessageRenderer
RecoveredMessageRenderer
```

Preferred pattern:

```text
ContactAllMessagesEvidenceScope
ConversationEvidenceScope
MessageSearchEvidenceScope
RecoveredMessagesEvidenceScope
→ shared evidence spine
```

## Attachment Policy Must Stay Outside Widgets

Widgets may render `MessageAttachmentEvidence`.

Widgets must not:

- inspect source attachment tables
- decide archive lookup policy
- reconstruct attachment provenance
- infer availability from raw paths

Attachment facts must be hydrated into render-ready evidence before presentation.

## Visual Consistency Is a Spine Concern

Evidence-reading surfaces should feel like one system.

If contact messages, conversation messages, search results, recovered messages, and handle messages diverge visually, first look for a missing shared-spine change before adding local presentation logic.

---

# Architectural Entropy Prevented

This invariant prevents recurrence of:

- duplicated message rendering paths
- inconsistent attachment/media behavior
- source-specific evidence widgets
- pagination mistaken for timeline navigation
- presentation-layer topology reconstruction
- search-result renderers that bypass evidence hydration
- stale center-panel repair logic
- hidden source/provenance decisions in widgets
- divergent visual language across evidence surfaces

The intended architecture is:

```text
many typed evidence scopes
→ one evidence spine
→ one coherent evidence-reading surface
```
