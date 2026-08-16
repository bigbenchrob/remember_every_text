---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-16
source_of_truth: audit
links:
  - 00-START-HERE.md
  - 02-MARCH-2026-RECOVERY-MANIFEST-AND-CLOSURE.md
  - ../../50-ENVIRONMENT-SAFETY/00-overview.md
  - ../../55-READERS-INTEGRATORS-ORCHESTRATORS/82-SOURCE-SCOPED-ARCHIVE-IMPORT-CUTOVER-PLAN.md
tests: []
---

# Historical Messages 2012-2016 Ingestion Audit

## Conclusion

The existing source-scoped Historical Archives path is the correct ingestion
architecture for this donor. A new importer is not justified.

The folder named `Messages_2012` contains 8,882 messages from July 25, 2012
through June 11, 2017. It therefore contains the expected 2012-2016 history
and also extends into 2017. Of its 8,882 message GUIDs:

- 6,513 already occur in the current live-source graph; and
- 2,369 are absent from the current live-source graph.

All 1,352 messages from 2012 and 2013 are absent from the current live source.
The current importer will nevertheless preserve all 8,882 donor occurrences
under a separate source identity. It intentionally does not deduplicate the
6,513 overlapping GUIDs against live-source rows.

The next operation should be one staging-clone rehearsal. No ingestion or copy
was performed during this audit.

## Scope And Naming Correction

The supplied donor path is:

```text
/Volumes/WD_ELEMENTS/Old_Messages/Messages_2012
```

The task text later calls it `Messages_2016`. No such nested or sibling input
was found within the supplied folder. This audit uses the actual
`Messages_2012` path and reports dates from its database rather than inferring
them from either label.

The current production MessageLens root inspected read-only was:

```text
/Users/rob/Library/Application Support/com.bigbenchsoftware.MessageLens
```

## Donor Inventory

Top-level structure:

```text
Messages_2012/
  chat.db
  chat.db-wal
  chat.db-shm
  Attachments/
  messages_export.csv
  simple_select.sql
```

| Item | Evidence |
|---|---:|
| complete donor folder | approximately 535 MiB |
| `chat.db` | 8,364,032 bytes |
| `chat.db-wal` | 0 bytes |
| `chat.db-shm` | 32,768 bytes |
| non-`.DS_Store` attachment-tree files | 777 |
| attachment-tree payload bytes | 549,860,436 |
| `messages_export.csv` | 805,353 bytes |
| `simple_select.sql` | 170 bytes |

`messages_export.csv` and `simple_select.sql` are export/helper artifacts.
They are not ingestion authority. `chat.db` is the relational authority.

Immutable SQLite `quick_check` returned `ok`. The checkpointed database reports
`journal_mode=delete`. Its WAL is empty, so there are no donor records waiting
only in WAL. The existing 32 KiB SHM is not authoritative for this snapshot.

Read-only audit digest:

```text
chat.db SHA-256
b6180dd4511fe0b345e2dae2bc6adb7baabf8354d3521eb9ebd69ab849a5a174
```

All donor database inspection used SQLite URI
`mode=ro&immutable=1`. Donor database and sidecar timestamps remained
unchanged.

## Historical Coverage

| Donor structure | Count |
|---|---:|
| messages | 8,882 |
| distinct nonblank message GUIDs | 8,882 |
| duplicate message GUIDs within donor | 0 |
| chats | 86 |
| handles | 77 |
| chat/message joins | 8,889 |
| chat/handle joins | 104 |
| attachment rows | 773 |
| message/attachment joins | 808 |

Message range:

```text
earliest: 2012-07-25 17:16:22 UTC
latest:   2017-06-11 16:11:27 UTC
```

| Year | Donor messages | Exact GUID overlap with live source |
|---|---:|---:|
| 2012 | 493 | 0 |
| 2013 | 859 | 0 |
| 2014 | 47 | 40 |
| 2015 | 1,601 | 1,288 |
| 2016 | 3,667 | 3,121 |
| 2017 | 2,215 | 2,064 |
| **Total** | **8,882** | **6,513** |

The current live-source graph begins on January 1, 2014. Chronological overlap
therefore covers 7,530 donor rows, while exact GUID overlap accounts for 6,513
rows. GUID overlap is the stronger identity comparison.

## Existing Ingestion Path

The current production path is:

```text
Historical Archives Settings workflow
  -> ArchiveMutationCoordinator.historicalArchiveImport
  -> SourceScopedArchiveGraphImportService.importAndProject(...)
  -> SourceScopedArchiveImportService.importSourceFacts(...)
  -> HistoricalMessagesArchiveSourceRegistrar
  -> source-scoped importers
  -> full idempotent graph projectors
  -> messageDataVersion refresh
```

Principal components:

- `HistoricalArchivesWorkflowPanelModel` protects the live `chat.db` path,
  enters the archive mutation coordinator, invokes import/projection, records
  source metadata, and refreshes evidence surfaces.
- `HistoricalMessagesArchiveSourceRegistrar` resolves the selected folder and
  registers or reuses a source with kind
  `historical_messages_archive`.
- `SourceScopedArchiveImportService` reuses the existing handle, chat, message,
  attachment, relationship, and rich-text importers.
- `SourceScopedArchiveGraphImportService` runs the existing full graph
  projectors after source import.

The current production import ledger contains only source IDs `1` and `2`:

```text
1  live_chat_db
2  live_address_book
```

Against a disposable clone of this exact state, registration would allocate
source ID `3` and a deterministic source key based on the selected `chat.db`
path. Imported row identity is:

```text
ss_id = (source_id << 43) | source_rowid
```

The donor's largest relevant rowid is 8,884, comfortably within the supported
43-bit source-row range.

## Effects On Existing Production-Shaped Data

The import operation appends source `3` facts to `macos_import_ss.db`. Full
projectors then insert or update graph rows by source-scoped `ss_id` in
`working_ss.db`. They do not reset or replace source `1` rows.

The operation does not import contacts, reset the import ledger, rebuild the
archive from scratch, or write user intent into graph stores. Overlay remains
the owner of user intent. The workflow writes only its expected Historical
Archives preflight, failure, or success status record to `overlay_settings`.

The historical path imports attachment **metadata** and
message/attachment topology because those are part of the source fact model.
It does not copy historical attachment payloads into `attachment_archive/` and
does not call an attachment archive writer. The `Attachments/` directory is
not required to recover the old message history in this first operation.

Historical payload recovery is therefore outside this rehearsal. The current
production attachment archive must remain byte-for-byte unchanged.

## Overlap Semantics

GUID is evidence, not canonical occurrence identity. The source-scoped schema
deliberately permits the same Apple GUID in multiple sources:

```text
live occurrence
  ss_id = pack(1, live rowid)

historical occurrence
  ss_id = pack(3, historical rowid)
```

Consequently, the rehearsal is expected to import and project all 8,882 donor
messages, not only the 2,369 GUIDs absent from live data. The 6,513 overlapping
GUIDs become separate graph rows. Existing architecture tests explicitly
protect this behavior.

This is not an importer defect, but it is an important product observation:
the staging rehearsal must inspect whether ordinary MessageLens evidence
surfaces present overlapping occurrences acceptably. Promotion must not be
considered until that is understood.

## Source-Preservation Caveat

The architecture is source-read-only, but its runtime opening mechanisms are
not currently immutable SQLite openers:

- `ArchiveSourceInspectionRepository` uses `sqlite3.open(...,
  OpenMode.readOnly)`; and
- `SqfliteSourceDatabaseOpener` uses `openDatabase(..., readOnly: true)`.

For this donor, `journal_mode=delete` and the WAL is empty, so no WAL
reconciliation is required. Nevertheless, a preservation rehearsal should not
expose the original donor's sidecars to a runtime opener that is merely
read-only.

The smallest no-code safety measure is to create a byte-identical disposable
source-input folder containing only the checkpointed `chat.db`, verify it
against the digest above, and make that copied input read-only. MessageLens can
then exercise its existing importer against the copy while the original donor
remains untouched. This is a rehearsal input, not a new importer and not a
replacement preservation archive.

## Exact Staging-Clone Rehearsal

This procedure is a plan only. It was not executed.

### 1. Establish offline inputs

1. Finish the separately managed production checkpoint with MessageLens
   stopped.
2. Verify that checkpoint with `tool/archive_checkpoint.dart`.
3. Record the production checkpoint manifest and its hashes.
4. Create a byte-identical disposable source input containing donor
   `chat.db` only. Verify its SHA-256 equals the digest above, omit WAL/SHM,
   and make the copied file and containing directory read-only.
5. Do not modify the original `Messages_2012` folder.

### 2. Restore a disposable production-shaped clone

Use an absent destination such as:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/
  MessageLens Historical Ingestion Rehearsal
```

Restore and verify the completed checkpoint into that destination:

```text
dart run tool/archive_checkpoint.dart restore-verify \
  --checkpoint <completed-production-checkpoint> \
  --restore "/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Historical Ingestion Rehearsal"
```

The restored clone initially carries the production marker copied from the
checkpoint. Preserve that marker with the rehearsal evidence, then replace
**only the disposable clone's marker** with a fresh format-v1 development
marker and archive instance ID. Do not alter the production marker or any
production payload. Verify the clone marker says `development` before launch.

This is an explicit one-off reclassification of a disposable clone. It must
not be presented as general marker migration or applied to production.

### 3. Point only MessageLens Development at the clone

Launch the Debug development identity with exactly:

```text
MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT="/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Historical Ingestion Rehearsal" \
  flutter run -d macos
```

Before selecting a source, confirm from admitted archive diagnostics that:

- bundle ID is `com.bigbenchsoftware.MessageLens.development`;
- environment is `development`;
- canonical archive root is the rehearsal root; and
- archive instance ID is the rehearsal marker's new identity.

The safety mechanism is structural, not mnemonic. The development identity
cannot admit the production marker, and the configured development override
cannot be used by a production build. If native claim, Dart canonicalization,
root, marker, or environment disagree, startup fails closed.

Do not use the ordinary editor launch item, which currently points to the
normal external development archive. Do not launch the production app for the
rehearsal.

### 4. Establish the clone baseline

Allow any normal live-source catch-up in the clone to finish first, then record
baseline counts and hashes. At the audit point, production-shaped source `1`
contained:

| Store | Source-1 messages | Source-1 attachments |
|---|---:|---:|
| source-scoped import | 136,938 | 40,001 |
| conversation graph | 136,938 | 40,001 |

The rehearsal must use its own post-catch-up baseline rather than treating
these live audit counts as frozen expectations.

Capture:

- all source-registry and source-1 table counts;
- source-1 GUID/date summaries;
- graph table counts by source;
- a complete Overlay table count/hash inventory;
- the checkpoint manifest for `attachment_archive/`; and
- the clone's archive marker and database integrity results.

### 5. Run the existing historical import

In Settings > Historical Archives:

1. select the disposable read-only donor-input folder;
2. confirm preflight reports 8,882 messages, 86 chats, 77 handles, zero
   missing message GUIDs, and the 2012-07-25 through 2017-06-11 range;
3. confirm the dry run reports 6,513 already represented GUIDs and 2,369 new
   GUIDs against the baseline graph;
4. invoke the existing Begin Import action once; and
5. wait for import, full graph projection, and evidence refresh to complete.

No attachment recovery action is part of this operation.

### 6. Verify the result

Expected source `3` import facts are:

| Fact | Expected count |
|---|---:|
| messages | 8,882 |
| chats | 86 |
| handles | 77 |
| attachments | 773 |
| chat/message edges | 8,889 |
| chat/handle edges | 104 |
| message/attachment edges | 808 |

Verify all of the following:

1. Source `1` rows and content identities equal the post-catch-up baseline.
2. Source `3` is registered once as `historical_messages_archive`.
3. Import and graph contain the expected source `3` facts and topology.
4. The 493 messages from 2012 and 859 messages from 2013 are visible on
   ordinary MessageLens evidence surfaces.
5. All 8,882 source `3` messages exist, including 6,513 GUID-overlap rows with
   distinct source-scoped identities.
6. The production-shaped `attachment_archive/` manifest is unchanged.
7. Existing Overlay/user-intent rows and values are unchanged, except for the
   expected Historical Archives source metadata setting.
8. SQLite integrity checks pass after the operation.
9. Restarting MessageLens Development against the same explicit rehearsal
   root preserves source `3` and old-message visibility.
10. A later live-source catch-up can append source `1` facts without changing
    or replacing source `3`.

Inspect duplicate-looking messages directly before considering any later
production operation.

## Promotion Boundary

A successful staging rehearsal does not authorize replacing the live
production archive with the clone. Production may advance while rehearsal is
underway, and the clone deliberately has a development marker and different
archive instance identity.

The safest eventual production operation would be a separately authorized
repeat of the proven historical import against then-current production after
a fresh offline production checkpoint, not wholesale promotion of a stale
development clone. That later decision remains outside this audit.

## Recommended Next Operation

> After the separately managed production checkpoint is complete, perform one
> staging-clone rehearsal exactly as described above: restore to a new
> disposable root, reclassify only that clone for development admission, use a
> verified read-only copy of the donor `chat.db`, run the existing Historical
> Archives import once, and verify source isolation, old-message visibility,
> overlap presentation, Overlay preservation, attachment-archive immutability,
> restart, and subsequent live-source catch-up.

Do not ingest into production before that rehearsal is reviewed.
