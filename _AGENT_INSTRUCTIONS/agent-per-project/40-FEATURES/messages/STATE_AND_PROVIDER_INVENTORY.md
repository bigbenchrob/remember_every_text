---
tier: feature
scope: state-provider-inventory
owner: agent-per-project
last_reviewed: 2026-04-21
links:
	- ./CHARTER.md
	- ./DOMAIN_AND_DATA_MAP.md
tests: []
feature: messages
doc_type: state-provider-inventory
status: draft
last_updated: 2026-04-21
---

# State & Provider Inventory — Messages

This inventory is authoritative for the current unified message timeline path. Older `contact_messages/` and `global_messages/` provider folders were removed by the rationalized message views work.

If you want the “how it works” narrative first, start here:
- `./message-display-flow-walkthrough.md`

| Provider / State | Kind | Location | Parameters | Responsibility |
| --- | --- | --- | --- | --- |
| `messageTimelineViewModelProvider` | `@riverpod` notifier | `lib/features/messages/presentation/view_model/timeline/message_timeline_view_model_provider.dart` | `MessageTimelineScope`, optional `scrollToDate` | Orchestrates timeline UI state: search controller, debounce, search mode/results, and jump methods.
| `messageTimelineOrdinalProvider` | `@riverpod` async notifier | `lib/features/messages/application/timeline/ordinal/message_timeline_ordinal_provider.dart` | `MessageTimelineScope` | Computes `totalCount`, owns scroll controllers/listeners, and provides jump helpers. Short-circuits during DB maintenance.
| `messageTimelineIndexCoordinatorProvider` | `@riverpod` provider | `lib/features/messages/presentation/view_model/timeline/ordinal/message_timeline_index_coordinator_provider.dart` | — | Chooses the appropriate ordinal strategy for the active `MessageTimelineScope`.
| `messageByOrdinalProvider` | `@riverpod` future family | `lib/features/messages/presentation/view_model/timeline/hydration/message_by_ordinal_provider.dart` | `MessageTimelineScope`, `ordinal` | Hydrates a single message row by mapping `ordinal → messageId → message joins → MessageListItem`.
| `messageByIdProvider` | `@riverpod` future family | `lib/features/messages/presentation/view_model/timeline/hydration/message_by_id_provider.dart` | `messageId` | Hydrates direct message IDs for search and context views.
| `timelineMetadataProvider` | `@riverpod` future family | `lib/features/messages/presentation/view_model/timeline/timeline_metadata_provider.dart` | `MessageTimelineScope` | Computes scope metadata such as counts and date ranges.
| `searchServiceProvider` | provider | `lib/essentials/search/feature_level_providers.dart` | — | Exposes `SearchService` to message timeline search.
| `dbMaintenanceLockProvider` | provider | `lib/essentials/db/feature_level_providers.dart` | — | Guards destructive DB maintenance; prevents providers from opening DB during reset.
| `driftWorkingDatabaseProvider` | provider | `lib/essentials/db/feature_level_providers.dart` | — | Single source of truth for opening `working.db` (avoids multiple connections/locking).

## State Objects & Caches
- `MessageTimelineViewModelState` (immutable): search text + debounced query + results + search mode.
- `MessageTimelineOrdinalState`: `totalCount` + `ItemScrollController` + `ItemPositionsListener` + strategy.
- `MessageTimelineScope`: scope discriminator for global, contact, chat, and recovered timelines.

Notes on lifecycle:
- Riverpod Notifier `build()` may run multiple times; stateful objects must be initialized idempotently.
- `MessageTimelineViewModel` owns a single `TextEditingController` and `Timer` debounce and disposes them via `ref.onDispose`.

## Invalidations & Triggers
- ViewSpec selection drives the `MessageTimelineScope`; changing scope creates new provider instances.
- Search updates originate from the VM-owned `TextEditingController` listener.
- DB maintenance lock causes ordinal provider to immediately return empty state (prevents “infinite loading”).

## TODO
- Continue reducing duplicated legacy shared/timeline hydration paths where safe.
