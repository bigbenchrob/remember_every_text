---
tier: feature
scope: design
owner: agent-per-project
last_reviewed: 2026-04-05
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ../../25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md
tests: []
feature: archive-canonical-attachments
status: proposed
created: 2026-04-05
---

# Design Notes - Archive-Canonical Attachments

## Core Design Decision

The archive-enabled experience should be **display-only from archive, ingestion-only from live**.

This intentionally separates two concerns that are currently entangled:

- where the app discovers new files
- where the UI is allowed to render from

## Why This Is Better Than Live-First Fallback

The old model lets the same attachment behave differently depending on timing:

- before archive copy: render from live cache
- after archive copy: render from archive
- after Apple eviction: render from archive if present, otherwise fail

That means display semantics change based on background timing and Apple cache behavior.

The new model keeps the display rule fixed:

- archive disabled -> live display
- archive enabled -> archive display

## Proposed Layer Responsibilities

### Attachments Application Layer

Owns the policy decision for attachment display source and attachment availability state.

This layer should answer questions like:

- Is the app in archive-enabled mode?
- Is the archive file ready?
- Should this attachment be reported as pending, available, unavailable-awaiting-recovery, or non-recoverable?

It should not leak raw "try this path, then that path" behavior to downstream hydration helpers.

### Archive Service

Owns file copying, deduplication, overlay metadata writes, and retryable archive work.

It should treat the live Messages path as an ingestion source only when archive mode is enabled.
It should also support recovery when an attachment that was previously unavailable later reappears in the live Messages folder.

The archive service should not be driven synchronously by the widget tree. It should run from background orchestration and prioritized recovery queues.

### Message Hydration

Consumes normalized attachment state rather than independently checking local file existence.

Hydration should stop deciding attachment source. It should only pass through resolved state.

### Presentation

Renders explicit states honestly:

- pending archive copy
- available attachment
- unavailable awaiting recovery
- non-recoverable only in high-confidence cases

For v1, the presentation layer should not expose a separate durable "archive failed" state. Archive-copy failures should normally collapse into the unavailable-awaiting-recovery bucket while internal retry metadata drives later attempts.

## Recommended v1 State Model

The user-facing state model should stay small:

- `pendingArchive`
- `available`
- `unavailableAwaitingRecovery`
- `nonRecoverable` only when recovery is implausible for clear, specific reasons

This is intentionally biased toward eventual recovery. Most operational failures in this feature are not truly final; they are unresolved conditions.

## Proposed State Sketch

Possible resolved attachment shape in archive-enabled mode:

```text
ResolvedAttachment
  - availability
  - provenance
  - displayFile
  - pendingReason?
  - nonRecoverableReason?
  - recoveryMetadata?
```

Key rule:

- `displayFile` must be null while `availability == pendingArchive`
- `displayFile` must point to archive storage when `availability == available`
- `displayFile` must never point at the live Messages path in archive-enabled mode

### Internal Recovery Metadata

The internal model should retain richer scheduling and diagnostics data than the user-facing state model.

Suggested fields:

```text
RecoveryMetadata
  - lastRecoveryAttemptAt
  - nextRecoveryAttemptAt
  - recoveryAttemptCount
  - recoveryPriority
  - userInterestRaisedAt?
  - lastRecoveryErrorSummary?
  - isNonRecoverable
```

This supports retry orchestration without forcing that complexity into the UI contract.

## Recovery Model For iCloud-Restored Files

An attachment that is unavailable at one moment is not necessarily permanently unavailable.

Because Apple can restore the underlying file back into `~/Library/Messages/Attachments`, the design needs a recovery path:

1. Attachment is unresolved and renders as cloud-only, missing, or retriable unavailable.
1. Attachment is unresolved and renders as unavailable-awaiting-recovery.
2. The normal sync cycle or a background recovery worker triggers a re-check.
3. If the live file has reappeared, MessageLens treats that as an ingestion event.
4. Archive service copies the file into the archive and writes overlay metadata.
5. Resolver updates the attachment to `available` from archive.

This keeps the display contract strict while still honoring late source-file restoration.

## Transition Model For New Messages

1. Auto-sync imports the new message into working data.
2. Message row becomes visible in the UI.
3. If the attachment is not archived yet but a live file exists, the attachment enters `pendingArchive`.
4. Archive service copies the file and records overlay metadata.
5. Resolver emits `available` with archive-backed display path.

This preserves fast message visibility without using the live cache as a display source.

## User-Interest Recovery Path

If the app renders an unavailable placeholder for an attachment that may exist in iCloud, clicking that placeholder should be able to raise the recovery priority for that attachment.

That flow should not render from the live path directly and should not block on immediate recovery. It should:

1. record user interest in the unresolved attachment
2. schedule or prioritize a background recovery attempt
3. let background recovery check whether the live file has reappeared
4. if present, archive it
5. transition the UI to the archive-backed available state when complete

This can coexist with periodic sync-based recovery. The important rule is that user interaction accelerates ingestion priority; it does not bypass the archive and does not need to complete immediately.

## Recommended Retry And Backoff Policy

The recovery policy should optimize for eventual archival rather than low-latency restoration.

Recommended shape:

1. **Fresh unresolved attachments**
  Retry on the normal sync cadence while the message is new.

2. **Aged unresolved attachments**
  Move to a slower background retry cadence once the attachment has remained unresolved across multiple sync cycles.

3. **User-interest boost**
  A placeholder click should move the attachment into a higher-priority background retry bucket.

4. **Long-tail persistence**
  Keep occasional retry attempts for unresolved archived-mode attachments so that late iCloud restores still get captured eventually.

One reasonable concrete policy would be:

- first day: retry on normal sync cadence
- next several days: retry hourly or per-app-session background recovery
- long tail: retry daily until archived or explicitly classified as non-recoverable

The exact numbers can be tuned later. The important design choice is stepped background backoff, not synchronous click-to-load.

## Non-Recoverable Threshold

The app should only move an attachment into `nonRecoverable` when it has strong evidence that eventual recovery is implausible.

Examples that may justify `nonRecoverable`:

- malformed source data prevents valid path resolution
- a deliberate product rule excludes a specific attachment kind
- long-horizon retries plus source-shape evidence show there is no viable recovery path

Cases that should remain in unavailable-awaiting-recovery:

- ordinary iCloud eviction
- transient archive copy errors
- retry backoff windows
- unresolved items that the user has not asked to prioritize yet

## Current Code Smells This Feature Should Remove

### Duplicated file existence checks

Current behavior is split between the attachment resolver and message hydration helpers. That creates policy drift.

### "Best available file" helpers

Helpers that pick any existing file path are incompatible with archive-canonical display because they hide the distinction between ingestion and rendering.

### Implicit pending and recovery behavior

Today, missing archive work tends to collapse into a live fallback or generic unavailable behavior. The new model requires first-class pending and recovery-aware states.

## Suggested Implementation Order

1. Normalize resolved attachment states in the attachments application layer.
2. Add recovery-aware resolution for attachments that may reappear later.
3. Add background retry/backoff orchestration plus user-interest prioritization.
4. Change hydration to consume normalized state only.
5. Update presentation to render pending and retriable unavailable explicitly.
6. Remove remaining live-first shortcuts.
7. Update canonical docs once behavior matches the new contract.

## Deferred Questions

- What metadata is needed to persist retry priority, last recovery attempt, and backoff state
- What exact source-shape evidence should be sufficient for `nonRecoverable`
- Whether background sync should proactively archive before blue-strobe notification, or whether the pending state alone is sufficient for v1
