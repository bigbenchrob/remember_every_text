---
tier: project
scope: production-data-protection
owner: agent-per-project
last_reviewed: 2026-07-28
source_of_truth: implementation-record
status: completed-with-documented-residual
links:
  - ./README.md
  - ./IMPLEMENTATION-PLAN.md
  - ./VALIDATION.md
  - ./PRODUCTION-ADOPTION-RUNBOOK.md
  - ./VALIDATION-RESULTS/production-cutover-2026-07-28.md
tests:
  - flutter analyze
  - flutter test
  - macos/RunnerTests/RunnerTests.swift
---

# Production Data Protection Completion Report

## Scope Completed

Slices 0-8 established the non-production boundary:

- immutable archive environment, build identity, archive instance, marker, and
  access-authority types;
- native macOS claim resolution and archive-scoped single-process admission
  before Flutter provider startup;
- Dart marker validation and fail-closed provider admission;
- authority-derived databases, attachments, logs, operational evidence,
  support exports, reset stores, and overlay-backed window state;
- explicit temporary test archives with no Application Support fallback;
- one reentrant archive mutation coordinator covering protected workflows;
- complete offline checkpoint manifests, receipts, integrity verification, and
  restore verification into a new disposable root;
- artifact identity verification and a hardened production packaging entry
  point.
- a non-publishing signed production-candidate path;
- explicit checkpoint-backed production adoption and rollback tooling;
- disposable adoption, production-admission, catch-up-import, and attachment
  preservation rehearsal.
- authorized in-place adoption of the existing production archive;
- installation and launch of signed, notarized production build `0.2.17+35`;
- verified startup catch-up and later live message/attachment preservation;
- separate external-root verification for the development identity.

`database_directory.dart`, the separate graph-maintenance execution gate, and
SharedPreferences-backed window storage were retired because they bypassed or
duplicated the new authority chain.

## Bounded Implementation Adjustments

Profile, rather than a separate development Release configuration, is the
optimized development artifact. Release remains production-shaped and fails
closed unless expected production signing is present.

Development artifact verification uses strict top-level code-signature
verification. Recursive `--deep` verification remains mandatory for production
because one third-party Debug framework has no resource seal even though the
application signature itself is valid.

Development root selection also supports one machine-local environment
override. It is accepted only for development identity, must name an existing
absolute writable directory, and is canonicalized independently by native and
Dart admission. The override replaces the complete development archive root;
no database, attachment, or logging subsystem receives separate path
authority.

## Validation Summary

- `flutter analyze`: clean.
- production-candidate/adoption focused suite: 68 tests passed.
- architecture tripwires: 352 tests passed.
- full Flutter suite: 1,442 tests passed.
- focused architecture/attachment regression suite: 358 tests passed.
- macOS native admission suite: seven cases.
- artifact verifier suite: five cases.
- checkpoint CLI help and refusal contract: verified.
- in-place adoption inventory: 25,982 files and seven SQLite databases recorded
  read-only without copying archive payload.
- Debug artifact: built as `MessageLens Development.app` and accepted only as
  development.
- External development root: native and Dart admission agreed on
  `/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development`,
  initialized a development marker there, and routed the marker, lock, logs,
  import database, and overlay database beneath it.
- Internal development archive: retained in place with its pre-verification
  file checksums unchanged.

All pre-cutover filesystem tests used temporary or synthetic archive roots.
The user separately authorized the real operation on 2026-07-28. The existing
production root was adopted in place and the current production application
was launched against it. Full execution evidence is recorded in
[`VALIDATION-RESULTS/production-cutover-2026-07-28.md`](VALIDATION-RESULTS/production-cutover-2026-07-28.md).

The signed production candidate is retained at
`build/production-candidate/MessageLens.app`. Its bundle identifier,
production metadata, signing team, entitlements, and absence of development
root metadata passed static verification. Candidate-only mode did not notarize,
install, launch, package, or publish it.

## Remaining Follow-Up

1. Keep the current production application running as the admitted
   preservation process and require fresh evidence before later slices.
2. Retain the verified recovery backup, cutover inventory, and legacy
   application archive.
3. Install a production build containing generalized delayed retry and verify
   recovery of the three conventional QuickTime rows left by the interrupted
   initial catch-up.
4. Keep the nine NULL-MIME plugin payload rows inventoried and excluded until
   their preservation semantics are explicitly decided.

Production adoption itself is complete.
