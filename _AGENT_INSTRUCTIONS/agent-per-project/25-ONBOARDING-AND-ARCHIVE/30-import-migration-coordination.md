# Graph Build Coordination

## Purpose

Onboarding coordinates startup/retry lifecycle but does not own source-scoped
import, projection, or graph query systems. This document describes the current
graph-first setup flow and the retired cleanup-storage boundary.

## Ownership Boundaries

| System | Owner | Location |
|--------|-------|----------|
| Bootstrap gate and user-facing status | Onboarding | `lib/essentials/onboarding/` |
| Source-scoped import ledger | source_scoped_import | `lib/essentials/source_scoped_import/` |
| Conversation graph build/projection/readiness | conversation_graph | `lib/essentials/conversation_graph/` |
| Archive metadata and historical cleanup storage | overlay / db / database health / reset infrastructure | Overlay metadata plus explicit diagnostics and reset boundaries only |
| Attachment archiving and recovery | attachments feature | `lib/features/attachments/` |

**Rule:** `OnboardingGate` delegates cleanup to `MessageDataResetService` and
graph build/rebuild to `ConversationGraphBuildController`. It must not call
`DbImportControlViewModel`, `runImportAndMigration()`, or retired
legacy migration paths as the app-facing setup path.

> **Safety:** `MessageDataResetService` removes only enumerated rebuildable
> derived database files and SQLite companions. Archived attachment payloads
> are preservation data, not rebuild inputs or cleanup targets. See
> [`ATTACHMENT-PRESERVATION-INVARIANT.md`](ATTACHMENT-PRESERVATION-INVARIANT.md).

## Pipeline Sequence

```
OnboardingGate.startImportAndGraphBuild()
  │
  ├─ 1. Cleanup / reset if needed
  │   └─ MessageDataResetService removes derived graph/import data
  │
  ├─ 2. Source-scoped graph build
  │   └─ ConversationGraphBuildController.runOnce(...)
  │       Source: ~/Library/Messages/chat.db (FDA-gated)
  │       Import ledger: ./macos_import_ss.db
  │       Working graph: ./working_ss.db
  │       Builds messages, chats, handles, topology, attachments,
  │       text enrichment, and graph indexes/readiness state.
  │
  └─ 3. Completion
      └─ OnboardingGate sets status = complete
          Graph build results and failures are persisted by onboarding-owned
          failure/report boundaries
          Overlay shows summary
```

## Progress Reporting

Onboarding progress is a durable projection of typed facts supplied by the
source-import and Conversation Graph services. Retired database files may
still be reset or inspected by diagnostics, but onboarding does not consume
`DbImportControlViewModel`, `runImportAndMigration()`, or retired projection
paths.

Enumerable import, rich-text, and row-oriented projection work reports exact
completed and total units at bounded cadence. Fast set-based projectors,
derived-store reset, and final readiness probes report typed coarse substages
without a fabricated percentage. Presentation consumes
`OnboardingOperationSnapshot`; it does not calculate work by inspecting
repositories.

The app-facing setup path is `MessageDataResetService` for cleanup/reset plus
`ConversationGraphBuildController` for source-scoped graph build/rebuild.

Source import also publishes fixed, domain-owned anomaly totals. The
orchestrator coalesces those totals with real progress, and Onboarding persists
them in its existing operation snapshot. Source identity failures remain
fatal. Optional interpretation may degrade only where the source domain has an
explicit truthful representation; relationship importers validate both source
endpoints before omitting and accounting for an invalid child edge.

## Failure Handling

| Failure | Behavior |
|---------|----------|
| Source-scoped graph build fails | Failure is persisted, status → `awaitingUserAction` |
| User clicks retry | Derived data is prepared and graph build re-runs |
| App crashes mid-pipeline | On next launch, failure history detected, user sees retry option |
| Stale partial source-scoped import/graph DB state detected | `OnboardingGate` enters `recoveringFailedAttempt`, resets app-owned derived DBs, then returns to `awaitingUserAction` |

**Persistence:** Results are stored as JSON in the overlay DB `OverlaySettings`
table, surviving app restarts.

## Database Topology

```
Source (read-only)         Source-scoped graph          App-owned user intent
─────────────────          ──────────────────────       ─────────────────────
~/Library/Messages/        ./macos_import_ss.db         ./user_overlays.db
  chat.db            ───→    (source facts)        ───→  (overlay DB)
                               │                          │
~/Library/Application          ▼                          │
  Support/.../          ./working_ss.db           ◄──────┘
  AddressBook-*          (conversation graph)       (merged at read time)
```

**Key:** Source-scoped import preserves source facts/provenance. Graph
projection writes canonical app graph rows keyed by `ss_id`. Archive service
writes to `overlay.db` and the filesystem archive folder. Providers merge
graph + overlay at read time.

## Re-Import Flow

When a user triggers re-import from Settings:

1. `OnboardingGate.startReimport()` is called
2. Status transitions: `reimporting` → `reimportBuildingGraph` → `reimportComplete`
3. `MessageDataResetService` resets enumerated rebuildable derived stores while
   preserving overlay intent and archived attachment payloads
4. `ConversationGraphBuildController` rebuilds the source-scoped graph
5. Archive rows in overlay are additive — existing entries survive

## Auto-Sync Integration

After initial onboarding completes, `ChatDbChangeMonitor` keeps the app current:

- Primes from the graph/source-scoped import cursor and checks startup catch-up.
- Polls `MAX(ROWID)` in `~/Library/Messages/chat.db` every 15 seconds.
- On change: runs the source-scoped graph build lifecycle.
- Archives newly imported live graph source ranges.
- Bumps graph/message data version providers on success.
- Runs a periodic graph-attachment sweep every 5 minutes for attachments that
  become locally available later.
- No user interaction required

See [`60-reimport-and-ongoing-sync.md`](60-reimport-and-ongoing-sync.md) for
details.
