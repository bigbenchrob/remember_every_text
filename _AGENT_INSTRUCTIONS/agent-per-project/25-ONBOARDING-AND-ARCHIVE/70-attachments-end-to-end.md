---
tier: project
scope: onboarding-and-archive
owner: agent-per-project
last_reviewed: 2026-06-04
source_of_truth: doc
links:
  - ./40-attachment-archive.md
  - ./50-deterministic-recovery.md
  - ./60-reimport-and-ongoing-sync.md
  - ../15-MACOS-SOURCE-DATABASES/00-overview.md
  - ../20-DATA-IMPORT-MIGRATION/01-overview.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
  - ../10-DATABASES/02-db-working.md
  - ../10-DATABASES/05-db-overlay.md
  - ../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/00-overview.md
tests: []
---

# Attachments End To End

## TL;DR

MessageLens uses an archive-first attachment model.

- The app-owned archive is the only durable attachment file source for UI rendering.
- Live Apple Messages files are ingestion sources only. They are useful when present, but they are not durable storage and must not be treated as stable.
- Deterministic recovery uses a historical `chat.db` snapshot and matching historical `Attachments` folder to map old files back to current `(message_guid, import_attachment_id)` identity and write archive metadata into the overlay database.

Only the source-scoped graph/import pipeline defines durable app-facing
MessageLens semantics. Source database observations, row counts, orphan counts,
and Apple path behavior are diagnostic evidence, not guarantees. Retained
legacy import/working identities remain compatibility bridges for archive and
recovery flows until those flows are fully graph-native.

## 1. Source Reality (Apple `chat.db`)

Apple `chat.db` stores attachment metadata in the `attachment` table and message-to-attachment relationships in `message_attachment_join`.

The source path column MessageLens imports is Apple `attachment.filename`. MessageLens stores that value as `local_path`.

Treat `attachment.filename` / `local_path` as volatile:

- iCloud may evict attachment files while leaving `chat.db` rows intact.
- Apple Messages may later restore files on demand.
- Paths may change after re-download or source-side storage behavior.
- A source row and source path do not prove the file exists now.

Rule: source DB is not a reliable storage layer.

The source database can explain why an attachment should exist structurally. It cannot guarantee display availability.

## 2. Import Stage

Import reads Apple-owned source databases into `macos_import_ss.db`. The import
DB is structural. It preserves source-scoped identity, joins, and provenance
needed for later graph projection and recovery.

Attachment-related import tables:

| Import table | Purpose |
| --- | --- |
| `attachments` | Imported Apple attachment metadata, including `guid`, `transfer_name`, `mime_type`, `total_bytes`, and `local_path`. |
| `message_attachments` | Normal message-to-attachment joins for source messages linked through `chat_message_join`. |
| `recovered_unlinked_message_attachments` | Attachment joins for source messages that lack normal chat linkage and are imported as recovered-unlinked content. |

Normal and recovered-unlinked flows are separated:

1. Source `message` rows with `chat_message_join` membership go to `messages`.
2. Source `message` rows without `chat_message_join` membership go to `recovered_unlinked_messages`.
3. Source `message_attachment_join` rows are routed to `message_attachments` or `recovered_unlinked_message_attachments` according to the imported message path.

Import does not assume the file exists at `attachment.filename`. It imports structural evidence and source metadata. Availability is resolved later.

## 3. Working Graph

Graph projection projects imported attachment data into `working_ss.db`.

Current graph attachment tables:

| Graph table | Purpose |
| --- | --- |
| `attachments` | Canonical attachment facts keyed by source-scoped identity. Includes source path hints, hash/path metadata when available, and presentation-query fields. |
| `message_to_attachment` | Canonical message-to-attachment graph edges keyed by `ss_id` endpoints. |

The working graph tracks references and projected metadata. It does not
guarantee file presence.

The graph `attachments` table is a projection from `macos_import_ss.db`; it is
not a durable file store. Graph rebuilds may recreate derived graph tables.
Incremental graph builds preserve source-scoped identity and apply
idempotent insert/update behavior.

## 4. Archive Model (Core Concept)

The archive is the durable attachment display model.

Core rules:

- Archive-enabled UI display prefers the app-owned archive.
- The archive is the only durable source for UI rendering.
- Live Messages files are ingestion sources only.
- `local_path` may be used to find a file to ingest, but it must not be treated as durable display state.
- Archive metadata lives in `user_overlays.db`, not `working_ss.db`.

Overlay table:

| Overlay table | Purpose |
| --- | --- |
| `archived_attachments` | Durable archive metadata keyed by `(message_guid, import_attachment_id)`. Stores archive path, size, content hash, provenance, and original source path audit data. |

Resolution is stateful and explicit. Attachment display code must use the attachment resolver rather than checking raw paths inline.

Attachment availability states:

| State | Meaning |
| --- | --- |
| `pendingArchive` | A live file exists and archive ingestion has been triggered. UI should show a pending/recovery state until archive-backed display is ready. |
| `available` | A displayable file exists under the current source policy. In archive-enabled mode this means an archive-backed file is available. |
| `unavailableAwaitingRecovery` | The attachment is structurally known but not displayable now. Later local availability or deterministic recovery may make it displayable. |
| `nonRecoverable` | The system has no viable live path, archive key, or recovery identity to make the attachment displayable. |

Do not collapse these states into a boolean. Missing files are expected operating conditions, not a reason to suppress attachment records.

## 5. Deterministic Recovery

Deterministic recovery restores evicted attachments from a user-selected historical snapshot.

Inputs:

- historical `chat.db`
- matching historical `Attachments` folder
- current source-scoped graph/import databases where available
- retained `macos_import.db` / `working.db` only as historical cleanup
  history or explicit fallback bridges where graph-native recovery has not
  replaced a path
- current `user_overlays.db`

The historical snapshot is opened read-only. Recovery never mutates Apple backups, current source databases, import tables, or working projection tables.

Current graph-native identity mapping:

1. Historical snapshot provides `(message.guid, attachment.guid)` pairs from historical `message_attachment_join`.
2. Current source-scoped import DB maps Apple `attachment.guid` to graph attachment `ss_id`.
3. Current conversation graph verifies the mapped attachment through `message_to_attachment` topology and the current message `ss_id`.
4. Overlay receives or skips an `archived_attachments` row keyed by the existing archive-compatible `(message_guid, import_attachment_id)` pair, where `import_attachment_id` is currently the source attachment ROWID unpacked from the graph attachment `ss_id`.

The archive overlay key remains compatibility-shaped so existing archived files
survive the graph migration. Do not extend retained historical GUID/import-id
bridges beyond explicit recovery compatibility.

Primary match:

- `attachment.guid` -> source-scoped import attachment `ss_id` -> graph `message_to_attachment` edge -> overlay-compatible `(message_guid, import_attachment_id)`.

Allowed fallback:

- Only when historical `attachment.guid` is `NULL`, the historical message has exactly one attachment, and the current working message has exactly one attachment.
- If all three conditions hold, the single current `import_attachment_id` is used.

Forbidden fallback:

- path-tail matching
- transfer-name matching
- file-size/date matching
- ordinal matching
- fuzzy string matching

### Current Caveat: Attachment Provenance Naming

Attachment provenance naming is currently inconsistent:

- deterministic recovery writes `imported_historical_snapshot`
- overlay schema comments and resolver logic may still reference `imported_historical`
- this inconsistency is known and must not be used for branching logic

Treat `(message_guid, import_attachment_id)` and archive file existence as the durable recovery facts. Normalize provenance naming before adding behavior that depends on historical provenance values.

## 6. Incremental Flow

Automatic sync is driven by `ChatDbChangeMonitor`.

Exact current sequence:

1. `ChatDbChangeMonitor` runs on macOS as a keep-alive provider.
2. It primes from the graph/source-scoped import cursor when available.
3. Every 15 seconds it reads `MAX(ROWID)` from `~/Library/Messages/chat.db`.
4. If the max source message row ID increased, it schedules a debounced probe.
5. The probe runs the source-scoped graph build lifecycle.
6. On successful graph import/projection, it calls `archiveGraphMessageSourceRange(...)` for the newly imported live source range.
7. It bumps graph/message data version signals so evidence providers refresh.

The incremental path treats `working_ss.db` as app truth for ordinary message
evidence. Graph Drift connection lifetime is preserved; UI refresh is signaled
through graph/message data version providers.

The monitor also runs a bounded graph-attachment sweep every 5 minutes via `archiveNextGraphSweepChunk()` so files that appear later can be ingested.

## 7. Rendering Model

Attachment rendering is downstream of data resolution.

The rendering path must follow the project spec architecture:

Spec → Coordinator → Resolver → Payload / ViewModel → Rendering

For attachments, this means:

- Navigation or panel selection chooses message scope through specs.
- Resolvers/hydration load messages and resolve attachment availability.
- Payloads/view models carry resolved attachment state.
- Widgets render the resolved state.

UI must prefer archive-backed files and show placeholders for unavailable attachments. Rendering must not depend on raw `local_path` as semantic truth.

If archive mode is disabled, any live-file display remains a resolver-owned source-policy decision. Widgets still must not bypass resolver/archive logic by reading Apple paths directly.

Reference the canonical spec docs for the boundary rules; do not reimplement spec orchestration in attachment UI code.

## 8. Failure Modes

| Failure mode | Handling |
| --- | --- |
| iCloud eviction | Source row remains, live file disappears. Resolver returns `unavailableAwaitingRecovery` or `nonRecoverable` depending on available identity/path data; deterministic recovery may restore from backup. |
| Path mutation | `local_path` may become stale. The path is audit/ingestion input only, not an identifier. Durable identity remains `(message_guid, import_attachment_id)` plus archive metadata. |
| Missing files at import time | Import still records structural attachment data and joins. Archive ingestion skips missing files; UI renders an unavailable state. |
| Files appear later | Periodic working sweep or resolver-triggered ingestion can archive newly available files. |
| Orphaned/unlinked attachments | Import routes joins for recovered-unlinked messages through explicit recovered/unlinked attachment relationships; graph projection keeps recovered content distinct from normal timelines, while retained files remain transitional compatibility material. |
| Historical file missing from backup | Deterministic recovery reports the mapped record as missing and does not guess. |
| Ambiguous historical mapping | Recovery reports an unmapped/ambiguous reason and does not use heuristic fallback. |

No attachment record should be hidden merely because its file is missing.

## 9. Non-Negotiable Rules

- Do not treat Apple file paths as stable identifiers.
- Do not treat `attachment.filename` / `local_path` as durable availability.
- Do not assume attachment existence at import, migration, hydration, or render time.
- Do not render directly from live Messages files by reading raw paths in widgets.
- Do not bypass the attachment resolver or archive logic.
- Do not store archive metadata in `working_ss.db` or retained `working.db`.
- Do not write to Apple Messages source databases or attachment directories.
- Do not merge recovered-unlinked attachment data into normal timelines without an explicit documented migration boundary.
- Do not invent heuristic recovery matching beyond the documented GUID match and single-attachment fallback.
- Do not branch on `imported_historical` versus `imported_historical_snapshot` until provenance naming is normalized.

## References

- `../15-MACOS-SOURCE-DATABASES/00-overview.md` - Apple source DB interpretation and source observation boundary.
- `../20-DATA-IMPORT-MIGRATION/01-overview.md` - retained import/migration history and compatibility context.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` - retained import and working table names.
- `../10-DATABASES/02-db-working.md` - retained working projection contract.
- `../10-DATABASES/05-db-overlay.md` - overlay DB and archive metadata boundary.
- `./40-attachment-archive.md` - archive storage and resolver details.
- `./50-deterministic-recovery.md` - historical snapshot recovery algorithm.
- `../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/00-overview.md` - rendering pipeline boundaries.
