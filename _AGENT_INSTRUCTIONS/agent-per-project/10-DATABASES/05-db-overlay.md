---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-04-21
source_of_truth: doc
links:
  - ./00-all-databases-accessed.md
  - ./07-overlay-database-independence.md
  - ./10-group-import-working.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
tests: []
---

# `db-overlay` — User Overrides (`user_overlays.db`)

`db-overlay` stores long-lived user customisations that must survive import/migration cycles. It pairs with `db-working` at the provider layer—never through direct database synchronization.

- **Alias**: `db-overlay`
- **Physical File**: `~/Library/Application Support/com.bigbenchsoftware.MessageLens/user_overlays.db`
- **Primary Consumers**: Overlay services, presentation providers

## File Location

| Item | Value |
| --- | --- |
| Directory | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/` |
| Filename | `user_overlays.db` |
| Provisioning | Created/opened by `overlayDatabaseProvider` (Drift) |
| Backups | External/operational backup if configured; not owned by the overlay database provider |

## Provider Access

- **Riverpod entry point**: `overlayDatabaseProvider`
- **Definition**: `lib/essentials/db/feature_level_providers.dart`
- **Type**: `Future<OverlayDatabase>` (Drift `GeneratedDatabase`)

Usage template:

```dart
final overlayDb = await ref.watch(overlayDatabaseProvider.future);
```

Providers that merge overlay and working data must request both databases separately and combine results in-memory. See `07-overlay-database-independence.md` for the non-negotiable rules.

## Schema Highlights

| Table | Purpose |
| --- | --- |
| `handle_to_participant_overrides` | Manual links between handles and participants (supersedes automatic matches when present). |
| `participant_overrides` | Custom participant metadata (short names, notes, display preferences). |
| `chat_overrides` | Chat-specific preferences (custom titles, colours, pin states) that persist across rebuilds. |
| `message_annotations` | Per-message annotations keyed by working message ID; newer saved/tag metadata uses GUID-keyed tables below. |
| `message_user_flags` / `message_user_tags` | Message saved state and user tags keyed by message GUID. |
| `favorite_contacts` | Favorite/recent contact state keyed by `participants.id`. |
| `handle_visibility_overrides` / `dismissed_handles` | User-controlled visibility, blacklist, and dismissal state. |
| `virtual_participants` | Overlay-scoped participants created by the user. |
| `archived_attachments` | Attachment archive metadata keyed by message GUID + import attachment ID. |
| `overlay_settings` | Overlay-scoped key/value settings. |

Full definitions live in `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`. The `20-DATA-IMPORT-MIGRATION` schema reference covers import and working databases; overlay details are owned here and in the code schema.

## Usage Rules

1. **Write through providers**: Only user-driven services mutate this database. Never write to it during migrations.
2. **Respect independence**: Do not copy overlay data into `db-working`. Merge at the provider layer. Review `07-overlay-database-independence.md` before touching overlay code.
3. **Keep migrations forward-only**: Overlay database migrations must be additive and preserve user data; avoid destructive changes.
4. **Invalidate providers after writes**: Ensure Riverpod providers that depend on overlay data are invalidated so merged views refresh.

## Cross-References

- `07-overlay-database-independence.md` — Architectural rules for keeping overlay and working databases isolated.
- `10-group-import-working.md` — Context on how overlay data supplements the import/working pipeline.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` — Table definitions and migration history.
