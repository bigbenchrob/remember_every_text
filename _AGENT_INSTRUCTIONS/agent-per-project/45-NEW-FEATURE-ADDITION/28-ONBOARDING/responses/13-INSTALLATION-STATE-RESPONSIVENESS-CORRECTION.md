---
tier: project
scope: onboarding-installation-state-responsiveness
owner: agent-per-project
last_reviewed: 2026-08-26
source_of_truth: implementation-record
---

# Installation State Responsiveness Correction

## Observed Defect

A production-shaped development archive on an external volume exposed repeated
UI stalls during startup and advanced Start Fresh. The application log showed
18.7 seconds between app launch and the first resolved onboarding-gate state.
The reset mutation itself deleted the two rebuildable derived stores in about
0.1 seconds.

The delay came from `SqliteMessageLensInstallationEvidenceReader`. Although its
provider returned a `Future`, the reader synchronously opened all four
MessageLens databases and performed schema, `quick_check`, topology, and row
count inspection on Flutter's UI isolate. Advanced Start Fresh repeated that
inspection before opening its confirmation and again at the service authority
boundary.

## Correction

The evidence-reader contract is now asynchronous. Its unchanged SQLite
inspection runs through `Isolate.run`, so the UI isolate remains available to
paint startup and operation progress. Classification semantics are unchanged:
the same schema, integrity, table, source-registry, message-count, and graph
topology evidence remains authoritative.

The advanced Settings action now reuses the completed installation state that
startup already established when deciding whether to show authorization. This
read is presentation eligibility only. After authorization and after the
operation surface has painted, `StartFreshService` still performs a fresh
authoritative installation classification before requesting mutation
authority. Virgin-state verification after reset also awaits the asynchronous
evidence reader.

## Related Contact Delay

The same manual run detected 38 newly arrived source messages. Graph projection
completed in 4.7 seconds, while attachment archival extended the complete live
update to 42.8 seconds. Contact profile and heatmap spinners overlapped that
one-time external-volume workload. `liveGraphUpdate` does not block ordinary
database reopen, so this was not a maintenance-lock defect. No Contact query or
attachment-archive architecture was changed in this correction.

## Invariants Preserved

- No database schema or persisted representation changed.
- No installation-state evidence or integrity requirement was removed.
- Start Fresh still requires explicit authorization and mutation admission.
- The reset allow-list is unchanged.
- Apple source data, overlays, Presence history, preferences, diagnostics, and
  `attachment_archive/` remain outside the reset target.
- No arbitrary delay or UI-only timing workaround was introduced.
