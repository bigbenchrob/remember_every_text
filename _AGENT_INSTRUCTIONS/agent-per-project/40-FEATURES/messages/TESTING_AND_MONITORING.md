---
tier: feature
scope: testing-monitoring
owner: agent-per-project
last_reviewed: 2026-06-05
links:
  - ./STATE_AND_PROVIDER_INVENTORY.md
  - ./WORK_LOG.md
tests: []
feature: messages
doc_type: testing-monitoring
status: current
last_updated: 2026-06-05
---

# Testing & Monitoring - Messages

This document focuses on the graph-backed Message Evidence Spine.

## Automated Coverage Targets

- Unit
  - Message evidence scope construction for global, contact, handle-filtered,
    conversation, recovered, and search contexts.
  - Full-scope skeleton count/order/month-key behavior.
  - Visible-row hydration by graph `message_ss_id`.
  - Scope search and AND/OR matching against the selected logical scope.
  - Attachment evidence hydration for archived, unavailable, and text-only rows.
- Integration
  - Graph repository joins for contact, conversation, handle, recovered, and
    global scopes.
  - Display identity precedence in sender labels and conversation headers.
  - Overlay saved/tag/annotation state merged at read time.
  - Maintenance lock behavior during reset/rebuild.
- Widget
  - Shared header renders title, metrics, search, and actions from typed model
    data.
  - Shared evidence rows render text, media, URL previews, badges, and fallback
    states consistently across surfaces.
  - Heatmap month selection jumps into the full skeleton, not a page fetch.
  - New-message affordance appears without forcing scroll when the user is
    reading mid-list.

## Test Data Requirements

- Large histories across multiple months/years.
- Multiple handles for one known contact.
- Group conversations and one-to-one conversations.
- Text-only, attachment-only, URL preview, attributed-body-only, sparse/system,
  and recovered/orphan messages.
- Unknown/unfamiliar handles and known-contact handle fallbacks.

## Monitoring & Diagnostics

- Graph build status and stage timings in the conversation graph status panel.
- Message evidence load time for skeleton and visible hydration.
- Attachment archive availability and missing evidence counts.
- Pending-new-message behavior during live polling updates.
- Stale scope or maintenance-lock errors during reset/rebuild.

## Manual Verification Checklist

- Open Contacts -> All messages and verify heatmap jumps remain coordinated.
- Apply a handle filter and verify heatmap/counts match the filtered scope.
- Open Conversations and select a long conversation; search within it.
- Open unfamiliar-source messages and verify known contacts are not mislabeled
  by raw handles.
- Send a new message while reading mid-list; verify the list does not force
  scroll and the pending affordance appears.
- Confirm attachments and URL previews render through the shared evidence tiles.
