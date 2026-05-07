# SNAPSHOT PROTOCOL

## Purpose

Define the required procedure for creating a safe, restorable snapshot of MessageLens application data before any high-risk operation.

This protocol MUST be followed before:

- schema changes
- import/migration changes
- archival import experiments
- any operation that may mutate macos_import.db or working.db

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

- macos_import.db (authoritative ledger)
- working.db (projection)
- user_overlays.db
- logs

---

## Attachment Handling

The attachments archive is large and does not need to be copied for every snapshot.

Default behavior:

- Snapshot MUST include all database files
- Attachments folder SHOULD NOT be copied unless explicitly required

Attachments are assumed to be stored separately and persist across snapshots.

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

Attachments are managed separately via external backup.

---

## Procedure

1. Ensure MessageLens app is NOT running

2. Create snapshot directory:

~/Desktop/MessageLens-backups/

3. Execute:

rsync -a --exclude 'Attachments' \
 ~/Library/Application\ Support/com.bigbenchsoftware.MessageLens/ \
 ~/Desktop/MessageLens-backups/MessageLens-$(date +%Y-%m-%d-%H%M)

Note:

The Attachments directory is explicitly excluded from routine snapshots.

4. Verify snapshot exists and contains:

- macos_import.db
- working.db
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
