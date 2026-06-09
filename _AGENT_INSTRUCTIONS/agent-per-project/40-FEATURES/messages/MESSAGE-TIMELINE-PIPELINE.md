---
tier: feature
scope: message-timeline-pipeline
owner: agent-per-project
last_reviewed: 2026-06-05
source_of_truth: doc
links:
  - ./DOMAIN_AND_DATA_MAP.md
  - ./STATE_AND_PROVIDER_INVENTORY.md
  - ./INTERACTIONS_AND_NAVIGATION.md
  - ./message-display-flow-walkthrough.md
  - ../../55-READERS-INTEGRATORS-ORCHESTRATORS/69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md
tests: []
feature: messages
doc_type: pipeline
status: current
---

# Message Evidence Pipeline

The active message presentation path is the Message Evidence Spine. This
document replaces the older `working.db` ordinal-timeline pipeline notes.

## Canonical Pipeline

```text
MessageEvidenceScope
  -> full selected-scope skeleton
  -> viewport/search-window hydration
  -> hydrated evidence row data
  -> shared header and message evidence widgets
```

Different sources may create different scopes. Once a scope says “show these
messages,” rendering converges.

## Timeline Navigation Invariant

Pagination is not timeline navigation.

For any timeline-like MessageLens surface, the selected message scope must be
represented by a full lightweight skeleton before the user navigates it. The
skeleton must cover the full logical selected message universe even when row
hydration and media loading are windowed or incremental.

The skeleton is also:

- semantic timeline infrastructure
- heatmap coordination infrastructure
- jump/navigation infrastructure
- temporal orientation infrastructure

Hard rules:

- Heatmaps coordinate with the full skeleton, not with a latest page.
- Jumps target skeleton indices, not ad hoc message batches.
- Row bodies/media hydrate near the viewport.
- Limits apply to hydration windows, not to the selected message scope.
- Source-specific scopes are allowed; source-specific evidence presentation is
  not.

## Message Source

Current ordinary message evidence reads from the source-scoped graph:

- `macos_import_ss.db.messages` preserves source facts/provenance.
- `working_ss.db.messages` stores lean app graph rows.
- `working_ss.chat_to_message` and related topology tables define graph
  membership.
- `user_overlays.db` stores durable user intent and merges at read time.

Legacy `working.db` may remain for retained archive/recovery compatibility, but
it is not ordinary app-facing message evidence truth.

## Identity

Message rows use canonical `message_ss_id` / `ss_id`. GUIDs are metadata or
bridge fields, not canonical identity.

Display identity is semantic, not relational. The resolver answers “what should
the user see?” and follows the current precedence:

1. user-assigned app display name / override
2. app-known contact identity
3. imported AddressBook/contact name
4. stable participant/conversation label
5. raw handle fallback only

Known contacts should not be primarily labeled by raw handles except in
explicit handle-scope controls or unknown-handle surfaces.

## Attachment Evidence

Attachment rendering follows archive-first graph evidence hydration:

1. Graph message/attachment edges identify attachment facts by `ss_id`.
2. Attachment evidence hydration resolves archive/source availability outside
   widgets.
3. Shared image/video/link/fallback tiles render typed evidence.

Widgets must not render directly from live Apple file paths and must not hide a
message because attachment hydration is incomplete.

## Search

Intra-view search is part of the evidence header grammar. Search must operate
against the selected logical scope, not just hydrated rows.

Search result counts, next/previous match, matching-only filters, and term
highlighting belong to the evidence scope/resolver layer and shared evidence
widgets, not source-specific renderers.

## Incremental Updates

`ChatDbChangeMonitor` polls `chat.db`, then runs the source-scoped graph build
lifecycle. On success it invalidates graph/evidence readers and archives
attachments for the graph source range.

The message view should preserve the user’s reading position. If new evidence
arrives below the visible window, use the pending-new-message affordance rather
than forcing a scroll.

## Non-Negotiable Rules

- Do not render directly from database rows.
- Do not create source-specific message renderers.
- Do not infer identity from raw handle strings when a known contact identity
  exists.
- Do not derive timeline navigation from pagination.
- Do not hide messages because identity, attachment, text, or preview hydration
  is incomplete.
- Do not put SQL/query work in widgets.
