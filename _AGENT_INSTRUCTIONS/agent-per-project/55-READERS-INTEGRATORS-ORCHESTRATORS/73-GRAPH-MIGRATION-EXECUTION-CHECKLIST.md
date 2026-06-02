---
tier: project
scope: source-scoped-graph-migration
status: active
last_reviewed: 2026-06-01
depends_on:
  - 70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md
  - 71-LEGACY-DEPENDENCY-MATRIX.md
  - 72-GRAPH-CHOKE-POINTS-AND-RETIREMENT-BLOCKERS.md
  - 75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md
  - 76-RECOVERED-MESSAGE-GRAPH-IDENTITY-PLAN.md
  - 77-RECOVERED-MESSAGE-GRAPH-PARITY-AUDIT.md
---

# 73 - Graph Migration Execution Checklist

## Purpose

This is the execution companion to the graph migration planning documents.

- `70` defines the roadmap.
- `71` classifies remaining legacy dependencies.
- `72` identifies choke points, compatibility bridges, overlay identity risks,
  and retirement blockers.
- This document tracks concrete execution slices and their exit criteria.

The purpose is to prevent opportunistic cleanup, accidental legacy deletion, or
feature drift while completing the graph migration.

## Execution Rules

1. Work from high-leverage choke points, not from isolated legacy references.
2. Do not delete legacy code until its blocker row is closed.
3. Do not promote a compatibility bridge into production architecture without
   naming it and defining its removal condition.
4. User intent remains overlay-only.
5. Import and projection must not consult overlay state.
6. Message-bearing surfaces must continue through the Message Evidence Spine.
7. Pagination is not timeline navigation.
8. Lifecycle work must be centralized through database/readiness/orchestration
   providers, not widget-triggered repair logic.

## Status Legend

- **Not started**: no implementation work has begun.
- **In progress**: active slice.
- **Blocked**: waiting on architectural decision, test failure, or missing
  dependency.
- **Review needed**: implementation complete enough for user review.
- **Done**: exit criteria met and tests recorded.

## Checklist

| Slice | Status | Goal | Systems involved | Blockers closed | Required verification | Exit criteria |
| --- | --- | --- | --- | --- | --- | --- |
| 0. Checkpoint current graph branch | Review needed | Establish a known-good baseline before further migration. | current worktree; generated files; graph/evidence/contact/search tests; app smoke path | prevents uncertain rollback after broad graph changes | code generation if stale; analyzer; focused tests; smoke test core views | app compiles/analyzes; focused tests pass or failures are documented; current branch can be safely committed |
| 1. Overlay identity key audit and bridge design | Review needed | Decide graph-era overlay keys before migrating search/contact identity. | `user_overlays.db`; saved/tags; participant overrides; favourites; manual links; archived attachments | prevents user-intent loss during identity migration | overlay schema audit; migration/bridge proposal; tests identified | every overlay identity form has target key, bridge plan, and duplicate-GUID rule where needed |
| 2. Graph-native Search and Search Identity | Review needed | Make search select graph evidence directly. | `SearchService`; graph search repository; saved/tag overlays; `MessageEvidenceScope`; search result context | legacy `working.db` search-index rebuild and indexer providers retired | graph search tests for global/contact/conversation/handle/saved/tags; full-scope skeleton tests | ordinary search returns graph `message_ss_id` scopes and no longer requires legacy message IDs |
| 3. Graph-native Contact and Handle Identity | Review needed | Move contact/profile/handle reads to graph facts plus overlay intent. | display identity resolver; contact picker; hero/profile; handle menus; manual links; favourites | graph read repositories no longer open legacy `working.db` for contact/handle identity bridges | identity precedence tests; contact picker tests; handle selector tests; manual link overlay tests | user override wins everywhere; contact/handle selectors are graph-native; overlay writes remain overlay-only |
| 4. MessageEvidenceScope cleanup | Review needed | Remove remaining legacy-selector-fed evidence scopes after search/contact migration. | message evidence spine; global/contact/handle/conversation/search scopes | prevents legacy selection leaking into shared renderer | route/spec tests; full-scope skeleton tests | all ordinary message-bearing routes start from typed graph evidence scopes |
| 5. Graph lifecycle orchestration | In progress | Make graph build/readiness/update flow production-owned. | graph build service; graph readiness; onboarding; reset; `ChatDbChangeMonitor`; invalidation | removes manual/dev-panel dependency | graph build idempotence; incremental update test; readiness state tests; reset/onboarding tests | graph build is first-class lifecycle path and failures are visible/actionable |
| 6. Remaining ordinary read migration | Review needed | Retire leftover ordinary `working.db` reads. | global heatmap; old chat summaries; stray/spam handle lists; diagnostics vs product routes | proof-era recent chat legacy-vs-graph comparison removed from SS status sheet | provider tests; route smoke tests; dependency `rg` checks | no ordinary user-facing read depends on `working.db` except documented compatibility bridges |
| 7. Archive/recovery identity plan | In progress | Design source-scoped archive/recovery identity without disrupting archive integrity. | attachment archive; deterministic recovery; cross-snapshot mapper; recovered messages | prevents premature recovery rewrite | mapping audit; archive compatibility tests identified | recovery/archive path has graph identity plan and existing archive records remain usable |
| 8. Legacy retirement | Not started | Delete legacy data/read/presentation systems only after blockers are closed. | legacy import/migration/read models; retired widgets; diagnostics | removes attractive nuisance code safely | dependency checks; analyzer; focused tests; smoke test | legacy systems are deleted, demoted to diagnostics, or explicitly preserved as recovery/lifecycle references |

## Slice 0 - Checkpoint Current Graph Branch

### Goal

Turn the current graph migration branch into a reliable baseline.

### Why First

The current branch contains graph projection, evidence spine convergence,
identity work, UI convergence, attachment evidence, and substantial legacy
deletion. Continuing migration without a checkpoint increases rollback cost and
makes future failures harder to attribute.

### Files and Systems Involved

- generated Riverpod/Freezed/Drift files
- `lib/essentials/conversation_graph/`
- `lib/essentials/source_scoped_import/`
- `lib/features/messages/`
- `lib/features/contacts/`
- `lib/features/chats/`
- `lib/features/handles/`
- focused tests under matching `test/` paths

### Required Work

1. Inspect worktree status.
2. Run code generation if generated files are stale.
3. Run analyzer on changed areas or full app if practical.
4. Run focused graph/evidence/contact/identity/search tests.
5. Smoke test key app flows:
   - Conversations sidebar
   - Conversation message evidence
   - Contact all messages
   - Contact by conversation
   - Contact handle filter
   - Search all messages
   - Unfamiliar sources
   - Recovered messages
   - Attachment/media evidence
6. Fix only checkpoint-blocking defects.
7. Commit the checkpoint when clean enough.

### Current Checkpoint Evidence

2026-05-30:

- Branch: `Ftr.convo-topol`.
- Code generation completed with
  `dart run build_runner build --delete-conflicting-outputs`.
- `flutter analyze` completed with no issues.
- `dart analyze` was blocked by a `custom_lint` plugin startup failure before
  code diagnostics; use `flutter analyze` as the current checkpoint analyzer
  signal unless that tooling blocker is resolved.
- Full `flutter test` completed with all tests passing after checkpoint test
  harness updates.
- Focused graph evidence, display identity, attachment evidence, and migrated
  message presentation tests passed.
- Focused navigation, sidebar coordination, source-scoped import schema,
  conversation signature, recent chats, search context, and unfamiliar-source
  tests passed.
- One stale sidebar coordinator assertion was updated to match the existing
  settings-root resolver contract of nine settings top-menu rows.
- Test harness updates now reflect current invariants: overlay schema version 4,
  deprecated virtual-participant `short_name` remains empty, environment
  readiness provider tests initialize Flutter binding, and legacy conversation
  browser tests use an in-memory favourites controller.
- A Freezed chat aggregate constructor was made non-const so its runtime
  participant uniqueness assertion remains legal Dart.
- Manual app smoke flow remains the open Slice 0 verification item.

### Exit Criteria

Done means:

- generated files are current.
- analyzer has no unexpected failures.
- focused tests pass or any failures are explicitly classified.
- app smoke flow is manually confirmed.
- no unrelated refactors are introduced during stabilization.
- the branch has a checkpoint commit or a clearly documented blocker.

## Slice 1 - Overlay Identity Key Audit and Bridge Design

### Goal

Protect user intent before graph-native Search and Contact Identity migration.

### Current Checkpoint Evidence

2026-05-30:

- Added `74-OVERLAY-IDENTITY-KEY-AUDIT.md`.
- Classified current overlay identity keys and graph-era target keys.
- Identified message overlays as the first bridge target before graph-native
  Search.
- Identified contact/handle overlays as the next bridge target before legacy
  participant/handle identity retirement.
- Confirmed conversation Core favourites are already graph-conversation-id
  keyed enough for the current slice.
- Began the message overlay bridge: new graph-native message intent overlay
  tables are keyed by `message_ss_id`; legacy rowid/GUID tables remain readable
  through a named compatibility repository.

### Exit Criteria

Done means:

- each overlay table has a graph-era identity target.
- existing legacy-keyed rows have a bridge or migration path.
- saved/tag duplicate-GUID behavior is defined.
- contact favourite migration behavior is defined.
- manual handle link identity behavior is defined.
- archive overlay compatibility remains intact.
- message user intent has a graph-keyed write target before Search becomes
  graph-native.

## Slice 2 - Graph-Native Search and Search Identity

### Goal

Search should select graph message evidence directly.

### Current Checkpoint Evidence

2026-05-30:

- Added a named graph search repository boundary under
  `lib/essentials/search/infrastructure/repositories/`.
- Graph search returns canonical `message_ss_id` values.
- Global, conversation, and handle evidence text matching now route through the
  graph search boundary instead of feature-local text-match readers.
- Graph-native message saved/tag overlays are searchable by `message_ss_id`.
- Legacy GUID saved/tag overlays remain as an explicit compatibility bridge and
  are ignored when a GUID maps to more than one graph message.
- Contact evidence search still uses the contact graph reader until Slice 3
  completes graph-native contact/handle identity.
- Removed the unused legacy-ID search service APIs
  (`searchChatMessageIds`, `searchContactMessageIds`, `searchGlobalMessageIds`)
  and their `working.db`/FTS fallback implementation. `SearchService` is now a
  graph search facade over typed `GraphMessageSearchScope` values.
- Focused graph search and evidence spine tests pass.

### Exit Criteria

Done means:

- ordinary search returns graph `message_ss_id` scopes.
- search result contexts use full selected logical scopes.
- saved/tag filters work through graph identity or a documented bridge.
- no ordinary search path requires legacy `working.db` message IDs.

## Slice 3 - Graph-Native Contact and Handle Identity

### Goal

Contact and handle reads should come from graph facts plus overlay intent.

### Current Checkpoint Evidence

2026-05-30:

- `contactsListRepositoryProvider` now reads graph contacts first from
  `working_ss.db.contacts`, `contact_to_handle`, `chat_to_handle`,
  `chat_to_message`, and `messages`.
- `contactsListRepositoryProvider` no longer gates on or opens legacy
  `working.db`; ordinary contact picker summaries now come from graph facts
  plus overlay virtual contacts.
- Contact picker/list summaries use graph contact ids when graph contact
  evidence exists.
- Graph contact summaries still omit contacts with no chat/message
  participation, preserving the picker rule that non-participating AddressBook
  contacts should not appear as ordinary selectable contacts.
- User display-name override still wins over graph-imported contact names.
- Legacy participant reads are no longer part of ordinary contact list/profile
  resolution. Virtual contact summaries now calculate chat/message metrics from
  graph topology.
- `contactProfileProvider` now reads graph contact profiles and overlay virtual
  contacts only; it no longer gates on or opens legacy `working.db`.
- `handlesForContactProvider` now reads graph `contact_to_handle` handles plus
  overlay handle links only; it no longer gates on or opens legacy `working.db`.
- `handleDisplayNameProvider` now resolves through graph display identity first
  so known contacts/user overrides win over raw handle labels in handle evidence
  views.
- `handleDisplayNameProvider` no longer opens legacy `working.db`; it resolves
  user-visible handle labels from overlay intent, graph display identity, and
  graph handle facts only.
- `strayHandlesProvider` and `dismissedHandlesProvider` now read graph
  canonical handle evidence only and respect overlay dismissal, visibility, and
  linking intent.
- Manual handle linking now reads unlinked handles and available participants
  from graph facts only. Link/create/unlink operations continue to write only
  to overlay user-intent tables; creating a contact for a graph handle creates
  an overlay virtual contact rather than mutating working data.
- Spam/blacklist handle management now reads graph canonical handles only and
  applies overlay visibility/blacklist state at read time. Block/unblock remain
  overlay-only writes.
- Focused contact and handle settings tests pass for graph-native behavior.

## Slice 5 - Graph Lifecycle Orchestration

### Goal

Make graph build, readiness, update, and reset behavior production-owned rather
than dev-panel-owned.

### Current Checkpoint Evidence

2026-05-30:

- Added central `conversationGraphReadinessProvider` and
  `conversationGraphPopulatedProvider` under
  `lib/essentials/db/feature_level_providers/`.
- The graph readiness checker inspects `working_ss.db` directly and reports
  whether the source-scoped graph has the core production shape:
  messages, chats, and chat/message topology.
- The provider is exported from the central database dependency entry point.
- The message sidebar cassette rack and top menu prompt now gate on graph
  population instead of legacy `working.db` population.
- The unused `workingDbPopulatedProvider` compatibility gate was retired.
- The live `chat.db` monitor now gates automatic incremental work on graph app
  data readiness instead of legacy working projection readiness.
- The onboarding fallback database-existence check now requires
  `macos_import_ss.db` plus a ready `working_ss.db` conversation graph; legacy
  import/working databases alone are no longer sufficient.
- The onboarding environment report now probes `working_ss.db` for the
  app-facing conversation graph readiness view and `macos_import_ss.db` for the
  app-facing import ledger while leaving legacy reset/import mechanics intact.
- Message data reset now treats `macos_import_ss.db` and `working_ss.db` as
  first-class derived app databases: it closes and invalidates the source-scoped
  import/graph providers, deletes `-wal`/`-shm` sidecars for all derived DBs,
  and preserves overlay plus attachment archive state.
- Onboarding fresh-start and message-data reset close derived database
  providers only when the corresponding base database file already exists, so
  graph-era cleanup does not recreate legacy database files just to delete them.
- Onboarding failure/support-bundle diagnostics now label the app-facing probe
  as `Conversation graph` instead of `Working database`.
- Added a central `conversationGraphBuildControllerProvider` that records graph
  build lifecycle state (`idle`, `running`, `succeeded`, `failed`) and is now
  the entry point for both the source-scoped dev panel and live `chat.db`
  monitor graph builds.
- Live `chat.db` changes now trigger the conversation graph build before any
  legacy compatibility import or migration, so automatic sync updates the
  app-facing graph before maintaining the legacy projection.
- Live `chat.db` monitor updates now treat source-scoped graph import/projection
  as the app-facing success path. Legacy ledger import and `working.db`
  migration still run for compatibility maintenance, but their failure or
  exception no longer blocks refreshed graph evidence when the graph build has
  succeeded.
- The live monitor now claims the global derived-data maintenance gate around
  the graph build, attachment archive pass, legacy import, and legacy migration.
  Gate denial still delays/retries to avoid overlapping maintenance work, but
  the gate is no longer provided indirectly by the legacy import path.
- Live monitor startup catch-up and cursor priming now compare `chat.db` to the
  source-scoped import ledger (`macos_import_ss.db`) rather than the legacy
  `macos_import.db` message cursor, so graph freshness is measured from the
  app-facing ledger.
- Live update attachment archiving now uses graph message source-row ranges
  from the source-scoped build report instead of legacy import batch ids.
  Existing overlay archive keys are preserved during transition.
- The legacy import control panel reset/clear actions now close, invalidate,
  and delete graph-era derived databases (`macos_import_ss.db`,
  `working_ss.db`) as well as legacy import/working databases.
- Database health/support-bundle audits now include the source-scoped import
  ledger and conversation graph databases alongside legacy import/working and
  overlay databases.
- Database health/support-bundle audits now curate source-scoped import and
  conversation graph table/relationship/invariant checks explicitly, while
  legacy `macos_import.db` and `working.db` are labelled as compatibility
  databases rather than production authority.
- Onboarding, environment-readiness, diagnostic-report, and import-control
  presentation copy now describes app-facing readiness as the source-scoped
  import ledger plus conversation graph rather than generic import/working
  databases.
- Onboarding abort/fresh-start cleanup now deletes graph-era derived databases
  as well as legacy import/working databases.
- First-run onboarding and settings-triggered reimport now rely on the import
  control migration path to build the conversation graph after successful
  migration, so successful setup requires graph-ready app data.
- Manual legacy import-control migration now runs the central conversation graph
  build after successful migration; a graph build failure is recorded as the
  user-visible migration failure state because the app-facing graph was not
  produced.
- Settings-triggered reimport now uses the same success contract as first-run
  onboarding: import result and migration/graph-build result must both succeed
  before the overlay can land on reimport complete.
- Concurrent graph build requests now coalesce through the central build
  controller instead of throwing. If the live monitor and a manual/status action
  overlap, both callers observe the same in-flight build result.
- Message History Coverage settings now count visible app messages from the
  conversation graph.
- Legacy `workingProjectionReadinessProvider` has been retired. Retained
  recovered parity diagnostics now report legacy recovered evidence
  unavailability directly instead of using a central `working.db` readiness
  gate.
- Focused graph readiness tests pass.

### Exit Criteria

Done means:

- contact picker/profile/hero read models are graph-backed.
- handle selectors are graph-backed.
- unfamiliar/stray handle review is graph-backed.
- manual handle-to-contact linking is graph-backed on the read side and
  overlay-only on the write side.
- spam/blacklist handle management is graph-backed on the read side and
  overlay-only on the write side.
- display identity resolver owns user-facing names.
- raw handle is primary only for unfamiliar sources or explicit handle controls.
- manual links and favourites remain overlay-only user intent.

## Slice 4 - MessageEvidenceScope Cleanup

### Goal

Ensure every ordinary message-bearing path enters through a graph-native typed
scope.

### Current Checkpoint Evidence

2026-05-30:

- Removed the legacy/graph chat read-model switch. Product recent-chat and chat
  selection flows now route through graph conversation identity only.
- `recentChatsProvider` is graph-only for product reads. The legacy recent-chat
  reader remains only as a diagnostic compatibility reader for the SS comparison
  panel.
- Removed unused legacy chat-by-age/unmatched-chat provider families that read
  `working.db` directly.
- Contact timeline heatmaps now attempt graph timeline data by default and use
  the legacy heatmap only as rebuild/reset compatibility fallback.
- Removed the unused legacy `ChatsRepository` aggregate skeleton, unimplemented
  SQLite repository provider, and old disabled chat timeline calculator/widget
  path. Calendar heatmap timeline data remains because conversation signatures
  still use it.
- Removed the diagnostic legacy recent-chat reader from the chats feature. The
  SS comparison panel now owns its own minimal `working.db` comparison query,
  so product chat providers expose graph recent-chat reads only.
- Removed retired `MessagesSpec.forChat` and
  `MessagesSpec.forChatInDateRange` variants. Heatmap month selection now has
  no built-in navigation fallback; callers must supply an explicit
  evidence-scope action.
- Removed GUID-keyed `MessageUserMetadata` controller/loader and legacy
  integer-keyed `MessageAnnotations` controller. Graph message user intent now
  enters through `MessageOverlay`; legacy overlay tables remain only as bridge
  inputs.
- Removed the unused URL preview developer widget. Active URL previews remain
  rendered through the shared attachment evidence path.
- Removed the obsolete search-result context anchor provider/chrome. Search
  result context anchoring now belongs to the evidence spine skeleton via
  `initialAnchorMessageId`, not a separate right-panel-derived presentation
  state bridge.
- Removed the obsolete recovered-specific visible-month provider/helper. All
  recovered and ordinary timeline heatmaps now use the shared
  `currentVisibleMonthForScopeProvider` keyed by typed message evidence scope.
- Contact and global message heatmaps now read graph timelines only. The
  legacy `contact_message_index` / `global_message_index` heatmap fallback and
  contact heatmap calculator have been retired.

### Exit Criteria

Done means:

- contact, conversation, handle, global, search, and recovered evidence routes
  are classified.
- ordinary routes use graph-native scopes.
- source-specific renderers do not reappear.
- timeline-like scopes preserve full selected logical message universes.

## Slice 5 - Graph Lifecycle Orchestration

### Goal

Make the graph build and readiness path production-owned.

### Exit Criteria

Done means:

- graph build has explicit lifecycle state.
- onboarding can build or validate graph data.
- reset/maintenance deliberately handles graph DBs.
- live `chat.db` changes trigger graph import/projection.
- graph evidence invalidates after successful projection.
- dev panel is instrumentation, not the only graph build entry point.

## Slice 6 - Remaining Ordinary Read Migration

### Goal

Close remaining user-facing `working.db` reads after search/contact/lifecycle
choke points are resolved.

### Current Checkpoint Evidence

2026-05-30:

- Message History Coverage settings now read visible message counts from the
  conversation graph and get FDA state through the onboarding provider
  boundary.
- Database Health Audit now receives FDA state from the provider-owned
  onboarding boundary instead of probing `FdaChecker` directly. Its legacy and
  graph database inventory remains intentionally broad because support bundles
  still need compatibility visibility.
- The macOS app shell no longer watches the shadow import-decision provider on
  startup and no longer exposes shadow polling start/stop/refresh toolbar
  controls. The source-scoped status sheet remains the toolbar diagnostic entry
  point.
- The unreachable shadow incremental-update status sheet and shadow polling
  orchestrator were retired. Lower-level shadow pipeline classes remain only
  for compatibility tests and any explicitly retained diagnostic work.
- Follow-up reachability scan showed no production imports of the old
  `lib/essentials/incremental_update/` shadow package outside that package.
  The retired shadow package and its package-local tests were removed as a
  single compatibility-retirement slice. Source-scoped import, graph build, and
  live `chat.db` monitor lifecycle paths remain intact.

2026-05-31:

- Fresh `working.db` / `macos_import.db` dependency scan found no remaining
  ordinary app-facing reads. Remaining legacy DB consumers are now classified
  as production lifecycle, archive/recovery, diagnostics/settings, legacy DB
  definitions, or tests for retained legacy systems.
- `71-LEGACY-DEPENDENCY-MATRIX.md` was refreshed to remove stale search,
  contact, handle, chat, and heatmap ordinary-read blockers that have already
  been migrated.
- Recovered deleted messages are now graph-backed in production. Retained
  legacy recovered-message tables remain diagnostic/archive compatibility
  sources rather than ordinary app reads.

### Exit Criteria

Done means:

- global and contact heatmaps are graph-backed.
- old chat summary fallbacks are graph-backed or retired.
- stray/spam handle lists are graph-backed or clearly diagnostic.
- `working.db` remains only for lifecycle, recovery/archive, diagnostics, or
  explicitly named compatibility bridges.

## Slice 7 - Archive and Recovery Identity Plan

### Goal

Move archive/recovery toward source-scoped identity without risking existing
archives.

### Current Checkpoint Evidence

2026-05-31:

- Added `75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md`.
- Identified the current archive overlay key as
  `(message_guid, import_attachment_id)` and the graph target identity as
  `(message_ss_id, attachment_ss_id)`.
- Documented the compatibility bridge that lets existing archive rows remain
  resolvable through graph facts by deriving live-source attachment row identity
  from `attachment_ss_id`.
- Defined separate migration strategies for:
  - current living attachment archive
  - historical MessageLens archive backup
  - recovered Messages folders
  - recovered deleted-message evidence
- Established the first implementation boundary: add graph archive identity/read
  resolution before changing overlay schema or recovered-message storage.
- Added `GraphAttachmentArchiveLookup` and
  `OverlayArchiveCompatibilityLookup` as the first named graph archive
  identity boundary.
- Conversation graph attachment summaries now resolve existing archive overlay
  records through the named graph archive lookup instead of deriving the legacy
  key inline.
- The compatibility bridge preserves existing
  `(message_guid, import_attachment_id)` archive rows and refuses non-live
  source ids to avoid cross-source rowid collisions.
- Focused graph archive lookup and chat attachment summary tests pass.
- Attachment archive rolling/manual sweeps and archive-all candidate selection
  now read graph attachment facts from `working_ss.db` instead of legacy
  `working.db.attachments`, while preserving existing overlay archive keys.
- Legacy import-batch archive handling remains in place only for compatibility
  callers; live update lifecycle archives attachments from source-scoped graph
  message source-row ranges.
- Focused attachment archive service tests pass against graph-backed sweep
  fixtures.
- Deterministic historical attachment recovery now maps through
  `macos_import_ss.db` and `working_ss.db` via `GraphCrossSnapshotMapper`
  instead of `macos_import.db` and `working.db`.
- The mapper exposes graph identity (`message_ss_id`, `attachment_ss_id`) while
  preserving the current overlay archive write key during transition.
- The obsolete legacy `CrossSnapshotMapper` implementation and tests were
  retired; shared mapping result types remain in a neutral model file used by
  the graph mapper and deterministic recovery provider.
- Focused graph cross-snapshot mapper tests pass.
- Added `76-RECOVERED-MESSAGE-GRAPH-IDENTITY-PLAN.md` to separate the
  recovered-message migration from ordinary graph message migration.
- Recovered message presentation is already on the shared Message Evidence
  Spine, but the source repository remains a legacy compatibility island until
  a recovered-message evidence repository boundary is introduced.
- Introduced the first recovered-message evidence repository boundary:
  `RecoveredMessageEvidenceRepository`, backed for now by
  `RetainedLegacyRecoveredMessageEvidenceRepository`. Runtime behavior remains
  legacy-compatible, but the remaining `working.db.recovered_unlinked_*` reads
  are now explicitly quarantined behind a named recovery boundary.
- Added focused repository tests for the compatibility boundary covering
  recovered fallback text, recovered attachment dedupe, contact scoping,
  no-handle outgoing inference, and contact-name resolution through legacy
  handle/participant links.
- Split the recovered-message boundary into:
  - domain read model/contract:
    `domain/message_evidence/recovered_message_evidence.dart`
  - legacy storage implementation:
    `infrastructure/repositories/retained_legacy_recovered_message_evidence_repository.dart`
  - thin Riverpod wiring:
    `infrastructure/repositories/recovered_unlinked_messages_provider.dart`
  This keeps the replacement point explicit without changing runtime behavior.
- Added schema-free `RecoveredMessageIdentity` domain tests that establish
  recovered rows as source message occurrences with identity
  `pack(source_id, message.ROWID)`. Duplicate ROWIDs across live/archive
  sources remain distinct, GUID does not define identity, and topology controls
  projection surface rather than identity.
- Added schema-free `RecoveredMessageEvidenceRepository` contract tests using
  an in-memory graph-shaped implementation. These tests lock the target
  source-scoped recovered evidence behavior before storage changes: ordinary
  graph-projectable rows are excluded, recovered-only rows use source-scoped
  message ids, duplicate GUIDs do not collapse, sparse/attachment-only evidence
  remains visible, and contact-scoped no-handle inference remains intact.
- Added `GraphRecoveredMessageEvidenceRepository` as an un-wired graph-backed
  replacement candidate for the legacy recovered repository. It reads
  source-scoped graph messages without `chat_to_message` topology, preserves
  `ss_id` message identity, hydrates graph attachment evidence, and keeps
  contact-scoped direct/no-handle inference behavior. Production recovered
  evidence still uses the legacy repository until real-data parity is reviewed.
- Focused graph recovered repository tests pass for topology exclusion,
  duplicate GUID/overlapping ROWID preservation, contact-scoped inference, and
  sparse/attachment-only evidence.
- Added `77-RECOVERED-MESSAGE-GRAPH-PARITY-AUDIT.md` with real-data comparison
  between legacy recovered rows and graph orphan evidence. The graph candidate
  matches 20,697 legacy recovered rows as graph-orphan evidence, repairs 195
  legacy recovered rows into ordinary chat topology, exposes 1 new graph-only
  orphan row, and leaves 3 legacy-only rows without current import/graph
  coverage. Attachment/text/GUID parity is clean for matched rows.
- Added a pure recovered-message parity comparator so future cutover checks can
  classify graph-orphan matches, now-projectable legacy rows, legacy-only rows,
  graph-only rows, and evidence mismatches without embedding comparison logic
  in widgets or repository implementations.
- Reclassified the 3 legacy-only recovered rows after user clarification: they
  correspond to Unknown Senders discard testing and should be treated as
  graph-era user-intent suppression, not source/import evidence loss. The
  parity comparator now distinguishes known suppressed legacy-only rows from
  unresolved legacy-only rows so diagnostics do not overstate dismissal effects
  as retention blockers.
- Added `recoveredMessageParityDiagnosticProvider` as a diagnostic-only
  application boundary around the legacy recovered repository, graph recovered
  candidate repository, `GraphRecoveredMessageProjectabilityRepository`,
  dismissed-handle overlay state, and pure parity comparator. This was used as
  the cutover gate before production recovered evidence moved to the graph
  repository.
- Surfaced the recovered-message parity diagnostic in the source-scoped Graph
  health tab. The UI reports graph parity status, recovered row counts,
  now-projectable rows, suppressed/unresolved legacy-only rows, graph-only rows,
  attachment/text/GUID mismatch counts, and the current production
  recovered-message routing.
- Added drilldown samples for unresolved legacy-only rows and text mismatches so
  parity blockers can be investigated from typed diagnostic output instead of
  one-off SQL.
- Classified equivalent "no preserved content" fallback labels as the same
  parity value. Legacy and graph wording differences for sparse/no-content
  artifacts no longer count as evidence text loss.
- Clarified the graph parity gate wording: matched graph evidence can pass while
  legacy-only rows remain a separate retention/acceptance caveat.
- Cut over `recoveredUnlinkedMessagesProvider` to
  `GraphRecoveredMessageEvidenceRepository`. Recovered-message presentation
  still uses the shared Message Evidence Spine, legacy recovered storage remains
  retained for diagnostics/fallback, and the parity diagnostic remains visible.
- Renamed the retained legacy recovered repository to
  `RetainedLegacyRecoveredMessageEvidenceRepository` so remaining `working.db`
  recovered reads are clearly diagnostic/compatibility reads, not production
  recovered-message routing.
- Message History Coverage no longer reads `working.db.recovered_unlinked_*`.
  It now reads conversation-linked and graph-orphan recovered counts from the
  conversation graph through a settings infrastructure repository.
- Removed `workingProjectionReadinessProvider` and its export. No production
  code uses `working.db` readiness as an app gate.
- Removed static `lib/debug_install/*` log artifacts after reference scan
  confirmed they were not runtime inputs or fixtures. Runtime/import/migration
  logs remain generated in their documented Application Support / Logs
  locations.
- Retired the recovered-message parity diagnostic bridge from the SS graph
  health panel. Production recovered evidence already reads graph orphan
  evidence, and the remaining legacy-only rows were accepted as retention
  caveats rather than graph evidence loss.
- Removed the retained legacy recovered-message diagnostic repository, pure
  parity comparator, projectability lookup, and their focused diagnostic tests.
  Legacy recovered tables still physically exist inside retained legacy DBs,
  but no runtime diagnostic bridge now opens `working.db.recovered_unlinked_*`.
- Removed the last `WorkingDatabase` helpers from `participant_merge_utils`;
  that utility now contains overlay/contact helper functions only.
- Retired the unused Supabase mirror runtime stubs: provider, service,
  bookkeeping repository, unimplemented migrators, config providers, value
  objects, and obsolete validation failure case. Existing `working.db`
  Supabase table definitions remain only because the retained legacy Drift
  schema itself is still retained.
- Historical archive folder preflight now estimates GUID-backed duplicate/new
  source rows against the conversation graph (`working_ss.db.messages`) instead
  of legacy `working.db.messages`. This removes a low-risk legacy read while
  keeping actual archive import/removal lifecycle behavior unchanged.
- Historical archive known-source sidebar data now flows through
  `HistoricalArchiveSourcesRepository`, a named settings infrastructure bridge
  over `macos_import.db.historical_archive_sources`. Application/sidebar code
  consumes typed archive-source metadata and no longer imports the legacy DB
  provider or sqflite record type directly.
- Import control's broad "reset all databases" action now delegates to
  `MessageDataResetService.resetDerivedData()`. The overlay-preserving
  deletion/invalidation behavior has one lifecycle owner; import control keeps
  only its local UI state mapping and the narrower import/projection clear
  actions.
- Import control's "clear import database" action now delegates to
  `MessageDataResetService.clearImportLedgers()`. Legacy and source-scoped
  import-ledger deletion share the same lifecycle owner; import control keeps
  only its local status/error presentation.
- Import control's "clear working database" action now delegates to
  `MessageDataResetService.clearProjectionDatabases()`. Legacy `working.db`
  and graph `working_ss.db` projection deletion share the same lifecycle owner;
  import control keeps only its local status/error presentation.
- `OnboardingGate` no longer owns a duplicate full derived-database deletion
  implementation. Abort and fresh-start cleanup now route through the same
  import-control reset boundary, while settings reimport keeps its import-only
  ledger cleanup path.
- `OnboardingGate` no longer owns import-ledger file deletion for settings
  reimport. Reimport now delegates ledger cleanup to
  `MessageDataResetService.clearImportLedgers()`, preserving onboarding as the
  lifecycle decision owner while centralizing database deletion/invalidation.

### Exit Criteria

Done means:

- existing archive records remain resolvable.
- historical MessageLens archive source strategy is defined.
- recovered Messages folder source strategy is defined.
- deterministic recovery no longer requires ordinary `working.db` identity in
  the long-term plan.
- recovered-message repository ownership is named before recovered storage is
  migrated.

## Slice 8 - Legacy Retirement

### Goal

Remove legacy systems only after their blockers close.

### Exit Criteria

Done means:

- every deleted system is listed in the dependency matrix or this checklist.
- every preserved system has a current classification.
- no ordinary user-facing read depends on legacy working/import identity.
- legacy import/projection is either retired or explicitly preserved as
  diagnostic/recovery infrastructure.

## Update Rule

Update this checklist when:

- a slice starts.
- a slice exits review.
- a blocker is discovered.
- a compatibility bridge is removed.
- a legacy dependency is reclassified.
- tests or smoke steps change.
