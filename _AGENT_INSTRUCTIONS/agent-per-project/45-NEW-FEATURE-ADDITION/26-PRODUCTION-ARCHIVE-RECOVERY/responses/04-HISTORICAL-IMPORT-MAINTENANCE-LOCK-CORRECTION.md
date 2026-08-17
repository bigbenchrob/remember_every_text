---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-16
source_of_truth: doc
links:
  - 03-HISTORICAL-MESSAGES-2012-2016-INGESTION-AUDIT.md
  - ../../10-DATABASES/00-all-databases-accessed.md
tests:
  - test/essentials/archive_environment/application/archive_scoped_persistent_providers_test.dart
---

# Historical Import Maintenance-Lock Correction

## Observed staging failure

The first Historical Archives import attempt against the disposable development
clone failed during `Preparing archive records` with:

```text
Bad state: working_ss.db is unavailable during database maintenance
```

The source-read and dry-run stages had already succeeded. No production archive,
frozen snapshot, original donor, attachment payload, or production identity was
involved.

## Durable state after failure

Immutable inspection with MessageLens stopped established:

- `source_registry` still contained only source `1` (`live_chat_db`) and source
  `2` (`live_address_book`);
- source `3` had zero import-ledger rows and zero graph rows;
- source `1` contained 136,942 messages in both import and graph stores;
- `macos_import_ss.db` and `working_ss.db` had not been written during the
  failed attempt;
- `overlay_settings['historical_archive_sources/v1']` truthfully recorded the
  failed preflight/import result; and
- no attachment payload or `archived_attachments` record changed during the
  attempt.

The four-message increase from Audit 03's earlier 136,938 source-1 snapshot was
normal live-source catch-up completed before the failed import. It was not
caused by the Historical Archives operation.

The only durable change owned by the failed attempt was retryable Historical
Archives status metadata in Overlay. No manual cleanup is required.

## Exact failure chain

```text
HistoricalArchivesWorkflow.beginImportForSelectedSource
  -> ArchiveMutationCoordinator.run(historicalArchiveImport)
  -> historicalArchiveImport activates database-reopen blocking
  -> action resolves SourceScopedArchiveGraphImportServiceProvider
  -> projector providers resolve DriftConversationGraphDatabaseProvider
  -> graph provider observes maintenance blocking
  -> graph provider throws before importAndProject begins
```

The operation therefore blocked its own first required graph access. Source
registration and message insertion were never reached.

The graph provider also used a reactive dependency on the maintenance signal.
That caused maintenance activation to dispose an already-open graph connection,
which contradicted the canonical rule that the signal blocks **new graph
connections** rather than revoking every existing handle.

## Correction

The Historical Archives workflow now prepares its feature-owned
`SourceScopedArchiveGraphImportService` before requesting mutation admission.
The admitted action uses that prepared capability for source import and graph
projection.

The persistent graph provider now samples the maintenance signal only when it
creates a connection. Consequently:

- the admitted operation may finish using its deliberately prepared graph
  connection;
- maintenance activation does not reactively revoke that connection; and
- a consumer that attempts a genuinely fresh graph open during the protected
  interval still receives the maintenance error.

No direct SQLite connection was added to Settings. Database construction remains
centralized, the mutation coordinator remains mandatory, and unrelated readers
gain no new authority.

## Retry disposition

The existing staging clone is safe to retry after installing/running the
corrected code. The source registrar and importers are already idempotent, but
in this observed failure they did not run at all: there is no source-3 partial
state to reconcile.

Do not recreate the staging clone solely because of this failure. Do not rerun
the GUI import until the explicit staging rehearsal resumes.
