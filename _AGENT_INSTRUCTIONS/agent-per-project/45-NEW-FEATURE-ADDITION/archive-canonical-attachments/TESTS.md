---
tier: feature
scope: tests
owner: agent-per-project
last_reviewed: 2026-04-05
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
tests: []
feature: archive-canonical-attachments
status: proposed
created: 2026-04-05
---

# Test Plan - Archive-Canonical Attachments

## Resolver Tests

- [ ] Archive disabled + live file exists -> available from live path
- [ ] Archive disabled + live file missing -> cloud-only or missing, depending on source record shape
- [ ] Archive enabled + archive file exists -> available from archive path
- [ ] Archive enabled + archive missing + live file exists -> pending archive, not live display
- [ ] Archive enabled + archive missing + live file missing -> unavailable-awaiting-recovery
- [ ] Archive enabled + attachment previously unavailable + live file later reappears -> transitions through archive ingestion to available
- [ ] Archive enabled + archive write previously failed -> unavailable-awaiting-recovery with updated recovery metadata
- [ ] High-confidence malformed or unsupported attachment source -> non-recoverable

## Archive Service Tests

- [ ] Archive copy is idempotent for the same `(message_guid, import_attachment_id)` pair
- [ ] Overlay row is written only after successful archive copy
- [ ] Failed copy does not create a false available state
- [ ] Retry path can move a failed or pending attachment to available
- [ ] Recovery path archives a file that reappears later in the live Messages folder
- [ ] Recovery backoff policy reschedules unresolved attachments without requiring UI-path retries

## Hydration Tests

- [ ] Message row hydration carries pending attachment state without dropping the row
- [ ] Message row hydration no longer picks a live file when archive mode is enabled
- [ ] Attachment helpers no longer bypass the policy boundary with direct file checks
- [ ] Hydration preserves unavailable-awaiting-recovery state for attachments that may recover later
- [ ] Hydration preserves internal recovery metadata needed for scheduling and diagnostics

## Presentation Tests

- [ ] Pending archive state renders the temporary placeholder text
- [ ] Pending -> available transition updates the row correctly
- [ ] Unavailable-awaiting-recovery renders as a single user-facing state in v1
- [ ] Non-recoverable renders only for high-confidence cases
- [ ] Clicking an unavailable placeholder raises background recovery priority without rendering from the live path directly
- [ ] Archive-enabled mode never renders a live Messages file path

## Regression Tests

- [ ] New messages remain visible during the archive gap
- [ ] Previously archived attachments remain viewable after live-file eviction
- [ ] Previously unavailable attachments become available after Apple restores the live file and MessageLens archives it
- [ ] Archive-disabled mode preserves the current live-only behavior
- [ ] Anomalous attachment records remain visible and diagnosable
- [ ] Non-image attachments follow the same archive-canonical policy flow as image attachments
- [ ] Long-unresolved archive-mode attachments are still retried on a slow cadence and can recover days later
