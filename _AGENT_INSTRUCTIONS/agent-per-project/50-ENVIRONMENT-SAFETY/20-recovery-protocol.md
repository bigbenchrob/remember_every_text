# RECOVERY PROTOCOL

## Purpose

Define the procedure for restoring MessageLens application data from a snapshot.

---

## Core Principle

Recovery is preferred over repair.

Do NOT attempt to fix corrupted databases in-place.

---

## Procedure

1. Ensure MessageLens app is NOT running

2. Identify snapshot folder:

~/Desktop/MessageLens-backups/MessageLens-YYYY-MM-DD-HHMM

3. Move current data folder:

mv \
 ~/Library/Application\ Support/com.bigbenchsoftware.MessageLens \
 ~/Library/Application\ Support/com.bigbenchsoftware.MessageLens.corrupted-$(date +%Y-%m-%d-%H%M)

4. Restore snapshot:

cp -R \
 ~/Desktop/MessageLens-backups/MessageLens-YYYY-MM-DD-HHMM \
 ~/Library/Application\ Support/com.bigbenchsoftware.MessageLens

---

## Verification

After relaunch:

- app starts normally
- source-scoped graph message counts are plausible
- overlay intent such as favourites and contact display-name overrides is present
- retained archive/recovery compatibility databases are present if they existed
  in the snapshot
- no graph build, retained projection, or overlay recovery errors are shown
- UI behaves correctly

---

## Failure Handling

If recovery fails:

- verify snapshot integrity
- ensure correct folder paths
- retry

---

## Agent Instruction

When instructed:

"Perform recovery protocol using snapshot X"

Agent MUST:

- output exact commands
- confirm user has selected correct snapshot
- require confirmation before proceeding

---

END
