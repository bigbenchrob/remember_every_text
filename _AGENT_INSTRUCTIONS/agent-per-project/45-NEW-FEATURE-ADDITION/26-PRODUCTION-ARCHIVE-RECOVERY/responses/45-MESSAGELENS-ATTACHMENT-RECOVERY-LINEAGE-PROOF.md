---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-21
source_of_truth: implementation-record
links:
  - ../prompts/44-MESSAGELENS-ATTACHMENT-RECOVERY-LINEAGE-PROOF.MD
  - ./44-MESSAGELENS-DATA-FOLDER-HISTORICAL-ARCHIVES-AUDIT.md
  - ../../../10-DATABASES/04-db-chat.md
  - ../../../10-DATABASES/00-all-databases-accessed.md
  - ../../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
---

# MessageLens Attachment-Recovery Lineage Proof

> **Promotion note (2026-08-21):** The proof established here is now owned by
> the shared Historical Archives/source-scoped-import boundary and gates the
> Mac Messages arm. See
> [Shared Historical Archives Messages Lineage Admission](46-SHARED-HISTORICAL-ARCHIVES-MESSAGES-LINEAGE-ADMISSION.md).

## Result

MessageLens now has a dormant, schema-free, read-only admission gate for one
narrow future operation:

> Recover missing attachment payloads from a MessageLens archive made from an
> earlier snapshot of the same continuing local Mac Messages `chat.db`
> lineage.

The gate does not enable the MessageLens Historical Archives arm. It does not
copy attachments, register a donor, import messages, import graph facts, merge
overlays, or reconstruct the donor's source ancestry.

The implementation compares every usable donor live-source
`message.ROWID <-> GUID` pair whose ROWID still exists in the authoritative
current `chat.db`. It returns one typed result:

- `sameLineage`;
- `contradictoryLineage`; or
- `insufficientEvidence`.

One same-ROWID/different-nonempty-GUID pair is a contradiction. Contradiction
always rejects the donor. A donor is admitted only after at least 64 exact
matches distributed across at least three of four ROWID bands, with no
contradiction and no internally inconsistent packed identity. All other cases
fail closed as insufficient evidence.

## 1. Narrowed Product Contract

The broader MessageLens data-folder audit remains useful design history, but
its general archive-federation and source-fact-import assumptions are not the
current product contract.

The supported recovery model is now:

```text
MessageLens donor archive
    -> read marker and donor live-source identity evidence
    -> prove same continuing local chat.db lineage
    -> inspect donor attachment preservation metadata and payloads
    -> prove each candidate belongs to the same current logical message
    -> only then consider copying a missing payload
```

The donor is an unsplittable attachment-recovery source. Its internal B/B1/B2
/B3 source history may be inspected diagnostically, but it is not imported,
registered, remapped, or reconstructed. Because donor messages are never
imported, overlapping donors cannot create duplicate message text or graph
facts.

## 2. Source-Scoped Identity Is Exactly Reversible

`SourceScopedRowKey` uses one bounded 63-bit SQLite integer:

```text
packed ss_id = (sourceId << 43) | sourceRowId
```

The bounds are:

```text
sourceId:    1 .. 1,048,575       (20 bits)
sourceRowId: 1 .. 8,796,093,022,207 (43 bits)
maximum packed value: 2^63 - 1
```

The exact inverse is:

```text
sourceId    = ss_id >> 43
sourceRowId = ss_id & ((1 << 43) - 1)
```

This is packing, not hashing. Within the documented bounds it is lossless and
collision-free. The same rule applies to every source kind; source kind does
not change the packing scheme.

The source-scoped ledger also stores `source_id` and `source_rowid` separately
beside `ss_id`. The lineage reader verifies that all three representations
agree before using a donor row as evidence. The inspected disposable staging
ledger contained zero mismatches across its message rows.

Focused tests now round-trip realistic row IDs, the maximum 43-bit row ID, all
current source classes represented by source IDs 1-3, and the maximum 20-bit
source ID. The maximum packed value is verified as SQLite's positive signed
64-bit maximum.

## 3. What ROWID Stability Does And Does Not Mean

### Structural evidence

The inspected 2012 donor declares:

```sql
CREATE TABLE message (
  ROWID INTEGER PRIMARY KEY AUTOINCREMENT,
  guid TEXT UNIQUE NOT NULL,
  ...
)
```

`PRAGMA table_info(message)` confirms that `ROWID` is the integer primary-key
column. SQLite documents that an `INTEGER PRIMARY KEY` is an alias for the
underlying rowid and that `VACUUM` may renumber only tables without an explicit
integer primary key. `AUTOINCREMENT` additionally prevents automatic reuse of
previously committed row IDs within the same table and database.

Primary references:

- <https://sqlite.org/rowidtable.html>
- <https://www.sqlite.org/autoinc.html>
- <https://www.sqlite.org/lang_vacuum.html>

The source importer reads `message.ROWID` directly and preserves it as both
`source_rowid` and part of `ss_id`. Existing join tables also refer to the same
source-local message ROWID.

### Supported stable lineage

ROWID can be trusted as a local continuity coordinate when all of the
following are true:

- the donor is an earlier snapshot of the same local Mac `chat.db` file
  lineage;
- Apple retained the explicit integer-primary-key `message` schema;
- the message row was updated in place or left unchanged;
- the row was not explicitly deleted and recreated with a different key; and
- the database was not reconstructed, exported/reloaded, or replaced by a
  different device's replica.

Ordinary updates to delivery state, read state, reactions, edits, payload
metadata, or other mutable columns do not change the primary key. `VACUUM`
does not renumber this explicit integer primary key. Deletion may make an old
row absent from the current database; absence is therefore not treated as a
contradiction.

### Unsupported or uncertain lineage

Automatic recovery is not authorized merely because a folder looks familiar.
The following remain unsupported unless the exact evidence gate independently
proves enough continuity:

- another Mac, iPhone, or iPad database;
- an iCloud-synchronized replica with independently allocated local ROWIDs;
- a database reconstructed from export, dump/reload, or sync replacement;
- a migration that rebuilt `message` without preserving primary keys;
- a foreign MessageLens archive with the same display name or path; and
- a donor with too few surviving comparable messages.

The current live `chat.db` could not be inspected directly from the Codex
process because macOS TCC denied access even through immutable read-only
SQLite. That limitation is recorded rather than disguised. The safety of the
gate does not depend on assuming the current database retained particular
rows: it compares the actual current ROWID/GUID facts at runtime and fails
closed if reconstruction has destroyed or contradicted continuity.

## 4. Exact Ear-Tag Algorithm

The reader considers only the donor source whose registry kind is
`live_chat_db`. Historical sources previously added to the donor are ignored;
they are donor ancestry diagnostics, not recovery identities.

The exact algorithm is:

```text
read donor source_registry
    -> require exactly one live_chat_db source

read every message for that donor source
    -> verify ss_id unpacks to stored source_id + source_rowid
    -> require a nonempty donor GUID for an anchor

read current chat.db message rows across the donor ROWID range

for each usable donor anchor
    current ROWID absent
        -> missing evidence

    current ROWID present but current GUID absent
        -> unusable evidence

    current ROWID present and GUID equal
        -> exact match

    current ROWID present and GUID different
        -> contradiction
```

The repository compares all overlapping records. It does not stop after a
sample and does not search for a donor GUID at another ROWID. Coincidentally
shared GUIDs at different ROWIDs therefore provide no lineage authority.

### Admission rules

`contradictoryLineage`:

- one or more same-ROWID/different-nonempty-GUID contradictions.

`sameLineage`:

- exactly one donor `live_chat_db` source;
- no contradiction;
- no donor packed-ID inconsistency;
- no duplicate donor source ROWID;
- at least 64 exact matching anchors; and
- matches occupy at least three of four deterministic donor ROWID bands.

`insufficientEvidence`:

- every other result, including too few surviving rows, malformed donor
  identity evidence, no donor live source, or matches concentrated too
  narrowly.

The 64-anchor requirement is not a sampling count. All overlap is still
checked. It prevents one or a handful of coincidental shared records from
authorizing recovery. The band requirement ensures the proof is distributed
through the donor's local row-ID history rather than clustered at one edge.

There is no "probably okay" result.

## 5. Typed Evidence

`MessageLensArchiveLineageEvidence` records:

- method version (`exact-rowid-guid-v1`);
- donor registered-source and live-source counts;
- donor message and usable-identity counts;
- blank donor GUID count;
- inconsistent packed-identity and duplicate ROWID counts;
- current rows observed in the donor range;
- comparable, matching, and contradictory counts;
- donor rows missing from current;
- current rows with unusable GUID evidence; and
- number of matching ROWID bands.

Presentation must consume these facts as typed data. It must not parse a
diagnostic string to decide admission.

## 6. Archive Identity Is A Separate Question

`archiveInstanceId` answers:

> Which MessageLens archive snapshot/source is this?

The ROWID/GUID ear tag answers:

> Was this archive's live-source data derived from the same continuing local
> Mac Messages database lineage as the current installation?

Neither answer substitutes for the other. A valid or familiar archive marker
does not prove Messages lineage. A copied donor at a new path retains the same
lineage evidence. Display labels, folder basenames, mount points, and path
similarity have no admission authority.

No lineage evidence is persisted in this slice. Existing metadata has no clean
typed home for it. A future durable recovery-source record should keep at least:

- MessageLens attachment-recovery source kind;
- donor `archiveInstanceId`;
- canonical donor archive identity;
- lineage method version and typed terminal result;
- evidence counts or a durable evidence receipt;
- admission time; and
- donor locator as non-identity metadata.

That is a future schema decision and was not smuggled into this implementation.

## 7. Future Per-Message Recovery Invariant

Archive admission is necessary but not sufficient. Every future payload
candidate must independently satisfy:

```text
donor attachment relationship
    -> donor live-source message source_rowid
    -> donor message GUID
    -> current chat.db has the same ROWID
    -> current message has the same GUID
    -> attachment identity and metadata satisfy the recovery contract
    -> payload bytes/hash satisfy preservation checks
    -> only then may a missing payload be copied
```

An archive-level pass must never turn later attachment matching into a loose
GUID-only or ROWID-only operation.

## 8. Threat Model Results

| Donor condition | Result |
| --- | --- |
| Same local lineage, moved or remounted path | Path has no authority; exact evidence may admit |
| Same ROWIDs, different GUIDs | Immediate contradiction and rejection |
| Some shared GUIDs at different ROWIDs | No matches from those GUIDs; contradiction or insufficient evidence |
| Same folder/display name | No effect |
| Same archive instance ID but foreign Messages history | Marker cannot admit; contradiction or insufficient evidence |
| Very small donor or heavily deleted overlap | Insufficient evidence |
| Internally inconsistent donor `ss_id` | Insufficient evidence |
| Donor containing historical source B1/B2/B3 | Those sources are ignored for lineage admission |

## 9. Read-Only Access And Ownership

The implementation lives in Attachments because it exists solely to protect
future attachment recovery. Settings/Historical Archives may later compose and
present it, but Settings does not own the lineage rule.

The infrastructure repository uses the existing `SourceDatabaseOpener` port
for both databases. The current database path is fixed when the verifier is
composed; `verifyDonor(...)` accepts only the donor import-ledger path. Future
application composition must obtain the current path from
`pathsHelperProvider -> PathsHelper.chatDBPath`. A selected folder, persisted
historical path, or display payload must never replace it.

The source opener creates isolated read-only handles, enables
`PRAGMA query_only`, applies the bounded busy timeout, and closes both handles
in a `finally` boundary. No new raw SQLite access path was added.

The donor must already have passed MessageLens archive qualification and
coherent-snapshot inspection. If a donor format or unresolved WAL cannot be
opened safely through the read-only source boundary, qualification must fail;
the lineage verifier does not migrate or normalize the donor.

## 10. Performance

The disposable staging ledger contained:

```text
source 1 live_chat_db: 137,258 messages
source 3 historical archive: 8,882 messages
packed identity mismatches: 0
```

An immutable read-only ordered scan of all 137,258 source-1 ROWID/GUID pairs
took approximately 0.08 seconds on this Mac. Current-side access is a range
scan over `message.ROWID`, an integer primary-key lookup path. Dart must also
materialize and compare the rows, so end-to-end time will be higher, but the
observed scale is comfortably compatible with folder qualification measured
in hundreds of milliseconds or a few seconds.

Exact comparison is therefore preferred. Sampling would weaken the proof
without solving an observed performance problem.

## 11. UX Recommendation

The future MessageLens arm should remain disabled until the rest of attachment
recovery is designed. Its eventual qualification flow can be:

```text
choose MessageLens folder
    -> qualify marker and coherent read-only stores
    -> verify same Messages lineage
    -> contradictory: modal, then hub
    -> insufficient: modal, then hub
    -> same lineage: inspect recoverable attachments
```

Human copy should explain the result without exposing ROWIDs or GUIDs:

- contradictory: "This MessageLens folder belongs to a different Messages
  history and can't be used for attachment recovery."
- insufficient: "I couldn't verify that this folder came from the same
  Messages history."

## 12. Tests And Tripwires

Focused tests now prove:

- source-scoped IDs round-trip exactly at realistic and maximum bounds;
- exact same-lineage comparison;
- foreign donor rejection for same ROWIDs/different GUIDs;
- shared GUIDs at different ROWIDs do not prove lineage;
- insufficient overlap fails closed;
- copied/renamed donor paths do not alter evidence;
- inconsistent packed donor identity cannot authorize recovery;
- donor historical-source ancestry is ignored; and
- the authoritative current path is fixed at verifier composition rather than
  supplied per folder-selection call.

The architecture suite also protects the dormant seam:

- the repository uses canonical source-scoping unpacking;
- it compares ROWID and GUID;
- it does not query source labels or source keys as lineage evidence;
- it does not accept `archiveInstanceId` as lineage evidence;
- it depends on `SourceDatabaseOpener`, not a new SQLite path;
- it imports no ledger writer or attachment archive writer; and
- the typed contract states that every future payload still needs its own
  identity proof.

## 13. Remaining Work

This slice makes it safe to design attachment matching. It does not yet make
payload recovery executable.

Before copying can be enabled, later slices still need:

1. read-only MessageLens donor marker/store qualification;
2. durable recovery-source admission metadata and operation receipts;
3. donor attachment metadata and payload inventory;
4. source-aware per-message and per-attachment matching;
5. hash/length verification and collision policy;
6. preservation-safe copy and metadata commit ordering;
7. restart/retry and removal semantics; and
8. the disabled MessageLens UI arm and truthful progress presentation.

No production, staging, donor, graph, overlay, source registry, archive marker,
or attachment payload was mutated by this work.
