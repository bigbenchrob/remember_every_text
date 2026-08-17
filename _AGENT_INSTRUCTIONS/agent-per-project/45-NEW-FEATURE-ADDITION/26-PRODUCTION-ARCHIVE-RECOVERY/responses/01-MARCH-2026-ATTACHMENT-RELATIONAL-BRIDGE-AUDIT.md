---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-16
source_of_truth: audit
links:
  - 00-START-HERE.md
  - ../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
tests: []
---

# March 2026 Attachment Relational Bridge Audit

## Conclusion

The clean relational bridge succeeds.

The checkpointed donor `chat.db` contains 33,018 message-to-attachment pairs.
Exactly 33,011 map through stable Apple GUIDs to the current live-source
MessageLens graph topology:

```text
33,011 / 33,018 = 99.9788%
```

This exceeds the approximately 99% preservation-recovery threshold. No
heuristic matching is justified.

Among 30,743 donor payloads found at deterministic paths inside the preserved
attachment tree:

- 30,736 map directly to current MessageLens messages and attachments;
- 30,382 already have intact production archive files;
- 354 mapped payloads have no archive metadata row and appear recoverable;
- 7 payloads belong to the bounded relational residue.

The 354 apparent recovery opportunities total 445,063,249 bytes (approximately
0.414 GiB). This audit recovered nothing and authorized no mutation.

## Structures Inspected

### Donor

The path supplied in the task contains an extra literal `:` directory. The
actual donor root is:

```text
/Volumes/WD_ELEMENTS/DO_NOT_LOSE/iMessages_backup/:
```

Inspected read-only:

```text
chat.db
chat.db-wal
chat.db-shm
Attachments-2026-03-29/
```

The attachment tree contains 33,229 files and occupies 43,144,572 KiB
(approximately 41.15 GiB). No other historical Messages archive was inspected.

### Current production

Current configuration and the production cutover record resolve the production
root to:

```text
~/Library/Application Support/com.bigbenchsoftware.MessageLens
```

Inspected read-only:

```text
macos_import_ss.db
working_ss.db
user_overlays.db
attachment_archive/
```

The current production stores contain:

| Structure | Count |
|---|---:|
| live-source import messages | 136,922 |
| live-source import attachments | 40,000 |
| live-source import message/attachment joins | 39,380 |
| live-source graph messages | 136,922 |
| live-source graph attachments | 40,000 |
| overlay archived-attachment rows | 33,398 |

## Safety And Snapshot Limitation

All quantitative queries used SQLite URI
`mode=ro&immutable=1`. The audit did not write production or donor database
content, donor payloads, or production archive payloads.

The installed production MessageLens process was already running during the
first pass and independently advanced its import and graph stores by three
messages. After those files remained stable for an eight-second observation
window, all decisive bridge and coverage counts were repeated. The match,
residue, archive-coverage, and recovery-opportunity results were unchanged; the
table above records the final stable message count. This is a point-in-time
audit of a live production archive, not an offline snapshot.

An initial schema-only probe used SQLite `mode=ro`. Although database and WAL
content remained unchanged, SQLite updated the donor `chat.db-shm` coordination
sidecar's modification metadata. The audit stopped using that mode immediately;
the sidecar was not restored because doing so would be another mutation.

Immutable SQLite access does not consume the donor's 1,936,432-byte WAL.
Therefore all reported counts describe the checkpointed `chat.db` file, not
any final records present only in that WAL. The measured result is sufficient
to establish feasibility, but a later operation must make its donor snapshot
semantics explicit before recovery begins.

## Exact Relational Bridge

Apple's donor schema supplies:

```text
attachment.ROWID
attachment.guid
attachment.filename
        ^
        |
message_attachment_join.attachment_id
message_attachment_join.message_id
        |
        v
message.ROWID
message.guid
```

Every donor join row has a nonblank message GUID and attachment GUID. Both GUID
columns are unique in the donor, and their current counterparts are unique in
the relevant live-source stores.

The current bridge is:

```text
donor message.guid
    -> working_ss.messages.guid where source_id(ss_id) = 1
    -> current message_ss_id

donor attachment.guid
    -> macos_import_ss.attachments.guid where source_id = 1
    -> current attachment_ss_id

(current message_ss_id, current attachment_ss_id)
    -> working_ss.message_to_attachment
    -> topology-confirmed direct match
```

Source `1` is the declared live `chat.db` source. Its canonical source-scoped
identity packs the source and source-local row identity as:

```text
ss_id = (source_id << 43) | source_rowid
```

The historical rowids are useful evidence but are not required for matching.
`GraphCrossSnapshotMapper` correctly uses message GUID and attachment GUID,
then confirms the resulting pair in graph topology.

For archive compatibility, the current attachment `ss_id` is decoded back to
its live-source attachment rowid. The persisted overlay key remains:

```text
(message_guid, import_attachment_id)
```

where `import_attachment_id` currently means the live Apple attachment rowid.

## Sample Proof

A privacy-minimized archived sample demonstrated the complete chain:

```text
donor message ROWID       14
donor attachment ROWID    2
message GUID suffix       EAF2266F
attachment GUID suffix    EAF2266F
current message_ss_id     8796093022222
current attachment_ss_id  8796093022210
decoded attachment rowid  2
graph topology            present
overlay archive key       present
archive payload           present
```

A second sample demonstrated a recovery opportunity without changing the
matching method:

```text
donor message ROWID       9671
donor attachment ROWID    369
message GUID suffix       6BD3B62C
attachment GUID suffix    6BD3B62C
current message_ss_id     8796093031879
current attachment_ss_id  8796093022577
decoded attachment rowid  369
graph topology            present
overlay archive key       absent
donor payload             present
```

No names, message text, or attachment content were read for sample proof.

## Counts And Match Rate

| Relational result | Pairs |
|---|---:|
| donor pairs | 33,018 |
| current message GUID found | 33,013 |
| current attachment GUID found | 33,011 |
| graph topology-confirmed direct match | 33,011 |
| current message missing | 5 |
| message found, attachment missing | 2 |
| both endpoints found but topology missing | 0 |

Direct relational match rate:

```text
33,011 / 33,018 = 99.9788%
```

For the 30,743 payloads physically found at deterministic standard attachment
paths, 30,736 map directly:

```text
30,736 / 30,743 = 99.9772%
```

## Payload And Archive Coverage

The donor join records divide as follows:

| Donor relationship condition | Pairs |
|---|---:|
| deterministic `~/Library/Messages/Attachments/...` path | 30,775 |
| payload exists at that path | 30,743 |
| payload missing at that path | 32 |
| blank path | 1,918 |
| nonstandard path | 325 |

The nonstandard paths comprise 170 other `~/Library/Messages/...` paths and
155 temporary plugin paths. They are residue, not grounds for heuristic
matching in this recovery slice.

Current archive coverage for the 30,736 mapped, present donor payloads is:

| Current production condition | Payloads |
|---|---:|
| archive metadata and file both present | 30,382 |
| archive metadata absent; apparently recoverable | 354 |
| archive metadata present but file missing | 0 |
| existing donor/archive file-size mismatch | 0 |
| overlay stored-size mismatch with archive file | 0 |

The 354 apparent opportunities are:

| MIME type | Payloads |
|---|---:|
| blank | 196 |
| `image/heic` | 104 |
| `image/jpeg` | 35 |
| `image/png` | 7 |
| `video/quicktime` | 7 |
| `image/gif` | 4 |
| `image/tiff` | 1 |

The blank-MIME payloads have deterministic standard attachment paths and are
relationally mapped, but their user-visible/plugin semantics remain a policy
question. The audit does not silently classify them.

## Residue

### Relational residue

Only seven donor pairs fail direct matching:

- five refer to messages absent from the current live-source graph;
- two refer to attachments absent from the current live-source import ledger;
- none has conflicting current topology.

No fallback matching should be added for seven rows.

### Donor database and filesystem residue

The donor database contains 33,663 attachment rows, of which 33,018 participate
in message/attachment joins. The preserved filesystem contains 2,162 files
without a case-insensitive, Unicode-normalized exact counterpart among the
database's standard attachment paths. This category can include payloads whose
database rows use nonstandard or temporary paths. It is not part of the clean
relational bridge and was not heuristically re-associated.

### Current archive residue

Across the complete current archive:

- 33,398 overlay rows reference 26,128 distinct content-addressed paths;
- every referenced path exists;
- the filesystem contains one file not referenced by an overlay path.

That single current filesystem orphan is outside this donor recovery decision.

### Conflict limits

No mapped existing file differs in size from its donor payload. Full byte-hash
comparison of approximately 41 GiB was deliberately not performed. Future
recovery must retain content-addressed writes, post-copy hash verification, and
explicit handling of any pre-existing destination whose bytes do not verify.

## Existing Recovery Seam

The repository already contains the required architecture:

- `SqliteHistoricalSnapshotReader` reads donor
  `message_attachment_join -> message -> attachment` relationships and resolves
  standard attachment-tree paths.
- `SourceScopedAttachmentSnapshotLookup` resolves attachment GUIDs in the
  source-scoped import ledger.
- `GraphCrossSnapshotMapper` performs the exact GUID-plus-topology bridge proven
  by this audit.
- `OverlayRecoveredAttachmentArchiveWriter` computes SHA-256 content addresses,
  copies regular files, verifies newly copied bytes, and records the existing
  overlay compatibility key without changing message history.
- `DeterministicRecovery` already composes reader, mapper, writer, and archive
  mutation coordination.

The matching architecture does not need redesign. Before it is used against
this preservation donor, its source-opening contract must be made safe for a
donor with WAL/SHM sidecars, and its candidate set must be reviewable without
invoking the writer.

## Smallest Next Implementation Step

Add a **read-only recovery-plan operation** around the existing snapshot reader
and mapper that:

1. opens an explicitly immutable donor snapshot without touching WAL/SHM;
2. emits only topology-confirmed donor payloads whose overlay archive key is
   absent;
3. reports the candidate count, total bytes, MIME breakdown, and seven-row
   residue;
4. invokes no archive writer; and
5. requires explicit review before any later mutation operation.

For the checkpointed March donor, that plan should reproduce the 354-candidate,
445,063,249-byte recovery opportunity measured here. The subsequent copy can
then be a separately authorized bounded operation using the existing
content-addressed writer.
