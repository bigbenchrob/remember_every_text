---
tier: project
scope: production-data-protection
owner: agent-per-project
last_reviewed: 2026-07-28
source_of_truth: implementation-plan
status: executed
links:
  - ./04-REVISED-OPERATIONAL-STATE.md
  - ./PRODUCTION-PRESERVATION-AUTHORITY.md
  - ./PRODUCTION-ADOPTION-RUNBOOK.md
  - ./VALIDATION-RESULTS/final-cutover-preparation-2026-07-28.md
  - ./VALIDATION-RESULTS/production-cutover-2026-07-28.md
  - ../../../60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md
tests: []
---

# Production Preservation Handoff Plan

## Purpose

Establish a current signed production application as the admitted preservation
authority for the existing production archive without moving, recreating, or
rewriting the archive merely to establish identity.

This plan did not itself authorize production launch, installation, archive
adoption, or mutation. The user later supplied that authorization, and the
handoff was executed on 2026-07-28.

## Current And Target States

Current achieved state:

- a current signed and notarized `MessageLens.app` continuously owns production
  preservation;
- it retains bundle identifier `com.bigbenchsoftware.MessageLens`, team and
  signing identity, Full Disk Access continuity, and the existing canonical
  production root;
- Debug/Profile continues to use `MessageLens Development` and only the
  external development archive;
- production and development coexist without sharing writable state.

The operation and bounded attachment residual are recorded in
[`VALIDATION-RESULTS/production-cutover-2026-07-28.md`](VALIDATION-RESULTS/production-cutover-2026-07-28.md).

## Governing Rules

1. Do not undo development isolation or repoint Debug/Run at production.
2. Do not launch the months-old installed application merely because it has the
   production bundle identifier.
3. Do not launch the signed candidate against production before authorization.
4. Do not launch two processes against the production root.
5. Do not move or rebuild production databases or attachments as part of
   adoption.
6. Do not create or edit the production marker ad hoc.
7. Preserve the old installed artifact, verified external recovery backup, and
   adoption inventory until the successor has demonstrated catch-up and
   attachment preservation.

## Preparation Completed

The non-publishing candidate path:

```text
./tool/build_and_notarize.sh --candidate-only
```

builds, signs, verifies, and copies a candidate to:

```text
build/production-candidate/MessageLens.app
```

It does not create a DMG, submit for notarization, publish tester artifacts,
install, or launch the application.

The candidate has passed static checks for production bundle/product identity,
environment metadata, signing identity and team, entitlements, canonical-root
policy, development-metadata absence, and Full Disk Access continuity
expectations.

The explicit checkpoint, restore, marker adoption, production admission,
catch-up import, attachment preservation, and rollback behavior have been
exercised on disposable archives. This preparation did not contact or mutate
the real production archive.

## Remaining Preparation

Before real cutover:

1. run the broader focused regression suite and analyzer;
2. produce the final artifact through the normal notarized distribution path;
3. verify the notarized artifact with the production identity verifier;
4. resolve the Apple developer-account agreement blocking notarization;
5. confirm no MessageLens process is using the production root;
6. refresh the small read-only adoption inventory immediately before cutover;
7. obtain explicit authorization.

The signed candidate is readiness evidence. It is not the final installed
artifact because candidate-only mode intentionally omits notarization.

## Authorized Cutover Shape

Under separate explicit authorization:

1. confirm no MessageLens process is using the production root;
2. verify the production-root native lock is free;
3. confirm the verified external recovery backup is available;
4. create a read-only in-place adoption inventory:

   ```bash
   dart run tool/production_archive_adoption.dart inventory \
     --source "$HOME/Library/Application Support/com.bigbenchsoftware.MessageLens" \
     --inventory "<new-small-inventory-root>"
   ```

5. adopt the unchanged real archive from the verified inventory:

   ```bash
   dart run tool/production_archive_adoption.dart adopt \
     --root "$HOME/Library/Application Support/com.bigbenchsoftware.MessageLens" \
     --inventory "<inventory-root>"
   ```

6. verify production admission:

   ```bash
   dart run tool/production_archive_adoption.dart verify-admission \
     --root "$HOME/Library/Application Support/com.bigbenchsoftware.MessageLens"
   ```

7. install and launch only the verified signed and notarized production
   artifact;
8. verify canonical root, marker, bundle, signing, Full Disk Access, archive
   admission, database health, overlays, and attachments;
9. verify startup catch-up crosses the pre-cutover source cursor;
10. verify attachment preservation for the catch-up range;
11. publish fresh durable preservation-authority evidence;
12. launch development separately and prove it still resolves only the
    external development archive.

There is no process handoff from a legacy Debug authority. The cutover restores
preservation from a currently unowned state.

## Abort And Rollback

Before any payload change, marker adoption can be rolled back only through:

```bash
dart run tool/production_archive_adoption.dart rollback \
  --root "$HOME/Library/Application Support/com.bigbenchsoftware.MessageLens" \
  --inventory "<inventory-root>"
```

The adoption service verifies that the archive payload still matches the
inventory plan. Once startup catch-up or any other write changes the payload,
rollback is mechanically refused.

After payload mutation:

1. stop the successor;
2. preserve all failure evidence;
3. do not delete/edit the marker or databases ad hoc;
4. restore the verified external backup into a separate destination;
5. compare and diagnose before any further production operation;
6. resume only through a reviewed recovery procedure.

The months-old installed application is not an automatic fallback.

## Normal Coexistence

After successful cutover:

- the signed production application is the sole production preservation
  authority;
- Debug/Profile may run against the external development archive;
- native and Dart admission agree independently on both roots;
- authority evidence, not process presence, determines preservation health;
- VS Code Run is never again treated as production deployment.
