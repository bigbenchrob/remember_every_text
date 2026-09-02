---
tier: project
scope: feature-28-first-install-production-admission
owner: agent-per-project
last_reviewed: 2026-09-02
source_of_truth: code-and-tests
related:
  - 22-LEGACY-TESTER-INSTALL-INSPECTION-AND-DELETION-AUTHORITY.md
  - ../../../../90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/PROPOSAL.md
---

# First-Install Production Archive Marker Bootstrap Correction

## Observed Failure

A tester launching MessageLens as a genuinely new production installation saw:

```text
ArchiveAdmissionException(ArchiveAdmissionFailure.missingMarker):
Production refuses an unmarked archive outside explicit adoption.
```

The canonical production archive root was absent or empty. This was not a
legacy archive and did not require adoption.

## Root Cause

Admission already distinguished an empty root from a non-empty unmarked root.
`FileSystemArchiveMarkerStore.canCreateInitialMarker()` permits first-marker
creation only when the root is absent, empty, or contains solely the native
`MessageLens.instance.lock` file.

After that proof, `_createInitialMarker()` nevertheless rejected every
production claim unconditionally. The production-only rejection therefore
contradicted the established empty-root admission boundary and blocked normal
first installation before Onboarding could begin.

## Correction

The unconditional production rejection was removed. Initial marker creation
now follows the same already-proven filesystem condition for production and
development:

- an absent or empty canonical root may receive its first environment marker;
- the native instance lock may already exist beside that new marker;
- the marker is written for the environment proven by the native claim;
- the resulting archive authority is full and immutable for the process.

The correction does not broaden admission for existing data. A non-empty
unmarked production root still cannot receive a marker through this path. It
must either match the exact read-only legacy tester fingerprint and receive
restricted deletion-only authority, enter an explicit adoption path, or fail
closed.

## Mechanical Protection

Focused tests now prove:

1. an absent canonical production root receives a production marker and full
   authority;
2. the legacy inspector is not consulted for an absent root;
3. a native process lock is preserved while the marker is created beside it;
4. exact non-empty legacy recognition remains restricted;
5. every other non-empty unmarked production root remains rejected;
6. malformed, mismatched, and incompatible markers remain rejected.

No database schema, archive payload, onboarding flow, or legacy deletion
contract changed.

## Release

The correction is included in MessageLens `0.2.100+118`.
