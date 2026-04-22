---
tier: feature
scope: domain-data-map
owner: agent-per-project
last_reviewed: 2026-04-21
links:
	- ./CHARTER.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: messages
doc_type: domain-data-map
status: draft
last_updated: 2026-04-21
---

# Domain & Data Map — Messages

This document describes the current unified message timeline implementation. Older contact-only docs were superseded by the rationalized message views work.

## Core Entities
- **Message projection (working DB):** `workingMessages` (Drift table: `db.workingMessages`)
	- Hydrated into `MessageListItem` via `lib/features/messages/presentation/view_model/shared/message_row_mapper.dart` and timeline hydration providers.
- **Contact ↔ message mapping:** `contact_message_index` (Drift table: `db.contactMessageIndex`)
	- Provides a stable ordering context for “messages with contact across all chats”.
- **Global message mapping:** `global_message_index` (Drift table: `db.globalMessageIndex`)
	- Provides global timeline ordering and month lookup.
- **Timeline scope:** `MessageTimelineScope` (`global`, `contact`, `chat`, `recovered`)
	- Selects the ordinal strategy and hydration behavior for `MessagesTimelineView`.

## Message Timeline Ordering Model (Ordinal)

The UI never pages by “offset + limit” directly. Instead it uses an **ordinal** model:

- For a given `MessageTimelineScope`, the index/strategy layer exposes:
	- `totalCount`: number of messages available
	- `ordinal -> messageId` mapping
	- `monthKey -> firstOrdinal` mapping

This enables:
- fast list skeleton (count-only)
- stable scroll targeting (`jumpToLatest`, `jumpToMonth`)
- per-row hydration (`ordinal -> message`) without rebuilding the whole list

Canonical files:
- Scope model: `lib/features/messages/domain/value_objects/message_timeline_scope.dart`
- Ordinal provider: `lib/features/messages/application/timeline/ordinal/message_timeline_ordinal_provider.dart`
- Index coordinator: `lib/features/messages/presentation/view_model/timeline/ordinal/message_timeline_index_coordinator_provider.dart`
- Hydration provider: `lib/features/messages/presentation/view_model/timeline/hydration/message_by_ordinal_provider.dart`
- Index data source: `lib/features/messages/infrastructure/data_sources/contact_message_index_data_source.dart`
- Global index data source: `lib/features/messages/infrastructure/data_sources/global_message_index_data_source.dart`

## Supporting Tables & Views
| Database | Table/View | Purpose | Notes |
| --- | --- | --- | --- |
| `db-working` | `workingMessages` | Primary UI projection for message rows. | Must include stable `id`, `guid`, `sentAtUtc`, sender handle refs.
| `db-working` | `globalMessageIndex` | Global ordering and month lookup. | Used by global scope.
| `db-working` | `contactMessageIndex` | Contact-scoped ordering and lookup. | Provides `messageId` ordering and month bucketing.
| `db-working` | `workingAttachments` (+ joins) | Attachments referenced by hydrated message rows. | Loaded via `attachment_info_loader.dart` when needed.

Notes:
- Import DB tables still exist and are essential to migration/import pipelines, but message UI depends on the *working* projection and recovered-message repositories.

## External Inputs
- Message import/migration populates `workingMessages`, `globalMessageIndex`, and `contactMessageIndex`.
- Rust extractor may enrich attributed bodies; message UI uses `textContent`, attachment metadata, user metadata, and recovered-message provenance where available.

## Downstream Consumers
- Messages center panel UI via `MessagesSpec` variants.
- Sidebar heatmaps and recovered-message navigators.
- Search services under `lib/essentials/search`, consumed by `messageTimelineViewModelProvider`.

## Data Contracts
- **ID stability:** `workingMessages.id` must be stable enough for scroll targeting and linking.
- **Index integrity:** every `contactMessageIndex.messageId` must exist in `workingMessages`.
- **Month key format:** `YYYY-MM` (e.g. `2025-12`) for jump behavior.
- **Maintenance safety:** during destructive DB maintenance/reset, contact messages providers must not open the DB.
	- The ordinal provider short-circuits to an empty state when `dbMaintenanceLockProvider` is true.
