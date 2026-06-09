---
tier: project
scope: source-scoped-graph-migration
status: active
last_reviewed: 2026-05-31
depends_on:
  - 70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md
  - 71-LEGACY-DEPENDENCY-MATRIX.md
  - 73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md
  - ../25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md
  - ../25-ONBOARDING-AND-ARCHIVE/50-deterministic-recovery.md
---

# 75 - Archive and Recovery Identity Plan

## Purpose

This document starts Slice 7 of the graph migration.

The goal is to move attachment archive and recovered-message systems toward
source-scoped identity without disrupting existing archived files, historical
recovery results, or evidence visibility.

This is a high-risk data-integrity area. Existing archive records are evidence
state, not disposable cache.

## Current Architecture Summary

The source-scoped graph now owns ordinary app-facing message and attachment
evidence:

```text
macos_import_ss.db.attachments
macos_import_ss.db.message_to_attachment
  -> working_ss.db.attachments
  -> working_ss.db.message_to_attachment
  -> graph message evidence rows
```

Graph attachment identity is:

```text
attachment_ss_id = SourceScopedRowKey.pack(source_id, source_attachment_rowid)
message_ss_id    = SourceScopedRowKey.pack(source_id, source_message_rowid)
```

The archive/recovery system still has legacy-era identity:

```text
archived_attachments(
  message_guid,
  import_attachment_id,
  archive_relative_path,
  ...
)
```

`import_attachment_id` currently means the live `chat.db.attachment.ROWID`.
Graph-era archive lookup derives that value from source-scoped attachment
identity while the overlay archive row key remains legacy-compatible.

Deterministic historical recovery now maps:

```text
historical chat.db attachment.guid
  -> current macos_import_ss.db attachment/message facts
  -> current working_ss.db message/attachment topology
  -> message_ss_id + attachment_ss_id
  -> overlay archived_attachments(message_guid, import_attachment_id)
```

Recovered deleted messages are graph-orphan evidence: source-retained
`working_ss.messages` rows without current `chat_to_message` topology are
rendered through the shared Message Evidence Spine. Legacy recovered tables
remain historical storage until broader legacy database retirement.

## Hard Invariants

1. Existing archived files and `archived_attachments` rows must remain
   resolvable.
2. Recovery must never mutate historical snapshot databases.
3. Recovery must never write structural source facts into overlay.
4. Overlay remains user/evidence state only.
5. Import and projection must not consult overlay.
6. Graph ordinary evidence must remain source-scoped and occurrence-preserving.
7. Missing attachment files are rendered as evidence states, never suppressed.
8. No heuristic recovery matching may be reintroduced.
9. GUIDs may remain bridge metadata, but must not become canonical graph
   identity.
10. Recovery migration must be additive and reversible until verified.

## Identity Forms in Play

| Identity form | Current owner | Current purpose | Graph-era role |
| --- | --- | --- | --- |
| `message_guid` | Apple source / import metadata | Archive overlay key, recovered-message bridge | Metadata and compatibility bridge only |
| `attachment.guid` | Apple source / import metadata | Deterministic historical recovery primary match | Source fact used for recovery matching |
| `import_attachment_id` | Legacy import/working identity | Archive overlay key | Compatibility bridge to `attachment_ss_id` |
| `message_ss_id` | Source-scoped graph | Canonical message row identity | Canonical evidence endpoint |
| `attachment_ss_id` | Source-scoped graph | Canonical attachment row identity | Canonical archive/recovery endpoint |
| archive content hash | Overlay/archive file store | Deduplicated physical file identity | Physical storage identity, not graph identity |
| archive relative path | Overlay/archive file store | Location of archived file | Evidence file locator |

## Target Identity Model

Long term, archive and recovery should resolve through canonical graph identity:

```text
archived attachment evidence
  keyed or bridgeable by:
    message_ss_id
    attachment_ss_id
```

The existing overlay key:

```text
(message_guid, import_attachment_id)
```

must remain readable as a compatibility bridge until all existing archive rows
have either:

- graph identity columns populated, or
- a deterministic read-time bridge to graph identity.

The graph-era archive lookup should prefer:

```text
(message_ss_id, attachment_ss_id)
```

and fall back to:

```text
(message_guid, import_attachment_id)
```

only as an explicit compatibility path.

## Existing Archive Records Strategy

Do not rewrite or delete existing archive rows as the first step.

The first safe move is a read-time bridge:

```text
working_ss.message_to_attachment
  JOIN working_ss.messages
  JOIN working_ss.attachments
  JOIN macos_import_ss.attachments
```

This can derive:

```text
message_ss_id
attachment_ss_id
message_guid
source_attachment_rowid
```

For live source `source_id = 1`, `source_attachment_rowid` is equivalent to the
legacy `import_attachment_id` value used by existing archive rows.

That means most existing archive rows can be resolved without changing the
overlay schema:

```text
overlay.message_guid = graph.messages.guid
overlay.import_attachment_id =
  SourceScopedRowKey.unpackSourceRowId(graph.attachments.ss_id)
```

This bridge is acceptable only because it is named, quarantined, and removal
criteria are explicit.

## Historical MessageLens Archive Source Strategy

The historical MessageLens `attachment_archive` backup is the highest-value
source because it already contains app-owned archived files that were copied
before many Apple evictions.

Graph-era strategy:

1. Treat the backup archive as an archive row/file source, not as source truth.
2. Read its overlay `archived_attachments` rows if available.
3. Map each row through the graph archive bridge:
   - `message_guid`
   - `import_attachment_id`
   - live source id assumption or documented source mapping
4. Copy missing files into the current archive using content-addressed storage.
5. Write current overlay archive rows idempotently.

Open point:

If imported historical archive rows came from a source other than live
`source_id = 1`, the old `(message_guid, import_attachment_id)` key does not
contain enough source scope. The migration must classify those rows before
automatic import.

## Recovered Messages Folder Strategy

A recovered `Messages` folder contains a historical `chat.db` plus matching
`Attachments/` directory.

Graph-era deterministic recovery should map:

```text
historical chat.db.message.guid
historical chat.db.attachment.guid
historical message_attachment_join
```

to:

```text
macos_import_ss.messages.guid
macos_import_ss.attachments.guid
macos_import_ss.message_to_attachment
```

and then to:

```text
working_ss.messages.ss_id
working_ss.attachments.ss_id
working_ss.message_to_attachment
```

The existing deterministic recovery rules still apply:

- GUID match is primary.
- NULL attachment GUID single-attachment fallback is allowed only when both
  historical and current sides have exactly one attachment.
- No filename/path-tail/size/date/string-similarity fallback.

The difference is that the confirmed target identity becomes:

```text
message_ss_id
attachment_ss_id
```

not:

```text
message_guid
import_attachment_id
```

Existing overlay writes may continue to write legacy bridge keys during the
transition, but the graph identity should be computed by the recovery mapper
as soon as practical.

## Recovered Deleted Messages Strategy

Recovered deleted messages are not yet ordinary graph messages because they may
not have live source rows in the current `chat.db`.

Do not force them into `working_ss.messages` until the source model is explicit.

The correct long-term shape is probably:

```text
source_registry:
  live-chat-db
  recovered-messages-folder:<stable-source-id>

macos_import_ss.messages:
  source_id = recovered source id
  source_rowid = historical message ROWID
  ss_id = pack(recovered source id, historical ROWID)

working_ss.messages:
  ss_id preserved
```

Then recovered messages become ordinary graph evidence from an additional
source, not a special legacy table.

Until then, recovered-message evidence may remain a documented
archive/recovery compatibility surface.

## Compatibility Bridges

| Bridge | Owner | Source side | Destination side | Why it exists | Removal condition |
| --- | --- | --- | --- | --- | --- |
| Archive overlay legacy key bridge | Attachment archive/resolver infrastructure | `(message_guid, import_attachment_id)` | `(message_ss_id, attachment_ss_id)` | Existing archive records are keyed by legacy identity. | Overlay rows are graph-keyed or graph lookup can always derive legacy keys from source-scoped graph facts. |
| Deterministic recovery graph mapper | Recovery infrastructure | historical `attachment.guid` + source-scoped graph import/projection DBs | graph attachment identity + overlay archive row | Historical recovery still has to bridge recovered snapshot facts into the current archive overlay key. | Recovered `Messages` folders become source-scoped graph sources, or the mapper remains the bounded historical recovery bridge. |
| Recovered deleted-message provider | Messages recovery infrastructure | graph messages without current `chat_to_message` topology | Message Evidence Spine rows | Recovered sources are not yet first-class graph import sources, so graph-orphan evidence is the production recovery projection. | Recovered `Messages` folders become source-scoped import sources or the graph-orphan recovered subsystem is explicitly preserved. |
| Historical archive settings dry-run | Settings/archive workflow | backup/current legacy archive keys | user-facing readiness counts | Existing workflow estimates against legacy working/import identity. | Dry-run estimates use graph archive bridge and source-scoped import facts. |

## Proposed Migration Sequence

### Step 1 - Graph Archive Identity Resolver Boundary

Add a named infrastructure boundary that can answer:

```text
given message_ss_id + attachment_ss_id,
find archived file metadata
```

It should:

- prefer future graph-keyed archive identity if present
- fall back to existing `(message_guid, import_attachment_id)` overlay rows
- keep all archive lookup policy outside widgets
- return typed evidence/availability data

No schema change is required for this first step.

### Step 2 - Graph-Aware Archive Sweep Inputs

Move archive sweeps from `working.db.attachments` to graph attachment facts:

```text
working_ss.attachments
working_ss.message_to_attachment
macos_import_ss.attachments
macos_import_ss.message_to_attachment
```

The physical source path remains Apple `attachment.filename` /
Messages Attachments path metadata.

This removes ordinary archive maintenance dependence on `working.db` while
preserving current overlay writes.

### Step 3 - Graph Deterministic Recovery Mapper

`GraphCrossSnapshotMapper` replaces the legacy import/working lookup with a
graph mapper:

```text
historical snapshot rows
  -> macos_import_ss attachment/message GUID facts
  -> working_ss message/attachment topology
  -> message_ss_id + attachment_ss_id
```

During transition, it may also compute the legacy overlay key for idempotent
writes.

### Step 4 - Overlay Schema Compatibility Decision

Decide whether to:

1. add nullable `message_ss_id` / `attachment_ss_id` columns to
   `archived_attachments`, or
2. keep overlay schema stable and use a permanent graph archive bridge table or
   resolver.

Do not make this decision before Step 1 and Step 2 prove read/write
compatibility.

### Step 5 - Recovered Deleted Messages as Graph Sources

Design recovered `Messages` folders as source-scoped sources.

This is larger than attachment recovery and should not be bundled with the
archive resolver migration.

## Tests Needed

### Archive Resolver Bridge

- graph attachment with existing legacy archive row resolves to archive file
- graph attachment with no archive row but live file reports pending archive
- graph attachment with missing file reports recoverable unavailable
- duplicate GUIDs across sources do not cross-resolve archive rows
- missing message GUID does not suppress attachment evidence

### Archive Sweep

- graph sweep archives a live file using graph attachment facts
- graph sweep is idempotent against existing legacy-key overlay row
- graph sweep advances cursor without relying on `working.db.attachments.id`
- graph sweep does not write working/import databases

### Deterministic Recovery

- historical attachment GUID maps to `attachment_ss_id`
- NULL GUID single-attachment fallback maps only when unambiguous
- historical row with missing current graph message is reported unmapped
- historical row with mismatched GUID/message topology is reported unmapped
- rerun creates no duplicate archive rows

### Recovered Messages

- current graph-orphan recovered-message evidence remains visible during
  transition
- legacy recovered tables remain historical storage until broader legacy DB
  retirement
- future recovered-source import preserves source-scoped occurrence identity
- recovered messages do not collapse into live-source messages by GUID

## Initial Implementation Boundary

The first implementation slice should not change schemas.

It should create the graph archive identity/read boundary and use it only where
it can replace an existing legacy lookup without changing user-visible behavior.

Recommended first files:

- `lib/features/attachments/application/attachment_resolver_provider.dart`
- `lib/features/attachments/application/attachment_archive_service_provider.dart`
- a new infrastructure/read-model boundary under `lib/features/attachments/`
- focused tests under `test/features/attachments/`

Do not start by rewriting recovered deleted messages.

## Implementation Notes

2026-05-31:

- Added a named graph archive lookup boundary:
  `GraphAttachmentArchiveLookup`.
- Added `OverlayArchiveCompatibilityLookup` as the explicit
  compatibility bridge from graph attachment identity to existing overlay rows.
- The bridge accepts `message_ss_id` and `attachment_ss_id`, verifies graph
  topology, derives the live-source legacy `import_attachment_id` from
  `attachment_ss_id`, and reads the existing
  `(message_guid, import_attachment_id)` archive row.
- The bridge intentionally refuses non-live source ids because the legacy
  archive key does not carry source scope.
- Conversation graph attachment summaries now depend on that named boundary
  instead of embedding archive-key derivation inline.
- Attachment archive rolling/manual sweeps and archive-all candidate selection
  now read graph attachment facts from `working_ss.db` instead of legacy
  `working.db.attachments`.
- Archive writes still use the existing overlay archive row shape and the
  existing `attachment_archive/` folder. Existing archive rows are skipped
  idempotently.
- The legacy import-batch archive path is retired. The current live update
  lifecycle archives newly imported graph/source-scoped live source ranges
  after graph import/projection.
- Deterministic historical attachment recovery now uses
  `GraphCrossSnapshotMapper` to map historical snapshot rows through
  `macos_import_ss.db` and `working_ss.db` instead of legacy
  `macos_import.db` and `working.db`.
- The graph recovery mapper returns `message_ss_id` and `attachment_ss_id`
  while still exposing the live-source attachment ROWID required by the current
  overlay archive row key.
- No overlay schema change was made.
- No archive files were moved, copied, renamed, or deleted.

## Done Means

Slice 7 is complete when:

1. ordinary archive resolution and sweeping no longer require `working.db`.
2. deterministic historical attachment recovery maps to graph identity.
3. existing archive rows remain resolvable.
4. recovered deleted messages are either source-scoped graph sources or
   explicitly preserved as a bounded recovery subsystem.
5. every remaining legacy archive/recovery dependency is documented as either
   retired, migrated, or intentionally retained.
