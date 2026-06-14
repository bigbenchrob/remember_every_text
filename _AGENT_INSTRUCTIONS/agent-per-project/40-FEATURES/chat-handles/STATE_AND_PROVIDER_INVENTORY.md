---
tier: feature
scope: state-provider-inventory
owner: agent-per-project
last_reviewed: 2026-06-14
links:
	- ./CHARTER.md
	- ./DOMAIN_AND_DATA_MAP.md
tests: []
feature: chat-handles
doc_type: state-provider-inventory
status: current
last_updated: 2026-06-14
---

# State & Provider Inventory — Chat Handles

> Current conformance note (2026-06-05): handle state is graph-backed for ordinary traversal and overlay-backed for user intent. Do not reintroduce draft provider placeholders as architecture.

| Provider | Type | Parameters | Description | Downstream Users |
| --- | --- | --- | --- | --- |
| graph handle read models | infrastructure/application providers | `ss_id` / scope-specific ids | Expose source-scoped handles, canonical aliases, and graph topology through named repositories/read models. | Conversations, contacts, message evidence, search. |
| manual handle link service | application service | contact/handle identity | Persists user-authored handle/contact links to overlay storage only. | Contact linking UI, unfamiliar-source review. |
| unfamiliar/spam handle providers | feature providers | mode/filter state | Review handles that are not yet resolved to known contacts or have user suppression state. | Unfamiliar sources and handle review surfaces. |

## State Objects & Caches
- Graph tables: `working_ss.handles`, canonical aliases, `chat_to_handle`, and `contact_to_handle`.
- Overlay tables: manual contact/handle links and dismissed/suppressed handle intent.
- Derived read models for display labels, sender labels, and handle-scoped message evidence.

## Invalidations & Triggers
- Overlay writes should invalidate display identity and handle review read models.
- Graph import/projection refresh should invalidate graph handle topology readers.
- Widgets should consume typed read models; they should not inspect overlay/graph tables directly.

## Open Stewardship Items
- Keep active provider names documented here when handle review or linking surfaces change.
- Retire retained historical handle terminology from docs as remaining recovery/archive bridges are removed.
