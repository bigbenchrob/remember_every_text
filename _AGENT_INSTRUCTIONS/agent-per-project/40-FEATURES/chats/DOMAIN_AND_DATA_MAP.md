---
tier: feature
scope: domain-data-map
owner: agent-per-project
last_reviewed: 2026-06-05
links:
	- ./CHARTER.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: chats
doc_type: domain-data-map
status: current
last_updated: 2026-06-05
---

# Domain & Data Map - Chats

## Core Entities
- Source-scoped chat rows in `macos_import_ss.db.chats`.
- Canonical conversation/chat rows in `working_ss.db.chats`.
- Canonical graph edges:
  - `working_ss.chat_to_message`
  - `working_ss.chat_to_handle`

## Supporting Tables & Views
| Database | Table/View | Purpose | Notes |
| --- | --- | --- | --- |
| `macos_import_ss.db` | `chats` | Source chat metadata and provenance from `chat.db.chat`. | Preserves source facts such as source row id, GUID, service, group metadata, and batch provenance. |
| `macos_import_ss.db` | `chat_to_message` | Source chat/message join facts plus precomputed source-scoped endpoints. | Projection is endpoint-preserving. |
| `macos_import_ss.db` | `chat_to_handle` | Source chat/handle participant topology plus precomputed source-scoped endpoints. | Feeds participant-aware summaries and group semantics. |
| `working_ss.db` | `chats` | Lean app graph conversation rows. | Uses `ss_id` as canonical identity. |
| `working_ss.db` | `chat_to_message` | Canonical conversation/message graph edges. | Drives message evidence scopes and timeline navigation. |
| `working_ss.db` | `chat_to_handle` | Canonical conversation/handle graph edges. | Drives participant labels, grouping, and signatures. |
| `user_overlays.db` | conversation favourites/preferences | User intent attached to graph conversation identity. | Overlay wins at read time; graph projection never reads overlay. |

## External Inputs
- `ChatDbChangeMonitor` detects new source rows and triggers graph import +
  projection.
- Source-scoped importers populate `macos_import_ss.db`.
- Conversation graph projectors populate `working_ss.db`.
- Overlay repositories persist user intent such as favourites.

## Downstream Consumers
- Conversation sidebar signature list.
- Contact-derived conversation lists.
- Message evidence scopes for selected conversations.
- Search result contexts and future theme/tag projections.
- Graph health/status diagnostics.

## Data Contracts
- `ss_id` is canonical conversation identity for source-derived chats.
- GUID is metadata/interop only, not canonical identity.
- Working graph relationships use `ss_id` endpoints only.
- Conversation summary/read models derive from graph topology; widgets render
  typed read-model data and do not query or reconstruct topology.
- Timeline-like conversation evidence scopes use the shared message evidence
  spine: full logical skeleton first, visible-row hydration second.
