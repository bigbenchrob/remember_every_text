---
tier: project
scope: production-data-protection
owner: agent-per-project
last_reviewed: 2026-07-28
source_of_truth: runbook
status: executed-with-documented-residual
links:
  - ./04-REVISED-OPERATIONAL-STATE.md
  - ./PRODUCTION-PRESERVATION-HANDOFF-PLAN.md
  - ./VALIDATION.md
  - ./VALIDATION-RESULTS/final-cutover-preparation-2026-07-28.md
  - ./VALIDATION-RESULTS/production-cutover-2026-07-28.md
tests: []
---

# Production Archive Adoption Runbook

## Execution Status

> The user authorized this operation, and it was executed on 2026-07-28.

The commands below remain the reviewed procedure and audit record. The
production archive is now adopted. Do not rerun adoption against it. See
[`VALIDATION-RESULTS/production-cutover-2026-07-28.md`](VALIDATION-RESULTS/production-cutover-2026-07-28.md)
for the actual execution evidence and bounded attachment residual.

## Current Operational Fact

Debug/Run is isolated to the development identity and external development
archive. The installed current production application now operates against the
adopted production archive and exercises live preservation.

Do not undo that isolation and do not use the months-old installed application
as an automatic fallback.

## Preconditions

- focused tests and analyzer pass for the cutover revision;
- the final production artifact is signed, notarized, stapled, and accepted by
  `tool/verify_macos_archive_identity.sh`;
- the production root is confirmed offline and unused by MessageLens;
- the existing external recovery backup remains available and verified;
- pre-cutover database health, source cursor, record counts, overlay state, and
  attachment inventory are recorded read-only;
- rollback ownership and evidence locations are explicit;
- the operator acknowledges that adoption creates the real production marker;
- explicit cutover authorization has been given.

## Procedure

Set operational paths explicitly:

```bash
PRODUCTION_ROOT="$HOME/Library/Application Support/com.bigbenchsoftware.MessageLens"
BACKUP_ROOT="/Volumes/WD_ELEMENTS/DATA_FOLDER_27-07-2026/com.bigbenchsoftware.MessageLens"
INVENTORY_ROOT="<new-small-adoption-inventory-root>"
```

Then:

1. Confirm no MessageLens process is using `PRODUCTION_ROOT` and the native
   production lock is free.
2. Confirm that `BACKUP_ROOT` remains mounted, readable, and unchanged from the
   verified recovery evidence.
3. Record a new read-only adoption inventory:

   ```bash
   dart run tool/production_archive_adoption.dart inventory \
     --source "$PRODUCTION_ROOT" \
     --inventory "$INVENTORY_ROOT"
   ```

   The inventory contains hashes, SQLite health evidence, and the planned
   archive identity. It does not copy archive payload and is not a backup.
4. Compare the inventory summary with the retained pre-cutover evidence.
5. Adopt the unchanged production root in place:

   ```bash
   dart run tool/production_archive_adoption.dart adopt \
     --root "$PRODUCTION_ROOT" \
     --inventory "$INVENTORY_ROOT"
   ```

6. Verify production admission before launching:

   ```bash
   dart run tool/production_archive_adoption.dart verify-admission \
     --root "$PRODUCTION_ROOT"
   ```

7. Install and launch only the verified signed and notarized current
   production artifact.
8. Verify bundle/signing identity, canonical root, marker/archive identity,
   Full Disk Access, databases, overlays, and attachments.
9. Verify startup catch-up advances from the pre-cutover source cursor.
10. Verify attachment preservation processes the catch-up range successfully.
11. Retain the recovery backup, inventory manifest, logs, and post-cutover
    evidence.
12. Launch Debug separately and verify it opens only the external development
    archive.

## Abort Before Payload Mutation

If adoption or admission fails before the application changes archive payload:

```bash
dart run tool/production_archive_adoption.dart rollback \
  --root "$PRODUCTION_ROOT" \
  --inventory "$INVENTORY_ROOT"
```

The tool removes only the exact planned marker from an otherwise unchanged
payload.

## Failure After Payload Mutation

Once catch-up or any other production write occurs, marker rollback is
mechanically refused.

1. Stop the successor.
2. Preserve all evidence.
3. Do not edit the marker, databases, or attachment archive ad hoc.
4. Restore the verified external backup into a separate destination.
5. Diagnose and plan recovery from known evidence.

Preparing this runbook does not weaken ordinary startup: an unmarked production
archive is still refused, and ordinary application startup cannot adopt it.

The full checkpoint/restore commands remain available for disposable recovery
rehearsals. They are not part of this real cutover because a complete verified
recovery backup already exists.
