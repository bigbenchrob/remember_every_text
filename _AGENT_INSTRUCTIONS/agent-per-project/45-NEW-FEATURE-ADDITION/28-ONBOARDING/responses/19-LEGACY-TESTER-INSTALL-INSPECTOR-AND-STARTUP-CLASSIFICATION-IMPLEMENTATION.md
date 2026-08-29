---
tier: project
scope: feature-28-legacy-tester-recognition
owner: agent-per-project
last_reviewed: 2026-08-29
source_of_truth: code-and-tests
links:
  - ../prompts/22-%20PRE-INSTALL-INSPECTION-DELETION.md
  - ./18-LAST-DISTRIBUTED-TESTER-BUILD-LEGACY-INSTALL-SIGNATURE-AUDIT.md
tests:
  - test/essentials/archive_environment/infrastructure/read_only_sqlite_legacy_tester_install_inspector_test.dart
  - test/essentials/archive_environment/application/archive_admission_service_test.dart
  - test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart
  - test/startup_installation_state_surface_test.dart
  - test/architecture/legacy_tester_install_inspection_boundary_test.dart
---

# Legacy Tester Install Inspector And Startup Classification

## Result

MessageLens can now recognize the pre-source-scoped database generation used
by the final April 2026 tester build without opening it through current
database providers, migrating it, marking it, or granting deletion authority.

The typed inspection outcomes are:

- `legacyTesterInstall`: the complete positive signature is proven;
- `notLegacy`: required evidence is absent or contradictory;
- `inspectionFailed`: the stores could not be inspected well enough to prove
  the signature.

Only `legacyTesterInstall` produces the restricted startup mode
`ArchiveAccessMode.legacyTesterInstallDetected`. That mode permits neither
persistent-store access nor archive mutation.

## Exact Signature

The inspection runs only after `ArchiveIdentityValidator` has proved that the
native production claim names the exact canonical production root. The root
must then contain all of this evidence:

- no `.messagelens-archive.json` marker;
- `macos_import.db`, SQLite schema version 4, with every required legacy import
  table;
- `working.db`, SQLite schema version 3, with every required legacy graph and
  projection table;
- `user_overlays.db`, SQLite schema version 3, with every required legacy
  overlay table;
- no `macos_import_ss.db`;
- no `working_ss.db`;
- no `presence.db`.

`attachment_archive/`, `derived_media/`, diagnostics, SQLite sidecars, and
unknown legacy files are neutral. They neither establish nor invalidate the
signature.

The table fingerprints come from the audited source revision associated with
the distributed `0.1.16+17` build. The data root cannot prove one exact build,
so the product claim remains deliberately narrower: this is the
pre-source-scoped database generation used by that tester build.

## Read-Only Inspection Path

`ReadOnlySqliteLegacyTesterInstallInspector` lives in
`essentials/archive_environment/infrastructure`. It:

1. rejects non-production claims;
2. rejects a marker, any current source-scoped database, or Presence database
   before opening a legacy store;
3. requires all three legacy paths to be ordinary files rather than symbolic
   links or directories;
4. opens each database with SQLite `OpenMode.readOnly`;
5. sets connection-local `PRAGMA query_only = ON` and a bounded busy timeout;
6. passes both inspection statements through the canonical read-only SQL guard;
7. reads only `PRAGMA user_version` and non-internal `sqlite_master` table
   names;
8. requires the complete application-table set to equal the audited
   fingerprint, so missing and unexpected application tables both fail closed;
9. closes each connection before returning.

The inspector imports no current database provider, Drift database, migration,
repository, logger, or mutation service. Tests compare every file byte before
and after both successful and failed inspection. No marker or current database
appears.

## Startup Integration

The integration point is `ArchiveAdmissionService`, after native claim
validation and marker lookup but before ordinary archive admission.

Previously, every nonempty unmarked production root received broad
`completeEraseOnly` authority. That inference has been removed. The service
now invokes the inspector and behaves as follows:

| Inspection | Startup result |
| --- | --- |
| Exact legacy proof | Restricted `legacyTesterInstallDetected` presentation |
| Not legacy | `nonEmptyUnmarkedArchive`; fail closed |
| Inspection failed | `legacyTesterInspectionFailed`; fail closed |

`StartupApp` checks the restricted legacy mode before it watches the current
installation-state provider. It renders only a bounded recognition surface.
That surface has no erase, migration, Start Fresh, or ordinary application
action. Authorization and deletion remain future work.

The mutation coordinator rejects every operation, including Complete Erase,
when this recognition mode is active. The older generalized Complete Erase
implementation remains quarantined for its existing separately authorized
uses; positive legacy recognition does not expose it.

## False-Positive Protection

Focused tests cover:

- exact `4/3/3` proof with and without optional archive/media folders;
- healthy marked current installations;
- ordinary Start Fresh installations;
- missing marker or attachment archive alone;
- one or two legacy databases;
- wrong schema versions, missing tables, and unexpected application tables;
- each current database appearing beside the legacy trio;
- a current marker beside the legacy trio;
- current installations retaining retired database residue;
- unreadable/corrupt SQLite evidence;
- non-canonical claims rejected before inspection;
- no current installation provider read during restricted startup;
- no mutation authority after recognition.

Every unmarked, incomplete, current, Start Fresh, damaged, or unprovable shape
therefore remains incapable of entering the future tester-delete path.

## Development Reproduction

There is no honest ordinary-Development GUI reproduction using current
facilities. The gate intentionally requires a validated production claim and
canonical production root. Allowing a Development build to enter it would
weaken the identity boundary; reproducing the old `4/3/3` stores would require
a purpose-built fixture/preparation mechanism that this slice explicitly does
not justify.

The SQLite inspector and startup projection are instead exercised with
disposable test roots and injected authorities. No production or tester data
was modified.

## Next Slice

The next reviewed slice may add explicit human authorization and a narrowly
admitted deletion operation for this proven cohort. It must retain these
invariants:

- source databases and non-MessageLens data are never deletion targets;
- recognition is not deletion authority;
- inspection failure remains non-mutating and fail-closed;
- no ordinary current store opens before the legacy decision;
- the exact positive signature remains mandatory.
