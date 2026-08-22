---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-21
source_of_truth: architecture-audit-and-dormant-implementation-record
links:
  - ../prompts/46-MESSAGELENS-ATTACHMENT-MATCHING-AND-PRESERVATION-SAFE-RECOVERY.MD
  - ./45-MESSAGELENS-ATTACHMENT-RECOVERY-LINEAGE-PROOF.md
  - ./46-SHARED-HISTORICAL-ARCHIVES-MESSAGES-LINEAGE-ADMISSION.md
  - ../../../10-DATABASES/15-messages-lineage-admission.md
  - ../../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
---

# MessageLens Attachment Matching And Preservation-Safe Recovery

## Result

The existing metadata is sufficient to identify attachment-recovery candidates
without a schema migration. A dormant, read-only matching layer now expresses
that proof and classifies payload state. It does not inspect a real donor
database yet, copy a payload, write archive metadata, enable a UI segment, or
authorize recovery.

The decisive logical identity is not a filename, path, or hash. After the donor
has passed shared same-Messages-lineage admission, it is the exact Apple
Messages relationship:

```text
message.ROWID + attachment.ROWID
```

with mandatory message GUID equality and attachment GUID agreement whenever
both snapshots retain a nonempty attachment GUID. The exact relationship is
stronger than attachment GUID alone because it proves which current message
expects the payload.

## 1. Attachment Identity Anatomy

The current identity chain is:

```text
Apple chat.db attachment.ROWID
  -> macos_import_ss.attachments.source_rowid
  -> SourceScopedRowKey(source_id, source_rowid)
  -> macos_import_ss.attachments.ss_id
  -> working_ss.attachments.ss_id

Apple chat.db message.ROWID
  -> macos_import_ss.messages.source_rowid
  -> SourceScopedRowKey(source_id, source_rowid)
  -> macos_import_ss.messages.ss_id
  -> working_ss.messages.ss_id

Apple message_attachment_join(message_id, attachment_id)
  -> macos_import_ss.message_to_attachment
  -> working_ss.message_to_attachment
```

The attachment import ledger retains:

- `source_id`;
- original Apple `attachment.ROWID` as `source_rowid`;
- packed `ss_id`;
- attachment GUID;
- filename and transfer name;
- UTI and MIME type;
- total bytes;
- created timestamp; and
- import batch.

The relationship table retains both original source ROWIDs and both packed
MessageLens IDs. The message row retains the original `message.ROWID` and
message GUID. Graph projection preserves the packed message and attachment IDs
and their edge.

The archive overlay uses the compatibility key:

```text
(message_guid, import_attachment_id)
```

where `import_attachment_id` is the original live Apple attachment ROWID. Its
record stores a path relative to `attachment_archive/`, recorded byte length,
optional SHA-256, provenance, archive time, and original local path.

## 2. Reversible Attachment Source Scoping

Attachments use the same canonical `SourceScopedRowKey` bit layout as messages
and every other source-scoped entity. There is no attachment-specific packing
rule:

```text
original attachment ROWID
  -> SourceScopedRowKey.pack(sourceId, ROWID)
  -> SourceScopedRowKey.unpackSourceRowId(ssId)
  -> original attachment ROWID
```

The dormant matcher calls the canonical unpacking utility for both message and
attachment IDs and verifies that packed ID, stored source ID, and stored source
ROWID agree. It contains no local bit arithmetic. Focused coverage now names
the attachment round trip explicitly.

## 3. Per-Message And Per-Attachment Proof

Archive-level `SameMessagesLineageAdmission` is required by type before the
matcher can run. That admission is necessary but does not authorize any
individual payload.

For each donor relationship, the strongest existing proof is:

1. donor packed message and attachment identities are internally coherent;
2. exactly one donor relationship occurrence connects the original message
   ROWID to the original attachment ROWID;
3. current authoritative import-ledger evidence contains that same original
   message ROWID;
4. donor and current message GUIDs are both nonempty and equal;
5. exactly one current relationship occurrence connects that message ROWID to
   the same original attachment ROWID;
6. current and donor attachment GUIDs agree when both are nonempty; and
7. donor archive metadata and physical payload evidence pass separately.

Within a proven continuation of the same `chat.db`, the explicit attachment
integer primary key and its exact message relationship are stable identity.
An attachment GUID corroborates that identity. If both snapshots retain a GUID
and they differ, the candidate is rejected. A blank GUID does not promote
filename, transfer name, MIME type, UTI, size, extension, or path into identity.

Path and display-name similarity have no admission or matching authority.

## 4. Current Authority

The future read-only evidence adapter should compose existing authorities:

- current message and attachment source identity:
  `macos_import_ss.db` through the canonical source-scoped import ledger;
- current message-to-attachment topology: source ledger plus
  `working_ss.db` graph projection;
- current preservation metadata: `user_overlays.db.archived_attachments`;
- current physical presence: the admitted current archive's
  `attachment_archive/`; and
- donor lineage: the shared `SameMessagesLineageAdmission`.

The donor MessageLens ledger is evidence only. It is never current identity
authority and is never migrated. The donor archive marker identifies which
archive was selected; it does not prove a message or attachment match.

## 5. Record Metadata Versus Payload

An import-ledger or graph attachment row proves only that MessageLens expects
an attachment. It does not prove that preservation bytes exist.

An overlay archive record likewise does not prove that its referenced file is
present. Current payload state must combine:

```text
archive compatibility key
  + bounded archive-relative path
  + regular-file presence
  + recorded length/hash verification when available
```

The dormant matcher therefore consumes a distinct current payload status:

- `missing`;
- `presentValid`;
- `presentConflict`; or
- `inaccessible`.

Only `missing` can become recoverable. Inaccessible current data is a conflict,
not permission to overwrite it.

## 6. Donor Payload Storage And Safety

MessageLens preservation payloads live beneath:

```text
<archive root>/attachment_archive/
```

Current hash-addressed paths use the SHA-256 prefix and digest. Older
compatibility payloads may use `_by_id`. Overlay paths are relative; absolute
original Messages paths are audit metadata only and are never donor read
authority.

The new read-only payload inspector:

- requires a nonempty relative path;
- rejects absolute paths and lexical traversal;
- rejects a symlinked donor root, payload root, final file, or intermediate
  component;
- canonicalizes the existing root and file and rechecks containment;
- requires a regular file;
- compares exact recorded byte length;
- computes SHA-256 by stream;
- compares a stored SHA-256 when one exists; and
- never creates, writes, normalizes, or copies donor content.

The strongest available integrity evidence is exact SHA-256 plus exact byte
length. If an older archive row has no hash, exact size plus successful hashing
is inspectable evidence, but the computed digest should govern a future
content-addressed destination.

## 7. Classifications

The typed result preserves these distinct outcomes:

- `recoverable`: identity is exact, current payload is missing, donor payload
  is present and valid;
- `alreadyPresent`: current payload is already valid;
- `donorMissing`: donor metadata exists but its bounded payload is absent;
- `messageMismatch`: original message ROWID is absent or its GUID differs;
- `attachmentMismatch`: original attachment ROWID or available attachment GUID
  differs;
- `conflict`: current payload is inaccessible/different, or donor bytes fail
  recorded integrity;
- `ambiguous`: identity or relationship occurrence is not singular; and
- `unsafeDonorPath`: the donor path fails containment or symlink rules.

No mismatch is silently converted to recoverable.

Multiple claims for one current archive compatibility key collapse to one
candidate only when their inspected SHA-256 values prove the donor bytes are
identical and their classifications agree. Otherwise the one destination is
classified ambiguous. One content-addressed donor payload may legitimately
serve more than one independently proven current relationship, but each
message/attachment relationship must pass separately.

## 8. Aggregate Preflight

The dormant preflight reports only mechanically derived facts:

- relationships examined;
- recoverable count;
- exact recoverable bytes from validated donor files;
- already-present count;
- donor-missing count;
- message-mismatch count;
- attachment-mismatch count;
- conflict count;
- ambiguous count; and
- unsafe-path count.

The eventual ready screen may truthfully say:

> I found N missing attachments that can be safely recovered.

Technical exclusions belong in Details. No projected message import count,
graph-build stage, or approximate attachment denominator is needed.

## 9. Mutation And Canonical Destination

The current archive authority already owns the canonical destination root and
the attachment feature already owns content-addressed destination naming. No
Historical Archives code should construct a destination path.

Recovery is filesystem plus overlay mutation:

1. copy verified bytes into current `attachment_archive/`;
2. verify destination size and hash; and
3. insert or repair the current `archived_attachments` compatibility record.

It must not change source import rows, graph rows, current messages, current
relationships, or other overlays. No graph rebuild is required because no
message or attachment topology changes.

The existing archive writer is not yet the final safe recovery primitive. It
copies directly to the destination and can overwrite an existing path. The
future mutation slice must add temp-file write, verification, no-destructive-
overwrite collision handling, and atomic rename/reuse semantics inside the
Attachments-owned storage boundary. That is an extension of existing
ownership, not a storage redesign.

`ArchiveMutationOperation.attachmentReconciliation` is the existing operation
class that best describes future recovery. The coordinator must serialize it
against normal attachment archiving, another reconciliation, clearing, reset,
and other archive mutations. It need not block ordinary import-ledger or graph
reads, but all observations used to authorize each copy must belong to the
admitted operation and be revalidated before commit.

## 10. Idempotency And Restart

The intended operation is naturally candidate-idempotent:

```text
inspect current state on each run
  -> valid payload now present: alreadyPresent
  -> still missing: recoverable
```

A future per-file operation should be:

```text
copy to current-owned temporary file
  -> verify length and SHA-256
  -> atomically install or reuse identical content-addressed file
  -> commit/repair overlay metadata
```

If the app exits after file installation but before overlay commit, a rerun can
verify and reuse the identical content-addressed file, then complete metadata.
If it exits before rename, the current archive must ignore and later clean the
operation-owned temporary file. A durable per-file journal is not currently
required, but this must be proved by the future copy implementation tests.

## 11. Provenance, Cartouches, And Removal

Recovered payload ownership remains with the current MessageLens attachment
archive. The donor is only where the missing bytes were found. Donor source
identity must never replace current message or attachment provenance.

The clearest product model is no persistent `Folders Already Added` cartouche
for MessageLens recovery donors. A donor is not an active content source after
recovery. Re-selecting the same `archiveInstanceId` should perform a fresh,
idempotent read-only scan because current missing/present state may have
changed.

An operation receipt containing donor archive instance ID, lineage method, and
aggregate outcome may later be useful for audit, but no existing schema is a
truthful home and none was added.

`Remove this folder...` has no meaningful MessageLens-recovery counterpart.
Recovered bytes are ordinary current preservation data and must not be deleted
because their donor is disconnected or forgotten. Attachment archive payloads
remain protected by the preservation invariant.

## 12. Donor Compatibility

The minimum donor read model needs only:

- marker identity and prior structural/coherent-snapshot qualification;
- one `live_chat_db` source in `source_registry`;
- `messages` identity columns;
- `attachments` identity/metadata columns;
- `message_to_attachment` relationship columns;
- `archived_attachments` compatibility key, relative path, size, and optional
  hash; and
- physical `attachment_archive/` files.

The future adapter must query these tables through isolated read-only source
connections and explicit column-shape checks. It must not instantiate a
migrating donor Drift database. Missing required columns produce an
incompatible/insufficient result, never donor mutation. This supports the
known March archive shape first without claiming arbitrary old-version
compatibility.

## 13. Dormant Implementation

Added under Attachments:

- typed relationship, archive metadata, payload inspection, candidate,
  classification, and aggregate preflight models;
- a pure matcher requiring `SameMessagesLineageAdmission`;
- canonical source-scoped identity coherence checks;
- duplicate-destination fail-closed behavior; and
- a read-only contained-path, size, and SHA-256 inspector.

Not added:

- real donor database enumeration;
- current database evidence composition;
- a provider or Historical Archives integration;
- copy/mutation;
- UI;
- durable donor identity;
- schema changes; or
- source registration.

## 14. Readiness For The Copy Slice

The identity and classification contract is now explicit and testable. Actual
preservation-safe copying is not yet ready to enable. The next bounded work
must add:

1. read-only donor/current evidence adapters with structural compatibility
   checks;
2. current physical payload inspection feeding the typed status;
3. aggregate validation on representative read-only archives;
4. an atomic, no-overwrite Attachments-owned copy/metadata primitive; and
5. mutation-coordinator composition and interruption tests.

None of those requirements needs donor migration, message import, graph
rebuild, or a new attachment identity schema.

## 15. Verification

Focused tests cover:

- attachment source-scoping round trip;
- same/different message GUID behavior;
- exact attachment ROWID and GUID behavior;
- filename/path non-authority;
- ambiguous and byte-identical duplicate claims;
- all payload classifications;
- exact aggregate count and byte total;
- retry becoming `alreadyPresent`;
- traversal and absolute-path rejection;
- symlink rejection;
- size/hash validation; and
- absence of mutation/presentation dependencies.

No production, staging, donor, database, marker, graph, overlay, or attachment
payload was opened or mutated by this work.
