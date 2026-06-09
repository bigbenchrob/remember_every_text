---
tier: feature
scope: message-display-flow-walkthrough
owner: agent-per-project
links:
  - ./DOMAIN_AND_DATA_MAP.md
  - ./INTERACTIONS_AND_NAVIGATION.md
  - ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: messages
doc_type: walkthrough
status: current
last_updated: 2026-06-05
---

# Message Display Flow Walkthrough

Current message display is graph-backed and routes through the Message Evidence
Spine. The retired `MessagesTimelineView` / `MessageTimelineScope` ordinal
stack is historical only.

For the architectural invariant, see:
`../../55-READERS-INTEGRATORS-ORCHESTRATORS/69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md`.

## Current Flow

```text
sidebar / ViewSpec selection
  -> typed MessageEvidenceScope
  -> full lightweight evidence skeleton
  -> viewport-local row hydration
  -> shared MessageEvidenceHeader + MessageEvidenceTimelineView
  -> shared media/text/evidence widgets
```

## 1. Scope Selection

Different surfaces may select different logical message universes:

- all messages
- messages for a contact
- messages for a selected contact handle
- messages in a conversation
- messages from an unfamiliar handle
- recovered/orphan message evidence
- search result context

The source-specific surface composes a typed `MessageEvidenceScope`. It does
not create a source-specific message renderer.

## 2. Skeleton First

Timeline-like scopes build a lightweight full-scope skeleton before row bodies
hydrate. The skeleton contains enough data for:

- stable message identity (`message_ss_id`)
- ordering
- date range and month keys
- heatmap coordination
- jump/navigation targets

The skeleton is semantic timeline infrastructure, not only a performance
optimization.

Hard rule: pagination is not timeline navigation. Limits may apply to visible
hydration windows or preview samples, not to the selected logical scope.

## 3. Visible-Row Hydration

Rows hydrate near the viewport by stable graph id. Hydration resolves:

- message text and semantic badges
- sender display identity
- attachments and archive availability
- URL previews
- saved/tag/annotation overlay state

Heavy evidence is local/on-demand. Widgets render typed row data and do not
query databases.

## 4. Header And Search

Every message evidence surface uses the shared `MessageEvidenceHeader` model
and renderer.

Header composers provide meaning:

- title
- metrics and date range
- scope details
- search placeholder/config
- action row

The header renderer provides form. Search operates against the selected logical
scope through the evidence spine, not just currently hydrated visible rows.

## 5. Attachments

Attachment rendering flows through graph attachment evidence hydration and
shared media tiles. Conversation, contact, global, handle, and recovered
surfaces must not invent separate attachment renderers.

## 6. Where To Look First

- Wrong scope/count/date range: inspect the scope composer and skeleton query.
- Heatmap jump wrong: inspect skeleton month keys and selected-scope identity.
- Row content wrong: inspect visible-row hydration and graph repository query.
- Image/video missing: inspect attachment evidence hydration and archive
  resolver.
- Visual inconsistency: inspect shared widgets under
  `presentation/widgets/message_evidence/`.
