---
tier: project
scope: production-data-protection
owner: agent-per-project
last_reviewed: 2026-07-28
source_of_truth: implementation-plan
status: completed-with-documented-residual
links:
  - ./CURRENT-STATE-AUDIT.md
  - ./PROPOSAL.md
  - ./QUESTIONS.md
  - ./VALIDATION.md
  - ./PRODUCTION-PRESERVATION-AUTHORITY.md
  - ./PRODUCTION-PRESERVATION-HANDOFF-PLAN.md
tests: []
---

# Production Data Protection Implementation Plan

## Status

Slices 0-10 are implemented. The user authorized Slice 9, and production
adoption was executed on 2026-07-28. The current production application is
admitted and preserving new arrivals. Twelve non-image attachment rows from
the interrupted initial catch-up remain explicit reconciliation work.

| Slice | Status |
| --- | --- |
| 0 — Baseline and tripwires | Complete |
| 1 — Archive identity domain | Complete |
| 2 — Native identity and process claim | Complete, with bounded configuration adjustment below |
| 3 — Dart admission and markers | Complete |
| 4 — Persistent-store migration | Complete |
| 5 — Test environment enforcement | Complete |
| 6 — Operation authority | Complete |
| 7 — Checkpoint and recovery evidence | Complete on disposable archives |
| 8 — Tooling and build hardening | Complete without production launch |
| 9 — Production adoption | Complete with documented non-image attachment residual |
| 10 — Canonical documentation | Complete for the executed cutover state |

## Implementation Strategy

The work is divided into independently reviewable slices.

Three constraints govern sequencing:

1. inert infrastructure may land before activation; and
2. development isolation may not be declared active until **every** app-owned
   persistent write target derives from the admitted development archive; and
3. continuity of live production preservation must be demonstrated before
   every implementation slice begins and maintained for the slice's full
   duration.

There must be no intermediate state described as safe while databases are
isolated but logs, attachments, preferences, or background ingestion still
write production.

### Blocking Preservation Prerequisite

Every slice in this plan, and every later Production Readiness workstream
slice, must satisfy
[`PRODUCTION-PRESERVATION-AUTHORITY.md`](PRODUCTION-PRESERVATION-AUTHORITY.md)
before implementation starts.

The transitional interruption is over:

- development separation remains active;
- the current production application is admitted against the adopted archive;
- startup catch-up and later live preservation have been demonstrated;
- every subsequent slice must verify fresh preservation evidence before it
  begins;
- the bounded non-image attachment residual does not weaken the continuity
  requirement and must remain visible until reconciled.

After adoption, every slice must again identify the adopted production archive
and fresh evidence from the admitted process exercising preservation
authority. Production Health may consume and display this evidence later, but
the guarantee is owned here as a precondition to implementation.

The implementation sequence for making this guarantee mechanical is defined in
[`PRESERVATION-AUTHORITY-IMPLEMENTATION-PLAN.md`](PRESERVATION-AUTHORITY-IMPLEMENTATION-PLAN.md).
The transition from the legacy process to a current signed application is
defined in
[`PRODUCTION-PRESERVATION-HANDOFF-PLAN.md`](PRODUCTION-PRESERVATION-HANDOFF-PLAN.md).
The superseded initial admission observation is retained in
[`VALIDATION-RESULTS/preservation-continuity-admission-2026-07-27.md`](VALIDATION-RESULTS/preservation-continuity-admission-2026-07-27.md).
The current candidate and rehearsal evidence is recorded in
[`VALIDATION-RESULTS/production-candidate-and-adoption-rehearsal-2026-07-27.md`](VALIDATION-RESULTS/production-candidate-and-adoption-rehearsal-2026-07-27.md).

## Slice 0 — Baseline And Tripwire Inventory

### Objective

Freeze the current authority surface before changing it.

### Work

- add architecture tests inventorying every approved consumer of
  `databaseDirectoryPath`;
- inventory every provider/service that creates a database, directory, file,
  log, SharedPreferences entry, or attachment target;
- inventory all callers of graph build, reset, historical archive mutation, and
  attachment maintenance;
- add tests proving current native process-lock behavior with injected lock
  paths;
- capture current production bundle/build settings as test fixtures;
- remove no behavior.

### Exit evidence

- a failing tripwire appears if a new direct physical-root consumer is added;
- all current persistent write targets and mutation entry points are enumerated;
- no production data is read or changed.

## Slice 1 — Inert Archive Identity Domain

### Objective

Introduce pure identity and validation rules without changing startup paths.

### Work

Create a focused archive-environment essential owning:

- archive environment value;
- archive instance identity;
- native application claim payload;
- resolved archive identity;
- archive marker model/codec;
- identity compatibility validator;
- canonical root policy interface;
- archive-access authority value.

Add pure tests for:

- valid production/development/test combinations;
- bundle/environment mismatches;
- production signature requirements;
- marker mismatch and malformed marker;
- forbidden production fallback;
- test root requirements;
- immutable process identity.

### Constraints

- no database provider consumes the new types yet;
- no marker is written;
- no build setting changes;
- no production behavior changes.

## Slice 2 — Native Build Identity And Process Claim

### Objective

Make native bootstrap produce one truthful environment/archive claim.

### Work

- add explicit environment metadata to macOS build configuration;
- give Debug/Profile the development bundle and product identity;
- keep Debug and Profile on development identity; retain Release as
  production-shaped and fail closed unless expected production signing is
  present;
- retain existing production bundle/signing configuration;
- derive native lock location from the declared environment/archive root;
- validate production signing identity before granting a production claim;
- expose the immutable native claim through a narrow platform channel;
- update native tests for:
  - development/production lock separation;
  - duplicate same-archive exclusion;
  - invalid build identity rejection;
  - production signature rejection;
- update launch configuration so ordinary editor launches select development.

### Constraints

Flutter providers still use the compatibility root during this inert native
slice. Do not launch the partially migrated app against real data.

### Exit evidence

- built artifact metadata identifies production or development unambiguously;
- native claim and lock identity are testable without Flutter providers;
- production identity remains unchanged.

### Implemented adjustment

No separate development Release configuration was introduced. Profile is the
optimized development configuration. A locally built Release artifact retains
production-shaped metadata but cannot acquire production archive authority
without the expected production signature. The production packaging script is
the only supported production artifact path and verifies identity before
packaging.

## Slice 3 — Dart Admission And Marker Lifecycle

### Objective

Complete admission before any persistent Dart service initializes.

### Work

- receive the native claim immediately after Flutter binding initialization;
- validate the claim against Dart archive rules;
- resolve and canonicalize the root;
- read and validate the archive marker;
- permit automatic marker creation only for an empty canonical development root
  or an explicit test root;
- stop startup on any mismatch;
- create one immutable archive access authority;
- inject that authority into the root provider container;
- keep pre-admission diagnostics console/memory-only;
- prevent background monitor startup until admission completes.

### Tests

- marker create/read/mismatch/malformed tests in temporary directories;
- development rejects production marker;
- production refuses unmarked root outside adoption mode;
- test refuses platform Application Support;
- provider container cannot be created without admitted authority;
- admission failure starts no monitor or persistent logger.

## Slice 4 — Complete Persistent-Store Migration

### Objective

Replace the global free path with admitted archive authority everywhere.

### Work

Migrate:

- source-scoped import database;
- Conversation graph database;
- overlay database;
- attachment archive directory;
- onboarding environment/readiness probes;
- derived-data reset file store;
- database health/readiness services;
- pipeline audit and incident evidence;
- support-bundle archive evidence;
- application log directory;
- window state and SharedPreferences assumptions.

Remove:

- normal runtime dependence on the mutable/global
  `databaseDirectoryPath`;
- provider defaults that derive a physical production path independently;
- hard-coded `MessageLens` log directory for all environments.

Update architecture tests so only native/root-resolution infrastructure can
know physical environment locations.

### Activation rule

At the end of this slice:

- ordinary Debug/Profile writes only development state;
- a missing development root creates only the canonical development archive;
- no persistent service writes before admission;
- no fallback to production exists.

This is the first point at which development isolation may be described as
active.

## Slice 5 — Test Environment Enforcement

### Objective

Convert current test isolation conventions into a fail-closed contract.

### Work

- provide a standard test archive fixture with temporary root and marker;
- update database/provider tests to consume it;
- reject Application Support resolution in test environment;
- add a full-suite tripwire that records every persistent root opened;
- add integration-test bootstrap that cannot construct production authority;
- require cleanup/retention policy for failed test archives.

### Exit evidence

- full test suite opens only memory or registered temporary roots;
- deliberately requesting production from test fails before filesystem access.

## Slice 6 — Complete Operation Authority

### Objective

Make conflicting archive mutations mechanically exclusive.

### Work

- introduce/evolve one archive-mutation coordinator;
- route all protected operation entry points through named reentrant authority;
- cover live monitor, graph controller, onboarding, recovery, reset, historical
  archive workflows, and attachment maintenance;
- make maintenance/read-availability state derive from operation authority;
- remove bypasses and duplicate authority sources;
- record environment, archive instance, owner, timing, and denied requests;
- guarantee release in success, failure, cancellation, and provider disposal.

### Tests

- every entry point acquires authority;
- a competing owner is rejected or queued according to the settled policy;
- nested same-owner stages are accepted;
- exceptions release authority;
- reset cannot overlap live graph update;
- historical import cannot overlap graph build;
- overlay independence remains intact.

## Slice 7 — Checkpoint And Recovery Evidence

### Objective

Establish verified recovery evidence for high-risk production maintenance.

### Work

- define checkpoint manifest and validation report;
- implement offline snapshot analysis/inventory;
- include all archive data classes and attachments;
- verify SQLite integrity and sidecar handling;
- add restoration into a disposable verification root;
- compare restored archive identity, files, databases, and health report;
- expose checkpoint status to production maintenance admission;
- keep current manual protocol as fallback until the new evidence is proven.

### Constraints

Do not restore directly over production during development.

### Exit evidence

- one disposable archive has been snapshotted, restored, and objectively
  compared;
- high-risk operation admission can require a valid checkpoint receipt.

## Slice 8 — Tooling And Production Build Hardening

### Objective

Ensure command-line and release workflows cannot bypass archive identity.

### Work

- update `tool/build_and_notarize.sh` to select and verify production
  configuration explicitly;
- verify bundle ID, environment metadata, signing team, signing identity, and
  entitlements before packaging;
- reject development artifacts;
- migrate or retire writable maintenance scripts outside admitted seams;
- document development, development-release, and production commands;
- add artifact-inspection tests/scripts that do not launch production.

## Slice 9 — Existing Production Archive Adoption

### Objective

Adopt the current permanent archive without moving or rewriting its contents.

### Authorization status

The user authorized the operation, and it was executed on 2026-07-28. See
[`PRODUCTION-ADOPTION-RUNBOOK.md`](PRODUCTION-ADOPTION-RUNBOOK.md).

### Preconditions

- Slices 0-8 complete and validated;
- exact checkpoint/adoption/rollback tooling verified on disposable archives;
- signed production candidate identity verified;
- development isolation proven;
- adoption runbook reviewed.

Before real cutover, the candidate must proceed through the normal notarized
distribution path, the verified external recovery backup must be available,
and the small read-only adoption inventory must be refreshed.

### Procedure

1. confirm no MessageLens process is using the production root;
2. verify native lock is free;
3. confirm the verified external recovery backup;
4. inventory the production root read-only without copying payload;
5. verify database health and expected archive files;
6. create the production marker atomically from the verified inventory plan;
7. install and launch only the verified signed and notarized production
   artifact;
8. verify archive identity and normal read behavior;
9. verify startup catch-up and production attachment preservation;
10. launch development and prove it resolves a different archive;
11. preserve the backup reference, inventory, and adoption report.

### Rollback

If marker/admission validation fails, stop the application and restore the
pre-adoption state according to the verified recovery runbook. Do not repair
identity by editing the marker ad hoc.

## Slice 10 — Canonical Documentation Promotion

### Objective

Move implemented truths out of the workstream package.

Update canonical owners:

- database identity and provider construction;
- environment safety and recovery;
- build/signing/FDA continuity;
- onboarding and archive workflows;
- import/graph operation authority;
- developer commands and agent guardrails.

Mark this workstream complete only after code, tests, runtime evidence, and
canonical documentation agree.

## Files And Layers Expected To Change

Implementation planning currently identifies these areas:

```text
macos/Runner/
macos/Runner/Configs/
macos/RunnerTests/
lib/main.dart
lib/essentials/db/
lib/essentials/logging/
lib/essentials/window_state/
lib/essentials/onboarding/
lib/essentials/conversation_graph/
lib/features/settings/ (archive workflow entry points)
lib/features/attachments/
test/
tool/
.vscode/
```

Feature business logic should change only where it enters mutation authority.
The environment system must not absorb import, graph, attachment, onboarding,
or overlay semantics.

## Release And Versioning

Activation of development/production isolation is release-worthy:

- bump `pubspec.yaml`;
- update `CHANGELOG.md`;
- retain production bundle/signing identity;
- capture screenshots only if user-facing diagnostics change;
- use a feature branch and reviewed merge.

Production archive adoption is an operational event and receives its own
durable completion report in addition to release notes.

## Stop Conditions

Stop implementation immediately if:

- any development path still resolves production after Slice 4;
- native and Dart identity differ;
- a provider writes before admission;
- production identity or path would change;
- marker adoption would occur during ordinary startup;
- operation authority has an uncovered mutating entry point;
- snapshot restoration cannot reproduce a healthy disposable archive;
- a test resolves Application Support unexpectedly.
