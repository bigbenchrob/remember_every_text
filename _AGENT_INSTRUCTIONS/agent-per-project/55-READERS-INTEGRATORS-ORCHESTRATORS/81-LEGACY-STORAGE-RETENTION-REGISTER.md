---
tier: project
scope: source-scoped-graph-migration
status: active
last_reviewed: 2026-06-08
depends_on:
  - 71-LEGACY-DEPENDENCY-MATRIX.md
  - 73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md
  - 75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md
  - 80-GRAPH-MIGRATION-INTERIM-PROGRESS-REPORT.md
---

# 81 - Legacy Storage Retention Register

## Purpose

The ordinary MessageLens app path is now graph-backed. Remaining
`macos_import.db` and `working.db` references should therefore be treated as
storage-retention questions, not ordinary UI migration blockers.

This register defines what remains, why it remains, and what must be true
before each retained storage/reference path can be removed.

## Current Decision

Do not delete retained storage/reference files yet.

The retained database files no longer own ordinary evidence, search, contact
identity, conversation browsing, live polling, Historical Archives execution,
or first-run graph setup. They remain only as bounded storage/reference inputs
for archive metadata compatibility, recovered-message comparison, reset, and
support diagnostics.

The safe next stage is:

```text
retain deliberately
→ replace remaining storage/key compatibility paths
→ verify historical data reachability
→ delete or freeze retained storage only as a reviewed storage-retirement slice
```

## Retained Storage Buckets

### 1. Retired Archive-Compatible Import/Projection Execution

**Primary files**

- `lib/essentials/db_importers/application/services/retained_legacy_archive_pipeline_provider.dart`
  (retired 2026-06-07)
- `lib/essentials/db_importers/application/services/orchestrated_ledger_import_service.dart`
  (retired 2026-06-07)
- `lib/essentials/db_importers/application/importers/**`
  (retired 2026-06-07)
- `lib/essentials/db_migrate/application/orchestrator/handles_migration_service.dart`
  (retired 2026-06-07)
- `lib/essentials/db_migrate/application/migrators/**`
  (retired 2026-06-07)
- `lib/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart`
- `lib/essentials/db/infrastructure/data_sources/local/working/working_database.dart`
  (retired 2026-06-08)

**Current status**

Historical archive workflows no longer import older Messages folders through
the retained legacy ledger/projection path. Forward import uses
`SourceScopedArchiveGraphImportService`; removal uses
`SourceScopedArchiveGraphRemovalService`.

This bucket remains listed because retained legacy code/files may still exist
for storage-retirement cleanup, but it is no longer the Historical Archives
execution path. The standalone import-control panel and `ViewSpec.import`
route have been retired.

**Current boundary**

The superseded bridge was explicitly named:

```text
RetainedLegacyArchivePipeline.rebuildLegacyProjectionAndGraph(...)
```

It is not the live-update path, not the ordinary app-facing projection path, and
no longer the Historical Archives import/removal path.

**Removal criteria**

Done means:

- historical archive import can write source facts directly into
  `macos_import_ss.db`.
- archive-derived messages, chats, handles, contacts, attachments, and topology
  project directly into `working_ss.db`.
- source IDs distinguish live source and archive sources.
- deterministic duplicate handling is graph-native and source-scoped.
- retained `macos_import.db` batches are no longer required to make
  archive messages visible.
- retained `working.db` projection is no longer required before graph
  refresh.
- existing historical archive UI either calls the new source-scoped archive
  path or is explicitly retired.

These criteria are now satisfied for Historical Archives import/removal. The
retained archive pipeline provider, old import progress/detail widgets,
old ledger orchestrator, old table-importer stack, old retained projection
orchestrator/migrator stack, and their tests have been removed. Broader deletion
of retained database files, schemas, and diagnostic surfaces must still
follow a separate storage-retirement slice.

### 2. Historical Archive Settings Metadata

**Primary files**

- `lib/features/settings/infrastructure/repositories/historical_archive_sources_repository.dart`
- `lib/features/settings/presentation/view_model/historical_archives_workflow_panel_model_provider.dart`

**Why retained**

The historical archive workflow stores and reads archive-source status in the
retained import database. This is compatibility metadata for user-visible
archive workflow state.

**Current boundary**

Settings code may read this metadata as a quarantined archive workflow bridge.
It must not treat retained import DB metadata as ordinary graph identity.
The retained `SqfliteImportDatabase` wrapper should expose only storage,
metadata, health, and reset support needed by this boundary; obsolete public
helpers for retained import execution, spam filtering, and row-existence
maintenance should be removed as soon as scans confirm no callers.
The old retained batch-ledger deletion API has been removed; Historical
Archives removal now deletes source-scoped archive rows through the graph
archive-removal service.
The generic retained import-DB raw-query wrapper has also been removed.
Callers that need health diagnostics or schema tests should use their own
explicit infrastructure query boundary instead of widening this retained
metadata wrapper.
The unused generic retained import-DB `countRows` helper has also been removed;
row-count diagnostics now belong to the database-health query layer rather than
the archive-source metadata wrapper.
The retained archive batch-count compatibility read has been removed as well.
Historical Archives source management now describes the source-scoped removal
target directly instead of reading old `macos_import.db.import_batches` rows.
Retained archive-source batch ID and import-start timestamp fields have been
removed from the public metadata wrapper. Their old SQLite columns are tolerated
only as existing-file schema compatibility.
Historical Archives workflow presentation no longer imports the retained
database wrapper or provider directly. Read/write access to
`macos_import.db.historical_archive_sources` is quarantined behind
`HistoricalArchiveSourcesRepository`, so presentation state handles archive
workflow semantics while infrastructure owns retained metadata persistence.
Fresh retained import DB creation no longer recreates those old archive-source
metadata columns.
Database health also treats retained `macos_import.db` as archive-source
metadata storage only; active source facts and topology health belong to
`macos_import_ss.db`.
Fresh retained `macos_import.db` creation now creates only
`schema_migrations` and `historical_archive_sources`. Existing older retained
import files may still keep legacy ledger tables for compatibility, but new
files do not recreate `import_batches`, `messages`, `handles`, `chats`,
attachments, or old topology ledgers.

**Removal criteria**

Done means:

- archive-source metadata has a source-scoped home.
- existing archive-source status can be migrated or intentionally discarded.
- the settings workflow no longer reads `macos_import.db` for archive-source
  rows.
- graph preflight/dry-run duplicate estimates remain available.
- removal/import success criteria no longer mention retained projection.

### 3. Reset and Derived-Data Maintenance

**Primary files**

- `lib/essentials/onboarding/application/message_data_reset_service.dart`
- `lib/essentials/onboarding/application/database_existence_checker.dart`

**Why retained**

Reset and startup detection intentionally know about both graph-era derived
databases and retained derived database files. This prevents stale files,
locking problems, or misleading readiness states during the transition.

**Current boundary**

Reset may delete:

- `macos_import.db`
- `working.db`
- `macos_import_ss.db`
- `working_ss.db`

This does not mean the retained databases are app truth. It means reset must
clean all derived data safely.
The central retained `working.db` provider has been removed. Reset still
deletes `working.db`, `working.db-wal`, and `working.db-shm` when present, but
it does not instantiate a retained Drift connection merely to close the file.

**Removal criteria**

Done means:

- retained storage has been retired or declared permanently historical.
- reset behavior no longer needs to close/delete retained DB files.
- startup no longer needs to distinguish legacy-only derived data from
  graph-ready data.
- old data folders are either migrated or explicitly ignored with a clear user
  recovery path.

### 4. Database Health and Support Diagnostics

**Primary files**

- `lib/essentials/db/application/database_health_audit/**`
- support bundle / diagnostic report actions that invoke database health audit

**Why retained**

Diagnostics intentionally inspect both current graph databases and retained
historical/reference databases while the transition is incomplete. This helps
identify stale-data, compatibility, and recovery conditions.

**Current boundary**

Diagnostic reads are allowed to look across layers as long as they do not make
retained storage authoritative for ordinary feature behavior.
Database health now treats retained `working.db` as recovered-message
compatibility storage plus minimal projection-state storage sanity. Ordinary
message/chat/contact/handle/attachment/reaction health belongs to
`working_ss.db`; retained `working.db` ordinal indexes are no longer audited as
timeline infrastructure because graph evidence skeletons own timeline
navigation.
Database health also opens retained `macos_import.db` and `working.db` through
read-only file query layers. It must not instantiate the central retained DB
providers merely to build diagnostics, because doing so could recreate retained
storage as a side effect of a support bundle or health report.
The old provider-backed retained import/working health query adapters have
been removed; retained health diagnostics now have exactly one retained
database access path: read-only file inspection.
Because retained `working.db` no longer has a central app provider, health and
support diagnostics must not reintroduce one for convenience.

**Removal criteria**

Done means:

- retained DB files are gone or classified as permanent historical storage.
- health audit labels no longer need to inventory retained storage layers.
- support bundles still expose enough graph/import/overlay evidence to debug
  data issues.

### 5. Retained Schema and Migrator Tests

**Primary files**

- `test/essentials/db/infrastructure/data_sources/local/import/**`
- retained tests for active `db_importers/**` monitor/extractor behavior

**Why retained**

Tests should remain as long as the corresponding retained compatibility code
remains. The old table-importer tests were removed with the old table-importer
execution stack, and retained `db_migrate` tests were removed with the retained
projection orchestrator/migrator stack. The remaining `db_importers` tests
protect active graph-era monitor/extractor behavior, not retained ledger import
execution.

The old retained `working.db` ordinal-index rebuild and trigger-maintenance
tests were also removed after the graph Message Evidence Spine took over
timeline skeletons and heatmap coordination. The physical
`global_message_index`, `message_index`, and `contact_message_index` tables may
still exist in retained schema for diagnostic inventory, but no active
maintenance API or test should preserve them as app-facing timeline
infrastructure.

The retained Drift schema implementation itself was later removed after the
central retained working provider was retired and reference scans confirmed no
production code or tests still instantiate `WorkingDatabase`. Existing
`working.db` files remain a storage-retention concern on disk, not an app schema
surface.

Database health may list these tables as retained schema inventory, but it
must not treat their emptiness, missing coverage, or missing relationships as
ordinary graph integrity failure. Timeline-like graph surfaces are validated
through the source-scoped Message Evidence Spine instead.

**Removal criteria**

Done means:

- corresponding retained production code is deleted or permanently frozen.
- archive/recovery functionality has graph-native tests.
- remaining retained import schema tests are either removed with the schema or
  kept only as fixture/documentation tests with explicit labels.

## Non-Retention Buckets

The following are no longer valid reasons to keep legacy storage:

- ordinary contact picker data
- contact hero/profile data
- contact handle filtering
- conversation sidebar/signatures
- ordinary message evidence
- global/contact heatmaps
- Search All or scoped search
- recovered deleted/no-handle message presentation
- live `chat.db` polling
- first-run app-facing setup

If future scans find retained `working.db` / `macos_import.db` reads in those
areas, classify them as defects or compatibility bridges requiring immediate
review.

## High-Risk Deletion Mistakes

Do not remove retained storage merely because ordinary UI no longer
uses it. The risky losses are:

- loss of historical archive-source status metadata.
- loss of compatibility with archived attachment rows still keyed in the older
  shape.
- degraded support diagnostics while users still have transitional data
  folders.
- inability to compare graph storage against retained historical storage during
  final retirement.

## Recommended Next Slice

Source-scoped archive import/removal has now cut over to graph-backed services,
and the retained archive execution stack has been removed from production code.
The remaining highest-leverage deletion blocker is no longer archive import
execution. It is retained storage/reference retirement:

```text
decide which retained macos_import.db / working.db file roles remain permanent
historical/reference storage, and which can be deleted or frozen
```

Closing that blocker would unlock the remaining storage simplification:

- eventual deletion or permanent freezing of `macos_import.db` / `working.db`
  schemas
- removal or narrowing of retained schema/health diagnostics
- final migration of any overlay/archive keys that still require retained
  identity interpretation

Until then, retained storage should stay bounded, named, and tested.
