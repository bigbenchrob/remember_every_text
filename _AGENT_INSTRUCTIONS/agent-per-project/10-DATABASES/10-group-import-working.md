---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-06-08
source_of_truth: doc
links:
       - ./00-all-databases-accessed.md
       - ./01-db-import.md
       - ./02-db-working.md
       - ./03-db-address-book.md
       - ./04-db-chat.md
       - ./05-db-overlay.md
       - ./07-overlay-database-independence.md
       - ./11-contact-to-chat-linking.md
       - ../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
       - ../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
tests: []
---

# `group-import-working-db` - Retired Import / Working Cleanup Contract

`db-import` and `db-working` were the legacy import/projection pair. The active
orchestrator/migrator implementation has been retired from app code. This
document preserves the historical contract so old files, diagnostics, and
archive/recovery decisions can still be interpreted correctly.

> Current conformance note (2026-06-08): ordinary app data now flows through
> `macos_import_ss.db` -> `working_ss.db` using source-scoped `ss_id` graph
> identity. Active archive-source metadata lives in overlay storage. Retired
> `macos_import.db` / `working.db` files are retired cleanup inventory only,
> and retired `working.db` has no central app provider.
> Do not use this retired import/working contract as the model for new
> graph-era features.

## 1. Historical Source -> Import -> Working Flow

```
macOS AddressBook (db-address-book)
            +
 macOS Messages (db-chat)
            ↓  import orchestrator
     db-import (source-derived ledger)
            ↓  migration orchestrator
     db-working (retired projection)
```

The old retired import and migration orchestrator classes are no longer active
runtime code. Historical files may still carry tables produced by that flow;
diagnostics may inspect those files read-only, and reset may delete them.

Production source-scoped flow:

```
macOS AddressBook (db-address-book)
            +
 macOS Messages (db-chat)
            |
            v
 db-import-ss (macos_import_ss.db)
            |
            v
 db-graph-working (working_ss.db)
```

## 2. Historical ID Preservation Rules

These rules explain old `working.db` contents. New graph-era work must use
source-scoped graph identity instead.

1. **Contact IDs** (`Z_PK`) from AddressBook become `participants.id` in historical `db-working`. No remapping, no new sequences.
2. **Handle IDs** from the Messages ledger are mapped through `MigrationContext.handleIdCanonicalMap`; canonical rows use a stable source handle ID, and every raw source handle is preserved in `handles_canonical_to_alias`.
3. **Chat GUIDs / IDs** from Messages remain identical throughout ledger and projection tables.
4. **Message GUIDs / ROWIDs** remain traceable in `db-working.messages`; source rows without chat-message joins use the recovered-unlinked path.

If diagnostic interpretation of historical data requires remapping IDs outside
the documented canonical handle map, stop and revisit this contract.
Undocumented remapping introduces data drift and breaks downstream joins. See
`./11-contact-to-chat-linking.md` for an end-to-end walkthrough of the
historical contact -> chat relationship.

## 3. Table Mapping Snapshot

| Working Table | Source Table | Notes |
| --- | --- | --- |
| `handles_canonical` | `db-import.handles` | Canonicalization groups raw handles and chooses a stable source handle ID for each canonical row. |
| `handles_canonical_to_alias` | Canonical map derived during migration | Records every raw source handle variant pointing to the canonical ID. |
| `participants` | `db-import.contacts` | Uses original AddressBook `Z_PK`. Drift class name: `WorkingParticipants`. |
| `handle_to_participant` | `db-import.contact_to_chat_handle` | Links canonical handles to participants with confidence scores. |
| `chat_to_handle` | `db-import.chat_to_handle` | Rebuilds memberships using the same handle IDs. |
| `messages` | `db-import.messages` | Preserves GUIDs/ROWIDs; adds derived columns only. |
| `recovered_unlinked_messages` | `db-import.recovered_unlinked_messages` | Preserves source rows that are not linked through normal chat-message joins. |
| `attachments` / `recovered_unlinked_attachments` | `db-import.attachments` plus normal/recovered attachment joins | Preserves attachment source identity and separates normal chat-linked rows from recovered rows. |
| `read_state` / `message_read_marks` | `db-import.messages` | Projects read timestamps and message-level read markers. |
| `global_message_index` / `message_index` / `contact_message_index` | Built from `db-working.messages` and related joins | Retired legacy indexes; ordinary timelines/search now use graph evidence/search. |

## 4. Current Lifecycle Expectations

- **Fresh `db-import` is metadata-owned**: Runtime features may update
  `historical_archive_sources` only through the historical archive-source
  repository. They must not rebuild old ledger tables.
- **Retired `db-working` is file storage only**: No central app provider or
  active Drift schema remains. Reset may delete it; diagnostics may inspect it
  read-only.
- **Write policy**: Durable user intent never writes to `db-import` or
  `db-working`; provider-layer merges must respect the overlay independence
  rules.

## 5. Current Import Reality: Source Message Orphans

The macOS source database may contain `message` rows that do not appear in
`chat_message_join`. The ordinary graph path represents this evidence through
source-scoped graph/orphan message semantics.

- `chat.db.message` count can exceed thread-linked graph topology
- the orphan portion should appear in source-scoped recovered/orphan graph
  evidence
- retired cleanup/diagnostic files may contain `db-import.recovered_unlinked_messages`
  and `db-working.recovered_unlinked_messages`
- audit logs should distinguish thread-linked counts from recovered preserved counts

This is the practical implication of the current Apple data shape: source visibility in `chat.db.message` and thread visibility via `chat_message_join` are not the same thing.

## 6. Debugging Checklist

1. Prefer the graph status panel and source-scoped graph evidence first.
2. For retired cleanup/diagnostic files, confirm whether the row exists in `db-import`
       only to interpret cleanup inventory, not to route active app behavior.
       For source orphan rows, check both `messages` and `recovered_unlinked_messages`.
3. Verify the corresponding row in `db-working` retains the same ID.
       For recovered rows, check `recovered_unlinked_messages` and `recovered_unlinked_attachments` rather than normal chat-linked tables.
4. Check `handle_to_participant` and `chat_to_handle` join paths using the preserved IDs.
5. Do not attempt to re-run deleted retired orchestrators. If old retired
   storage is required for a recovery task, design an explicit graph-era
   retired-file audit, migration, or export path.
6. Inspect retired `import_log` and `migrate_log` only as historical
   diagnostics. Graph build status lives in the Conversation Graph status panel.
7. If IDs differ at any step, halt - someone attempted to remap during historical migration.

## 7. Related Documents

- `01-db-import.md` — Ledger details and provider access.
- `02-db-working.md` — Projection schema and usage.
- `./11-contact-to-chat-linking.md` — Deep dive into handle/contact/chat linking.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` — Table-level schema definitions.
