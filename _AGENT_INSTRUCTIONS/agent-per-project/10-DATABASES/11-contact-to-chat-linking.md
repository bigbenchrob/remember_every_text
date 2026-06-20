---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-06-05
source_of_truth: doc
links:
  - ./00-all-databases-accessed.md
  - ./01-db-import.md
  - ./02-db-working.md
  - ./03-db-address-book.md
  - ./04-db-chat.md
  - ./06-addressbook-path-resolution.md
  - ./07-overlay-database-independence.md
  - ./10-group-import-working.md
  - ../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
  - ../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
tests: []
---

# Contact -> Conversation Linking Walkthrough

This walkthrough captures the graph-era path a macOS AddressBook contact takes to appear in conversation and contact-scoped message views. Use it to double-check the source-scoped graph contract whenever you touch handle/contact logic.

## 1. Resolve the Live AddressBook Bundle

- Always obtain AddressBook paths through `getFolderAggregateEitherProvider` (see `06-addressbook-path-resolution.md`). The provider inspects the `Sources/` subdirectories and returns the active bundle so importers never attach stale SQLite files.

## 2. Source-Scoped Import Phase

- Source-scoped importers run for AddressBook and Messages data.
- Contacts land in source-scoped import tables:
  - `contacts` – preserves `Z_PK`, display names, organisation flags.
  - `contact_phone_email` – normalised phone/email rows keyed by `ZOWNER`.
  - contact/handle matching evidence or direct graph contact/handle projection inputs.
- Chat handles import into source-scoped `handles`, and membership rows populate `chat_to_handle`.
- Ledger tables retain source identifiers and batch provenance. Incremental import preserves existing rows; full/reimport flows may clear and rebuild source-derived ledger tables through import code.

## 3. Graph Projection Phase

- Graph projectors copy source-scoped import facts into `working_ss.db`.
- Projection preserves source-scoped row identity and builds canonical graph endpoints directly.
- The current contact path depends on handles, canonical handle aliases, contact-to-handle links, chat membership, and messages.

### Key Graph Outputs

| Graph Table | Source | Purpose |
| --- | --- | --- |
| `handles` / canonical aliases | source-scoped handles | Canonicalise handle variants while retaining source handle facts. |
| `contacts` | source-scoped contacts | Project AddressBook contacts as graph contact identities. |
| `contact_to_handle` | contact channel matches + canonical handles | Link graph contacts to canonical handles. |
| `chat_to_handle` | source chat membership | Represent conversation participant topology by canonical handle endpoints. |
| `chat_to_message` | source chat/message joins | Represent conversation message topology by canonical `ss_id` endpoints. |

## 4. Resulting Relationship in `working_ss.db`

When graph projection completes:

1. Each projectable AddressBook contact has a graph contact row.
2. Every handle variant observed during import is represented by source-scoped handle facts and canonical aliasing.
3. `contact_to_handle` ties graph contacts to canonical handles.
4. `chat_to_handle` stores conversation membership referencing canonical handle endpoints.
5. `chat_to_message` stores conversation message membership referencing canonical message `ss_id`s.

Joining `contacts -> contact_to_handle -> chat_to_handle -> chats` yields conversations associated with that contact. Message evidence then scopes through the graph topology and `ss_id` endpoints.

Historical legacy `participants -> handle_to_participant -> chat_to_handle -> chats` chains may help interpret retired storage files only. Archive/recovery code should use graph contact/handle topology plus explicit overlay compatibility keys, not retained participant chains, and ordinary app surfaces must never use the legacy chain as their model.
