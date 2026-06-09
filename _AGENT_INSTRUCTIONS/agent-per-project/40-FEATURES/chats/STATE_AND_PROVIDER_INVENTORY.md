---
tier: feature
scope: state-provider-inventory
owner: agent-per-project
last_reviewed: 2026-06-05
links:
	- ./CHARTER.md
	- ./DOMAIN_AND_DATA_MAP.md
tests: []
feature: chats
doc_type: state-provider-inventory
status: current
last_updated: 2026-06-05
---

# State & Provider Inventory - Chats

> Current conformance note (2026-06-05): ordinary chat/conversation reads are
> graph-backed. Do not reintroduce legacy `working.db` chat repositories,
> `chatsByAgeProvider`, or a parallel chat heatmap model. Conversation
> navigation and summaries should flow through the conversation graph and the
> shared message evidence spine.

| Provider | Type | Parameters | Description | Downstream Users |
| --- | --- | --- | --- | --- |
| `conversationOverviewsProvider` | @riverpod future | optional limit | Reads conversation summaries from `working_ss.db` topology through the conversation graph repository. | Conversation sidebar, diagnostic conversation browser. |
| `conversationSignaturesProvider` / related signature providers | @riverpod future/notifier | filter/sort/search preferences | Produces sidebar conversation signature rows and persists presentation preferences in overlay storage. | Conversations sidebar. |
| `recentChatsProvider` | @riverpod future | optional limit | Graph-backed compatibility/read-model adapter for the retained diagnostic conversation browser. | Diagnostic/reference conversation browser. |
| `chatsViewModelProvider` | @riverpod controller | selected graph chat id | Routes selected conversations into sidebar flow state; it does not own chat data. | Diagnostic/reference conversation browser and graph status samples. |
| `conversationFavouritesProvider` | @riverpod notifier/read model | graph conversation id | Persists global conversation favourite intent in overlay storage. | Conversation signature rows and contact-derived conversation lists. |

## State Objects & Caches
- Canonical chat/conversation rows live in `working_ss.db.chats`.
- Topology is expressed through `working_ss.chat_to_message` and
  `working_ss.chat_to_handle`.
- User intent such as favourites is overlay-owned and merged at read time.
- Message evidence is not rendered by the chats feature; selected
  conversations produce message evidence scopes consumed by the shared evidence
  spine.

## Invalidations & Triggers
- Source-scoped graph build completion invalidates graph conversation readers.
- Overlay favourite/preference changes invalidate signature and list read models.
- Live `chat.db` polling appends graph rows and then invalidates graph-backed
  message/conversation evidence surfaces.

## TODO
- Retire or demote the diagnostic center-panel conversation browser once the
  sidebar signature flow fully covers its inspection role.
- Keep conversation presentation unified through shared signature cards and the
  message evidence spine.
