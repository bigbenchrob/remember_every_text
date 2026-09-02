---
tier: project
scope: production-data-protection
owner: agent-per-project
last_reviewed: 2026-07-27
source_of_truth: validation-plan
status: production-cutover-validated-with-documented-residual
links:
  - ./CURRENT-STATE-AUDIT.md
  - ./PROPOSAL.md
  - ./QUESTIONS.md
  - ./IMPLEMENTATION-PLAN.md
tests: []
---

# Production Data Protection Validation Plan

## Current Result

The user authorized production adoption, and the operation completed on
2026-07-28. The final signed and notarized application is installed and has
demonstrated catch-up and live preservation. See
[`VALIDATION-RESULTS/production-cutover-2026-07-28.md`](VALIDATION-RESULTS/production-cutover-2026-07-28.md).

The historical validation sequence below remains the basis on which the
cutover was admitted.

## Current Validation Status

Gates 1-3 and 5-8 have automated or disposable-fixture evidence. Gate 4 has
provider/path-isolation coverage but has not yet received the complete
interactive development path-manifest exercise listed below.

Gate 8 now includes a signed, non-publishing production candidate, a fresh
signed DMG, and strict static identity verification. Apple rejected
notarization of the DMG because a required developer agreement is missing or
expired. The DMG is therefore not the final cutover artifact.

Gate 9 preparation has exercised checkpoint creation, restore, marker adoption,
production admission, catch-up import, attachment preservation, unchanged
payload rollback, and post-mutation rollback refusal on disposable archives.
The existing external production backup has been verified, and a read-only
in-place adoption inventory has been recorded without copying production
payload. The real Gate 9 operation and Gate 10 remain blocked.

Retained evidence is under [`VALIDATION-RESULTS/`](VALIDATION-RESULTS/).
No validation run launched the production application or mutated the production
archive.

## Purpose

This document defines the evidence required to claim that production data is
protected.

Passing unit tests is necessary but insufficient. The boundary spans:

- Xcode configuration;
- bundle and signing identity;
- native process admission;
- Dart startup;
- filesystem roots;
- SQLite providers;
- logs and preferences;
- background ingestion;
- mutation-operation coordination;
- snapshot and recovery.

Validation therefore proceeds from pure tests to built-artifact inspection,
disposable runtime exercises, and finally a separately authorized production
adoption.

## Evidence Rules

Every validation record identifies:

- date and code revision;
- build artifact and configuration;
- environment and archive instance;
- canonical root;
- source databases used;
- test operator;
- expected and observed result;
- relevant logs/reports;
- whether any production resource was touched.

Production remains out of scope until the production-adoption gate.

## Gate 1 — Static Architecture

### Required checks

- no ordinary feature constructs a physical app database path;
- all persistent providers require archive access authority;
- no global default silently resolves Application Support;
- source database openers remain read-only/query-only;
- no test environment accepts production root/marker;
- no app logger or preference store initializes before admission;
- every protected mutation entry point references operation authority;
- development and production build settings are explicit.

### Evidence

- architecture test report;
- `flutter analyze`;
- targeted source inventory diff;
- generated-code consistency.

### Pass condition

No unapproved persistent-root or mutation-authority bypass exists.

## Gate 2 — Pure Identity And Marker Tests

### Cases

| Case | Expected result |
| --- | --- |
| Development identity + development root + development marker | Accepted |
| Development identity + production marker | Rejected |
| Production identity + development marker | Rejected |
| Test identity + Application Support root | Rejected |
| Test identity + explicit temporary root/marker | Accepted |
| Production bundle + invalid/ad hoc signing | Rejected |
| Empty canonical production root | Production marker created atomically |
| Non-empty unmarked production root matching exact legacy fingerprint | Restricted legacy recognition authority |
| Other non-empty unmarked production root outside adoption mode | Rejected |
| Empty canonical development root | Development marker created atomically |
| Non-empty unmarked development root | Review/recovery required |
| Malformed/unknown marker version | Rejected |
| Path alias resolving to production from development | Rejected after canonicalization |

### Pass condition

Every invalid identity fails before persistent provider construction.

## Gate 3 — Native Process Admission

### Disposable runtime matrix

| First process | Second process | Expected |
| --- | --- | --- |
| Development A | Development A | Second rejected/activates first |
| Production clone identity in disposable harness | Same production clone | Second rejected |
| Development | Production clone | Both may run; roots and locks differ |
| Development instance A | Development instance B, if supported | Both may run only if archive roots/locks differ |
| Crashed owner | Same archive restart | Restart acquires released OS lock |

### Additional checks

- native claim environment matches Info.plist/build configuration;
- native lock path corresponds to claimed archive;
- Dart receives the same claim;
- no Flutter provider starts for a rejected duplicate;
- invalid production signing cannot receive production claim.

### Pass condition

Exactly one process owns one writable archive, and different environments do
not share locks or roots.

## Gate 4 — Persistent Write Isolation

### Instrumented disposable exercise

Run development through:

- first launch;
- onboarding;
- automatic sync;
- search and normal browsing;
- overlay changes;
- attachment ingestion;
- graph rebuild;
- reset/reimport;
- historical archive import/removal;
- support-bundle export;
- window move/resize and preference changes;
- application logging.

Record every opened/written path.

### Pass conditions

- every app-owned write is beneath the admitted development root or
  environment-scoped development log/preferences location;
- no path is beneath production Application Support or production log domain;
- Apple sources are opened read-only;
- marker and operation evidence identify development;
- restarting preserves development state without affecting production.

## Gate 5 — Test Isolation

### Required exercise

- run full Flutter test suite with persistent-open instrumentation;
- run native Runner tests;
- run any integration tests;
- deliberately construct a provider without test authority;
- deliberately supply production root/marker to test identity.

### Pass conditions

- all writes use memory or registered temporary roots;
- forbidden provider construction fails before filesystem access;
- no live Apple source is written;
- failed tests retain only explicitly requested diagnostic fixtures;
- production paths never appear in the open/write manifest.

## Gate 6 — Operation Authority

### Concurrency cases

| Active operation | Competing operation | Expected |
| --- | --- | --- |
| Live incremental update | Full graph build | Competing owner cannot write concurrently |
| Live incremental update | Reset | Reset waits/rejects before deletion |
| Full graph build | Historical import | One owner proceeds |
| Historical import | Historical removal | One owner proceeds |
| Attachment reconciliation | Reset/graph maintenance | Conservative exclusive policy enforced |
| Same operation nested stage | Same owner re-entry | Accepted and hold count balanced |
| Any protected operation throws | Next operation | Authority released and next may proceed |

### Coverage proof

Maintain a test inventory mapping every protected public action to its operation
authority request. A new action without a mapping fails architecture tests.

### Pass condition

No protected entry point writes without authority and no failure leaves stale
authority.

## Gate 7 — Checkpoint And Recovery

### Disposable rehearsal

1. prepare a representative disposable archive containing all databases,
   overlays, historical-source metadata, attachments, logs, and SQLite
   sidecars;
2. stop the app;
3. create checkpoint and manifest;
4. verify hashes and database integrity;
5. alter or reset the disposable archive through approved services;
6. restore into a separate verification root;
7. run database health, graph counts, overlay checks, archive-source checks, and
   attachment reconciliation;
8. compare restored state to the checkpoint manifest.

### Failure cases

- missing attachment;
- missing overlay database;
- stale or absent WAL/SHM treatment;
- corrupt database;
- mismatched marker/archive instance;
- incomplete manifest;
- interrupted copy.

### Pass condition

The validator rejects incomplete checkpoints and one complete checkpoint
restores a healthy, equivalent disposable archive.

## Gate 8 — Built Artifact Verification

### Development artifact

Verify:

- development bundle identifier and display name;
- development environment metadata;
- development signing identity;
- development root;
- environment-scoped logs/preferences;
- separate FDA entry where granted.

### Production artifact

Without launching it against production, inspect:

- bundle identifier `com.bigbenchsoftware.MessageLens`;
- archive environment `production`;
- expected signing team and Developer ID identity;
- release entitlements;
- notarization/stapling for the final cutover artifact;
- absence of development marker/root metadata;
- production build script verification output.

### Pass condition

No artifact has mixed production/development identity.

### Current evidence

The signed candidate at `build/production-candidate/MessageLens.app` passes all
static checks other than notarization/stapling, which is intentionally deferred
to the final distribution artifact. See
[`VALIDATION-RESULTS/production-candidate-and-adoption-rehearsal-2026-07-27.md`](VALIDATION-RESULTS/production-candidate-and-adoption-rehearsal-2026-07-27.md).

## Gate 9 — Production Adoption Authorization

Production adoption may be scheduled only when Gates 1-8 pass and their
evidence is retained.

Required approvals/evidence:

- reviewed implementation completion report;
- verified external recovery backup;
- verified read-only production adoption inventory;
- exact production adoption runbook;
- verified production artifact;
- confirmed rollback procedure;
- operator acknowledgement that this is a production mutation.

This document does not grant that authorization.

The final verified artifact for this gate must be signed, notarized, and
stapled. The current signed candidate and DMG prove identity and startup
configuration but are not the final installable cutover artifact.

## Gate 10 — Production Adoption Verification

After separately authorized adoption:

- production marker identifies the existing archive instance;
- production databases and attachment archive remain at the existing location;
- database health and record counts match pre-adoption evidence;
- overlay/user intent remains intact;
- live incremental sync succeeds;
- development launches into a separate archive;
- development cannot open production even when explicitly pointed toward it;
- duplicate production launch is rejected;
- support bundle reports correct environment/archive identity;
- completion, recovery-backup, and adoption-inventory references are retained.

## Regression Matrix

The following checks remain in the permanent suite:

- identity compatibility table;
- marker parsing/version/mismatch;
- pre-admission provider rejection;
- development/test production-root rejection;
- native duplicate-process admission;
- environment-separated locks;
- source read-only enforcement;
- persistent path manifest;
- operation-authority entry-point inventory;
- operation conflict/release behavior;
- overlay independence;
- reset scope;
- historical live-source rejection;
- checkpoint completeness/restore.

## Evidence Artifacts

Implementation should produce:

```text
VALIDATION-RESULTS/
  static-architecture-report.md
  identity-test-report.md
  native-admission-report.md
  development-path-manifest.md
  test-isolation-report.md
  operation-authority-report.md
  checkpoint-recovery-report.md
  artifact-identity-report.md
  production-adoption-report.md   # only after separate authorization
```

Create artifacts only when the corresponding work runs. Do not pre-fill
success.

## Failure Policy

Any failure involving root identity, production fallback, pre-admission write,
operation-authority bypass, checkpoint completeness, or production artifact
identity is a blocker.

Do not compensate with warnings, cleanup, or a developer checklist. Correct the
structural boundary and rerun the gate.
