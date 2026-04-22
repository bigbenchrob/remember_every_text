---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-04-21
source_of_truth: doc
links:
  - ./00-all-databases-accessed.md
  - ./01-db-import.md
  - ./05-db-overlay.md
  - ./10-group-import-working.md
  - ./07-overlay-database-independence.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
  - ../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
tests: []
---

# `db-working` — Drift Projection (`working.db`)

## Overview

`db-working` is the Drift-managed projection the Flutter application reads from. Migrators translate the source-derived ledger in `db-import` into normalized tables tailored for UI queries, search/index access, analytics, and provider-backed state.

- **Alias**: `db-working`
- **Physical File**: `~/Library/Application Support/com.bigbenchsoftware.MessageLens/working.db`
- **Primary Consumers**: Flutter UI, background services, analytics tooling

## File Location

| Item | Value |
| --- | --- |
| Directory | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/`
| Filename | `working.db`
| Provisioning | Created/opened by `driftWorkingDatabaseProvider` using Drift + `NativeDatabase.createInBackground` |
| Backups | External/operational backup if configured; not owned by the working database provider |

Manual access requires shutting down the Flutter app and orchestration tooling to avoid WAL/locking conflicts.

## Provider Access

- **Riverpod entry point**: `driftWorkingDatabaseProvider`
- **Definition**: `lib/essentials/db/feature_level_providers.dart`
- **Type**: `Future<WorkingDatabase>` (Drift `GeneratedDatabase`)

Usage pattern:

```dart
final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
```

Do not instantiate `WorkingDatabase` directly—providers configure foreign key pragmas and lifecycle management.

## Schema & Drift Definitions

- Drift database: `lib/essentials/db/infrastructure/data_sources/local/working/working_database.dart`
- See `_AGENT_INSTRUCTIONS/agent-per-project/20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` for full table listings and relationships.

Representative tables:

| Table | Purpose |
| --- | --- |
| `handles_canonical` / `handles_canonical_to_alias` | Canonical handle registry and alias mapping preserved from import. |
| `participants` | Projection of AddressBook contacts (IDs == original `Z_PK`). The Drift class is `WorkingParticipants`; the SQL table is `participants`. |
| `handle_to_participant` | Links canonical handles to participants with confidence data. |
| `chat_to_handle` | Chat membership referencing canonical handle IDs. |
| `chats` | Chat metadata (service, title, derived counters). |
| `messages` | Message records referencing chat + handle IDs, along with derived UI flags. |
| `recovered_unlinked_messages` / `recovered_unlinked_attachments` | Preserved source rows and attachments that are not linked through normal chat-message joins. |
| `global_message_index` / `message_index` / `contact_message_index` | Rebuilt ordinal indexes for global, chat, and contact timelines. |
| `attachments` | Projected attachment metadata keyed to message GUIDs and import attachment IDs. |
| `reactions` / `reaction_counts` | Projected tapbacks and cached reaction totals. |
| `read_state` / `message_read_marks` | Chat-level and message-level read-state projection. |

## Typical Use Cases

- Powering UI providers and queries for chats, messages, participants, and overlays.
- Running analytics or smoke checks against the user-facing projection.
- Verifying that migrations honored source IDs and relationships.

Remember: `db-working` is projection-owned. Full migration clears migrator target tables and rebuilds them; incremental migration preserves existing rows and applies migrator-specific inserts/updates. Any manual edits are unsupported and may be overwritten or made inconsistent by the next migration.

## Related Rules & Contracts

- **Source identity remains traceable**: Chat IDs/GUIDs, message IDs/GUIDs, handle IDs, and participant IDs must remain traceable from `db-import`. Canonical handle/participant tables may normalize relationships, but must not hide source identity. See `10-group-import-working.md` for the canonical flow.
- **Overlay independence**: `db-working` never writes to `db-overlay`, and vice versa. Providers merge overlay data at runtime (see `07-overlay-database-independence.md`).
- **Provider-only access**: Always request the database via `driftWorkingDatabaseProvider` to avoid locking conflicts and to ensure foreign key enforcement is enabled.

## Cross-References

- `10-group-import-working.md` — Pipeline rules governing how data arrives here.
- `01-db-import.md` — Source ledger feeding this projection.
- `07-overlay-database-independence.md` — Runtime merge strategy for overlay data.
- `../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md` — Service orchestrating projections into `db-working`.
