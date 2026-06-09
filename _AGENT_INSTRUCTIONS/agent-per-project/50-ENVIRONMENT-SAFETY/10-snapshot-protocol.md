# SNAPSHOT PROTOCOL

## Purpose

Define the required procedure for creating a safe, restorable snapshot of MessageLens application data before any high-risk operation.

This protocol MUST be followed before:

- schema changes
- source import, graph projection, retained import/projection, or overlay
  schema changes
- archival import experiments
- any operation that may mutate `macos_import_ss.db`, `working_ss.db`,
  `macos_import.db`, `working.db`, or `user_overlays.db`

---

## Assumptions

This protocol assumes:

- The attachments archive is backed up independently (e.g. via CCC)

- Attachment files are not mutated during typical development workflows

If these assumptions are not true, a full snapshot including attachments is required.

---

## Scope

Application data folder:

~/Library/Application Support/com.bigbenchsoftware.MessageLens

Includes:

- macos_import_ss.db (source-scoped import ledger)
- working_ss.db (conversation graph projection)
- macos_import.db (retained archive/recovery compatibility ledger)
- working.db (retained archive/recovery compatibility projection)
- user_overlays.db
- any matching SQLite sidecar files (`*.db-wal`, `*.db-shm`) if present
- logs

---

## Attachment Handling

The attachments archive is large and does not need to be copied for every snapshot.

Default behavior:

- Snapshot MUST include all database files
- The app-owned attachment archive SHOULD NOT be copied unless explicitly
  required

Archived attachment files are assumed to be stored separately and persist
across snapshots.

If attachment integrity is being tested, a full snapshot including attachments may be required.

---

## Core Principle

Snapshots must be:

- complete for database state (all .db files and relevant config/logs)

- timestamped

- immutable after creation

- easily restorable

Note:

Routine snapshots intentionally exclude the attachments archive.

Archived attachments are managed separately via external backup.

---

## Procedure

1. Ensure MessageLens app is NOT running

2. Create snapshot directory:

~/Desktop/MessageLens-backups/

3. Execute:

rsync -a --exclude 'attachment_archive' \
 ~/Library/Application\ Support/com.bigbenchsoftware.MessageLens/ \
 ~/Desktop/MessageLens-backups/MessageLens-$(date +%Y-%m-%d-%H%M)

Note:

The app-owned `attachment_archive` directory is explicitly excluded from
routine database snapshots.

4. Verify snapshot exists and contains:

- macos_import_ss.db
- working_ss.db
- macos_import.db
- working.db
- user_overlays.db
- any copied SQLite sidecar files if they existed at snapshot time
- expected file sizes (non-zero)

---

## Success Criteria

- snapshot folder exists
- databases present
- no errors during copy

---

## Failure Handling

If snapshot fails:

- STOP all further work
- resolve filesystem or permission issue
- retry

---

## Agent Instruction

When instructed:

"Perform snapshot protocol"

Agent MUST:

- output exact command to be run
- require user confirmation of success
- NOT proceed until confirmed

---

END
