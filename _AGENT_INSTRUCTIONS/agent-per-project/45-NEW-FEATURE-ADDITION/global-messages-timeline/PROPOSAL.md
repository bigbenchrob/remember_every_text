---
tier: project
scope: proposal
owner: agent-per-project
last_reviewed: 2026-06-06
source_of_truth: historical-record
links:
  - ../../40-FEATURES/messages/message-display-flow-walkthrough.md
  - ../ordinal-index-all-messages/PROPOSAL.md
  - ../ordinal-index-all-messages/DESIGN_NOTES.md
tests: []
---

# Feature Proposal: Global Messages Timeline (All Messages)

## Current Conformance Note (2026-06-06)

This proposal captured the original global timeline ambition. Its UX goal
remains relevant, but its `working.db: message_index` mechanics are superseded
by the graph-backed Message Evidence Spine. Any future global timeline must be
implemented as a typed graph `MessageEvidenceScope` with a full logical
skeleton and viewport hydration. Pagination is not timeline navigation.

Do not introduce a global-timeline-specific renderer. Once the scope resolves
to message evidence, it must use the shared evidence header, skeleton,
hydration, attachment evidence, and row rendering path.

## Summary
Add a **Global Messages** experience: “every message I have ever sent to or received from anyone”, browsable as a single chronological timeline with:
- **Search-first** workflows (most important)
- **Heatmap/month jump** (second)
- **Smooth browsing** via ordinal-skeleton + hydration (same core architecture as contact messages)

Graph-era implementation must use the Message Evidence Spine's full-scope
skeleton and viewport hydration so the UI can scale to very large datasets
without loading full message payloads upfront. The original `message_index`
strategy is historical context only.

## User Motivation / Use Cases

### Search across unknown senders
- “Find the Instant Pot receipt” without knowing the phone/email; search text + jump to Aug 2023.
- “Jerry’s Tiki Hut” — recall a person/event by phrase.

### Time-window browsing
- “Jump to July 2020 and browse around.”

### Drill-down (future)
- From an interesting message: “show this thread/chat” or “show surrounding context”.

## Goals (v1)

### Must-have
- Global timeline reachable via ViewSpec navigation.
- Ordinal-skeleton list + per-row hydration (same mental model as contact messages).
- Search results view with good context:
  - correspondent display name + handle
  - timestamp
  - snippet/highlight
  - action: “jump to this in timeline”
- Heatmap/month jump to reposition the timeline.
- UI stability for large data: no scroll jitter during hydration.

### Should-have (still v1, if inexpensive)
- “Peek context” for a message: show ±N messages around a selected message.
- Lightweight filters:
  - has attachments
  - from me / from others
  - unknown senders only

## Non-Goals (v1)
- Full chat thread view restoration (chat UI remains intentionally removed for now).
- Building a complete faceted search UI with many chips/fields; keep constraints minimal.
- Any changes to import/migration pipelines unless required by missing index data.

## Proposed UX / Presentation

### Timeline rows
Same message bubble/attachment cards as contact messages, plus a **prominent correspondent label**:
- Display name (best available)
- Handle (phone/email) when ambiguous

### Modes
- **Browse mode:** scrollable ordinal timeline.
- **Search mode:** list of matches with context + jump.

## Architecture (matches the “VM + helpers” pattern)

We will replicate the same folder semantics as contact messages:
- `presentation/view/` — dumb global timeline view
- `presentation/view_model/global_messages/`
  - `global_messages_view_model.dart` — coordinator/facade
  - `jump/` — ordinal state + jump helpers
  - `hydration/` — ordinal → hydrated list item

Key constraint: **the view depends on the view model**, not on scattered providers.

## Data & Indexing

Expected graph-era backing:
- graph `MessageEvidenceScope` for the full selected logical message universe
- source-scoped `message_ss_id` skeleton rows for timeline/jump coordination
- shared evidence-row hydration for visible rows and media

Open questions:
- Confirm which graph repository boundary should own global timeline skeleton
  construction.
- Confirm whether month keys should be read from the graph skeleton query or
  derived during skeleton construction.

## Risks
- Performance at scale: global dataset could be 10x contact scope.
- Ambiguity: same person across multiple handles; correspondent display must be clear.
- Search result explosion: must not block UI; need sensible limits + paging.

## Scope Decisions Needed (sign-off)
Pick the v1 scope:
1) **A — Minimal v1:** search + browse + heatmap month jump (no extra filters).
2) **B — Practical v1:** A + 2–3 quick filters (attachments / from-me / unknown senders).
3) **C — Power v1:** B + “peek context” around a message.

## Acceptance Criteria
- Global timeline loads and scrolls smoothly on large datasets.
- Search can find messages from unknown senders and navigate to the right timeframe.
- Month jump reliably repositions without jitter.
- Lint clean; provider + DB access rules respected.
