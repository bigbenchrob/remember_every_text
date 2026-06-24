---
tier: project
scope: source-scoped-graph-migration
status: active
last_reviewed: 2026-06-24
depends_on:
  - 71-LEGACY-DEPENDENCY-MATRIX.md
  - 73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md
  - 75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md
  - 80-GRAPH-MIGRATION-INTERIM-PROGRESS-REPORT.md
---

# 81 - Retired Historical Storage Register

## Purpose

The ordinary MessageLens app path is now graph-backed. Remaining
`macos_import.db` and `working.db` references should therefore be treated as
retired cleanup-inventory questions, not ordinary UI migration blockers.

This register defines what remains, why it remains, and what must be true
before each retired-file purpose can be reduced, migrated, explicitly ignored,
or removed.

## Current Decision

Document retired files as cleanup/diagnostic inventory. Do
not delete them blindly.

`macos_import.db` and `working.db` are retired historical cleanup inventory,
not permanent system-of-record storage. Existing user data folders may keep
them during the transition for recovery, audit, comparison, and support
diagnostics. They are no longer treated as rollback insurance for ordinary app
operation.

The retired database files no longer own ordinary evidence, search, contact
identity, conversation browsing, live polling, Historical Archives execution,
or first-run graph setup. New ordinary app behavior must not read or write
them. Remaining access is allowed only when it is explicitly classified in this
register as retired cleanup/diagnostic evidence.

The safe next stage is:

```text
retain deliberately
→ replace remaining storage/key compatibility paths
→ verify historical data reachability
→ reduce retained purposes under this register
→ delete or explicitly ignore retired files only after reviewed user-safe criteria
```

Full deletion should occur only after all of the following are true:

1. archive/recovery identity and archive lookup no longer require retained
   storage.
2. support diagnostics have graph/source-scoped equivalents.
3. retained-file audit value has either been migrated, exported, or explicitly
   rejected as unnecessary.
4. a user-safe backup/retention path exists for anyone who may still need old
   recovery data.

Until then, the target is not deletion by default. The target is a shrinking,
bounded retention register where every retained purpose is named, justified,
tested, and prevented from becoming ordinary app authority again.

## Retained Storage Buckets

### 1. Retired Archive-Compatible Import/Projection Execution

**Retired execution files**

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

**Remaining retired storage boundaries**

- retained user-data files: `macos_import.db`, `working.db`, and sidecar
  WAL/SHM files in existing data folders

**Current status**

Historical archive workflows no longer import older Messages folders through
the retained historical ledger/projection path. Forward import uses
`SourceScopedArchiveGraphImportService`; removal uses
`SourceScopedArchiveGraphRemovalService`.

This bucket remains listed because retained historical database files may still
exist for storage-retirement cleanup, but it is no longer the Historical
Archives execution path. The standalone import-control panel and
`ViewSpec.import` route have been retired.

**Current boundary**

The superseded retained archive pipeline is retired. Historical Archives
import/removal now uses source-scoped graph services directly:

- `SourceScopedArchiveGraphImportService`
- `SourceScopedArchiveGraphRemovalService`

Retained database files may still exist for storage-retirement cleanup,
diagnostics, backup interpretation, and historical reference. No retained
import/projection execution boundary remains current.

**Completed execution-retirement criteria**

Done:

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

**Remaining storage-reduction criteria**

Done means:

- retained `macos_import.db` / `working.db` file purposes are reduced to the
  storage buckets listed below.
- backup/export/delete/ignore policy is explicit for users who may still need
  old recovery or audit data.
- support diagnostics no longer require old schema assumptions except where
  deliberately preserved as historical-file inspection.
- reset cleanup can safely handle old files without recreating them as app
  authority.

The completed execution-retirement criteria are now satisfied for Historical
Archives import/removal. The retired archive pipeline provider, old import
progress/detail widgets, old ledger orchestrator, old table-importer stack,
old retired projection orchestrator/migrator stack, and their tests have been
removed. Broader deletion of retired database files, schemas, and diagnostic
surfaces must still follow this retention register and the full-deletion
criteria above.

### 2. Historical Archive Settings Metadata

**Primary files**

- `lib/features/settings/infrastructure/repositories/historical_archive_sources_repository.dart`
- `lib/features/settings/infrastructure/repositories/archive_source_inspection_repository.dart`
- `lib/features/settings/feature_level_providers.dart`
- `lib/features/settings/presentation/view_model/historical_archives_workflow_panel_model_provider.dart`

**Why kept**

The historical archive workflow previously stored and read archive-source
status in the retained archive metadata database. That active workflow state
has moved to overlay settings. Retained `macos_import.db` files may still carry
old archive-source rows in existing data folders, but those rows are now
retired transitional material only.

**Current boundary**

Settings code reads and writes active Historical Archives source metadata
through `HistoricalArchiveSourcesRepository`, backed by overlay settings. The
central `retainedArchiveMetadataStoreProvider` has been removed. No active app
provider should construct `RetainedArchiveMetadataDatabase`; retained
`macos_import.db` is now a file-retention concern for reset, diagnostics, and
explicit cleanup/export/discard decisions.
The old `RetainedArchiveMetadataDatabase` wrapper and
`RetainedArchiveMetadataStore` interface have been retired from production
source. Existing retained files can still be removed by reset or inspected by
read-only file-query diagnostics, but there is no retained metadata database
abstraction left for app code to depend on.
Obsolete public helpers for retained import execution, spam filtering, and
row-existence maintenance should remain absent.
The old retained batch-ledger deletion API has been removed; Historical
Archives removal now deletes source-scoped archive rows through the graph
archive-removal service.
The generic retained archive metadata raw-query wrapper has also been removed.
Callers that need health diagnostics or schema tests should use their own
explicit infrastructure query boundary instead of widening this retained
metadata wrapper.
The unused generic retained archive metadata `countRows` helper has also been
removed; row-count diagnostics now belong to the database-health query layer
rather than the archive-source metadata wrapper.
The old retained archive batch-count read has been removed as well.
Historical Archives source management now describes the source-scoped removal
target directly instead of reading old `macos_import.db.import_batches` rows.
Retained archive-source batch ID and import-start timestamp fields have been
removed from the public metadata wrapper. Their old SQLite columns are tolerated
only as existing-file schema compatibility.
Historical Archives workflow presentation no longer imports the retained
database wrapper or provider directly. Active Historical Archives source
metadata has moved to overlay-owned settings storage behind
`HistoricalArchiveSourcesRepository`; the settings feature public provider now
composes that repository from `overlayDatabaseProvider`, not
`retainedArchiveMetadataStoreProvider`. The retained
`macos_import.db.historical_archive_sources` table is no longer the active
workflow metadata home. It remains existing-file retired storage only
until a deliberate cleanup/export/discard policy removes the old file purpose.
Fresh retained archive metadata DB creation no longer recreates those old
archive-source metadata columns.
Database health treats retained `macos_import.db` as retired archive-source
cleanup inventory only; active source facts and topology health belong to
`macos_import_ss.db`.
No active app provider now creates a fresh retained `macos_import.db`.
Existing older retained `macos_import.db` files may still keep
`schema_migrations`, `historical_archive_sources`, historical ledger tables,
or old topology ledgers for transitional cleanup inventory.

**Reduction criteria**

Done means:

- archive-source metadata has an overlay-owned workflow home or a
  source-scoped/source-registry provenance home, as appropriate.
- existing archive-source status can be migrated or intentionally discarded.
- the settings workflow no longer reads `macos_import.db` for archive-source
  rows. This is satisfied for active Historical Archives metadata by the
  overlay-backed `HistoricalArchiveSourcesRepository`.
- graph preflight/dry-run duplicate estimates remain available.
- removal/import success criteria no longer mention retained projection.

### 3. Reset and Derived-Data Maintenance

**Primary files**

- `lib/essentials/onboarding/application/message_data_reset_service.dart`
- `lib/essentials/onboarding/application/database_existence_checker.dart`

**Why kept**

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

**Reduction criteria**

Done means:

- retired storage has been reduced to deliberate transitional cleanup/diagnostic
  storage with explicit retirement criteria.
- reset behavior no longer needs to close/delete retained DB files.
- startup no longer needs to distinguish legacy-only derived data from
  graph-ready data.
- old data folders are either migrated or explicitly ignored with a clear user
  recovery path.

### 4. Database Health and Support Diagnostics

**Primary files**

- `lib/essentials/db/application/database_health_audit/**`
- support bundle / diagnostic report actions that invoke database health audit

**Why kept**

Diagnostics intentionally inspect both current graph databases and retained
historical cleanup databases while the transition is incomplete. This helps
identify stale-data, compatibility, and recovery conditions.

**Current boundary**

Diagnostic reads are allowed to look across layers as long as they do not make
retired cleanup inventory authoritative for ordinary feature behavior.
Database health now treats retained `working.db` as recovered-message retired
cleanup/diagnostic evidence plus minimal projection-state storage sanity. Ordinary
message/chat/contact/handle/attachment/reaction health belongs to
`working_ss.db`; retained `working.db` ordinal indexes are no longer audited as
timeline infrastructure because graph evidence skeletons own timeline
navigation.
Database health also opens retained `macos_import.db` and `working.db` through
read-only file query layers. It must not instantiate the central retained DB
providers merely to build diagnostics, because doing so could recreate retained
storage as a side effect of a support bundle or health report.
The old provider-backed retained archive metadata / working health query
adapters have been removed; retained health diagnostics now have exactly one
retained database access path: read-only file inspection.
Because retained `working.db` and retained `macos_import.db` no longer have
central app providers, health and support diagnostics must not reintroduce one
for convenience.
Focused tests now verify that read-only retained database health inspection:

- does not create missing `working.db` / `macos_import.db` files.
- reads existing retained files without mutating them.
- remains a diagnostic boundary rather than a retained database provider.

**Reduction criteria**

Done means:

- retired DB files are gone, exported, explicitly ignored, or classified as
  deliberate cleanup inventory.
- health audit labels no longer need to inventory retired file layers.
- support bundles still expose enough graph/import/overlay evidence to debug
  data issues.

### 5. Retained Schema and Migrator Tests

**Primary files**

- `test/essentials/db/infrastructure/data_sources/local/import/**`
- retained/source-scoped tests for graph monitor behavior and source-scoped
  extractor behavior

**Why kept**

Tests should remain as long as the corresponding retired-storage code or
diagnostic boundary remains. The old table-importer tests were removed with the
old table-importer execution stack, and historical `db_migrate` tests were
removed with the retired projection orchestrator/migrator stack. The old
`db_importers` folder has also been retired: graph monitor tests now live under
`conversation_graph`, while extractor/enrichment tests now live under
`source_scoped_import`.

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

**Reduction criteria**

Done means:

- corresponding retained production code is deleted or narrowed to explicit
  cleanup/diagnostic boundaries.
- archive/recovery functionality has graph-native tests.
- remaining retained archive metadata schema tests are removed with the schema
  wrapper or kept only as fixture/documentation tests with explicit labels. The
  old wrapper tests have now been deleted with the production wrapper.

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

Do not remove retired cleanup inventory merely because ordinary UI no longer
uses it. The risky losses are:

- loss of historical archive-source status metadata.
- loss of compatibility with archived attachment rows still keyed in the older
  shape.
- degraded support diagnostics while users still have transitional data
  folders.
- inability to compare graph storage against retired historical inventory during
  final retirement.

## Retention Reduction Register

Future work should continue reducing retired-file purposes rather than deleting
files opportunistically. Track each remaining purpose by answering:

- What retained file/table/path is involved?
- Is it recovery, audit, comparison, diagnostics, reset, cleanup, or archive
  metadata?
- What graph/source-scoped equivalent would replace it?
- What user data could be lost or made harder to recover if this disappears?
- What test or support report proves the replacement?

Known retained purposes:

| Purpose | Current retired-file inventory | Allowed owner | Reduction target |
| --- | --- | --- | --- |
| Archive-source workflow metadata | overlay settings key `historical_archive_sources/v1`; old `macos_import.db.historical_archive_sources` may exist in retained files | Historical Archives settings repository | Active metadata has moved to overlay storage. Decide whether old retained metadata is migrated, exported, or intentionally discarded before deleting retained files. |
| Existing-folder reset cleanup | `macos_import.db`, `working.db`, WAL/SHM files | Message data reset service | Keep until old derived files are either no longer created or a safe backup/cleanup policy replaces direct deletion. |
| Support diagnostics and audit | read-only retained file inspection | Database health/support diagnostics | Add graph/source-scoped equivalents for any retained report value before narrowing retained inspection. |
| Historical comparison / retained-file audit | existing user `working.db` / `macos_import.db` files | Diagnostic-only file readers | Keep only while a named diagnostic or audit report still needs retained-file context; ordinary rollback safety is no longer a retention reason. |
| Archive/recovery compatibility keys | retained-shaped overlay/archive keys and old message/attachment identifiers | Named compatibility bridges only | Replace with graph/source-scoped archive identity and prove recovered attachment/message lookup parity. |

Current implementation note:

- Message overlay compatibility now names retained rowid annotation fallback
  and GUID-keyed fallback explicitly. New message overlay writes target
  graph-native `message_ss_id` tables; retained annotation/GUID rows are
  read-only compatibility sources.
- Active `lib/` code is guarded by an architecture test that forbids new
  legacy-named concepts. Retained storage and compatibility bridges must be
  named for their current architectural role.

## Recommended Next Slice

Source-scoped archive import/removal has now cut over to graph-backed services,
and the retired archive execution stack has been removed from production code.
The remaining highest-leverage retention blocker is no longer archive import
execution. It is retired-file storage reduction:

```text
reduce each retired macos_import.db / working.db purpose behind the retention
register, without letting either file become ordinary app authority or permanent
storage
```

Closing that blocker would unlock the remaining storage simplification:

- eventual deletion, export, migration, or explicit ignore policy for
  `macos_import.db` / `working.db` schemas
- removal or narrowing of retained schema/health diagnostics
- final migration of any overlay/archive keys that still require retained
  identity interpretation

Until then, retired cleanup inventory should stay bounded, named, tested, and
explicitly transitional.
