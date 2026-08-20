---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-20
source_of_truth: implementation-record
links:
  - ../00-START-HERE.md
  - ./08-ARCHIVE-MUTATION-OWNER-AWARE-DATABASE-ADMISSION-IMPLEMENTATION.md
  - ./35-MAC-MESSAGES-IMPORT-COMPLETION-AND-CHOOSER-FEEDBACK-IMPLEMENTATION.md
tests:
  - test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart
  - test/essentials/source_scoped_import/infrastructure/import_database_provider_test.dart
---

# Historical Archive Import Ledger Contention Correction

## Observed Failure

After several successful remove-and-add rehearsals on the disposable Feature
26 staging archive, one explicit folder addition failed at the first import
stage. The durable application log identified the exact statement:

```sql
INSERT INTO import_batches (source_id, started_at_utc) VALUES (?, ?)
```

SQLite returned `database is locked` for `macos_import_ss.db`. Source reading
had completed, but no message insertion or graph projection had begun.

## Cause

Historical Archives correctly owned `historicalArchiveImport` through
`ArchiveMutationCoordinator`. The live Messages monitor also correctly defers
its admitted mutation work while another owner holds that authority.

The competing access came from Environment Readiness. Acquiring mutation
authority changed the maintenance signal, which recomputed the Onboarding
environment report. That report already declined to inspect `working_ss.db`
during maintenance, but still opened `macos_import_ss.db` to calculate its
message-row count. The resulting short-lived read overlapped the source-3
batch write. The canonical import-ledger connection had no busy timeout, so
the valid write failed immediately rather than waiting for the read to end.

This was not accumulated repeated-folder state and not a failure of source
identity. It was an unrelated observational read crossing an admitted
maintenance boundary, amplified by zero bounded lock tolerance on the writer.

## Authority Correction

During admitted maintenance, Environment Readiness now opens neither derived
store for observational row counts:

```text
maintenance active
    -> report maintenanceInProgress
    -> do not count macos_import_ss.db rows
    -> do not count or inspect working_ss.db rows
    -> refresh derived-store facts after maintenance releases
```

This is the primary correction. Readiness reports the truthful operation state
instead of competing with the operation that owns the stores.

## Bounded Contention Tolerance

The canonical `ImportDatabase` connection now applies:

```sql
PRAGMA busy_timeout = 3000
```

This permits a legitimate ledger write to wait through a brief SQLite lock
instead of failing instantly. It is defensive tolerance, not resource
authority. It does not permit Environment Readiness or any other unrelated
reader to ignore the maintenance boundary.

## Failed-Attempt State

Read-only staging inspection after the failure found:

- one existing source-3 registry row;
- zero source-3 import batches;
- zero source-3 messages;
- no source-3 graph projection;
- intact source-1 data;
- `PRAGMA quick_check = ok`; and
- no attachment-archive stage or operation.

Source registration is intentionally idempotent. A later explicit retry uses
the same source identity and does not require manual cleanup. The disposable
staging clone therefore remains safe to retry after installing the corrected
build; it does not need to be recreated from the frozen snapshot.

## Regression Protection

Focused tests establish two independent invariants:

1. a maintenance-time Environment Readiness evaluation does not request a
   table count from either derived store and does not inspect graph readiness;
2. the canonical import ledger waits through a controlled short-lived read
   lock and then successfully writes its import batch.

No database schema, Historical Archives workflow, source identity, graph
projection, attachment preservation, donor, staging data, or production data
changed as part of this correction.

## Verification

- Focused import-ledger and environment-report tests: 30 passed.
- Historical Archives workflow/panel and mutation-coordinator tests: 65
  passed.
- Complete Onboarding and source-scoped import suites: 194 passed.
- Architecture tripwires: 374 passed.
- `flutter analyze`: no issues.
- `dart format`: clean.
- `git diff --check`: clean.

No GUI retry was performed by the agent. The next manual rehearsal should use
the corrected build and the existing disposable staging clone.
