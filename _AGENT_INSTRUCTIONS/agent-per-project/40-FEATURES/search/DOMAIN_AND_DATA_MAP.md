---
tier: feature
scope: domain-data-map
owner: agent-per-project
last_reviewed: 2026-06-05
links:
	- ./CHARTER.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: search
doc_type: domain-data-map
status: current
last_updated: 2026-06-05
---

# Domain & Data Map - Search

> Current note (2026-06-05): current search is essentials-owned
> (`lib/essentials/search`) and graph-backed. Search should select graph
> message evidence scopes by `message_ss_id`; do not reintroduce legacy
> `working.db` ids or planned `db-working` FTS tables as ordinary app truth.

## Core Components
- Graph search repository over `working_ss.db` message/conversation topology.
- Query service that returns typed graph evidence scopes and stable
  `message_ss_id` values.
- Overlay compatibility bridge for saved/tag rows that still carry historical
  GUID or legacy-id identity.

## Supporting Tables & Views
| Database | Table/View | Purpose | Notes |
| --- | --- | --- | --- |
| `working_ss.db` | `messages` | Graph message text and semantic facts. | Search returns `message_ss_id`. |
| `working_ss.db` | `chat_to_message` / `chat_to_handle` | Scope search by conversation and participants. | Uses canonical `ss_id` endpoints. |
| `working_ss.db` | handles/contact graph tables | Resolve contact/handle/conversation scopes. | Display identity merges overlay names at read time. |
| `user_overlays.db` | saved/tag/search intent | User-owned saved/tag metadata. | Legacy GUID/id rows may be bridged until overlay identity is fully graph-native. |
| External | Spotlight integration (future?) | Potential system-level search hook. | Research required.

## Data Sources
- Message Evidence Spine for selected evidence scopes.
- Conversation graph for topology, participants, and scope constraints.
- Display identity resolver for user-facing names.

## Downstream Consumers
- Message evidence views and search result context surfaces.
- Conversation/contact/handle scopes through `ViewSpec` conversions.
- Future theme/tag/favourite projections.

## Data Contracts
- Query API returns stable graph identifiers (`message_ss_id`,
  conversation/chat `ss_id`, canonical handle/contact ids as applicable).
- Search operates against the selected logical scope, not just visible hydrated
  rows.
- Source-specific search scopes are allowed; source-specific message renderers
  are not.
- Overlay user intent must remain overlay-owned and merge at read time.
