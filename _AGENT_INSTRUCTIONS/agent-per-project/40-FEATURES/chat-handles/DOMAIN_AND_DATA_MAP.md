---
tier: feature
scope: domain-data-map
owner: agent-per-project
last_reviewed: 2026-06-05
links:
	- ./CHARTER.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: chat-handles
doc_type: domain-data-map
status: current
last_updated: 2026-06-05
---

# Domain & Data Map - Chat Handles

> Current conformance note (2026-06-05): handle identity is graph-backed and
> source-scoped. Manual linking remains overlay-owned. The retained historical
> `handles_canonical` / alias scheme informed the graph model, but ordinary
> reads should use `working_ss.db` handles, canonical handle aliases, and graph
> topology.

## Core Entities
- Source-scoped handle rows in `macos_import_ss.db.handles`.
- Canonical handle rows and aliases in `working_ss.db`.
- Canonical participant topology through `working_ss.chat_to_handle` and
  `working_ss.contact_to_handle`.
- Overlay manual links for user-defined contact/handle associations.

## Supporting Tables & Views
| Database | Table/View | Purpose | Notes |
| --- | --- | --- | --- |
| `macos_import_ss.db` | `handles` | Source Apple handle rows with service + identifier and source provenance. | `id` is metadata, not globally unique identity. |
| `macos_import_ss.db` | `chat_to_handle` | Source participant topology plus precomputed graph endpoints. | Preserves source facts and canonical endpoints. |
| `working_ss.db` | `handles` / canonical aliases | Canonical handle graph identity and alias collapse. | Uses source-scoped ids and canonical handle endpoints. |
| `working_ss.db` | `chat_to_handle` | Conversation participant topology. | Drives group semantics and conversation signatures. |
| `working_ss.db` | `contact_to_handle` | Contact/handle graph linkage. | Feeds contact-scoped evidence and identity resolution. |
| `user_overlays.db` | manual handle/contact links | User overrides for handle-to-contact identity. | Overlay-only; graph projection is not modified by manual linking. |

## External Inputs
- Source-scoped handle/chat-handle importers read Apple `chat.db`.
- Contact import/project maps AddressBook channels to graph handles where
  possible.
- Manual override service writes user intent to overlay storage only.

## Downstream Consumers
- Conversation graph summaries and signatures.
- Message Evidence Spine for sender labels and handle-scoped evidence.
- Contact picker/hero/contact conversation surfaces.
- Search feature for handle/contact/conversation lookups.

## Data Contracts
- Source handle `ss_id` is stable for source-derived handle occurrences.
- Canonical handle aliases collapse service/format variants for traversal while
  retaining source handle facts.
- Manual overrides are semantic/user intent and live only in overlay storage.
- Known contact display identity wins over raw handles except in explicit
  handle-scope controls or unknown-handle surfaces.
