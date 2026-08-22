---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-21
source_of_truth: implementation-record
links:
  - ../prompts/47-PRESERVATION-SAFE-ATTACHMENT-RECOVERY-INFRASTRUCTURE.MD
  - ./47-MESSAGELENS-ATTACHMENT-MATCHING-AND-PRESERVATION-SAFE-RECOVERY.md
  - ../../../25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md
  - ../../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
---

# Preservation-Safe Attachment Recovery Infrastructure

## Result

The dormant MessageLens attachment-recovery arm can now install an
already-proven donor payload safely in isolated storage. No Historical
Archives control, provider, chooser, operation, or production call path invokes
this infrastructure.

The implementation reuses the canonical attachment ownership chain:

```text
AttachmentArchiveFileStore
  -> canonical content-addressed destination
  -> verified temporary file
  -> atomic no-overwrite install

AttachmentArchiveWriteStore
  -> overlay metadata reconciliation after physical success
```

It does not create a recovery-specific destination algorithm or write directly
from Settings/Historical Archives.

## Existing Write-Path Finding

The pre-existing canonical file store copied source bytes directly to the final
path. `OverlayRecoveredAttachmentArchiveWriter` also used an
`exists`-then-copy sequence. Neither existence check was a no-overwrite
guarantee, and a failed copy could expose a partial final file.

This slice strengthens `AttachmentArchiveFileStore`, which is already the
canonical archive path/hash/file boundary. The dormant MessageLens installer
uses that strengthened port. The earlier Mac Messages snapshot arm remains
behaviorally unchanged and is not wired to this new MessageLens workflow.

## Atomic Installation

The destination remains:

```text
attachment_archive/<sha256 prefix>/<sha256><normalized extension>
```

Installation is:

1. create an exclusive temporary file in the destination directory;
2. stream donor bytes into it;
3. flush and close;
4. verify exact byte count and SHA-256;
5. call POSIX `link(2)` from the temp file to the final path;
6. remove the temp path; and
7. verify the final file.

The macOS `link(2)` directory-entry creation is atomic and fails when the
destination exists. It never replaces that destination. If another writer wins
the race, the store verifies the winner and returns `alreadyPresent` for
identical bytes or `conflict` otherwise.

Temporary files use the recognizable marker `.messagelens-install-`. They are
never addressed by archive metadata and never qualify as final payloads.
Expected failures clean them up.

## Verification And Typed Outcomes

The verified donor capability carries:

- bounded donor archive-relative identity;
- extension;
- exact observed size; and
- computed SHA-256.

The writer re-verifies the stream at execution. A donor changed between
preflight and execution becomes `donorChanged`. Expected installation outcomes
remain typed:

- `installed`;
- `alreadyPresent`;
- `conflict`;
- `donorMissing`;
- `donorChanged`;
- `verificationFailed`;
- `unsafeSource`; and
- `metadataUpdateFailed`.

Unexpected filesystem/infrastructure failures remain exceptions at the file
boundary and are translated only where the recovery contract has a truthful
expected classification.

## Metadata Ordering And Retry

Overlay `archived_attachments` remains the metadata authority. Recovery writes
only the current compatibility key, canonical relative path, size, hash,
recovery provenance, and current archive time. No donor overlay row is copied.

Ordering is strictly:

```text
verified payload installed
  -> overlay record reconciled
```

If metadata fails after installation, the payload is retained. Retry derives
the same content-addressed destination, verifies the existing file, and then
reconciles the missing/stale overlay row. This is the intended crash-recovery
state and requires no durable recovery journal.

## Crash Semantics

| Interruption point | Durable state | Retry |
|---|---|---|
| During copy | recognizable temp only | new verified copy; stale temp is not payload truth |
| After temp verification | recognizable temp only | same |
| Immediately before install | recognizable temp only | same |
| After install, before metadata | valid final payload | verifies existing bytes, reconciles metadata |
| After metadata | valid payload plus matching metadata | `alreadyPresent` |

## Evidence Adapters

### Donor

`SqliteMessageLensAttachmentDonorEvidenceReader` opens donor
`macos_import_ss.db` and `user_overlays.db` with SQLite read-only mode and
`PRAGMA query_only = ON`. It runs explicit SELECT/PRAGMA compatibility queries,
performs no migration, and fails closed if required tables or columns are
missing.

The adapter receives those already-resolved database paths together with the
donor archive root, verifies that both paths remain within that root, and does
not import the app's central physical-database filename authority. Future
composition must resolve the donor files before constructing this reader.

Supported compatibility is structural rather than a broad version promise:

- source-scoped `messages`, `attachments`, and `message_to_attachment` with
  the identity/topology columns used by the matcher; and
- `archived_attachments` with compatibility key, relative path, size, and hash.

This covers the known MessageLens archive lineage represented by the current
Feature 26 target. Older shapes lacking those fields are unsupported and fail
closed.

### Current

`ImportLedgerMessageLensAttachmentEvidenceReader` uses only the canonical
`ImportLedger`, `AttachmentArchiveReadStore`, and `AttachmentArchiveFileStore`.
It adds no ad-hoc current database connection and verifies current physical
presence against overlay size/hash evidence.

## Concurrency And Authority

Atomic no-overwrite installation is the decisive filesystem concurrency rule.
Live archiving or another recovery may create the same content-addressed file;
the losing writer verifies rather than overwrites it.

Runtime invocation is mechanically gated by the existing
`ArchiveMutationOperation.attachmentReconciliation` operation. The mutation
coordinator mints an opaque `ArchiveMutationCapability` only for the exact
admitted async scope, and the installer requires that capability before it
opens donor bytes or changes payload/metadata state.

The capability is not durable metadata or attachment identity. It cannot be
constructed by a feature, cannot authorize a different operation, is inactive
while a nested scope owns the caller position, and becomes unusable when its
originating scope ends. This preserves caller-specific scope rather than
turning operation admission into a reusable bearer token. No new mutation
operation or mutex was added.

## Batch And Progress

No batch executor was added. The single-payload primitive is now sufficiently
typed for a future bounded executor to report real attachment and byte
denominators without pre-committing batch failure policy or UI.

## Preserved Boundaries

The implementation does not:

- import donor messages;
- write a source registry or import ledger;
- mutate or rebuild the graph;
- merge donor overlay data;
- change message provenance or source-scoped IDs;
- enable the MessageLens Historical Archives segment;
- create a chooser, cartouche, ready state, or Recover button; or
- touch any real donor, staging, production, or attachment payload.

The untracked `46b` prompt was removed only after SHA-256 proved it was
byte-identical to Prompt 46.

## Verification

Focused coverage proves atomic visibility, temp cleanup, verification failure,
existing-payload preservation, a concurrent destination race, idempotent retry,
metadata-after-file ordering, metadata-failure reconciliation, path/symlink
safety, read-only donor access, unsupported-schema rejection, canonical current
store use, exact-scope mutation capability enforcement, stale/wrong-operation
rejection, and absence of Historical Archives wiring.

Full verification results are recorded in the completion report for this task.
The completed verification was:

- attachment feature suite: 141 tests passed;
- focused Historical Archives regression set: 103 tests passed;
- repository architecture tripwires plus the recovery-specific tripwire: 382
  tests passed;
- complete Flutter suite: 1,894 tests passed;
- `flutter analyze`: no issues;
- macOS debug build: succeeded as `MessageLens Development.app`; and
- `git diff --check`: clean.

No real archive, donor, staging database, production database, or attachment
payload was opened or mutated during this slice.
