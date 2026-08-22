---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-22
source_of_truth: implementation-record
---

# Batch Attachment Recovery And Controlled-Loss Validation

## Outcome

The Historical Archives MessageLens arm can now execute the attachment-only
operation established by its preflight. The operation recovers only the exact
typed `recoverable` set from an admitted same-lineage donor. It imports no
messages, graph data, overlays, source registration, or provenance and creates
no donor cartouche.

## Authority And Ownership

The Settings workflow requests
`ArchiveMutationOperation.attachmentReconciliation` through
`ArchiveMutationCoordinator.runWithCapability(...)`. The canonical batch
executor and the canonical single-payload installer both require that live,
caller-specific capability. A missing, wrong-operation, nested-parent, or
expired capability is rejected mechanically.

The batch executor never copies directly. Its chain is:

```text
completed typed preflight and exact recoverable set
    -> execution-boundary evidence and donor-integrity revalidation
    -> streaming payload size/SHA-256 proof
    -> canonical single-payload installer
    -> atomic no-overwrite payload installation
    -> current-owned metadata reconciliation
    -> authoritative final metadata/file verification
    -> candidate reclassification
```

The donor readers and payload verifier remain read-only.

## Execution And Progress

The typed execution stages are:

1. `verifyingDonorPayloads`;
2. `installingPayloads`;
3. `finalVerification`;
4. `complete`.

Progress exposes exact total, verified, processed, recovered, and terminally
verified attachment counts plus exact total, verified, and copied bytes.
Payload SHA-256 is streamed and reported in bounded updates. Candidates that
became `alreadyPresent` after preflight are not hashed or copied.

Historical Archives publishes the operation presentation before resolving the
executor and waits for the supplied end-of-frame barrier before expensive
work. Narrator describes the current scope while Directed Instrumentation
projects real stages and counts. Completed rows remain visibly Done for the
established 1.5-second terminal dwell.

## Outcomes And Failure Policy

Expected item-level outcomes are retained and the batch continues:

- installed;
- already present;
- conflict;
- donor missing or changed;
- verification failure;
- metadata update failure;
- message or attachment mismatch;
- ambiguous identity;
- unsafe source path.

Unexpected donor-integrity, authority, or storage failures stop the batch and
preserve the last truthful operation stage. Earlier successful installs remain
preservation data.

The success acknowledgement is:

> **Attachment recovery complete**
>
> MessageLens recovered **N missing attachments** from the folder you selected.

A qualified result is:

> **Attachment recovery finished**
>
> Recovered: N
> Could not recover: M

`OK` dismisses the acknowledgement and returns to the virgin MessageLens hub.

## Terminal Truth And Retry

The executor does not trust its counters. It rereads current payload status,
checks installed physical files against execution-time size and hash, and
reclassifies every approved candidate. Full success requires all outcomes to
be physically satisfied and zero candidates to remain recoverable.

No durable recovery journal is needed. The single installer writes a verified
temporary file in the destination rename domain, atomically installs without
overwrite, then publishes metadata. If execution stops after any subset, a
rerun derives truth from current storage: completed items become
`alreadyPresent`, metadata is reconciled without duplicate rows, and only
remaining missing payloads are copied.

## Controlled-Loss Rehearsal

`tool/generate_message_lens_attachment_recovery_controlled_loss_manifest.dart`
is a read-only external test-preparation helper. It accepts distinct donor and
receiving archive roots, requires the receiving archive marker to say
`development`, opens evidence databases read-only, selects seven deterministic
moderate-size image payloads with exact one-to-one identity and equal donor /
receiving bytes, streams SHA-256 for both copies, and writes a JSON manifest
outside both archives.

The helper does not delete payloads and is not product persistence. The product
does not read the manifest.

### Mandatory deletion timing

> Do not remove any files until implementation is complete, all automated
> tests pass, the branch is committed and pushed, and the final controlled-loss
> manifest has been generated and reviewed.

After that point only the human may remove exactly the manifest's receiving
paths from the disposable development/staging archive. Never remove donor
files, database rows, or attachment metadata.

The manual sequence is:

1. Fully quit MessageLens and review the manifest's archive roots, N, bytes,
   paths, sizes, and hashes.
2. Verify all listed donor and receiving files exist.
3. Remove only the listed receiving payload files.
4. Launch MessageLens against that exact disposable receiving archive.
5. Choose Historical Archives -> MessageLens and select the intact donor.
6. Require preflight count and bytes to equal the manifest. Stop without
   recovery if either differs.
7. Choose `Recover Attachments` and observe real Narrator/instrumentation
   progress.
8. Require the terminal acknowledgement to report exactly N recovered.
9. Verify every receiving file exists and matches manifest/donor size and
   SHA-256; verify donor files are unchanged.
10. Run the same preflight again and require zero recoverable attachments.

## Verification Coverage

Focused coverage proves exact-set admission, monotonic real progress, first
install and already-present rerun, expected-item continuation, systemic stop,
donor changes, wrong and expired capabilities, interrupted-subset convergence,
atomic concurrent-destination no-overwrite, payload-before-metadata ordering,
first-paint workflow ownership, all-Done dwell, complete and partial terminal
acknowledgements, hub return, and no donor cartouche.

Architecture tripwires preserve the canonical batch/installer chain, donor
read-only access, absence of message or graph import, and the controlled-loss
helper's no-delete boundary.

The completed implementation passed:

- 101 focused attachment-recovery and Historical Archives tests;
- 553 broader attachment, database-access, mutation-coordination, Historical
  Archives, and architecture tests;
- the complete 1,949-test Flutter suite;
- `flutter analyze` with no issues;
- a macOS debug build; and
- `git diff --check`.
