---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-06-08
source_of_truth: doc
links:
  - ./00-all-databases-accessed.md
  - ./02-db-working.md
  - ./05-db-overlay.md
  - ./10-group-import-working.md
tests: []
---

# Overlay Database Independence Rule

## 🚨 INVIOLABLE ARCHITECTURAL PRINCIPLE 🚨

**`db-overlay` (`user_overlays.db`) is completely independent from graph projection (`working_ss.db`) and from retained historical files (`macos_import.db` / `working.db`).**

1. **No synchronization** — The databases never copy data to each other.
2. **No cross-writing** — Code that writes to overlay never writes to working, and vice versa. **No dual-writes.**
3. **No shared projection/import/cleanup maintenance** — Tasks for one
   database must not read or mutate the other. Graph projection, source import,
   retired-file diagnostics, cleanup, and recovery tooling NEVER consult
   overlay.
4. **Provider-level merging only** — Combine data in Riverpod providers or services, not in SQL.
5. **Overlay wins on conflict** — When a provider/read model merges graph-derived data + overlay data for the same entity, the overlay value ALWAYS takes precedence.

Breaking these rules jeopardizes user data persistence and invalidates the source/projection contract. **This principle is inviolable and must be heeded by all agents.**

## Separation of Concerns

| Concern | Writes to | Reads from | Survives migration |
|---|---|---|---|
| **Import source data** | Import DB only | Source DBs only | Rebuilt or extended by import flows |
| **Graph projection data** | Graph working DB only | Source-scoped import DB only | Rebuilt or incrementally updated by graph projection |
| **Retained archive metadata** | Retained import DB only | Source/archive metadata only | Maintained only for archive-source compatibility |
| **Retained historical projection inventory** | — | Retained working DB only | Read-only diagnostics/recovery reference |
| **User intent** (overlay) | Overlay DB only | — | Always persists |
| **Providers/read models** (read path) | — | Graph-derived data ∪ Overlay, overlay wins | N/A |

Source-scoped import is a **pure function** of macOS source databases → `macos_import_ss.db`. Graph projection is a **pure function** of `macos_import_ss.db` → `working_ss.db`. Retained archive metadata is maintained separately in retained `macos_import.db` for archive-source compatibility. None of these paths reads overlay.
User actions are **pure writes** to overlay. They never write to graph tables or retained files.
Providers/read models are the **sole merge point** where projection data and overlay data are read and combined.

## Architectural Model

```
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                         │
│  (Riverpod providers – THIS IS WHERE MERGING HAPPENS)        │
│                                                             │
│  Example: display/contact/conversation read model            │
│    1. Read graph contact/handle/conversation facts           │
│    2. Read overlay favourites/manual links/name overrides    │
│    3. Merge/override results                                 │
│    4. Return unified typed view to the UI                    │
└───────────────────────┬────────────────────┬─────────────────┘
                        │                    │
                        │                    │
                   READ ONLY            READ ONLY
                        │                    │
                        ▼                    ▼
          ┌─────────────────────┐  ┌─────────────────────┐
          │   working_ss.db      │  │  user_overlays.db   │
          │  (db-graph-working)  │  │  (db-overlay)       │
          │                     │  │                     │
          │ • Rebuilt per graph  │  │ • Persists forever │
          │   projection         │  │ • Manual overrides │
          │ • Contacts, handles, │  │ • Preferences      │
          │   messages, chats    │  │                    │
          │ • Never touched by   │  │ • Never touched by │
          │   user actions       │  │   projections      │
          └─────────────────────┘  └─────────────────────┘
                 ▲                           ▲
                 │                           │
            WRITE ONLY                  WRITE ONLY
                 │                           │
          ┌──────┴────────┐         ┌───────┴────────┐
          │ Graph Build / │         │  User Actions  │
          │ Projection    │         │  (via Services)│
          └───────────────┘         └────────────────┘
```

## Correct Usage Patterns

### ✅ Merge in Providers

```dart
@riverpod
Future<List<ConversationSummary>> conversationsForContact(Ref ref, int contactId) async {
  final graphDb = await ref.watch(driftConversationGraphDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  final automatic = await graphDb.conversationsForContact(contactId);
  final manual = await overlayDb.manualConversationOverridesForContact(contactId);

  return mergeConversationFactsWithOverlay(automatic, manual);
}
```

### ✅ Persist Manual Overrides Separately

```dart
Future<void> linkHandleToParticipant({
  required Ref ref,
  required int handleId,
  required int participantId,
}) async {
  final overlayDb = await ref.read(overlayDatabaseProvider.future);
  await overlayDb.setHandleOverride(handleId: handleId, participantId: participantId);
  ref.invalidate(conversationsForContactProvider);
}
```

### ❌ Anti-Pattern 1: Mirror Overlay into Working

```dart
// WRONG: Do not copy overlay rows into projection tables
Future<void> syncOverlayToWorking(Ref ref) async {
  final overlayDb = await ref.read(overlayDatabaseProvider.future);
  final graphDb = await ref.read(driftConversationGraphDatabaseProvider.future);

  final overrides = await overlayDb.getAllHandleOverrides();
  for (final override in overrides) {
    await graphDb.insertHandleOverride(override); // 🚫 BLOCKER
  }
}
```

### ❌ Anti-Pattern 2: Migration Snapshot/Restore Cycle

A projection/migration step must never read overlay data before projection and write it
back into derived source-data storage afterwards. This was the "Restore Overrides" anti-pattern:

```dart
// WRONG: snapshot overlay → run migration → restore into working
final overrides = await overlayDb.getAllHandleOverrides(); // 🚫 reads overlay
await projection.run();                                     // rebuilds derived storage
for (final o in overrides) {
  await workingDb.into(workingDb.handleToParticipant).insert(
    HandleToParticipantCompanion.insert(
      handleId: o.handleId,
      participantId: o.participantId!,
      source: const Value('user_manual'),                   // 🚫 writes to working
    ),
  );
}
```

**Why it's wrong:** The snapshot/restore cycle creates a hidden dependency
between the two databases. If it's skipped (bug, crash, new code path), user
data silently disappears. The correct approach is for providers to merge
overlay and graph-derived data at read time — projection never needs to know about overlay.

### ❌ Anti-Pattern 3: Dual-Write on User Action

A user action must never write the same intent to both databases:

```dart
// WRONG: writing the same link to overlay AND derived source-data storage
Future<void> linkHandle(int handleId, int participantId) async {
  await overlayDb.setHandleOverride(handleId, participantId);  // overlay ✅
  await (workingDb.delete(workingDb.handleToParticipant)       // working 🚫
        ..where((t) => t.handleId.equals(handleId)))
      .go();
  await workingDb.into(workingDb.handleToParticipant).insert(  // working 🚫
    HandleToParticipantCompanion.insert(
      handleId: handleId,
      participantId: participantId,
      source: const Value('user_manual'),
    ),
  );
}
```

**Why it's wrong:** The projection copy is wiped on rebuild, creating a
race between "last projection" and "last user action". User intent belongs
exclusively in overlay; providers merge it at read time.

### ❌ Anti-Pattern 4: User-Intent Columns on Working Tables

User-controlled flags like `is_blacklisted` or `is_visible` must not live as
columns on graph projection tables that get rebuilt by projection:

```dart
// WRONG: storing user's spam decision on a working-DB table
await (workingDb.update(workingDb.handlesCanonical)
      ..where((t) => t.id.equals(handleId)))
    .write(HandlesCanonicalCompanion(isBlacklisted: const Value(true))); // 🚫
```

**Correct:** Store in overlay (`HandleVisibilityOverrides` table) and merge
in providers via `overlayDb.getAllHandleVisibilities()`.

## Responsibilities by Database

| Concern | `db-graph-working` / retained files | `db-overlay` |
| --- | --- | --- |
| Ownership | Source-scoped graph projection; retired files only for recovery/reference diagnostics | User-facing services and archive-source metadata |
| Lifecycle | Graph projection is disposable/rebuildable; retired files are transitional cleanup storage | Persistent |
| Writes | Graph projectors write graph DB; retired import/working files are not ordinary write targets | User actions/services and archive-source metadata services only |
| Contents | Source-derived contacts, handles, chats, messages, topology, projection inputs; historical file inventory | Manual handle links, custom names, visibility preferences, message user metadata, favorites, archived attachment metadata, archive-source metadata |
| Foreign Keys | Enforced by Drift schema | Enforced by Drift schema |

## Debugging Checklist

1. Is the override present in `db-overlay`? Run `SELECT * FROM handle_to_participant_overrides`. 
2. Are providers/read models merging overlay + graph data? Audit calls to both providers.
3. Were dependent providers invalidated after the override was written?
4. Does any code attempt to mutate graph projection in response to overlay changes? Remove it.
5. Are projections/migrations touching overlay tables? They must not.

## Resolved Violations (Historical Reference)

The following violations were fixed on the `Ftr.overlay-handle-visibility` branch:

1. **`ManualLinking.linkHandleToParticipant()`** — Was dual-writing to both overlay and working. Now writes overlay only; providers merge at read time.
2. **`ManualLinking.unlinkHandle()`** — Was deleting from working DB. Now deletes from overlay (reverts to addressbook default).
3. **`ManualLinking.createParticipantForHandle()`** — Was writing handle→participant link to working. Now writes link to overlay (participant record stays in working as the only participant table).
4. **`SpamManagement.blockHandle()`/`unblockHandle()`** — Was writing `is_blacklisted`/`is_visible` to working DB's `handles_canonical`. Now writes to overlay's `HandleVisibilityOverrides`; spam providers merge at read time.
5. **"Restore Overrides" migration step** — Snapshot/restore cycle read overlay before migration and wrote manual links back into working. Removed entirely; providers now merge overlay + working at read time.

## Related Documentation

- `02-db-working.md` — Retained Drift projection overview.
- `05-db-overlay.md` — Overlay database schema and access patterns.
- `10-group-import-working.md` — Retained import/working contract.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` — Retained table definitions.
