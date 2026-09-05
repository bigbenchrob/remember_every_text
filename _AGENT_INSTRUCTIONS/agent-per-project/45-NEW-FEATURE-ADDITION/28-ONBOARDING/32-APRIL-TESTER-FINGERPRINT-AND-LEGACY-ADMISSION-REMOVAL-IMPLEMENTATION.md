---
tier: project
scope: onboarding
owner: agent-per-project
last_reviewed: 2026-09-05
source_of_truth: implementation-record
---

# April Tester Fingerprint And Legacy Admission Removal

## Outcome

The temporary April 2026 tester-compatibility subsystem has been removed from
production code. MessageLens no longer identifies an application generation
from a whole-folder database fingerprint and no longer exposes an
April-specific startup, authority, presentation, deletion, or relaunch path.

The permanent compatibility model is now:

```text
current MessageLens root ownership
  -> per-store schema version
  -> supported migration path
  -> integrity and reconciliation verification
```

## April-Only Concepts Removed

The implementation deleted the following dedicated production seams:

- `LegacyTesterInstallInspector`;
- `ReadOnlySqliteLegacyTesterInstallInspector` and its exact database/table
  signature comparison;
- `LegacyTesterInstallInspection`;
- `legacyTesterInstallDetected` startup classification and presentation;
- `legacyTesterInspectionFailed` admission exception;
- `legacyTesterInstallDeletion` mutation operation and authority;
- the **Delete Old Data and Continue** action, service, providers, generated
  providers, presentation model, and view;
- the April-specific startup branch and relaunch/handoff wiring;
- construction and export edges used only by those components.

No dormant production copy of the `4/3/3` recognition remains. Historical
prompts, audits, and implementation responses retain their terminology as a
record of the retired experiment.

## Startup Routing Before And After

Before removal, a meaningful non-empty unmarked production root was sent to an
exact legacy inspector. A match could create special mutation authority and
show a one-off deletion offer; a mismatch produced a fingerprint-specific
failure.

After removal, startup has three durable meanings:

1. An absent or bootstrap-empty production root is Virgin and may receive its
   first ordinary archive marker.
2. A current owned root is admitted through its archive marker/UUID, then each
   store is interpreted through its own schema and integrity rules.
3. Meaningful unsupported, inconsistent, corrupt, or non-empty unmarked state
   fails closed into generic remediation.

The third case does not infer an application release from filenames, directory
shape, table counts, or table signatures. It exposes neither April-specific
language nor an April-specific deletion offer.

## Archive Marker And UUID Responsibilities Retained

`.messagelens-archive.json`, the archive UUID, canonical-root proof, and
`ArchiveAccessAuthority` continue to:

- identify the MessageLens-owned archive instance;
- isolate Production and Development roots;
- bind checkpoint, attachment, preservation, and mutation consumers to one
  admitted identity;
- admit first marker creation only for a truly absent or bootstrap-empty
  installation.

The marker is not an application-release fingerprint and does not carry an app
version.

## Schema Migration And Generic Remediation

No physical database schema, schema-version constant, or migration history was
changed. Supported current installations still use each database's own schema
version and migration implementation. Unsupported or inconsistent current data
continues to fail closed through the existing typed remediation architecture.

## Tests Removed

Tests and fixture support whose desired behavior was retired were deleted:

- exact April legacy inspection boundary and SQLite fingerprint tests;
- April deletion action, service, integration, and presentation tests;
- the synthetic April tester installation fixture;
- startup and mutation-authority cases that asserted the special legacy route.

## Tests Retained Or Updated

Archive-admission tests now prove that every meaningful non-empty unmarked
production root fails with the generic `nonEmptyUnmarkedArchive` result, while
absent and bootstrap-empty roots retain ordinary marker initialization.
Startup presentation and mutation-coordinator tests no longer construct or
admit retired legacy state. Existing suites remain authoritative for:

- current marker/UUID and Production/Development isolation;
- per-store database migrations and integrity checks;
- preservation-safe Start Fresh;
- attachment archive preservation and ownership;
- Historical Archives;
- generalized Complete Erase/root replacement;
- architecture boundaries and production startup reachability.

## Slice B Deliberately Deferred

This change does not remove the generalized whole-root Complete Erase
transaction/store, its crash-convergent root-replacement machinery, or a
current recovery path that genuinely depends on it. That is Slice B and
requires a separate bounded audit. It is no longer coupled to an April tester
classifier or special legacy authority.

## Verification

The completed implementation passed the following checks on
`Ftr.archive-recovery`:

- `dart format` on every surviving Dart file changed by this removal;
- 444 focused onboarding, archive-admission, mutation-boundary, startup, and
  architecture tests;
- 24 focused Historical Archives admission, repository, and preflight tests;
- the complete Flutter test suite: 2,139 tests passed;
- `flutter analyze` with no issues;
- `flutter build macos --debug`, producing the development application;
- `git diff --check`;
- repository searches confirming that the retired April fingerprint,
  admission, mutation, deletion, and presentation identifiers no longer exist
  in `lib/` or `test/`.

The macOS build emitted only pre-existing/non-blocking Xcode build-version and
third-party `volume_controller` privacy-manifest warnings.
