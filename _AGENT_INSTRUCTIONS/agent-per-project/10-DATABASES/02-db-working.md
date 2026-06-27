---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-06-21
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

# `db-working` - Retired Cleanup/Diagnostic File (`working.db`)

## Overview

`db-working` is the retired `working.db` cleanup filename. The Drift schema and
migrator implementation have been retired from active app code. Existing user
data folders may still contain a retired projection file, and reset or
read-only diagnostics must tolerate that file.

> Current conformance note (2026-06-08): ordinary Flutter UI reads now use the
> source-scoped conversation graph in `working_ss.db` through
> `driftConversationGraphDatabaseProvider` and graph read models. Do not add
> new product-facing read behavior to `working.db`, and do not reintroduce a
> general app provider for it.

- **Alias**: `db-working`
- **Physical File**: `~/Library/Application Support/com.bigbenchsoftware.MessageLens/working.db`
- **Primary Consumers**: Reset cleanup and read-only diagnostics

## File Location

| Item | Value |
| --- | --- |
| Directory | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/`
| Filename | `working.db`
| Provisioning | Retired cleanup-file storage only; no central app provider remains |
| Backups | External/operational backup if configured; not owned by the working database provider |

Manual access requires shutting down the Flutter app and orchestration tooling
to avoid WAL/locking conflicts.

## Access Boundary

There is no central app provider for retired `working.db`. Ordinary app
reads, search, timelines, heatmaps, recovered-message evidence, and contact
identity use the source-scoped graph and Message Evidence Spine.

Reset may delete the retired file alongside other derived-data files.
Diagnostics may inspect the retired file through explicit read-only file query
boundaries. New product or compatibility work must not reintroduce a general
provider for this database without a reviewed storage-retirement decision.

## Retired File Contents

The old Drift schema implementation has been retired from app code.
Existing user data folders may still contain a historical `working.db` file
with the old projection tables, but MessageLens no longer opens that file
through a Drift database class.

Representative historical tables that may still appear in old files:

| Table | Purpose |
| --- | --- |
| `handles_canonical` / `handles_canonical_to_alias` | Canonical handle registry and alias mapping preserved from import. |
| `participants` | Projection of AddressBook contacts (IDs == original `Z_PK`). The Drift class is `WorkingParticipants`; the SQL table is `participants`. |
| `handle_to_participant` | Links canonical handles to participants with confidence data. |
| `chat_to_handle` | Chat membership referencing canonical handle IDs. |
| `chats` | Chat metadata (service, title, derived counters). |
| `messages` | Message records referencing chat + handle IDs, along with derived UI flags. |
| `recovered_unlinked_messages` / `recovered_unlinked_attachments` | Preserved source rows and attachments that are not linked through normal chat-message joins. |
| `global_message_index` / `message_index` / `contact_message_index` | Retired legacy ordinal-index tables. Ordinary timeline navigation and heatmap coordination now use graph evidence skeletons. |
| `attachments` | Projected attachment metadata keyed to message GUIDs and import attachment IDs. |
| `reactions` / `reaction_counts` | Projected tapbacks and cached reaction totals. |
| `read_state` / `message_read_marks` | Chat-level and message-level read-state projection. |

## Typical Use Cases

- Reset cleanup may delete retired `working.db` files.
- Diagnostics may inspect the retired file through read-only file query
  boundaries while legacy storage remains in user data folders.
- Historical documentation may refer to old projection tables when explaining
  migration decisions.

Remember: `db-working` is retired transitional cleanup storage, not the ordinary app
truth. Historical retired projection concepts may still appear in schema
records, but ordinary MessageLens evidence, search, timelines, and heatmaps use
the source-scoped graph. Any manual edits are unsupported and may make retired
diagnostics inconsistent.

## Related Rules & Contracts

- **Source identity remains traceable in retired cleanup/diagnostic files**: Chat
  IDs/GUIDs, message IDs/GUIDs, handle IDs, and participant IDs should remain
  interpretable from old `db-import` / `db-working` pairs. See
  `10-group-import-working.md` for the historical compatibility flow.
- **Overlay independence**: `db-working` never writes to `db-overlay`, and vice versa. Providers merge overlay data at runtime (see `07-overlay-database-independence.md`).
- **No general provider access**: do not reintroduce a general retired
  `working.db` app provider. Use graph/overlay/source-scoped import providers
  for active behavior, and explicit read-only diagnostic boundaries for
  retired file inspection.

## Cross-References

- `10-group-import-working.md` — Historical retired pipeline rules.
- `01-db-import.md` — Retired import cleanup-file details.
- `07-overlay-database-independence.md` — Runtime merge strategy for overlay data.
- `../55-READERS-INTEGRATORS-ORCHESTRATORS/81-LEGACY-STORAGE-RETENTION-REGISTER.md` — Current retired cleanup-inventory status.
