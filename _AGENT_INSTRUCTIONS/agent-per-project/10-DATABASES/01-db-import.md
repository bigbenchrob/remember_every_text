---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-06-20
source_of_truth: doc
links:
  - ./00-all-databases-accessed.md
  - ./02-db-working.md
  - ./03-db-address-book.md
  - ./04-db-chat.md
  - ./10-group-import-working.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
  - ../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
  - ../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
tests: []
---

# `db-import` - Retired Import Cleanup File (`macos_import.db`)

## Overview

`db-import` is the retired `macos_import.db` cleanup filename. Existing user data
folders may still contain historical legacy ledger tables or older retired
archive-source metadata from earlier versions, and diagnostics/reset code must
tolerate those files.

> Current conformance note (2026-06-20): ordinary graph-era import work uses
> `macos_import_ss.db` via source-scoped import providers. Archive-source
> metadata now lives in `user_overlays.db` behind overlay-owned services. Do not
> add new product-facing behavior or provider access to `macos_import.db`; it is
> transitional cleanup storage only.

- **Alias**: `db-import`
- **Physical File**: `~/Library/Application Support/com.bigbenchsoftware.MessageLens/macos_import.db`
- **Primary Consumers**: Read-only database health diagnostics and reset cleanup

## File Location

| Item | Value |
| --- | --- |
| Directory | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/`
| Filename | `macos_import.db`
| Provisioning | No active provider should create this file. Existing files may be inspected read-only by diagnostics or removed by reset cleanup. |
| Backups | External/operational backup if configured; not owned by the import database provider |

Do not add provider access for this file. Manual SQLite clients can lock files
while the app runs; use read-only diagnostic boundaries when inspection is
deliberately required.

## Schema

`db-import` is a retired plain SQLite/Sqflite database. The old retired
metadata adapter has been removed from active code.

Existing user folders may still contain older tables such as `messages`,
`attachments`, `recovered_unlinked_messages`, or `import_batches`. Treat them as
historical retired storage inventory. Do not build new ordinary features on
those tables.

## Typical Use Cases

- Inspect old `macos_import.db` files read-only during diagnostics.
- Delete the retired file during full derived-data reset.

Because historical user files may still contain retired ledger or metadata tables,
diagnostics should report what exists without treating those tables as active
app truth.

## Related Rules & Contracts

- **No active provider access**: Archive-source metadata belongs to overlay-owned
  services. Do not recreate retired `macos_import.db` provider access.
- **No active import semantics**: Source identity, rich text, reactions,
  recovered/orphan evidence, and attachment topology now belong to
  `macos_import_ss.db` and `working_ss.db`, not `macos_import.db`.

## Cross-References

- `10-group-import-working.md` — Retired import/working contract.
- `02-db-working.md` — Retired projection cleanup-file status.
- `../55-READERS-INTEGRATORS-ORCHESTRATORS/81-LEGACY-STORAGE-RETENTION-REGISTER.md` — Current retired cleanup-inventory status.
