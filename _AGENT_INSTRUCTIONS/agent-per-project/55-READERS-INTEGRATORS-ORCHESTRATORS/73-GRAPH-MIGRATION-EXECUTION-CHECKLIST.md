---
tier: project
scope: source-scoped-graph-migration
status: active
last_reviewed: 2026-06-19
depends_on:
  - 70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md
  - 71-LEGACY-DEPENDENCY-MATRIX.md
  - 72-GRAPH-CHOKE-POINTS-AND-RETIREMENT-BLOCKERS.md
  - 75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md
  - 76-RECOVERED-MESSAGE-GRAPH-IDENTITY-PLAN.md
  - 77-RECOVERED-MESSAGE-GRAPH-PARITY-AUDIT.md
  - 81-LEGACY-STORAGE-RETENTION-REGISTER.md
  - 82-SOURCE-SCOPED-ARCHIVE-IMPORT-CUTOVER-PLAN.md
---

# 73 - Graph Migration Execution Checklist

## Purpose

This is the execution companion to the graph migration planning documents.

- `70` defines the roadmap.
- `71` classifies remaining legacy dependencies.
- `72` identifies choke points, compatibility bridges, overlay identity risks,
  and retirement blockers.
- This document tracks concrete execution slices and their exit criteria.

The purpose is to prevent opportunistic cleanup, accidental retained-data
deletion, or feature drift while completing the graph migration.

## Execution Rules

1. Work from high-leverage choke points, not from isolated legacy references.
2. Do not delete legacy code until its blocker row is closed.
3. Do not delete, overwrite, or reclassify retained `macos_import.db` /
   `working.db` user data files until their retention-register criteria are
   closed.
4. Do not promote a compatibility bridge into production architecture without
   naming it and defining its removal condition.
5. User intent remains overlay-only.
6. Import and projection must not consult overlay state.
7. Message-bearing surfaces must continue through the Message Evidence Spine.
8. Pagination is not timeline navigation.
9. Lifecycle work must be centralized through database/readiness/orchestration
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
| 0. Checkpoint current graph branch | Done | Establish a known-good baseline before further migration. | current worktree; generated files; graph/evidence/contact/search tests; app smoke path | prevents uncertain rollback after broad graph changes | code generation if stale; analyzer; focused tests; smoke test core views | app compiles/analyzes; focused tests pass or failures are documented; current branch can be safely committed |
| 1. Overlay identity key audit and bridge design | Done | Decide graph-era overlay keys before migrating search/contact identity. | `user_overlays.db`; saved/tags; participant overrides; favourites; manual links; archived attachments | prevents user-intent loss during identity migration | overlay schema audit; migration/bridge proposal; tests identified | every overlay identity form has target key, bridge plan, and duplicate-GUID rule where needed |
| 2. Graph-native Search and Search Identity | Done | Make search select graph evidence directly. | `SearchService`; graph search repository; saved/tag overlays; `MessageEvidenceScope`; search result context | legacy `working.db` search-index rebuild and indexer providers retired | graph search tests for global/contact/conversation/handle/saved/tags; full-scope skeleton tests | ordinary search returns graph `message_ss_id` scopes and no longer requires legacy message IDs |
| 3. Graph-native Contact and Handle Identity | Done | Move contact/profile/handle reads to graph facts plus overlay intent. | display identity resolver; contact picker; hero/profile; handle menus; manual links; favourites | graph read repositories no longer open legacy `working.db` for contact/handle identity bridges | identity precedence tests; contact picker tests; handle selector tests; manual link overlay tests | user override wins everywhere; contact/handle selectors are graph-native; overlay writes remain overlay-only |
| 4. MessageEvidenceScope cleanup | Done | Remove remaining legacy-selector-fed evidence scopes after search/contact migration. | message evidence spine; global/contact/handle/conversation/search scopes | prevents legacy selection leaking into shared renderer | route/spec tests; full-scope skeleton tests | all ordinary message-bearing routes start from typed graph evidence scopes |
| 5. Graph lifecycle orchestration | Done | Make graph build/readiness/update flow production-owned. | graph build service; graph readiness; onboarding; reset; `ChatDbChangeMonitor`; invalidation | removes manual/dev-panel dependency | graph build idempotence; incremental update test; readiness state tests; reset/onboarding tests | graph build is first-class lifecycle path and failures are visible/actionable |
| 6. Remaining ordinary read migration | Done | Retire leftover ordinary `working.db` reads. | global heatmap; old chat summaries; stray/spam handle lists; diagnostics vs product routes | proof-era recent chat legacy-vs-graph comparison removed from SS status sheet | provider tests; route smoke tests; dependency `rg` checks | no ordinary user-facing read depends on `working.db` except documented compatibility bridges |
| 7. Archive/recovery identity plan | Done | Design source-scoped archive/recovery identity without disrupting archive integrity. | attachment archive; deterministic recovery; cross-snapshot mapper; recovered messages | prevents premature recovery rewrite | mapping audit; archive compatibility tests identified | recovery/archive path has graph identity plan and existing archive records remain usable |
| 8. Legacy retirement and retained storage reduction | In progress | Delete retired execution/read/presentation code only after blockers are closed, while reducing retained DB storage under the retention register. | legacy import/migration/read models; retired widgets; diagnostics; retained `macos_import.db` / `working.db` files | removes attractive nuisance code safely without losing retained user data | dependency checks; analyzer; focused tests; smoke test; retention-register review | legacy systems are deleted, demoted to diagnostics, or explicitly preserved as recovery/lifecycle/compatibility references |

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
  retained virtual-participant `short_name` schema column remains empty,
  environment
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
- Contact evidence search now participates in the graph evidence/search path
  after Slice 3 completed graph-native contact/handle identity.
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
- `contactsListRepositoryProvider` is now composed at the contacts feature
  boundary; graph contact list reads are behind a typed `ContactsListReader`.
- `recentContactsProvider` is now composed at the contacts feature boundary;
  overlay recent-contact reads are behind a typed `RecentContactsReader`.
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
- `contactProfileProvider` and `handlesForContactProvider` are now composed at
  the contacts feature boundary; graph/overlay reads are behind typed
  application read contracts instead of exported infrastructure provider files.
- `virtualParticipantsProvider` is now composed at the contacts feature
  boundary; overlay virtual-contact reads are behind a typed
  `VirtualParticipantsReader`.
- `handleDisplayNameProvider` now resolves through graph display identity first
  so known contacts/user overrides win over raw handle labels in handle evidence
  views.
- `handleDisplayNameProvider` no longer opens legacy `working.db`; it resolves
  user-visible handle labels from overlay intent, graph display identity, and
  graph handle facts only.
- `handleDisplayNameProvider` is now composed at the handles feature boundary;
  graph/overlay reads are quarantined behind a typed
  `HandleDisplayNameReader` rather than exported as an infrastructure provider.
- `strayHandlesProvider` and `dismissedHandlesProvider` now read graph
  canonical handle evidence only and respect overlay dismissal, visibility, and
  linking intent.
- Manual handle linking now reads unlinked handles and available participants
  from graph facts only. Link/create/unlink operations continue to write only
  to overlay user-intent tables; creating a contact for a graph handle creates
  an overlay virtual contact rather than mutating graph/import projection data.
- Spam/blacklist handle management now reads graph canonical handles only and
  applies overlay visibility/blacklist state at read time. Block/unblock remain
  overlay-only writes.
- Focused contact and handle settings tests pass for graph-native behavior.
- Contact-name and chat-handle feature docs now describe graph-era display
  identity: user override wins, imported graph/contact identity follows, and
  raw handles are fallback/explicit-scope labels only. Short-name and nickname
  paths are documented as retired app-facing concepts.

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
- Live `chat.db` changes now trigger the conversation graph build as the
  app-facing production update path. The retained legacy import/migration
  maintenance tail has been retired from live updates.
- Live `chat.db` monitor updates now treat source-scoped graph import/projection
  as the app-facing success path; retained `macos_import.db` / `working.db`
  files are transitional cleanup storage, not live-update outputs.
- The live monitor now claims the global derived-data maintenance gate around
  the graph build and attachment archive pass.
  Gate denial still delays/retries to avoid overlapping maintenance work, but
  the gate is no longer provided indirectly by the legacy import path.
- Live monitor startup catch-up and cursor priming now compare `chat.db` to the
  source-scoped import ledger (`macos_import_ss.db`) rather than the legacy
  `macos_import.db` message cursor, so graph freshness is measured from the
  app-facing ledger.
- Live monitor success semantics are expressed directly in the control flow:
  graph build success advances the app-facing cursor and refreshes graph
  evidence. The former live-update legacy import/migration compatibility tail
  was later retired during Slice 8.
- Real-data polling proof completed on 2026-06-02: sending one live message
  advanced the monitor cursor from source rowid `149213` to `149214`; the
  `chat-db-monitor` owner ran the graph build; graph build status ended
  `succeeded`; one graph message was imported and one graph message was
  projected; `rowIdDelta` returned to `0`.
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
- First-run onboarding and settings-triggered reimport now run the central
  source-scoped conversation graph build directly. They no longer invoke the
  retained legacy import/migration control path as the app-facing setup or
  rebuild mechanism.
- Graph build failure is recorded in overlay onboarding failure state using the
  existing migration-failure reporting slot, so setup/reimport failures remain
  visible without making legacy migration the authority.
- Settings-triggered reimport now uses the same success contract as first-run
  onboarding: the source-scoped graph build must succeed before the overlay can
  land on reimport complete.
- Concurrent graph build requests now coalesce through the central build
  controller instead of throwing. If the live monitor and a manual/status action
  overlap, both callers observe the same in-flight build result.
- Message History Coverage settings now count visible app messages from the
  conversation graph.
- Legacy `workingProjectionReadinessProvider` has been retired. Retained
  recovered parity diagnostics now report legacy recovered evidence
  unavailability directly instead of using a central `working.db` readiness
  gate.
- The unused `LegacyProjectionStatusRepository` / Drift implementation has
  been retired. Graph readiness is now the only app-facing readiness gate for
  whether message evidence can be shown. The later retained archive pipeline
  and its private legacy full-vs-incremental rebuild check have also been
  retired; graph readiness remains the app-facing readiness boundary.
- Dead `db_migrate` scaffolding not used by the retained archive-compatible
  projection path has been retired: the unimplemented `AppSettingsMigrator`
  and empty `MigrationOrderPolicy` file.
- Empty, unreferenced placeholder files were retired from contacts,
  reactions, retained `db_migrate` sqlite helpers, and window-state macOS
  utilities. No active imports referenced them.
- Pipeline incident display language now renders retained migration-stage
  incidents as “Retained historical projection” while preserving the persisted
  `PipelineIncidentStage.migration` enum value for overlay compatibility.
- Historical archive workflow presentation now refers to the retained
  archive-compatible rebuild as a bounded retained projection instead of
  generic “migration.” This was later superseded when Historical Archives
  import/removal moved to source-scoped graph services and the retained
  projection execution path was retired.
- Real-data polling proof continued on 2026-06-03: live message and attachment
  messages were imported/projected through the source-scoped graph and appeared
  in open graph-backed contact evidence views without changing contact context.
- Successful graph builds now bump the shared message-data version from the
  central build controller, so graph evidence, conversation lists, heatmaps, and
  identity-dependent message surfaces refresh from one lifecycle signal.
- Incremental projection cursor indexes on import graph edge ledgers reduced
  chat/message edge projection for a single-message live update to effectively
  `0 ms` on the tested data set.
- Rich-text enrichment is explicitly bounded for live imported source-row
  ranges; full missing-text enrichment is reserved for builds with no newly
  imported messages. The Rust blob extractor availability smoke test is cached
  at the extractor boundary to avoid repeated fixed setup work.
- Open message views preserve user scroll context during live updates and use
  the shared pending-new-message indicator rather than forcing an automatic
  scroll to the newest row.
- Focused graph readiness tests pass.

### Exit Criteria

Done means:

- graph build has explicit lifecycle state.
- onboarding can build or validate graph data.
- reset/maintenance deliberately handles graph DBs.
- live `chat.db` changes trigger graph import/projection.
- graph evidence invalidates after successful projection.
- dev panel is instrumentation, not the only graph build entry point.

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
- Contact and global timeline heatmaps now read graph timeline skeletons; the
  legacy heatmap fallback was later retired in this slice.
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
- Legacy import-batch archive handling has been retired; live update lifecycle
  archives attachments from source-scoped graph message source-row ranges.
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
  Spine. The later graph cutover in this slice replaced the temporary legacy
  compatibility repository with graph-orphan evidence.
- Earlier in the recovered-message slice, introduced the first recovered-message
  evidence repository boundary:
  `RecoveredMessageEvidenceRepository`, backed for now by
  `RetainedLegacyRecoveredMessageEvidenceRepository`. Runtime behavior remains
  legacy-compatible, but the remaining `working.db.recovered_unlinked_*` reads
  are now explicitly quarantined behind a named recovery boundary.
- Added focused repository tests for the temporary compatibility boundary
  covering
  recovered fallback text, recovered attachment dedupe, contact scoping,
  no-handle outgoing inference, and contact-name resolution.
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
- Added `GraphRecoveredMessageEvidenceRepository` as a graph-backed
  replacement for the legacy recovered repository. It reads
  source-scoped graph messages without `chat_to_message` topology, preserves
  `ss_id` message identity, hydrates graph attachment evidence, and keeps
  contact-scoped direct/no-handle inference behavior.
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
- Added the now-retired `recoveredMessageParityDiagnosticProvider` as a
  diagnostic-only
  application boundary around the legacy recovered repository, graph recovered
  candidate repository, `GraphRecoveredMessageProjectabilityRepository`,
  dismissed-handle overlay state, and pure parity comparator. This was used as
  the cutover gate before production recovered evidence moved to the graph
  repository.
- Temporarily surfaced the recovered-message parity diagnostic in the
  source-scoped Graph health tab. The UI reported graph parity status, recovered
  row counts,
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
  still uses the shared Message Evidence Spine, while legacy recovered storage
  remains physical historical storage inside retained DB files until broader
  storage retirement.
- Earlier, renamed the retained legacy recovered repository to
  `RetainedLegacyRecoveredMessageEvidenceRepository` so remaining `working.db`
  recovered reads are clearly diagnostic/compatibility reads, not production
  recovered-message routing. This diagnostic repository was later removed after
  graph parity was accepted.
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
  Legacy recovered tables still physically exist inside retained DB files,
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
- Import control's broad "reset all databases" action was consolidated into
  `MessageDataResetService.resetDerivedData()`. The later retirement of the
  import-control panel removed its narrower import/projection clear actions,
  and the corresponding intermediate reset-service methods were retired.
- Historical archive removal now uses source-scoped archive graph removal and
  graph reprojection directly. It no longer depends on retained projection
  cleanup helpers from the old import-control lifecycle.
- `OnboardingGate` no longer owns a duplicate full derived-database deletion
  implementation. Abort and fresh-start cleanup now route through the same
  import-control reset boundary, while settings reimport keeps its import-only
  ledger cleanup path.
- `OnboardingGate` no longer owns import-ledger-only deletion for settings
  reimport. Reimport uses the full graph-era derived-data reset path before
  rebuilding the source-scoped graph.
- Import control no longer queries legacy `working.db` directly to decide
  incremental migration mode. That retained compatibility question now lives
  inside `RetainedLegacyArchivePipeline`, the named archive-compatible rebuild
  boundary.
- Import control no longer performs a live Messages `chat.db` freshness
  precheck before retained migration. Historical archive workflows import the
  selected archive source explicitly before migration, and app-facing live
  updates use the graph monitor/build lifecycle instead.
- The retired import-control migration path no longer has a close-only legacy
  database lifecycle hook. Source-scoped graph lifecycle and reset own active
  connection cleanup; retained `working.db` is deleted as a file when reset
  requires it rather than opened through a retained provider.
- The source-scoped conversation graph status provider no longer owns its
  diagnostic SQL. It now delegates source/import/working count collection to
  `ConversationGraphStatusRepository`, keeping the application provider as a
  thin coordinator and the status panel as presentation only.
- Conversation graph status log writing now follows the same boundary:
  application owns the typed log-writer contract and markdown formatting,
  infrastructure owns `_LOGS` path discovery and file writes, and the status
  sheet consumes `conversationGraphStatusLogWriterProvider` instead of
  constructing a filesystem writer directly. An architecture tripwire protects
  this diagnostic boundary.
- Attachment archive settings no longer compute archive record count through
  application-owned SQL. `AttachmentArchiveStatsRepository` owns the
  filesystem-size plus overlay archive-record count read, leaving
  `ArchiveSettings` focused on preference state and user actions.
- Retired remaining commented boilerplate `use_cases_example.dart` stubs under
  attachments, reactions, contacts essentials, and db essentials after
  reference scans confirmed they were not runtime inputs or fixtures.

### Exit Criteria

Done means:

- existing archive records remain resolvable.
- historical MessageLens archive source strategy is defined.
- recovered Messages folder source strategy is defined.
- deterministic recovery no longer requires ordinary `working.db` identity in
  the long-term plan.
- recovered-message repository ownership is named before recovered storage is
  migrated.

## Slice 8 - Legacy Retirement And Retained Storage Reduction

### Goal

Remove retired legacy execution/read systems only after their blockers close,
and reduce retained compatibility storage only under explicit retention
criteria.

### Current Checkpoint Evidence

2026-06-03:

- Live `chat.db` polling no longer runs the retained legacy import/migration
  tail after a successful graph build. The live monitor now performs only:
  source change detection, source-scoped graph build, graph attachment archive
  by source-row range, graph freshness cursor advancement, and shared message
  evidence invalidation.
- Removed `LegacyCompatibilityMaintenanceService`, its provider, generated
  provider output, and focused service tests. Manual import/onboarding legacy
  paths remain intact until those lifecycle entry points are retired
  deliberately.
- Updated `71-LEGACY-DEPENDENCY-MATRIX.md` so the live monitor is classified as
  graph production lifecycle and the deleted compatibility service is recorded
  as a closed deletion candidate.
- Retired the standalone legacy migration panel and removed the
  `ImportSpec.forMigration` route. The import control surface no longer offers
  a user-facing migration tab; any retained legacy migration entry points are
  compatibility/archive/diagnostic references, not onboarding/settings product
  setup.
- First-run onboarding and settings-triggered reimport now call the central
  conversation graph build controller directly after derived-data reset. They
  no longer call `DbImportControlViewModel.startImport()` or
  `DbImportControlViewModel.startMigration()`.
- The onboarding overlay progress copy now reflects graph build/rebuild status
  from `ConversationGraphBuildController` rather than legacy import/migration
  progress.
- The onboarding overlay no longer watches `DbImportControlViewModel` for
  progress or completion rendering. Successful setup/reimport summaries now
  render the source-scoped graph build report directly.
- `onboardingEnvironmentReportProvider` no longer watches
  `DbImportControlViewModel`. It derives readiness from source probes,
  source-scoped import/graph readiness, dev overrides, persisted overlay
  failure state, and the centralized maintenance lock.
- The onboarding dev panel now uses `MessageDataResetService` and
  `ConversationGraphBuildController` directly for reset/progress display. The
  obsolete `OnboardingProgressView` legacy-stage widget was removed.
- Onboarding gate tests no longer override or fake
  `DbImportControlViewModel`; graph rebuild behavior is tested through the
  graph build service boundary directly.
- `PanelCoordinator` no longer contains an import-panel route. `ImportSpec`,
  `ViewSpec.import`, `DbImportControlPanel`, and
  `DbImportControlViewModel` are retired; reset/clear maintenance remains
  owned by `MessageDataResetService` and its active onboarding/sidebar callers.
- The retained import-control UI is now import-only: `DbImportMode`,
  `selectedMode`, and unreachable migration progress/summary rendering were
  removed. Historical archive compatibility calls use
  `RetainedLegacyArchivePipeline.rebuildLegacyProjectionAndGraph(...)`, not a
  presentation-owned import-control migration method.
- `OnboardingEnvironmentReport` now owns a semantic
  `OnboardingPipelineFailure` model. Onboarding no longer imports or exposes
  legacy `DbImportResult` / `DbMigrationResult` entities; overlay persistence
  remains backwards-compatible with legacy diagnostic writers and maps those
  rows into onboarding failure summaries at the read boundary.
- At this checkpoint, contact/handle/message overlay key compatibility was
  centralized in `retained_overlay_identity_bridge.dart` to stop duplicated
  graph-id/retained-id pack/unpack logic. That bridge was later retired:
  contact and handle compatibility moved to feature-owned identity helpers,
  message evidence canonicalization moved to the message evidence identity
  helper, and message overlay fallback moved inside the graph message overlay
  repository.
- The obsolete live import status precheck was removed from the retained
  `DbImportControlViewModel.startMigration()` path. Historical archive
  workflows already run archive import explicitly before retained migration, so
  `ImportStatusChecker`, `LiveImportStatusService`, and the unreachable
  `runImportAndMigration()` control-provider path were deleted.
- The retained archive-compatible projection rebuild API is now named
  `RetainedLegacyArchivePipeline.rebuildLegacyProjectionAndGraph(...)`, making
  explicit that it rebuilds legacy projection identity only as an archive /
  recovery compatibility step before refreshing the graph. The old
  presentation-owned `startMigration()` API was removed.
- `AttachmentArchiveService.archiveImportedBatch()` was deleted. Live updates
  archive graph/source-scoped live source ranges with
  `archiveGraphMessageSourceRange(...)`; retained full/manual migration still
  uses `archiveAllAvailable()`.
- Retained archive-compatible legacy import/projection execution moved behind
  `RetainedLegacyArchivePipeline`. The import-control panel now renders
  diagnostic progress around that application service, and historical archive
  settings workflows call the same service directly instead of reaching into
  `DbImportControlViewModel`.
- After that boundary extraction, `DbImportControlViewModel.startMigration()`
  and its unreachable projection-clear/database-diagnostic residue were
  removed. The retained import-control presentation surface is now import/reset
  diagnostics only; archive-compatible projection rebuilds are application
  service calls.
- The retained import-control progress UI no longer uses `db_migrate`
  table-progress types to render import progress. Its presentation model now
  speaks in import-domain progress phases/statuses only.
- Dead `db_migrate` scaffolding was deleted: fake `runMigration()`,
  unused Freezed migration report/failure wrappers, empty DTO/use-case/service
  files, the commented repository template, and the empty migrator-name value
  object. This was an intermediate cleanup step before the remaining
  projection execution stack was retired.
- Onboarding readiness terminology now says graph projection / graph build for
  app-facing setup failures and workflow states. `OnboardingEnvironmentReport`
  no longer exposes migration-failure fields for graph failures, onboarding
  persisted failure storage no longer imports `DbMigrationResult`, and the old
  overlay key remains only as a backward-compatible storage key.
- Remaining app-facing navigation/logging wording was cleaned so generic
  "import/migration" language no longer appears in sidebar parking comments,
  panel provider comments, pipeline audit comments, or retained archive
  projection failure strings. The retained `db_migrate` implementation names
  were later removed with the old projection execution stack.
- Message History Coverage already reads graph summary counts, but its report
  DTO and tests still used `workingDb*` field names. Those were renamed to
  graph-accounted terminology so the settings read model no longer presents
  the retired `working.db` projection as its conceptual source.
- Attachment archiving, recent contacts, onboarding, and cross-snapshot mapper
  comments were updated to describe graph-backed source-range archiving,
  graph-backed contact summaries, import/projection compatibility, and retained
  archive bridge behavior instead of generic migration / working-DB ownership.
- The retained import/projection audit writers were later removed with the old
  execution paths. Support bundles may still attach historical `import_log` and
  `migrate_log` files from older data folders, but no active writer produces
  those files.
- The handles spam/visibility placeholder no longer exposes graph-migration
  implementation wording to users; it now states the product capability is not
  available yet.
- Historical archive workflow code briefly named retained archive rebuild
  results as projection results internally. That wording was later superseded
  when Historical Archives import/removal moved to the source-scoped graph path.
- Pipeline incident headlines/fallback errors now say retained historical
  projection when old compatibility reports are displayed. The persisted
  migration stage enum remains unchanged for overlay compatibility.
- The shared execution gate and graph contacts list comments now describe
  source import, graph build, archive graph projection, and graph data-version
  invalidation directly instead of generic migration/import wording.
- Pipeline incident stage display now maps the persisted `migration` enum to
  "Retained historical projection" so diagnostic UI reflects the compatibility
  boundary without changing stored overlay values.
- Attachment archive settings and handles-info spec comments now use
  "derived-data rebuilds" / "dependency refactor" wording instead of migration
  terminology where no legacy projection lifecycle is involved.
- Message attachment presentation comments now refer to directly constructed
  presentation instances rather than "legacy instances"; the shared evidence
  widgets remain graph/evidence-spine based.
- A fresh scan of remaining `legacy` / `migration` / `working.db` references
  showed intentional compatibility bridges, persisted overlay keys, retained
  archive projection internals, and explicit graph-to-legacy identity bridges.
  Those should remain named as compatibility until the underlying storage
  bridge is retired.
- Live polling completion logs now say retained legacy `working.db` projection
  maintenance is no longer run from live polling, matching the source-scoped
  graph lifecycle boundary.
- Obsolete onboarding `.gitkeep` placeholders were removed from directories
  that now contain real graph-era onboarding application/domain/
  infrastructure/presentation code.
- The 2026-06-04 direct-provider dependency scan found no ordinary
  user-facing feature/read surface opening the retained working/import
  providers. Later slices removed the retained working provider entirely and
  narrowed retained import provider access to archive metadata, reset, and
  retained import schema compatibility.
- Conversation graph infrastructure now names `ConversationGraphDatabase`
  dependencies and status counts as graph database/data instead of
  proof-stage `workingDatabase` terminology. The status panel still shows the
  physical database filename where useful, but the read model no longer
  presents the graph as legacy `working.db`-shaped data.
- The conversation graph database upgrade test no longer opens two
  `ConversationGraphDatabase` instances on the same executor at once, removing
  a test-only Drift duplicate-database warning.
- `PipelineIncidentTracker` now exposes
  `recordRetainedProjectionResult(...)` for retained `db_migrate` callers
  instead of `recordMigrationResult(...)`. The stored
  `PipelineIncidentStage.migration` value remains unchanged for overlay
  compatibility, but application code named the retained projection boundary
  explicitly before that execution path was retired.
- Attachment archive rolling sweeps now use graph terminology in code-facing
  method/helper names (`archiveNextGraphSweepChunk`,
  `archiveGraphSweepBurst`) and diagnostics. The persisted overlay cursor keys
  remain unchanged as storage compatibility keys, but the service no longer
  describes graph attachment sweeps as working-database sweeps.
- Manual handle-link service tests no longer instantiate legacy
  `WorkingDatabase` fixtures. The tests now exercise overlay-only user intent
  directly with graph-era stable ids, matching the production boundary where
  manual links write only to `user_overlays.db` and graph/contact readers merge
  overlay intent at read time.
- Retired database health inspection is now covered by focused read-only
  query-layer tests. The tests verify that health diagnostics do not create a
  missing retained `working.db` / `macos_import.db`, and that existing retained
  files can be inspected without mutation. This keeps support diagnostics from
  becoming a back-door retained database provider.
- The unused `lib/essentials/contacts/domain/entities/` contact aggregate
  files were retired. They carried obsolete `pinnedRank` terminology and had no
  runtime imports.
- Removed the now-unused `ContactId` / `MessageId` Freezed value objects and
  the unreferenced JSON converters in `domain_driven_development`. Graph-era
  contact/message identity is source-scoped integer identity plus typed
  graph/evidence read models, not these old string value-object wrappers.
- Active contact favourite read models now use `favoritedAt` instead of
  `pinnedAt`, and provider comments describe graph contact facts rather than
  working-database metadata. Persisted overlay column names remain unchanged for
  storage compatibility.
- The unused `ManualHandleLink` domain entity was retired. Runtime manual-link
  behavior is owned by `ManualHandleLinkService` plus graph/overlay read models,
  and no active code imports the old entity.
- Empty, unreferenced repository-interface placeholders were retired from
  contacts essentials, database domain, attachments, handles, and reactions.
  Real repository contracts remain as named graph/search/archive/evidence
  boundaries rather than generic DDD template files.
- The unused reactions feature shell was retired after reference scans found no
  active imports for its feature-level provider, `Reaction`, `ReactionId`, or
  `ReactionKind`. Retained legacy reaction tables/migrators and graph message
  semantic fields remain because reaction evidence is preserved through the
  message/projection path, not through the deleted feature-domain model.
- Placeholder "coming soon" cross-surface shells were retired from attachments,
  chats, and handles after reference scans found only placeholder tests. Active
  attachment archive/recovery, graph conversation/chat presentation, and handle
  settings/read behavior remain in their real feature files.
- The superseded handle placeholder cassette branch was retired:
  `unmatchedHandlesList`, `strayPhoneNumbers`, and `strayEmails` spec variants
  plus their placeholder payloads, resolvers, widgets, generated providers, and
  tests. The active handle triage topology remains info card -> type switcher
  -> mode switcher -> `strayHandlesReview`.
- The unreachable handles settings cassette shell was retired. `HandlesSettingsSpec`,
  its coordinator, inert manual-link/spam payload resolvers, and placeholder
  settings widgets had no runtime caller after the unified triage flow became
  the active handle surface. The graph/overlay operation providers remain
  because they are semantic services rather than dead presentation shell code.
- The duplicate chats heatmap timeline model was retired. `RecentChatSummary`
  no longer carries an always-null heatmap field, and timeline/heatmap data is
  owned by the message evidence/sidebar heatmap path rather than a parallel
  chats-domain model.
- The unused generic attachment Freezed model was retired. `Attachment`,
  `AttachmentId`, and `AttachmentStatus` had no active imports outside their
  generated files and converter; graph attachment behavior remains owned by
  message evidence rows, archive records, `AttachmentInfo`, and
  `ResolvedAttachment`.
- The unused `TopChatMenuChoiceConverter` utility was retired. Active
  `SidebarUtilityCassetteSpec` serialization does not reference the converter,
  and top-menu behavior remains owned by the sidebar utility spec/constants.
- The duplicate unused `ComingSoonSettingsInfoResolver` was retired. The active
  settings informational cassette path remains `SettingsInfoResolver`; no
  settings topology or renderer referenced the duplicate resolver.
- The unused AddressBook folder presentation layer was retired. Old loading,
  data, error widgets and `FolderListViewModel` had no active imports and still
  referenced obsolete route assumptions. The AddressBook folder resolver,
  aggregate/domain entities, and repositories remain active because onboarding
  and source-scoped contact import still require runtime AddressBook path
  resolution.
- The unused duplicate `AddressBookFolderListDataSource` was retired. Active
  AddressBook candidate discovery and viability checks are owned by
  `AddressBookFolderRepository`, which remains wired through
  `feature_level_providers.dart`.
- Obsolete AddressBook candidate-selection providers were retired:
  `BadAddresses`, `ChosenAddressFolderPathRepository`, and
  `FolderAggregateRepository`. The old user-selectable candidate workflow is
  gone; production AddressBook resolution now flows through
  `AddressBookFolderPathsFinder` -> `AddressBookFolderRepository` ->
  `futureGetFolderAggregateProvider`. The persisted folder preference key is
  retained so existing saved choices remain readable.
- The obsolete `AddressBookFolderFailure.folderFavouriteNotStored` Freezed
  wrapper was retired after reference scans found no active imports. The active
  AddressBook readiness path continues to use `FolderRetrievalFailure`.
- The generic `more_failures/Failure` Freezed union was replaced with a small
  named `FolderRetrievalFailure` class. The dead template variants
  (`empty`, `unprocessableEntity`, `unauthorized`, `badRequest`) had no active
  imports, and AddressBook readiness still exposes the same failure message.
- Stale feature docs for messages, search, chat handles, and chats were updated
  to describe graph-era `ss_id` identity, the Message Evidence Spine,
  conversation graph topology, and overlay-owned user intent. The old
  `working.db` ordinal/index/provider language is now retained only in
  explicitly superseded historical docs.
- The message display walkthrough, message pipeline, interactions, and testing
  docs were refreshed to describe the active Message Evidence Spine instead of
  the retired `MessagesTimelineView` / `MessageTimelineScope` path.
- Import/onboarding lifecycle docs now distinguish production source-scoped
  graph build from retained legacy `macos_import.db` -> `working.db`
  projection. Auto-sync documentation points to `ChatDbChangeMonitor` ->
  source-scoped graph build -> graph data-version invalidation, while retained
  import/migration docs are labeled archive/recovery compatibility.
- Retained import/migration schema, importer, migrator, and Rust extractor docs
  now label `macos_import.db` / `working.db` as compatibility references and
  point new ordinary work toward `macos_import_ss.db`, `working_ss.db`, graph
  projectors, and source-scoped rich-text enrichment.
- Database access docs now list `db-import-ss` / `db-graph-working` as the
  production graph database pair and classify legacy `db-import` /
  `db-working` as retained archive/recovery compatibility. The contact/handle
  identity model now describes graph/display identity plus overlay intent
  instead of legacy participants as the active UI authority.
- Overlay independence, `chat.db`, contact-to-conversation linking, and
  inviolate database rules now describe source-scoped graph projection as the
  production path while preserving retained projection wording only for old
  compatibility references. The hard rules now prohibit overlay writes into
  either graph projection or retained working projection.
- Onboarding/archive docs now describe archive metadata as overlay-owned,
  source-scoped graph projection as the ordinary app path, and retained
  legacy import/working projection as archive/recovery compatibility. Generic
  "working database" language was replaced where it blurred that boundary.
- Deterministic recovery docs now match the graph-era mapper: historical
  snapshots map through source-scoped import attachment `ss_id` and graph
  `message_to_attachment` topology, while overlay archive rows retain the
  compatibility-shaped `(message_guid, import_attachment_id)` key so existing
  archived files remain usable.
- Environment-safety snapshot/recovery docs now list the source-scoped graph
  DBs, retained compatibility DBs, overlay DB, and SQLite sidecars explicitly,
  and routine snapshots exclude the app-owned `attachment_archive` folder
  rather than a stale `Attachments` directory name.
- The April `archive-canonical-attachments` feature proposal/checklist/design
  docs are now marked as historical planning records. They point future work to
  the current archive-first onboarding/archive docs, graph attachment evidence
  hydration, and shared resolver/service boundaries instead of serving as a
  competing source of truth.
- The older `app-breakdown-refactor` control docs are now explicitly marked as
  historical refactor records. Their anti-drift principles remain valid, but
  their concrete `MessageTimelineScope` / `MessagesTimelineView` /
  `working.db` timeline vocabulary is superseded by the graph-backed Message
  Evidence Spine.
- The `message-history-coverage-check` planning docs now state that their
  original `working.db` accounting language is historical. The active Message
  History Coverage feature keeps the user-facing name but compares source
  `chat.db` counts against graph-accounted MessageLens evidence.
- Build-considerations docs now mark the March 2026 onboarding/import debug
  handoff as a superseded historical record. Current setup/live-update guidance
  points to onboarding/archive, source-scoped import/graph build, and this
  execution checklist instead of the retired legacy import-panel brief.
- Project overview, aggregate-boundary, data-location, essentials, macOS
  source-database, and snapshot-protocol docs now identify the graph-era
  ordinary data path (`macos_import_ss.db` -> `working_ss.db`) and classify
  retained `macos_import.db` / `working.db` references as archive/recovery
  compatibility. Source orphan-message docs now refer to graph-orphan/recovered
  evidence rather than dedicated legacy working-table projection as current
  architecture.
- Spec-system data pipeline invariants now describe the source-scoped graph
  pipeline, overlay authority, retained compatibility leakage, and Message
  Evidence Spine rules. The coordinated message-display reference now uses
  `MessageEvidenceScope`, full skeletons, viewport hydration, and shared
  evidence rendering instead of retired `MessageTimelineScope` /
  `MessagesTimelineView` guidance.
- The `40-FEATURES/rationalized-message-views` folder is now explicitly marked
  as superseded historical material. Its old `MessageTimelineScope`,
  ordinal-strategy, and `MessagesTimelineView` guidance points readers to the
  current graph-backed Message Evidence Spine docs before any new work.
- Root agent quick-reference files (`AGENTS.md` and
  `.github/copilot-instructions.md`) now direct ordinary database access to the
  source-scoped import / conversation graph / overlay providers, classify
  the then-current `retainedArchiveMetadataStoreProvider` as retained archive
  metadata compatibility, and state that retained `working.db` has no central
  app provider. Later slices retired that provider and demoted the old files to
  cleanup/diagnostic storage.
- Active instruction index links now point to current `01-PROJECT` and
  `42-SPEC-SYSTEM` paths instead of removed `00-PROJECT`, `00-GLOBAL`,
  `50/52/54/56-*` spec-system folders, or `30-NEW-FEATURE-ADDITION`.
- Active layout, database, feature, and build handoff docs now reference
  current `42-SPEC-SYSTEM`, `45-NEW-FEATURE-ADDITION`, and `01-PROJECT`
  paths instead of removed spec/project folder names.
- The active new-feature workflow README now names `45-NEW-FEATURE-ADDITION`
  as the staging location rather than its retired `30-*` predecessor.
- The active new-feature workflow README now links to the shared instruction
  submodule with the correct relative path and references the existing feature
  brief template instead of removed proposal/checklist/test template files.
- Active markdown link audit now passes for current per-project docs after
  repairing the main use-case index link and macOS FDA continuity source-file
  links.
- Retained import-orchestrator guidance now describes the importer as an
  archive/recovery compatibility path rather than the production replacement
  path. The former `ImportSpec` diagnostic route tag has been retired.
- Retained migration-orchestrator/table-migrator guidance now directs new
  ordinary projection work to source-scoped graph import/projector/read-model
  paths and reserves `db_migrate` additions for archive/recovery compatibility.
- Retained `working.db` database docs no longer describe it as powering
  ordinary UI providers or the user-facing projection; those docs now classify
  it as archive/recovery compatibility and diagnostics only.
- Database Health Audit docs now match the implemented five-layer audit scope:
  source-scoped import, conversation graph, overlay, retired import cleanup
  diagnostics, and retired working cleanup diagnostics.
- Active messages feature docs now describe overlay reads through graph
  evidence/overlay repositories rather than vague graph/legacy bridges, and
  the Message Evidence Spine invariant path was corrected.
- Active search and handle docs now describe graph-backed search/handle identity
  plus overlay-owned manual links instead of retained `working.db` FTS,
  working-DB participants, index rebuilds, or graph re-projection after user
  link actions.
- Active search charter/provider docs now identify `SearchService` and
  `GraphSearchRepository` as the current graph-backed search spine, replacing
  old planned FTS/index provider names with graph repository contract guidance.
- Historical recovered/unlinked-message docs now preserve their data-fidelity
  and quarantine-labeling intent while pointing current implementation work to
  source-scoped graph recovered-message identity and parity/cutover plans.
- Historical message-variant preservation docs now state that semantic parity
  does not mean field parity, and that future semantic work belongs in
  source-scoped import facts, lightweight graph/query semantics, and the
  Message Evidence Spine rather than a resurrected legacy schema mirror.
- Historical global/all-messages timeline docs now preserve the full-skeleton
  plus viewport-hydration invariant while marking `working.db` ordinal/index
  mechanics as superseded by graph-backed `MessageEvidenceScope` routing.
- Historical manual handle-to-contact linking docs now preserve the
  overlay-owned user-intent principle while marking working-DB menu merge and
  retained reindex instructions as superseded by graph read models plus
  overlay identity bridges.
- Historical Messages Merge REDUX docs are now marked as historical archive
  research. Their durable lesson remains "historical archives are additional
  sources, not private presentation paths," while their concrete `db-import` ->
  migration -> `working.db` visibility pipeline is superseded by source-scoped
  import, conversation graph projection, and the Message Evidence Spine.
- Historical enhanced-search and modular-FTS docs are now labeled as
  search-backend research. Their modular indexer lessons remain useful, but
  graph-native `SearchService` / `GraphSearchRepository` and `message_ss_id`
  evidence scopes are the current search authority.
- Living attachment archive and deterministic recovery planning docs now
  preserve archive-first, overlay-owned, no-heuristics principles while
  pointing current integration to source-scoped attachment identity, graph
  `message_to_attachment` topology, and shared message evidence hydration.
- Historical onboarding/readiness/import-rationalization docs now preserve
  their useful setup-evidence and DDD-boundary principles while labeling the
  retained `db_importers` / `db_migrate` / `working.db` setup path as legacy
  context. Current onboarding guidance points to source-scoped import,
  conversation graph build/readiness, overlay persisted failures, and retained
  compatibility diagnostics only where explicitly named.
- Historical contact menu, picker, virtual-contact, and cassette-cleanup docs
  now preserve scalable contact selection and cross-surface separation intent
  while marking participant-ID, `short_name`/nickname, and `working.db`
  contact-favourite mechanics as superseded. Current guidance points to graph
  contact/handle facts, overlay-only user intent, and canonical display
  identity resolver precedence.
- A 2026-06-06 retention-oriented dependency scan found no new ordinary
  app-facing retained `working.db` / `macos_import.db` reads. Remaining direct
  legacy provider/database use is classified as retained archive-compatible
  import/projection execution, historical archive settings workflow,
  onboarding reset/derived-data maintenance, database health/support
  diagnostics, retained `db_migrate` internals/tests, legacy schema tests, or
  graph-era source-scoped import/projector access to the source-scoped
  `ImportDatabase` provider. The retained legacy database schemas are now
  storage-retirement questions, not ordinary UI migration blockers.
- Added `81-LEGACY-STORAGE-RETENTION-REGISTER.md` to make the remaining
  storage-retention buckets explicit before further deletion: retained
  archive-compatible import/projection, historical archive settings metadata,
  reset/derived-data maintenance, database health/support diagnostics, and
  retained schema/migrator tests.
- Added `82-SOURCE-SCOPED-ARCHIVE-IMPORT-CUTOVER-PLAN.md` after reviewing the
  retained storage register and archive/recovery identity plan. The plan
  identifies the next high-leverage blocker as source-scoped historical archive
  import, with the first implementation task limited to deterministic archive
  source registration before row import or Historical Archives UI cutover.
- Implemented the first source-scoped archive identity slice: historical
  Messages archive source constants, `ImportDatabase.getOrCreateSource(...)`,
  and `HistoricalMessagesArchiveSourceRegistrar`. The registrar validates a
  selected archive folder contains `chat.db`, derives a deterministic
  `historical-messages-archive:<chat.db path>` source key, registers/reuses the
  source in `macos_import_ss.db.source_registry`, and returns the assigned
  `source_id` without importing archive rows or changing the Historical
  Archives UI workflow.
- Added `SourceScopedArchiveImportService` as the first graph-native archive
  import application boundary. It registers/reuses the selected archive source,
  runs the existing source-scoped importers for messages, chats, handles,
  attachments, chat/message edges, chat/handle edges, and message/attachment
  edges with that archive `source_id`, and returns a typed per-table report.
  This imports archive source facts into `macos_import_ss.db` only; graph
  projection, Historical Archives UI cutover, and retained legacy archive path
  retirement remain pending.
- `SourceScopedArchiveImportService` now runs source-scoped rich-text
  enrichment for the selected archive source after import. Enrichment decodes
  imported `attributed_body_blob` values from `macos_import_ss.db.messages`
  through the existing extractor boundary, does not reopen archive `chat.db`
  for text extraction, and does not touch other sources.
- Added `SourceScopedArchiveGraphImportService` under `conversation_graph` as
  the graph projection wrapper around the source-scoped archive import service.
  `source_scoped_import` remains responsible only for archive source facts and
  enrichment; the graph-owned wrapper runs the safe full idempotent projectors
  after archive import/enrichment instead of using live-source incremental
  projection shortcuts. Focused graph tests verify an archive message, chat,
  handle, attachment, and topology edges project into `working_ss.db` with
  source-scoped `ss_id` endpoints and remain idempotent on rerun. Historical
  Archives UI cutover and retained legacy archive removal retirement remained
  pending at this point.
- Added Riverpod provider wiring for the source-scoped archive import service
  and the graph-owned archive import/projection service. The provider boundary
  preserves the same architecture: archive source facts/enrichment are
  constructed from `source_scoped_import`, while graph projection composition
  is constructed from `conversation_graph` projectors. Historical Archives UI
  cutover remains pending.
- Historical Archives forward import now calls the graph-owned
  `SourceScopedArchiveGraphImportService` instead of the retained legacy
  archive pipeline. The workflow claims the shared maintenance/execution gate,
  imports the selected archive as a source-scoped source, projects it into the
  conversation graph, bumps the shared message-data version, and persists the
  existing archive-source metadata record for settings visibility.
- Historical Archives removal now calls a graph-owned
  `SourceScopedArchiveGraphRemovalService` instead of deleting retained legacy
  import batches and running retained projection. Removal deletes the
  selected archive source's source facts, topology edges, and import batches
  from `macos_import_ss.db`, preserves `source_registry`, clears/reprojects
  `working_ss.db` from the remaining source-scoped import facts, invalidates
  graph readiness/populated providers, and bumps the shared message-data
  version. Focused tests cover source-scoped ledger deletion, graph removal,
  source registry preservation, re-import with stable source identity, and
  updated Historical Archives UI/view-model wording.
- Retired the retained legacy archive pipeline provider, old
  import-progress/detail widgets, import-control panel, import-control
  view-model, `ImportSpec`, and `ViewSpec.import` route after Historical
  Archives import/removal moved to source-scoped graph services. Derived-data
  reset and import-ledger clearing remain available through active
  `MessageDataResetService` callers rather than a standalone import panel.
- Historical Archives UI/view-model language now reflects source-scoped graph
  archive import/projection rather than retained projection. The
  remaining archive metadata line is explicitly labeled compatibility metadata,
  not an execution path.
- Removed retained projection failure recording from the app-wide
  `PipelineIncidentTracker`. The persisted `PipelineIncidentStage.migration`
  value remains for old report compatibility, while active graph/onboarding
  incident reporting no longer imports retained `DbMigrationResult` types.
- Retired the old `OrchestratedLedgerImportService` and its provider after
  confirming there were no active callers. The `db_importers` feature-level
  provider now exposes only the Rust message extractor used by source-scoped
  rich-text enrichment. With the old service gone, `PipelineIncidentTracker`
  also no longer imports retained `DbImportResult` types or exposes a
  retained import-result recording method.
- Retired the dependent old table-importer execution stack after confirming
  that the old ledger orchestrator was its only runtime owner. This removed the
  old `application/importers/**`, duplicate `infrastructure/sqlite/importers/**`,
  `ImportOrchestrator`, `IImportContext`, row-progress framework, incremental
  ledger integrity check, and corresponding tests. The active `db_importers`
  folder now contains the graph live monitor, import execution gate/debug
  support, and Rust extractor boundary only.
- Replaced onboarding failure persistence writes that depended on the retired
  `DbImportResult` entity with an onboarding-owned `saveImportFailure(...)`
  method. The old overlay key and JSON fields remain readable, but no retained
  import-result class remains in production code.
- Retired the old `db_migrate` projection execution stack after confirming it
  had no production callers. This removed the retained projection
  orchestrator, migrators, migration context/progress framework,
  `DbMigrationResult`, and matching tests. Retained `working.db` storage/schema
  remains available for diagnostics/reset/storage-retirement review, but no
  retained projection execution service remains.
- Trimmed the retained `RetainedArchiveMetadataDatabase` public helper surface by
  deleting uncalled legacy ledger-reset, row-existence, and spam-flag helpers.
  The retained `macos_import.db` wrapper remains available for historical
  archive metadata, health diagnostics, reset/storage checks, and retained
  schema tests, not as an ordinary import execution API.
- Retired the old `WorkingDatabase` ordinal-index rebuild and trigger
  maintenance API (`global_message_index`, `message_index`, and
  `contact_message_index`) after caller scans confirmed it was test-only. The
  physical `working.db` tables remain retained schema/diagnostic inventory
  until the broader legacy DB storage-retirement decision.
- Demoted those retained ordinal-index tables in database health from integrity
  checks to inventory-only diagnostics. Health no longer reports missing
  `global_message_index` coverage or index-to-message relationships as graph
  corruption, because graph evidence skeletons now own timeline navigation.
- Removed the stale import-debug `ledgerRowCachingEnabled` toggle after scans
  confirmed the retained table-importer cache path was gone. The remaining
  import-debug settings only control diagnostic logging used by the retained
  import DB wrapper.
- Trimmed the remaining import-debug provider down to retained import database
  logging only and relabeled central retained `macos_import.db` / `working.db`
  provider comments so they no longer imply ordinary app-facing ownership.
- Removed the retained `macos_import.db` batch-ledger deletion API and its test
  after Historical Archives removal moved to source-scoped archive graph
  deletion. The retained import DB wrapper still exposes archive-source
  metadata needed by the settings workflow.
- Removed the generic retained `RetainedArchiveMetadataDatabase.rawQuery` wrapper after
  caller scans confirmed health diagnostics and tests use their own
  infrastructure query boundaries. This keeps retained `macos_import.db`
  access limited to named metadata operations.
- Removed the unused retained `RetainedArchiveMetadataDatabase.countRows` helper. Retained
  import row counts now live only behind the database-health query layer instead
  of on the retained import DB wrapper itself.
- Removed the retained archive batch-count compatibility read from Historical
  Archives preflight and source-management copy. Archive removal now reports the
  source-scoped removal target directly instead of inspecting old
  `macos_import.db.import_batches` rows.
- Removed retained archive-source batch ID / import-start timestamp fields from
  the public metadata wrapper. The old SQLite columns remain only as physical
  schema compatibility for existing retained `macos_import.db` files.
- Fresh retained `macos_import.db` creation and the historical v5 archive-source
  metadata upgrade now use the narrowed archive metadata schema and no longer
  recreate retained import batch-count / batch-ID / import-start columns.
- Database health now treats retained `macos_import.db` as archive-source
  metadata storage only. Old retained import ledger table and relationship
  checks moved out of the expected health surface; source-scoped import owns
  active message/chat/handle/attachment health checks.
- Fresh retained `macos_import.db` creation now creates only
  `schema_migrations` and `historical_archive_sources`. Older retained import
  files remain upgrade-compatible, but new files do not recreate
  `import_batches`, `messages`, `handles`, `chats`, attachments, or old
  topology ledger tables.
- Database health now treats retained `working.db` as recovered-message
  compatibility storage plus minimal projection-state storage sanity. Ordinary
  message/chat/contact/handle/attachment/reaction health and timeline
  navigation checks belong to `working_ss.db` and graph evidence skeletons.
- Database health now inspects retained `macos_import.db` and `working.db`
  through read-only file query layers instead of central retained DB providers.
  Health/support diagnostics therefore report missing retained files without
  recreating retained storage as a side effect.
- The obsolete provider-backed retained import/working health query adapters
  were removed after caller scans confirmed diagnostics use only the read-only
  retained file query layer for `macos_import.db` and `working.db`.
- The central retained `driftWorkingDatabaseProvider` was removed after scans
  confirmed no production caller still opens retained `working.db`. Reset keeps
  deleting the retained `working.db` files directly, but no longer instantiates
  a Drift connection solely to close them.
- The retained `WorkingDatabase` Drift schema implementation, generated file,
  service-constraint constants, and schema parser test were removed after scans
  confirmed `working.db` is now only retained file storage. Existing retained
  `working.db` files may still be deleted by reset or inspected read-only by
  diagnostics, but no app code instantiates the old schema.
- Historical Archives workflow presentation no longer imports
  `RetainedArchiveMetadataDatabase` or reads `retainedArchiveMetadataStoreProvider` directly.
  Retained `macos_import.db.historical_archive_sources` read/write access is
  quarantined behind `HistoricalArchiveSourcesRepository`, keeping archive
  metadata compatibility in infrastructure while source-scoped archive
  import/removal remains the active execution path.
- Historical Archives archive-source preflight no longer performs raw
  `chat.db` SQLite inspection inside the presentation workflow model. Source
  folder/file checks, archive `chat.db` counts, Apple date conversion, and
  duplicate-GUID dry-run comparison now live behind
  `ArchiveSourceInspectionRepository`; the workflow model composes typed
  inspection results into UI state.
- Active database/import documentation now matches the retired-code reality:
  retained `macos_import.db` is documented as fresh archive-source metadata
  storage only, retained `working.db` is documented as file/schema inventory
  with no central provider, and the old import/migration orchestrator,
  importer, and migrator guides are explicitly historical rather than active
  implementation instructions.
- Top-level agent/essentials indexes now mark `db_migrate/` as retired
  historical projection reference material rather than an active retained
  service folder. The remaining pipeline incident display label now says
  "Historical retained projection" so old incident records do not imply an
  active legacy projection path.
- Canonical architecture and database index docs now describe retained
  `macos_import.db` as archive-source metadata storage and retained
  `working.db` as historical file/schema inventory. They no longer describe
  `db-import` -> `db-working` as an active retained pipeline or `working.db`
  as a Drift-backed ordinary projection.
- Core data-integrity and overlay-separation invariants now distinguish active
  source-scoped import/projection from retained archive metadata and retained
  historical file inventory. The rules preserve overlay independence and
  record fidelity without implying retained `working.db` is an active app
  projection target.
- Message data reset now avoids instantiating the retained `macos_import.db`
  provider solely to close/delete retained files. It closes the retained import
  database only if the provider already exists, preserving reset coverage while
  avoiding accidental retained storage recreation during cleanup.
- Live chat-db monitor completion logs now describe live polling as updating
  only the source-scoped conversation graph, avoiding active runtime language
  that suggests retained `working.db` projection maintenance remains part of
  the polling path.
- Onboarding gate source comments now describe retired legacy database files
  as transitional cleanup storage only, while `startImportAndGraphBuild`
  remains the app-facing setup path.
- Database health audit role labels and notes now call retained
  `macos_import.db` and retained `working.db` transitional cleanup storage.
  The database keys remain stable for report consumers, but exported role text
  no longer describes retained projection as an active app-facing compatibility
  path or permanent reference tier.
- Active source/test comments now avoid loose "legacy" wording where the
  implementation is merely using retained files or old overlay/archive key
  compatibility. Remaining legacy-named variables/tests are intentional bridge
  terminology for old rowid/GUID/contact-id storage forms.
- The retained pipeline incident stage display label now reads "Retained
  historical projection" so old persisted reports remain readable without
  implying there is an active retained projection lifecycle.
- The source-scoped archive cutover plan and retained storage register now
  reflect the implemented state: Historical Archives import/removal is
  graph-backed, retained archive import/projection execution has been removed,
  and the remaining blocker is cleanup-storage retirement for retained
  `macos_import.db` / `working.db` file roles.
- Migration planning docs 71, 72, 78, 80, 81, and 82 were tightened so retained
  `macos_import.db` / `working.db` references mean storage, metadata,
  diagnostics, reset cleanup, or compatibility-key lookup. They no longer
  describe retained archive projection as a current fallback execution path.
- Historical Archives metadata now reads through the typed
  `RetainedArchiveMetadataStore` contract. The central DB provider remains the
  sole owner that constructs the retained `macos_import.db` archive metadata
  adapter; settings/archive callers use the semantic store boundary rather than
  importing the concrete database wrapper.
- Retired database filenames are now centralized in the DB dependency entry
  point as `retiredMacosImportDatabaseFileName` and
  `retiredWorkingDatabaseFileName`. Reset and database-health
  code no longer hard-code `macos_import.db` / `working.db` outside that
  retired cleanup boundary.
- Retired filename tests now assert against the central constants instead of
  repeating raw database names. Active archive-source metadata now lives in
  overlay, while old database files remain transitional cleanup targets.
- A production/test scan for raw `macos_import.db` / `working.db` strings now
  resolves only to the central retained filename constants.
- Historical archive source metadata repository constructor and field names now
  use `metadataDb` / `_metadataDb`, avoiding generic import-ledger terminology
  inside the settings metadata boundary.
- Message data reset support logs now name retained metadata, source-scoped
  import, and source-scoped graph databases explicitly instead of referring to
  generic import/projection databases.
- Retained metadata database tests and health-audit test names now refer to the
  retained archive metadata role rather than calling the wrapper an active
  import database. Local retained-metadata variables now use `metadataDb`.
- Active database access docs now name overlay storage as the archive-source
  metadata owner. Retired database filenames remain centralized for
  reset/storage cleanup and diagnostics only.
- Onboarding environment reporting now calls the app setup ledger
  `sourceScopedImportDatabase`, and gate/reset diagnostic log keys use
  `sourceScopedImportDb*`. This keeps onboarding readiness language separate
  from retained archive metadata storage.
- Full Disk Access probing and System Settings launching now live behind the
  `FullDiskAccess` boundary. Onboarding gate/report code consumes semantic
  FDA/path providers, Historical Archives receives the current Messages
  `chat.db` path as typed view-model data, and the old application-level
  `FdaChecker` was removed. An architecture tripwire prevents onboarding and
  settings code from reintroducing direct `dart:io`, `Process.run`, or
  `FdaChecker` access.
- Attachment cross-snapshot mapping comments now distinguish canonical graph
  `ss_id` endpoints from the temporary overlay-compatible
  `(message_guid, import_attachment_id)` archive key. Historical attachment
  recovery mapping is documented as source-scoped import ledger plus graph
  topology, not retained `macos_import.db` / `working.db` projection storage.
- The remaining import-debug settings comments now describe retained database
  diagnostics generically rather than implying an active retained import
  execution database.
- Active environment safety and database-health README docs now describe
  retained `macos_import.db` and retained `working.db` as historical cleanup
  inventory, not as an active retained import/projection pair or permanent
  reference tier.
- Onboarding/archive coordination docs now describe retained files as metadata,
  diagnostics, reset, and historical cleanup storage. Mentions of
  `DbImportControlViewModel` / `runImportAndMigration()` are now explicit
  "do not call retired paths" guardrails rather than live service ownership.
- The top-level data-location index now points retained archive-source metadata
  readers at the retained metadata store boundary and describes `import_log` /
  `migrate_log` as historical retained diagnostics rather than active graph
  lifecycle logs.
- AddressBook database docs now describe contact facts flowing into the
  source-scoped import ledger and graph contact/handle identity. They no longer
  tell application code to use retained `db-working.participants` as the
  projected contact authority.
- Contact/participant identity docs now treat old retained
  `working.participants` rows as historical-file interpretation only and no
  longer reference the removed retained Drift `WorkingParticipants` class.
- Project overview, architecture overview, and essentials index now use
  retained cleanup terminology. They point active archive metadata callers at
  overlay storage instead of suggesting any retained database provider as a
  normal feature entry point.
- Message, onboarding, and contact-name feature docs now distinguish retained
  archive-source cleanup / historical cleanup storage from active graph
  authority. The docs no longer describe retained `working.db` as ordinary
  archive/recovery compatibility for production message evidence.
- Chats and chat-handles feature docs now use the same retained-cleanup
  vocabulary: conversation and handle truth are graph-backed; retained
  `working.db` / canonical-handle rows are historical cleanup context only.
- Remaining current feature docs now avoid "retained legacy" as generic
  terminology. They distinguish retained historical cleanup material from
  active graph, overlay, and evidence-spine ownership.
- Onboarding/archive docs now use retained historical cleanup terminology
  for old `macos_import.db` / `working.db` attachment-recovery context while
  preserving the current rule that archive metadata is overlay-owned and graph
  recovery maps through source-scoped identity first.
- Source database and retained import/migration docs now distinguish source-
  scoped graph import/projection from retained historical import/projection
  mechanics. These docs still preserve old mechanics for interpreting old logs
  and data folders, but no longer describe them as active legacy authority.
- Canonical pipeline-invariant and database-health docs now classify old
  `macos_import.db` / `working.db` access as retained historical cleanup
  storage. Failure-mode docs still forbid ordinary app surfaces from reopening
  those files as authority.
- Build-handoff guidance now uses the same retained historical terminology for
  old import/projection code and keeps it limited to explicit
  archive/recovery compatibility or diagnostics.
- Production retained-database access scan is now small and classified:
  reset/storage infrastructure owns low-level retained file closing, Historical
  Archives reads retained metadata through the semantic provider, and recovered
  message evidence uses graph rows rather than retained `working.db` rows.
- The storage-retention register now uses retained historical storage language
  in its active register sections while preserving explicit compatibility
  boundaries for old data folders and archive metadata.
- A remaining navigation comment now refers to retired placeholder widgets
  rather than "legacy" placeholders, keeping active-code terminology focused on
  intentional compatibility bridges.
- Overlay identity audit now has a current implementation snapshot that
  classifies remaining active-code `legacy` symbols as intentional old-overlay
  key bridges. Those bridge names are preserved until old overlay rows are
  migrated or intentionally retained read-only.
- Architecture guard test wording now refers to tracked temporary exceptions
  rather than "legacy exceptions"; remaining test uses of `legacy` cover
  intentional overlay/id compatibility behavior.
- Added an architecture tripwire that keeps direct
  `retainedArchiveMetadataStoreProvider` access limited to reset/storage
  infrastructure and the Historical Archives repository boundary. Archive
  metadata readers should depend on `RetainedArchiveMetadataStore`, while the
  concrete `RetainedArchiveMetadataDatabase` adapter remains quarantined behind
  the central DB provider.
- Added a companion architecture tripwire that keeps retained `working.db`
  filename access limited to central DB constants, reset cleanup, and database
  health inspection. Ordinary code should not add retained working-file access.
- Added a retained database filename-literal tripwire so `macos_import.db` and
  `working.db` code literals stay centralized in `feature_level_providers.dart`.
  Other code must use the named retained filename constants.
- Added an architecture tripwire that forbids retired retained import/migration
  execution symbols and package paths from returning to `lib/`. Ordinary
  import/projection must remain source-scoped graph lifecycle work.
- Added a retained import-wrapper import tripwire so
  `RetainedArchiveMetadataDatabase` remains quarantined behind the central DB
  provider instead of spreading into ordinary feature code. Historical Archives
  uses the typed retained metadata store boundary.
- Centralized the overlay database filename as `overlayDatabaseFileName` on the
  overlay Drift database. The graph health and database health paths now use
  the shared constant instead of hard-coded `user_overlays.db` literals.
- Added an architecture tripwire that keeps the `user_overlays.db` filename
  literal centralized on the overlay database type.
- Added an architecture tripwire that keeps app database construction behind
  database classes and provider boundaries. Feature code should consume named
  providers rather than constructing import, graph, overlay, or retained
  database instances directly.
- Conversation graph readiness and maintenance-lock diagnostics now interpolate
  `conversationGraphDatabaseFileName` instead of hard-coding `working_ss.db`
  inside production code.
- Added an architecture tripwire that keeps source-scoped database filename
  literals centralized on `importDatabaseFileName` and
  `conversationGraphDatabaseFileName`.
- Added an architecture tripwire that keeps active-code `legacy` terminology
  quarantined inside explicit old-overlay/key compatibility bridges. New
  production code should use graph, retained metadata, retained reference, or
  source-scoped terminology instead of introducing new legacy-named concepts.
- Attachment archive compatibility read models now use
  `archiveCompatibilityAttachmentId` wording at the graph boundary. The
  persisted overlay column remains `import_attachment_id`, but active typed
  graph-facing code no longer describes this as retained import attachment
  identity.
- Focused architecture and attachment-archive bridge tests confirm the
  retained/source-scoped filename guards and archive compatibility read model
  remain intact after the terminology hardening pass.
- Moved the Rust attributed-body extractor port, implementation, and provider
  from `essentials/db_importers` into `essentials/source_scoped_import`. The
  extractor is now owned by source-scoped message enrichment and archive import
  rather than the retired import-execution folder.
- Moved the shared execution gate from `essentials/db_importers` into
  `essentials/conversation_graph/application/orchestration` as
  `GraphMaintenanceExecutionGate`. Live polling and Historical Archives now
  coordinate through a graph-maintenance lifecycle owner instead of an
  importer-owned gate. `db_importers` is now reduced to live source monitoring
  plus retained database debug settings.
- Moved retained database debug settings from `essentials/db_importers` into
  `essentials/db/application` as `RetainedDatabaseDebugSettings`. The retained
  metadata DB wrapper now depends on a database-layer diagnostic setting, not
  an importer-layer setting. `db_importers` now contains only the live
  `chat.db` monitor.
- Moved the live `chat.db` monitor from `essentials/db_importers` into
  `essentials/conversation_graph/application/monitor`. The public
  `chatDbChangeMonitorProvider` name is preserved, but ownership now matches
  its current responsibility: detecting live source changes and triggering
  conversation graph lifecycle work.
- Removed the retired `essentials/db_importers` source and test folders
  entirely. Added an architecture tripwire that fails if those folders return;
  source fact importers belong to `source_scoped_import`, graph lifecycle work
  belongs to `conversation_graph`, and retained DB diagnostics belong to
  `essentials/db`.
- Removed the empty retired `essentials/db_migrate` source and test directory
  shells after confirming no files remained. The retired-folder tripwire now
  protects both `db_importers` and `db_migrate` so old retained execution roots
  cannot quietly reappear.
- Removed empty proof-era `test/essentials/incremental_update_ss` and retained
  Drift `working` schema test/source directory shells. The retired-folder
  tripwire now also protects `incremental_update_ss` and the removed retained
  Drift working-schema path while leaving future graph-native search indexing
  paths available if they are deliberately introduced.
- Re-ran full `flutter analyze` after source-scoped import/graph ownership
  moves and fixed the remaining test import-order fallout. Focused
  architecture, source-scoped archive import, graph archive import, and
  rich-text enrichment tests pass.
- Fresh active source/test scans confirm the retired `db_importers`,
  `db_migrate`, `incremental_update_ss`, and retained Drift `working` schema
  paths are absent except for the intentional architecture tripwire strings.
- Retained `macos_import.db` and `working.db` are now documented as
  transitional compatibility storage, not permanent system-of-record storage
  and not deletion targets by default. Future slices should reduce retained
  purposes through the storage retention register, and full deletion requires
  archive/recovery independence, graph/source-scoped diagnostic equivalents,
  historical cleanup migration/export/rejection, and a user-safe
  backup/retention path.
- Added an architecture tripwire that keeps
  `retainedArchiveMetadataStoreProvider` limited to reset cleanup and the
  Historical Archives metadata repository. This turns the retained
  transitional-storage policy into a source-level guard: ordinary app behavior
  must not start reading or writing retained `macos_import.db` through the
  semantic metadata provider.
- Renamed the retained `macos_import.db` wrapper from the old
  `SqfliteImportDatabase` / `sqflite_import_database.dart` identity to
  `RetainedArchiveMetadataDatabase` /
  `retained_archive_metadata_database.dart`, and collapsed the old
  `sqfliteImportDatabaseProvider` alias into the single semantic
  `retainedArchiveMetadataStoreProvider`. The old class, provider, and file
  names are now guarded by the retired import/projection tripwire.
- Added `RetainedArchiveMetadataStore` as the narrow settings/archive metadata
  contract. Feature infrastructure no longer imports the concrete retained DB
  adapter; the architecture tripwire now allows that adapter import only in the
  central DB provider.
- Renamed the final active message overlay compatibility bridge terminology
  from legacy row ownership to retained-overlay identity. Rowid annotation
  fallback is now described as retained annotation fallback, GUID fallback
  remains explicitly GUID-keyed, and active `lib/` code is protected by an
  architecture tripwire that forbids new legacy-named concepts.
- Updated the deterministic historical attachment recovery planning notes so
  future implementation targets source-scoped import facts, graph
  message/attachment edges, and named retained overlay-compatible archive
  bridges. The folder no longer instructs future work to use the removed
  `sqfliteImportDatabaseProvider`, retained `working.db` attachment identity,
  or retained import/working DBs as the ordinary recovery mapping spine.
- Added a source database port for source-scoped import reads:
  `SourceDatabaseOpener` / `ReadOnlySourceDatabase`. Source-scoped application
  importers now depend on that port, while the sqflite `chat.db` /
  AddressBook adapter is quarantined in infrastructure. An architecture
  tripwire now prevents `package:sqflite` from returning to
  `source_scoped_import/application`. Import DB write transactions now expose a
  small infrastructure-owned `ImportDatabaseWriteTransaction` wrapper so
  application importers do not depend on sqflite `Transaction` or
  `ConflictAlgorithm` types.
- Added an `ImportLedger` domain port for source-scoped import application
  services. Importers, archive registration, and rich-text enrichment now type
  themselves against the semantic ledger port instead of the concrete
  `ImportDatabase` infrastructure wrapper. Provider files remain composition
  points for wiring concrete dependencies. An architecture tripwire now guards
  non-provider source-scoped import services from importing the concrete import
  database provider.
- Added `sourceScopedImportLedgerProvider` as the source-scoped import
  feature-level provider for the import ledger port. Source-scoped application
  provider files now watch that semantic provider instead of
  `importDatabaseProvider` directly, and the architecture tripwire now protects
  the entire `source_scoped_import/application` tree from importing the
  concrete import database provider.
- Renamed source-scoped application constructor fields, provider locals, and
  importer call sites from `importDatabase` to `importLedger` where the
  dependency is typed as `ImportLedger`. Concrete `ImportDatabase` names remain
  only in infrastructure adapters, projection repositories, and tests that need
  direct fixture assertions.
- Moved source-scoped contact importer provider access to the AddressBook
  folder preference key behind the `address_book_folders` public
  `feature_level_providers.dart` boundary. Added an architecture tripwire so
  source-scoped import application code cannot import feature infrastructure
  files directly.
- Added `sourceScopedImportDatabaseProvider` as the public source-scoped import
  feature boundary for graph projection/status provider composition that still
  needs concrete import-DB access. Conversation graph provider files now watch
  that feature-level provider instead of importing the import database
  infrastructure provider directly, with a tripwire to prevent regression.
- Onboarding existence checks, environment report path construction, and
  derived-data reset now use `sourceScopedImportDatabaseFileName` /
  `sourceScopedImportDatabaseProvider` from the source-scoped import
  feature-level boundary instead of importing the import database
  infrastructure provider directly.
- Archive graph removal now depends on the `ImportLedger` port for source-key
  lookup and source-fact deletion instead of importing concrete
  `ImportDatabase`. The conversation graph application tripwire now covers the
  whole application layer, not just provider files, so concrete source-scoped
  import database access stays out of graph application code.
- Historical Messages archive folder validation, `chat.db` path resolution,
  source-key path normalization, and default label derivation now live behind
  `HistoricalMessagesArchiveSourceFolderResolver`. Archive source registration
  and archive graph removal consume the typed resolver result instead of
  performing direct filesystem/path work, and an architecture tripwire prevents
  those application services from reintroducing `File`, `Directory`, or
  `path.join` logic.
- Moved `GraphCrossSnapshotMapper` out of attachments application code and into
  attachments infrastructure repositories, because it is a retained recovery
  query adapter over source-scoped import and graph databases. Deterministic
  recovery now obtains source-scoped import DB access through the public
  `sourceScopedImportDatabaseProvider` boundary.
- Database health audit service composition now obtains source-scoped import DB
  access and filename metadata through the public source-scoped import feature
  boundary. The concrete source-scoped import database type remains only in the
  database health query adapter for now, pending a later infrastructure split.
- Moved the database health audit query layer out of application and into
  `essentials/db/infrastructure/repositories/`. The application service still
  owns report composition; infrastructure now owns concrete SQL/DB query
  adapters for retained databases, source-scoped import, graph, and overlay DBs.
- Split the database health query contract from the concrete adapters:
  `DatabaseHealthQueryLayer`, table specs, and column specs now live in the
  application audit package, while sqlite/Drift-backed query adapters remain in
  infrastructure. Application tests fake the contract without importing
  infrastructure.
- Moved `databaseHealthAuditServiceProvider` composition into the central DB
  feature-level provider entry point. `DatabaseHealthAuditService` is now a
  pure application report composer; provider wiring owns source-scoped import,
  graph, overlay, and retained database adapter construction.
- Added a narrow `CurrentAttachmentSnapshotLookup` contract for historical
  attachment recovery. `GraphCrossSnapshotMapper` now depends on that lookup
  plus the graph DB instead of taking the full source-scoped import database;
  the concrete source-scoped attachment lookup remains in attachments
  infrastructure.
- Renamed the deterministic recovery precondition from import-DB population to
  current attachment snapshot availability, and added an architecture tripwire
  that prevents `GraphCrossSnapshotMapper` from re-importing the concrete
  source-scoped import database.
- Added attachment recovery application ports for cross-snapshot mapping and
  recovered-file archive writing. Deterministic recovery now orchestrates
  recovery phases against those capabilities; infrastructure owns the concrete
  graph/import lookup and overlay/filesystem archive writes.
- Added an architecture tripwire so deterministic recovery cannot drift back
  into direct infrastructure mapper/archive-writer imports.
- Added an attachment archive stats reader port. `ArchiveSettings` no longer
  constructs the concrete archive stats repository directly; feature-level
  provider composition owns the concrete overlay/archive-directory wiring.
- Added an attachment archive settings store port. `ArchiveSettings` still owns
  archive preference semantics and debug key parsing, but overlay settings and
  archive-record deletion are now behind attachments infrastructure.
- Added an attachment archive read-store port. `AttachmentResolver` no longer
  reads overlay archive rows or recovery-hint settings directly; infrastructure
  owns compatibility archive lookup and hint decoding.
- Added an `AttachmentFileAccess` boundary. `AttachmentResolver` still owns
  attachment availability semantics, but local file construction and
  existence checks now live behind attachments infrastructure. The architecture
  tripwire prevents `attachment_resolver_provider.dart` from reintroducing
  direct `dart:io`, `File(...)`, or `existsSync()` access.
- Moved graph search scope and repository contract into the search application
  layer. SQL-backed graph search remains infrastructure; search service and
  message evidence code now depend on the application search contract.
- Moved `displayIdentityResolverProvider` composition into the contacts
  feature-level provider boundary. The display-identity application package now
  contains semantic identity types/contracts only; concrete graph/overlay
  repository construction belongs to feature composition.
- Moved message user-intent overlay composition into the messages feature-level
  provider boundary. The message user-metadata application package now contains
  the graph-keyed controller and repository contract only; the retained
  graph/overlay compatibility bridge remains an infrastructure implementation.
- Moved recovered-unlinked message evidence provider composition into the
  messages feature-level boundary. Evidence spine and recovered heatmap UI now
  consume the public provider while concrete graph recovered-message reads stay
  in infrastructure behind the domain repository contract.
- Moved unfamiliar-source handle review actions behind the handles feature
  boundary. `HandleLensView` now calls a typed handle review action provider;
  overlay persistence for reviewed/unlinked handles is owned by handles
  infrastructure and guarded by an architecture tripwire.
- Moved contact hero display-name override writes behind a contact action
  boundary. The hero widget still collects the edited name, but user-intent
  persistence now flows through `ContactDisplayNameOverrideController` and an
  overlay-backed store instead of direct widget database access. Added
  provider-level coverage proving set/clear display-name override intents cross
  the action boundary and persist only as overlay user intent.
- Moved contact hero favourite toggles behind a contact action provider. The
  widget reports favourite intent; provider-level action code owns repository
  calls and invalidation of dependent contact picker/favourite projections.
- Moved `favoriteContactsRepositoryProvider` out of contacts sidebar resolver
  tools and into contacts infrastructure. Favourites projection providers still
  consume the repository provider, but concrete overlay-backed repository
  composition no longer lives in the application resolver folder.
- Moved manual handle-link persistence behind a contacts store boundary.
  `ManualHandleLinkService` now owns validation and cache invalidation only;
  overlay virtual-contact and handle-link table operations are performed by an
  infrastructure `ManualHandleLinkStore` implementation. `HandleLensView`
  consumes the contacts public feature boundary instead of importing contacts
  application internals directly.
- Moved Conversations sidebar signature preference persistence behind a
  messages store boundary. `ConversationSignaturePreferencesController` now
  owns filter/sort preference semantics only; overlay setting read/write
  mechanics live in messages infrastructure and are protected by an architecture
  tripwire.
- Moved Contact picker filter-mode persistence behind a contacts store boundary.
  `PickerFilter` now owns all/favourites preference semantics only; overlay
  settings storage lives in contacts infrastructure and is covered by a focused
  persistence test plus architecture tripwire.
- Moved global conversation Favourites/Core persistence behind a conversation
  graph store boundary. `ConversationFavouritesController` now owns graph
  favourite semantics only; overlay setting read/write mechanics live in graph
  infrastructure and are guarded by an architecture tripwire.
- Moved contact display-name override store composition into contacts
  infrastructure. `ContactDisplayNameOverrideActions` now owns only user-intent
  action semantics and dependent provider invalidation; overlay store
  construction is guarded by an architecture tripwire.
- Moved handle spam/visibility persistence behind a handles store boundary.
  `SpamManagement` now owns graph handle visibility semantics and provider
  invalidation only; overlay visibility table operations live in handles
  infrastructure and are guarded by an architecture tripwire.
- Moved developer-mode persistence behind a debug store boundary.
  `DeveloperMode` now owns release/default/debug semantics only; overlay
  setting read/write mechanics live in debug infrastructure and are guarded by
  an architecture tripwire.
- Moved handle manual-link mutations in the handles settings resolver through
  `ManualHandleLinkService`. The transitional read model still composes graph
  and overlay facts, but link/unlink/create actions no longer write overlay
  tables directly and are guarded by an architecture tripwire.
- Moved sidebar flow preference persistence behind a sidebar store boundary.
  `SidebarFlow` still owns deterministic state, validation, serialization, and
  projection semantics, but overlay setting read/write mechanics now live in
  sidebar infrastructure and are guarded by an architecture tripwire.
- Moved sidebar action storage mutations behind feature-owned action/store
  boundaries. `SidebarActionDispatcher` now routes contact access and
  unfamiliar-handle dismiss/restore intents without opening overlay storage or
  performing storage-backed mutations directly.
- Moved onboarding failure-storage construction behind an infrastructure
  provider. Onboarding gate/status application code now records and reads graph
  build/import failure state through an onboarding storage boundary rather than
  constructing overlay-backed storage directly.
- Moved pipeline incident storage construction behind logging infrastructure.
  `PipelineIncidentTracker` still owns incident semantics and lifecycle, but no
  longer reaches for overlay storage directly.
- Moved graph-health repository construction into conversation graph
  infrastructure. The graph-health application provider now reads through the
  repository boundary instead of wiring graph DB, overlay DB, archive directory,
  and external recovery-source paths itself.
- Moved chat-summary repository construction into conversation graph
  infrastructure. Chat summary application providers now read through the
  `ChatSummaryRepository` boundary instead of wiring graph DB, overlay DB, and
  archive lookup infrastructure directly.
- Moved manual-linking read composition behind an infrastructure repository.
  Manual-linking providers now expose unlinked-handle, available-participant,
  and handle-link-info read providers without performing graph/overlay SQL or
  overlay read composition directly.
- Moved conversation-reader repository construction into conversation graph
  infrastructure. Conversation reader application providers now depend on the
  `ConversationRepository` boundary instead of constructing the SQLite
  repository directly.
- Moved contact-graph repository construction into conversation graph
  infrastructure. Contact graph application providers now depend on the
  `ContactGraphRepository` boundary instead of constructing the SQLite
  repository directly.
- Moved message-graph repository construction into conversation graph
  infrastructure. Message graph reader providers now depend on the
  `MessageGraphRepository` boundary instead of constructing the SQLite
  repository directly.
- Moved message-projection repository construction into conversation graph
  infrastructure. Message projector providers now depend on the
  `MessageProjectionRepository` boundary instead of wiring import DB, graph DB,
  and the SQLite repository directly.
- Moved the remaining graph projector repository construction into
  conversation graph infrastructure. Chat, handle, contact, attachment, and
  topology projector providers now depend on projection repository boundaries
  instead of wiring import DB, graph DB, and concrete SQLite repositories
  directly.
- Moved graph status repository/path/database composition into conversation
  graph infrastructure. The public graph status application provider now
  exposes status semantics without opening source/import/working graph storage
  directly.
- Moved archive graph projection clearing behind a `GraphProjectionResetter`
  application port with a Drift-backed infrastructure implementation. Archive
  graph removal now requests projection reset semantically instead of importing
  or clearing the graph database directly.
- Moved handle spam-management read composition behind a handles
  infrastructure repository. `SpamManagement` still owns block/unblock action
  semantics, while graph handle reads and overlay visibility composition now
  live behind `SpamHandlesRepository`.
- Moved settings graph read composition behind infrastructure repositories.
  Message-history coverage and historical-archive preflight workflow code now
  ask named repositories for graph-aware summaries instead of opening the
  conversation graph database from application or presentation view-model code.
- Moved live monitor import-ledger cursor/count reads behind an
  `ImportLedgerProbeReader` boundary. `ChatDbChangeMonitor` still owns
  live-source polling and scheduling decisions, but no longer opens the
  source-scoped import database provider directly for startup/cursor probes.
- Moved live monitor source `chat.db` row/count probes behind a
  `ChatDbSourceProbeReader` boundary. `ChatDbChangeMonitor` owns polling
  decisions, while infrastructure owns the SQLite mechanics of reading
  `MAX(ROWID)` and importable source message counts.
- Narrowed graph refresh-token imports. Conversation graph readers, chat
  summaries, graph build controller, and message evidence/contact timeline
  providers now import the specific message-data-version/readiness provider
  files they need instead of the broad central database provider entry point.
- Moved current Messages attachment path refresh behind a feature-owned
  `CurrentMessagesAttachmentPathLookup` boundary. The attachment archive
  service still owns archive/recovery orchestration, but source `chat.db`
  attachment path lookup now lives in infrastructure behind a typed port.
- Narrowed historical archive workflow lifecycle imports. The workflow
  view-model now imports graph readiness, maintenance lock, and message data
  version provider files directly instead of depending on the broad database
  provider entry point.
- Moved onboarding environment filesystem/SQLite probes behind
  `OnboardingDatabaseProbeReader`. The environment report still owns setup
  classification semantics, while infrastructure owns file probing, table
  counts, and graph-readiness database inspection.
- Routed onboarding fallback database-existence checks through the same
  `OnboardingDatabaseProbeReader` boundary. The fallback gate now asks whether
  source-scoped import and graph storage are populated without owning file or
  graph-readiness probing directly.
- Split historical Messages snapshot reading into an application contract plus
  a `SqliteHistoricalSnapshotReader` infrastructure implementation. Recovery
  orchestration still owns phase semantics, while SQLite enumeration and
  deterministic historical attachment path resolution live behind the
  attachments feature boundary.
- Moved message attachment evidence path probing behind `AttachmentFileAccess`.
  Message evidence still maps graph/recovered attachment facts into
  display-ready evidence, but file existence checks and home-directory
  expansion now belong to the attachments feature boundary. A focused
  architecture tripwire prevents the message evidence model/composer from
  regaining direct filesystem access.
- Split message-history coverage export into application semantics and a
  settings infrastructure exporter. The application layer now owns the export
  result contract, filename, and JSON payload shape; filesystem writes and
  Finder reveal live behind `MessageHistoryCoverageReportExporter`, exposed
  through the settings feature boundary.
- Moved derived database file probing/deletion behind
  `DerivedMessageDataFileStore`. `MessageDataResetService` still owns reset
  orchestration, provider invalidation, maintenance locking, and dialogs, while
  infrastructure owns file existence checks and deletion of database
  base/WAL/SHM files.
- Moved attachment archive clear/export filesystem operations behind
  `AttachmentArchiveFileOperations`. `ArchiveSettings` still owns archive
  preference orchestration and overlay record clearing, while infrastructure
  owns native folder picking and archive directory IO.
- Moved Chat DB monitor platform capability detection behind
  `ChatDbMonitorRuntimeEnvironment`. `ChatDbChangeMonitor` still owns live
  polling and graph-update lifecycle decisions, while infrastructure owns the
  concrete macOS runtime check.
- Moved database-health database file existence checks out of the
  `DatabaseHealthQueryLayer` application contract and into concrete
  infrastructure query-layer implementations. The health audit service still
  owns audit semantics; infrastructure owns filesystem interpretation of
  database paths.
- Moved database-health report writing and runtime platform metadata behind
  `DatabaseHealthAuditReportWriter` and `DatabaseHealthRuntimeEnvironment`.
  `DatabaseHealthAuditService` now owns report construction semantics only,
  while infrastructure owns JSON file output and OS/timezone inspection.
- Moved attachment archive file-store mechanics behind
  `AttachmentArchiveFileStore`, then split archive graph reads, overlay writes,
  and sweep cursor/status persistence into named attachment-feature ports.
  `AttachmentArchiveService` now owns archive orchestration and policy flow
  only. `GraphAttachmentArchiveCandidateReader` owns graph candidate SQL,
  `AttachmentArchiveWriteStore` owns archive record/recovery hint/integrity-row
  persistence, `AttachmentArchiveSettingsStore` owns sweep state, and
  `AttachmentArchiveFileStore` owns home-path expansion, source-file existence
  checks, hashing, archive file writes, and integrity file reads.
- Moved historical archive folder selection behind
  `HistoricalArchiveFolderChooser`. The historical archive workflow still owns
  selected-source/preflight/import semantics, while settings infrastructure owns
  the native folder picker mechanics.
- Moved recovered attachment path expansion out of message-domain
  `AttachmentInfo` and into `AttachmentFileAccess`. `AttachmentInfo` now
  remains source metadata/classification data, while the attachments feature
  boundary owns home-directory expansion and file-presence interpretation.
- Moved shared media tile file resolution out of `MediaTileAttachment` and
  into `AttachmentFileAccess` use at the rendering boundary. The media tile
  adapter now remains a display DTO, while file existence and path expansion
  stay in the attachments feature boundary.
- Changed `ResolvedAttachment` from a concrete `File`-carrying domain object
  to a path-based availability result. Attachment resolution now returns
  `resolvedFilePath`; widgets may create renderable files at the presentation
  edge, while the attachments domain remains data-oriented.
- Moved graph-status archived-file opening behind an
  `ArchivedAttachmentFileOpener` boundary. The status sheet still exposes the
  diagnostic action, but URL-launch/runtime mechanics live in graph
  infrastructure and are guarded by an architecture tripwire.
- Moved message URL-preview launching behind an app-level
  `ExternalUriOpener` boundary. Message preview widgets still render tappable
  links, but external launch mechanics are centralized and protected by an
  architecture tripwire.
- Narrowed `AttachmentFileAccess` to a path-based application contract.
  Infrastructure still performs file-existence checks, and presentation may
  create renderable `File` objects at the media edge, but the application port
  no longer exposes concrete file handles.
- Moved conversation graph readiness file/SQLite probing out of the public
  readiness provider and into `SqliteConversationGraphReadinessChecker`.
  The provider now owns lifecycle invalidation and path selection only, while
  infrastructure owns graph-storage inspection.
- Removed the reset service's direct concrete graph-database import for
  filename access. Reset orchestration now uses the public database provider
  boundary for graph storage constants as well as provider invalidation.
- Moved diagnostic report presentation results into the logging domain and
  removed direct `LogExportService` imports from onboarding and environment
  readiness presentation views. Presentation now triggers diagnostic report
  export through application actions and renders a domain result; the concrete
  export service remains infrastructure-owned and protected by an architecture
  tripwire.
- Moved diagnostic report export mechanics behind a
  `DiagnosticReportExporter` application contract and logging feature provider.
  Startup, sidebar, onboarding, and environment-readiness callers no longer
  fetch `LogFileWriter` plus database-health services for diagnostic bundle
  export; infrastructure owns support-bundle/export launch mechanics, and a
  tripwire prevents diagnostic action helpers from importing that
  infrastructure directly.
- Moved pipeline incident storage and audit-log writing behind logging
  application contracts. `PipelineIncidentTracker` now consumes
  `PipelineIncidentStore` and `PipelineIncidentLogWriter` through the logging
  feature boundary, while overlay persistence and file audit logging remain in
  infrastructure. The old infrastructure storage provider was removed and the
  tracker tripwire now blocks direct logging-infrastructure imports.
- Moved message-history coverage export destination lookup behind the logging
  feature boundary. Sidebar action dispatch no longer reaches through
  `appLoggerProvider.notifier.writer` for `LogFileWriter` internals; it consumes
  the named diagnostic log-directory provider, and the sidebar dispatcher
  tripwire now blocks direct writer reach-through.
- Moved `ArchiveSourceInspector` provider composition to the settings
  feature-level boundary. The inspection contract remains application-owned,
  the SQLite/filesystem implementation remains infrastructure-owned, and a
  tripwire prevents the retired application provider from returning.
- Added an onboarding feature-level provider boundary for FDA access,
  onboarding database probing, onboarding failure persistence, and derived-data
  file operations. Onboarding application code now depends on application
  contracts through that boundary, while concrete macOS, SQLite, overlay, and
  filesystem implementations remain infrastructure-owned. A tripwire prevents
  the retired infrastructure provider locations from returning.
- Split historical archive source inspection into an application
  `ArchiveSourceInspector` contract plus an infrastructure SQLite/filesystem
  implementation. The historical archives workflow now requests source
  preflight through the application boundary instead of importing the concrete
  inspection repository directly, with a tripwire preventing presentation
  regression.
- Moved the Historical Archives folder chooser provider into settings
  application code. The file-selector adapter remains infrastructure-owned,
  while the workflow consumes the application `HistoricalArchiveFolderChooser`
  boundary; an architecture tripwire prevents the provider wrapper from moving
  back into infrastructure.
- Split retained historical archive source metadata into an application
  `HistoricalArchiveSources` contract plus an infrastructure retained-metadata
  repository. Historical Archives workflow and sidebar summaries now consume
  application source metadata providers instead of the concrete retained
  repository, with a tripwire preventing regression.
- Routed contacts presentation contact-summary usage through the contacts
  feature-level public API. `ContactSummary` remains in the current contact
  list read-model implementation for now, but presentation no longer imports
  the concrete repository file directly, and a tripwire prevents that boundary
  regression.
- Moved Historical Archives folder chooser provider composition to the
  settings feature-level boundary. The application contract remains in
  settings application code, the native file-selector adapter remains
  infrastructure-owned, and the retired application/infrastructure provider
  locations are guarded by an architecture tripwire.
- Moved developer-mode store provider composition to the debug feature-level
  boundary. `DeveloperMode` still owns default/debug-mode semantics, while
  overlay-backed setting storage remains infrastructure-owned behind the
  `DeveloperModeStore` contract and the retired infrastructure provider wrapper
  is guarded by a tripwire.
- Moved sidebar flow preference-store provider composition to the sidebar
  feature-level boundary. `SidebarFlow` still owns deterministic sidebar state
  and persistence semantics, while overlay-backed setting storage remains
  infrastructure-owned behind the `SidebarFlowPreferenceStore` contract.
- Moved conversation signature preference-store provider composition to the
  messages feature-level boundary. The preferences controller still owns
  filter/sort semantics, while overlay-backed setting storage remains
  infrastructure-owned behind the `ConversationSignaturePreferencesStore`
  contract.
- Moved contacts user-intent provider composition to the contacts feature-level
  boundary for display-name overrides, favourite contacts, manual handle links,
  and picker filter mode. Application controllers now consume feature-boundary
  providers for their storage/repository contracts instead of importing
  infrastructure provider islands.
- Moved handle visibility, spam-handle, and manual-linking read provider
  composition to the handles feature-level boundary. Handle application
  providers now consume named boundary providers while graph/overlay-backed
  implementations remain infrastructure-owned behind contracts.
- Added a conversation graph feature-level provider boundary for read-side
  graph repository composition. Chat summaries, contact graph reads,
  conversation reads, graph health, and message graph reads now consume named
  boundary providers; the retired infrastructure provider islands are guarded
  by an architecture tripwire.
- Moved graph projection repository and resetter provider composition into the
  conversation graph feature-level boundary. Projectors still own projection
  semantics and consume repository contracts; concrete import/graph database
  wiring is centralized at the boundary and protected by a tripwire.
- Moved conversation graph favourites-store and status-snapshot provider
  composition into the conversation graph feature-level boundary. Favourites
  controller and status reader remain semantic/application-owned while
  overlay/source/import/graph wiring is centralized at the boundary.
- Moved Chat DB monitor probe/runtime provider composition into the
  conversation graph feature-level boundary. The monitor still owns lifecycle
  decisions and consumes source/import/runtime probe ports; concrete SQLite,
  source-scoped import, and platform runtime wiring is centralized at the
  boundary.
- Moved message history coverage repository/exporter provider composition into
  the settings feature-level boundary. The coverage resolver and sidebar action
  dispatcher now consume the public settings API while graph database and
  filesystem exporter wiring stay centralized at the boundary.
- Routed the contact manual-link service's stray-handle invalidation through
  the handles feature-level public API instead of importing handle
  infrastructure providers directly. Added a cross-feature import tripwire for
  handle display/stray-handle provider access.
- Routed the handles manual-linking provider's virtual-participant invalidation
  through the contacts feature-level public API instead of importing contacts
  infrastructure providers directly. Added a cross-feature import tripwire for
  contact profile/handle/virtual-participant provider access.
- Routed contacts application resolver/widget builders through the contacts
  feature-level public API for contact summaries, profile prewarm, handles,
  recents, and virtual participants instead of importing contacts
  infrastructure read-model files directly. Expanded the contact boundary
  tripwire to cover application and presentation surfaces.
- Routed handles application presentation for stray-handle review through the
  handles feature-level public API instead of importing handle infrastructure
  provider files directly. Added a handles application/presentation tripwire
  so same-feature UI composition does not bypass the public boundary.
- Moved historical archive source provider composition into the settings
  feature-level boundary. The application `HistoricalArchiveSources` contract
  remains semantic, while retained `macos_import.db` metadata repository access
  is wired only at the settings public API boundary and guarded by the existing
  archive-source metadata tripwire.
- Routed non-infrastructure contacts/handles tests through the public feature
  APIs for contact summaries, contact list provider overrides, and stray-handle
  provider overrides. Infrastructure tests still import concrete repositories
  directly when they are testing those repositories themselves.
- Split stray-handle read models from graph storage implementation. Public
  `StrayHandleSummary` and stray/spam/dismissed providers now live at the
  handles feature boundary, while graph SQL and overlay filtering live behind a
  `StrayHandlesReadRepository` implementation. The retired infrastructure
  provider file is guarded from returning.
- Aligned graph archive documentation with the current attachment port
  boundaries. `AttachmentArchiveService` is now documented as orchestration and
  policy flow only; graph candidate reads, archive record writes, sweep state,
  and filesystem operations belong to named attachment-feature ports.
- Extracted current attachment snapshot lookup provider composition behind the
  `CurrentAttachmentSnapshotLookup` application port. Cross-snapshot mapping
  now consumes the typed lookup provider, while source-scoped import database
  access stays localized to the attachments feature boundary.
- Added an architecture tripwire that keeps concrete
  `sourceScopedImportDatabaseProvider` access out of attachment code below the
  feature-level provider boundary. Infrastructure adapters may query the import
  ledger through typed constructor dependencies; provider composition remains
  centralized.
- Removed the unused standalone `lib/test_mouse_tracking.dart` diagnostic app
  after confirming it had no active references. Hover/mouse tracking diagnostics
  should not live as app entrypoints under `lib/` unless they are part of a
  named developer surface.
- Moved graph-status archived-file opener and status-log writer provider
  composition into the conversation graph feature-level boundary. The
  application layer retains only the typed action contracts, infrastructure
  retains the concrete opener/writer implementations, and architecture
  tripwires prevent the retired application-provider islands from returning.
- Exposed `AppLogger` through the logging feature-level boundary and routed
  app consumers away from direct `logging/application/app_logger.dart`
  imports. The logger remains the same runtime provider, but other systems now
  depend on the public logging API and an architecture tripwire prevents direct
  application-logger imports from returning.
- Replaced a database-health report `TODO` diagnostic note with an explicit
  build-metadata limitation and aligned the fallback build name/number with
  `pubspec.yaml`. Runtime Flutter build defines still take precedence when
  provided.
- Reworded sidebar panel resolution error handling to make the current
  ownership explicit: errors are logged without disrupting the panel projection
  path, and any user-visible incident surfacing must belong to a named
  diagnostics surface rather than an imperative repair inside panel rendering.
- Clarified the new-feature workflow index so historical feature-planning
  folders under `45-NEW-FEATURE-ADDITION/` are not mistaken for active graph-era
  implementation guidance. Active work must be listed in the current-feature
  table, linked from the current roadmap/checklist, or explicitly requested.
- Corrected the R-I-O reading-flow index so the retired incremental-update
  pilot is described as historical validation that has been absorbed into the
  source-scoped graph lifecycle, not as current runtime behavior.
- Added an explicit historical-status banner to
  `50-INCREMENTAL-UPDATE-PILOT.md` so its retained shadow-pilot details are not
  mistaken for current app architecture.
- Removed the deprecated `lib/config/theme/theme.dart` reference barrel after
  confirming active code imports current spacing/widget/token files directly.
  Theme callers should continue using the concrete token/provider/widget
  boundaries rather than the retired `AppTheme`/`BbcColors` surface.
- Routed the navigation panel-stack tab strip through `themeColorsProvider` and
  `themeTypographyProvider` instead of local `Theme.of(context)` reads, keeping
  navigation chrome on the shared app token vocabulary.
- Added an architecture tripwire that rejects active `Theme.of(...)`,
  `MacosTheme.of(...)`, and `CupertinoTheme.of(...)` usage in `lib/`. App UI
  surfaces should use the shared theme provider/token vocabulary.
- Removed stale all-comment theme-extension and contact-lozenge prototype code
  so theme scans report active architectural drift rather than historical
  commented examples.
- Marked the completed UI sweep checklist's old `theme.dart` barrel export item
  as superseded by direct spacing/widget/token imports and theme provider usage.
- Removed deprecated dropdown menu font-weight aliases after confirming callers
  use typed leading-label and selected-value style slots. The shared dropdown
  surface now exposes one current styling path instead of carrying stale
  compatibility parameters.
- Clarified the retained virtual-participant `short_name` column in code and
  tests as schema storage only. User-facing contact identity continues to flow
  through `display_name` and the canonical display identity resolver, not a
  resurrected short-name path.
- Removed the all-comment `lib/core/util/broadcast.dart` scratch utility after
  confirming it had no active references. Retired diagnostics and experiments
  should not remain under `lib/` as apparent application code.
- Removed stale commented imports and a malformed window-delegate example
  comment from active root utility/provider files. Active source should not
  carry old dependency hints that can be mistaken for current architecture.
- Removed commented-out router and cassette-rack tracer-bullet code while
  preserving the explicit topology contract comments. Future route or sidebar
  behavior should be introduced through current spec/coordinator patterns, not
  resurrected from commented skeletons.
- Added an architecture tripwire rejecting hand-written `lib/` Dart files that
  contain only comments. Retired experiments should be deleted or moved to
  documentation so active source scans continue to reflect executable systems.
- Reworded sidebar rack comments that still described the current default
  cascade as a tracer-bullet state. The initial messages sidebar cascade is now
  documented as current behavior rather than experimental scaffolding.
- Removed unused duplicate DDD interface files after confirming active value
  objects use `common_interfaces.dart` and no code imports the standalone
  `i_entity.dart` / `i_validatable.dart` files.
- Reworded stale “NEW” contact-picker constant comments so active domain
  constants describe current behavior instead of an old implementation phase.
- Removed the unused `NotAuthenticatedError` DDD utility symbol after confirming
  no active code references it. The remaining error helper is the value-object
  `UnexpectedValueError` path used by current value objects.
- Removed obsolete commented-out future tooltip/cassette variants so the active
  spec files describe current cross-surface contracts instead of hypothetical
  scaffolding.
- Reworded the date-conversion utility header so timestamp-format notes remain
  useful and professional without changing any conversion behavior.
- Added an architecture tripwire that rejects active-code `TODO` / `FIXME`
  markers in hand-written Dart files, forcing deferred work into explicit
  planning docs rather than executable-code drift.
- Reworded stale root-provider comments so shared provider ownership and
  theme-mode behavior are described as current architecture rather than a
  temporary theming experiment.
- Replaced raw string throws in `PathsHelper` with typed `StateError`s so path
  initialization failures preserve diagnostic cause without throwing arbitrary
  objects.
- Replaced the AddressBook folder probe's raw string throw with a typed
  `StateError` that preserves the path and underlying open failure.
- Added an architecture tripwire that rejects raw string throws in active
  hand-written Dart files.
- Removed stale commented debug `print` calls from path and AddressBook folder
  helpers now that typed errors and explicit probe behavior cover diagnostics.
- Added an architecture tripwire that keeps raw `print` usage limited to the
  existing root zone interceptor and retained-database diagnostic boundary.
- Replaced remaining generic `throw Exception(...)` uses in hand-written
  production code with typed `StateError`s, and added a tripwire to keep
  generic exception throws out of active Dart.
- Removed the stale `SearchResultContextEvidenceScope` intra-scope search
  `UnimplementedError`; bounded search-result context now intersects global
  graph text matches with the context skeleton so matches stay inside the
  selected evidence scope.
- Replaced the remaining production `UnimplementedError` with an explicit
  unsupported-state `StateError`, and added a tripwire to keep unfinished
  runtime-path markers out of active `lib/` code.
- Updated current AddressBook database guidance snippets so they demonstrate
  typed `StateError` failures instead of generic `Exception` throws.
- Replaced remaining test-fake `UnimplementedError` markers with explicit
  unsupported-method failures, keeping unfinished-marker scans meaningful while
  preserving fake repository behavior.
- Reclassified current feature-doc `TODO` buckets for chats, chat-handles,
  search, and messages as explicit open stewardship items, and refreshed their
  review metadata so deferred work is documented rather than normalized as
  executable-code-style TODO debt.
- Updated current chats and search interaction/navigation docs so they describe
  the graph-era Conversations flow, Message Evidence Spine search behavior, and
  anti-regression guardrails instead of stale draft panel concepts.
- Refreshed chats, chat-handles, search, and messages work logs with graph-era
  entries and converted checkbox-style follow-ups into open stewardship notes.
- Refreshed the Rust FFI dylib bundling build note so its metadata and embedded
  Xcode shell script match the current project file, including the Big Bench
  framework bundle identifier and framework-directory reset.
- Reworded the superseded onboarding/import debug handoff so its objective,
  blocker, file list, and resume prompt are explicitly historical and cannot be
  mistaken for current graph-era onboarding instructions.
- Updated the Rust message extractor handoff to document the current
  blob-based enrichment path, making explicit that live graph updates decode
  stored `attributed_body_blob` rows and must not rescan all of `chat.db` for a
  single new message.
- Aligned the extractor packaging instructions with the checked-in Xcode
  "Bundle Rust Message Extractor" phase, removing stale manual
  resource/post-build copy guidance.
- Clarified current archive documentation so full archive sweeps are described
  as explicit graph archive sweeps over graph candidates, not legacy archive
  compatibility paths.
- Tightened source-database and historical handoff wording so retained
  database files are documented as compatibility storage/diagnostics, while
  live `chat.db` remains a read-only source for the source-scoped graph.
- Clarified the import-orchestrator docs split: current `ChatDbChangeMonitor`
  runbook content is live guidance, while retained importer mechanics are
  historical retained-storage interpretation only.
- Refreshed review metadata on the source `chat.db`, import overview, and
  import-monitor docs touched by the graph ownership clarification pass.
- Corrected stale dependency-matrix/checklist wording that implied the retired
  retained archive pipeline still owned a private legacy rebuild-readiness
  check.
- Updated the graph completion roadmap and retained storage register so their
  active-status sections describe Historical Archives import/removal as
  source-scoped graph services, with remaining work limited to retained
  cleanup-storage retirement.
- Reworded the source-scoped archive cutover plan's Stage 4 as completed for
  execution code, leaving only the retained-file cleanup-storage policy as a
  future decision.
- Aligned the graph completion roadmap's lifecycle phase with the completed
  graph lifecycle orchestration slice: ordinary build/readiness/update
  ownership is done, while remaining work is retained cleanup-storage policy
  and diagnostic hardening.
- Aligned the graph completion roadmap's display-identity phase with the
  completed graph-native contact/handle identity slice: ordinary surfaces use
  graph plus overlay display identity, while remaining work is stewardship and
  old-field/bridge retirement.
- Replaced stale roadmap "immediate next slices" with the current remaining
  work: retained cleanup-storage policy, archive overlay key evolution,
  historical/recovered source intake, and diagnostic hardening.
- Updated the roadmap risk register so the leading risk is now retained
  storage policy lagging behind graph ownership, not graph lifecycle work
  lagging behind UI work.
- Reworded the roadmap and this checklist so retained `macos_import.db` /
  `working.db` user data files are protected by retention-register criteria,
  while retired execution/read code remains eligible for deletion after blocker
  closure.
- Clarified the retained storage register's first bucket: old archive
  import/projection implementation files are completed execution retirement,
  while remaining `macos_import.db` / `working.db` files are storage boundaries
  with separate reduction criteria.
- Verified `flutter test test/architecture/forbidden_imports_test.dart`
  passes with 111 architecture tripwires, including retained database
  quarantine and retired import/projection path guards.
- 2026-06-15 boundary hardening checkpoint:
  - Moved contact conversation signature display derivation into the messages
    application resolver layer. `ContactGraphConversationSection` now receives
    display-ready `ConversationSignatureDisplayModel` values instead of
    reading raw contact graph snapshots in presentation.
  - Moved contact-context identity equivalence out of the heatmap widget into a
    named resolver utility, keeping graph contact-id normalization out of the
    widget builder.
  - Converted the remaining hand-written core Riverpod provider declarations
    for router/window-state wiring to generated providers and added a tripwire
    preventing new manual provider declarations in active `lib/` code.
  - Confirmed the Conversations top-menu projection remains sidebar-derived:
    no center conversation evidence is projected until a conversation signature
    is selected; the old `conversationBrowser` spec is not the normal
    Conversations branch projection.
  - Removed the obsolete `MessagesSpec.conversationBrowser` route, its
    view-spec coordinator branch, panel compatibility branches, and navigation
    log variant. Later cleanup retired the standalone
    `ConversationBrowserView`, its integrator, and their tests entirely.
  - Removed the old `ConversationBrowserView` from the chats public
    feature-level export surface, then retired the underlying reference UI once
    scans confirmed it had no production route/export.
  - Added architecture tripwires that keep the retired conversation browser out
    of the chats public export surface and prevent its route/internal paths
    from returning as a backdoor conversation read path.
  - Renamed the graph-facing archive lookup record field from retained import
    identity language to `archiveCompatibilityAttachmentId`. The retained
    archive overlay still uses `(message_guid, import_attachment_id)`, but the
    graph contract now presents that value as an archive compatibility key
    rather than canonical attachment identity.
  - Added an architecture tripwire that keeps retained import identity language
    out of the graph-facing archive lookup contract while preserving the
    infrastructure compatibility bridge to the current archive table.
  - Renamed graph archive candidate read-model fields from retained overlay
    column language to `archiveMessageGuid` and
    `archiveCompatibilityAttachmentId`. The archive service now explicitly maps
    those compatibility keys into the existing overlay write-store API.
  - Added an architecture tripwire that keeps retained archive column names out
    of the graph archive candidate contract.
  - Clarified `AttachmentArchiveReadStore` and `attachmentResolverProvider`
    comments so their `messageGuid` / `importAttachmentId` parameters are
    explicitly treated as the current archive compatibility key, not canonical
    graph identity.
  - Renamed graph health missing-attachment recovery sample fields to
    `archiveMessageGuid` and `archiveCompatibilityAttachmentId`, keeping
    retained archive table column names inside repository/query code rather
    than exposing them through the diagnostic application model.
  - Documented the remaining message/media evidence DTO archive keys as
    current archive compatibility keys and added an architecture guard so
    `AttachmentInfo` / `MediaTileAttachment` cannot silently turn
    `messageGuid` / `importAttachmentId` into canonical graph identity.
  - Clarified the archive write-store, archive file-store, and recovery-hint
    key contracts so retained archive key names remain explicitly bounded to
    compatibility storage instead of becoming graph identity vocabulary.
  - Added `ArchiveCompatibilityKey` as a named application-layer bridge type
    for retained `(message_guid, import_attachment_id)` archive storage and
    replaced ad hoc graph candidate de-duplication string keys with the typed
    compatibility key.
  - Added an architecture tripwire preventing graph archive candidate
    de-duplication from reintroducing ad hoc string tuple archive keys.
  - Threaded `ArchiveCompatibilityKey` through archive read/write-store
    recovery-hint and idempotency methods, reducing primitive
    `messageGuid` / `importAttachmentId` parameters to evidence/media resolver
    compatibility edges.
  - Moved optional archive compatibility key derivation onto
    `GraphAttachmentArchiveCandidate`, so graph archive repositories and
    archive services consume typed compatibility intent instead of rebuilding
    the retained key pair locally.
  - Added typed archive compatibility key derivation to recovered
    cross-snapshot mapped attachment records and used it in the recovered
    archive writer.
  - Aligned `AttachmentArchiveReadStore.readArchiveRecord` with
    `ArchiveCompatibilityKey`, so archive read-store lookup and recovery-hint
    lookup now share the same typed compatibility boundary.
  - Updated `ArchivedAttachmentWrite` to carry `ArchiveCompatibilityKey`
    directly; only the retained overlay writer unwraps it into
    `(message_guid, import_attachment_id)` table columns.
  - Centralized media-tile archive compatibility key completeness checks on
    `MediaTileAttachment.hasArchiveCompatibilityKey`, keeping widgets from
    duplicating primitive pair checks.
  - Added an architecture tripwire requiring archive read/write-store lookup,
    idempotency, and recovery-hint contracts to use `ArchiveCompatibilityKey`
    rather than primitive retained archive key pairs.
  - Updated `AttachmentArchiveService.archiveAttachment` and
    `prioritizeRecovery` to accept `ArchiveCompatibilityKey` directly, added a
    matching architecture tripwire, and centralized media-tile recovery action
    key derivation behind a single helper.
  - Simplified `attachmentResolverProvider` so callers pass `AttachmentInfo`
    evidence only; the resolver derives the optional
    `ArchiveCompatibilityKey` internally instead of exposing retained
    `messageGuid` / `importAttachmentId` as provider-family identity.
  - Converted graph health archive/recovery diagnostics to compare typed
    `ArchiveCompatibilityKey` values instead of ad hoc
    `messageGuid::importAttachmentId` strings, and added an architecture
    tripwire preventing raw string tuple archive keys from returning to graph
    health.
  - Removed the retained attachment-key half from the graph-facing
    `GraphAttachmentArchiveRecord`; archive lookup callers now receive only
    archive record facts, while the retained compatibility key remains inside
    the lookup implementation.
  - Kept `ArchiveCompatibilityKey` intact through
    `AttachmentArchiveService` source-path refresh helpers, reducing internal
    propagation of primitive retained attachment ids.
  - Updated `AttachmentArchiveFileStore.writeArchiveEntry(...)` to accept
    `ArchiveCompatibilityKey`; only the filesystem adapter unwraps the key
    when it needs the retained id for deterministic fallback filenames.
  - Added an architecture tripwire that froze the then-current
    `retained_overlay_identity_bridge.dart` import surface, keeping
    retained-overlay graph key conversion from spreading without explicit
    review while the transitional bridge still existed.
  - Moved contact-side retained/graph identity matching into a contacts
    application read-model helper, removing direct identity-bridge imports from
    the contact hero widget and favorite contact providers.
  - Moved message evidence context-anchor id compatibility into a named message
    evidence identity helper, removing direct identity-bridge imports from the
    message evidence spine provider.
  - Retired the old standalone conversation browser diagnostic view,
    integrator, and tests after scans confirmed no production route/export
    depended on them. Kept architecture tripwires preventing the old
    conversation-browser route/export/internal path from returning.
  - Cleaned active test terminology so retained-storage tests use current
    `retained` / `existing` / `source` vocabulary rather than implying that
    old legacy execution paths remain active.
  - Re-ran active source/test scans after the retained terminology cleanup.
    Active `lib/` / `test/` code now contains no `legacy` terminology except
    the intentional architecture tripwire that prevents new active
    legacy-named concepts.
  - Confirmed the retired `db_importers`, `db_migrate`, `incremental_update_ss`,
    retained Drift `working` schema, and old conversation browser roots remain
    physically absent from active source/test trees.
  - Confirmed the only active retained database access surfaces at that point
    were named retention boundaries: archive-source metadata storage, reset
    cleanup, read-only diagnostics/health, overlay/archive compatibility keys,
    and explicit retained-overlay identity bridges guarded by architecture
    tests. The shared retained-overlay identity bridge was later retired.
  - Added a companion architecture tripwire for the retained
    `macos_import.db` filename constant so production code can only reference
    retained archive metadata storage through central DB ownership or reset
    cleanup. This mirrors the existing retained `working.db` reference guard.
  - Renamed the source-scoped import-ledger reader and attachment snapshot
    lookup local database handles from generic `importDb` to `importLedgerDb`,
    keeping active graph/archive code terminology distinct from retained import
    storage.
  - Moved media-tile archive compatibility key derivation onto
    `MediaTileAttachment.archiveCompatibilityKey`, so shared message display
    widgets consume typed media evidence instead of reconstructing compatibility
    identity from primitive `messageGuid` / `importAttachmentId` fields.
    Added an architecture tripwire to keep that boundary from regressing.
  - Aligned cross-snapshot mapper test fixture naming with the active
    source-scoped import-ledger terminology by renaming generic `importDb`
    handles to `importLedgerDb`.
  - Added an architecture tripwire that allow-lists production
    `ArchiveCompatibilityKey` construction sites. New code must pass typed keys
    through existing evidence/resolver/diagnostic boundaries instead of
    rebuilding retained archive compatibility identity ad hoc.
  - Moved active Historical Archives source metadata out of retained
    `macos_import.db` storage and into overlay-owned settings storage behind
    `HistoricalArchiveSourcesRepository`. The settings feature provider no
    longer watches `retainedArchiveMetadataStoreProvider`, and the retained
    provider tripwire was tightened so settings cannot regain that authority.
  - Removed the central `retainedArchiveMetadataStoreProvider` entirely after
    active Historical Archives metadata moved to overlay storage. Message-data
    reset still deletes retained `macos_import.db` files by filename, but no
    app provider now constructs a retained `macos_import.db` database.
  - Retired the unused `RetainedArchiveMetadataDatabase` wrapper,
    `RetainedArchiveMetadataStore` interface, and their dedicated schema tests.
    Existing retained files may still be deleted by reset or inspected by
    read-only diagnostic/file-query paths, but there is no active retained
    metadata database abstraction left in `lib/`.
  - Renamed the retained database filename constants to
    `retiredMacosImportDatabaseFileName` and
    `retiredWorkingDatabaseFileName`. Reset and diagnostics still know how to
    delete/inspect existing files, but active code no longer names them as
    metadata stores or historical working databases.
  - Renamed graph-health archive readiness internals from "working attachment"
    to "graph attachment" so attachment reachability is described as
    graph/source-scoped identity plus overlay archive records, not retained
    `working.db` shape.
  - Renamed conversation graph projection/status repository constructor fields
    and tests from generic `importDatabase` to `importLedgerDatabase`. The only
    remaining conversation-graph `importDatabase` wording is the physical
    diagnostic database-name field shown in the graph status panel.
  - Added an architecture tripwire requiring conversation graph repository and
    projection tests to use import-ledger naming for the source-scoped import
    database. This keeps active graph projection terminology separate from
    retained import compatibility storage.
  - Moved retained-overlay id conversion out of the conversation graph domain
    folder into
    `application/identity/retained_overlay_identity_bridge.dart`, and updated
    the import-surface tripwire. The bridge remains transitional compatibility
    logic, not graph domain identity semantics.
  - Added a retired-file tripwire preventing the old
    `conversation_graph/domain/identity_key_bridge.dart` path and test from
    returning. Retained-overlay id conversion must stay in the named
    application compatibility boundary.
  - Rechecked active source/test roots after the retained-overlay bridge move.
    No retired `db_importers`, `db_migrate`, `incremental_update_ss`,
    retained Drift `working` schema, old conversation browser, old
    `MessageTimelineScope`, or old `MessagesTimelineView` source/test paths
    were present.
  - Rechecked the explicit retained-overlay identity bridge surface. The
    remaining imports are the bounded contact, handle, and message
    compatibility readers already allow-listed by the architecture tripwire;
    no presentation widget or graph domain file imports the bridge.
  - Rechecked graph/archive compatibility surfaces. Archive key construction
    remains limited to typed `ArchiveCompatibilityKey` boundaries, and graph
    archive lookup contracts expose archive facts rather than retained archive
    table identity.
  - `flutter analyze` passed cleanly. `dart analyze` is currently not a useful
    verifier in this environment because the custom_lint analyzer plugin fails
    to start with a local dynamic-library/AOT snapshot error before reporting
    project diagnostics.
  - Added an architecture tripwire preventing retired contact name variants
    (`shortName`, `short_name`, `nickname`, `nameMode`, `name_mode`) from
    re-entering active app-facing identity code. The single user-authored
    display-name path remains `participant_overrides.display_name_override`.
  - Removed the retired `participant_overrides.name_mode` and
    `virtual_participants.short_name` columns from the active overlay Drift
    schema with an overlay schema migration. The architecture tripwire now
    allows retired contact-name variants only in explicit drop-column cleanup
    statements, and overlay schema tests assert that fresh databases do not
    recreate those columns.
  - Retired the shared
    `conversation_graph/application/identity/retained_overlay_identity_bridge.dart`
    file and test. Contact and handle retained-id compatibility now lives in
    feature-owned identity helpers, message evidence canonicalization lives in
    the message evidence identity helper, and architecture tripwires prevent
    the shared bridge from returning.
  - Renamed the message user-intent repository from
    `message_overlay_identity_bridge_repository.dart` to
    `graph_message_overlay_repository.dart`. The repository still honors
    retained rowid/GUID overlay rows as internal compatibility fallbacks, but
    its public boundary is graph-keyed message overlay state.
  - Corrected the Message Evidence Spine naming invariant so contact display
    precedence no longer includes an app-derived short-name step. Short-name,
    nickname, and name-mode variants are now documented as retired
    compatibility artifacts rather than evidence naming inputs.
  - Added an architecture tripwire preventing source-specific message renderer
    classes/files (`ContactMessageRenderer`, `ConversationMessageRenderer`,
    `SearchResultMessageRenderer`, `RecoveredMessageRenderer`) from returning.
    Source-specific message scopes remain allowed; source-specific evidence
    presentation remains blocked by test.
  - Added an architecture tripwire preventing the retired ordinal
    `MessageTimelineScope` / `MessagesTimelineView` path and its old timeline
    strategy folders from returning. Active evidence must continue through
    `MessageEvidenceScope`, full-scope skeletons, visible-row hydration, and
    `MessageEvidenceTimelineView`.
  - Renamed the message evidence initial-row provider parameter from generic
    `limit` to `hydrationLimit`. This preserves the full selected logical scope
    invariant by making the bounded value explicitly local to visible-row
    hydration, including larger month-jump hydration windows.
  - Added an architecture tripwire that scans the message evidence spine for
    selected-scope cap regressions such as generic `limit` parameters,
    `LIMIT 500`, or `take(500)`. Bounded values in the spine must remain
    explicit hydration windows.
  - Removed the direct center-panel show call from
    `ContactGraphConversationSection`. Contact-by-conversation selection now
    updates `SidebarFlow`, and the conversation evidence center spec is derived
    from contact conversation projection state. The existing architecture
    tripwire for the contact conversation section now also blocks direct
    center-panel navigation imports and `MessagesSpec.forConversation`
    construction inside the widget.
  - Moved message right-panel close controls behind the navigation-owned
    `panelActionsProvider`. Search-result context and recovered-attachment
    message presentation views no longer mutate `panelsViewStateProvider`
    directly; they render the local close control and invoke a typed navigation
    action. Added an architecture tripwire preventing message presentation code
    from directly naming `panelsViewStateProvider` or `WindowPanel`.
  - Added a broader architecture tripwire preventing feature presentation
    widgets from constructing `ViewSpec` / `MessagesSpec` or mutating
    `WindowPanel` state directly. Feature presentation should render typed
    data and dispatch semantic actions; sidebar flow, sidebar action
    dispatchers, and navigation action boundaries own panel routing.
  - Moved handle display-name cache invalidation for manual handle links into
    `ManualHandleLinkService`. `HandleLensView` now invokes the service and
    updates only its local form state; it no longer performs provider
    invalidation as an imperative repair after successful link actions.
  - Moved handle-filter unlink read invalidation into `ManualHandleLinkService`.
    The handle-filter widget now invokes the manual-link action boundary and
    performs only sidebar selection flow updates. Added a narrow architecture
    tripwire preventing widget-level provider invalidation from returning to
    that unlink path.
  - Routed contact-scoped conversation selection through a new
    `ContactConversationSelected` sidebar action intent. The contact
    conversation signature widget now dispatches a semantic action instead of
    mutating `SidebarFlow` directly; the dispatcher owns the call to
    `selectContactConversation`, and tests cover the contact-scoped projection.
  - Routed the Contact sidebar All messages / By conversation toggle through a
    `ContactProjectionChanged` sidebar action intent. The heatmap widget now
    reports the user's projection choice, while `SidebarActionDispatcher` owns
    the translation into `showContactTimelineAt` or
    `showContactConversationNavigator`.
  - Routed the recovered no-handle navigator button through a
    `RecoveredNoHandleFromMeOpened` sidebar action intent. The cassette widget
    now reports navigation intent only; `SidebarActionDispatcher` owns the
    recovered no-handle flow mutation and projected center-panel state.
  - Routed the chats feature selection controller through
    `SidebarActionDispatcher` by extending `ConversationSelected` with optional
    anchor/search context. `ChatsViewModel` now translates chat selections into
    semantic sidebar actions rather than mutating `SidebarFlow` directly, with
    an architecture tripwire guarding the boundary.
  - Moved stray-handle/handle-message center evidence projection into
    `SidebarFlowState`. The flow state now carries explicit handle evidence
    selection (`lens` vs `messages`) on the Stray Handles branch, and
    `SidebarActionDispatcher` no longer constructs `MessagesSpec` or pushes
    message evidence panels directly. Architecture tests now guard that
    dispatcher boundary.
  - Updated the stray-handles review cassette to derive selected-row state from
    `SidebarFlowState.selectedHandleEvidenceId` instead of inspecting the
    effective center panel spec. This keeps presentation selection aligned with
    the same semantic source that derives the center evidence panel.
  - Cleaned stale sidebar widget-builder comments that still described widgets
    as constructing panel specs on user interaction. Added an architecture
    tripwire requiring sidebar widget guidance to use the current semantic
    action / derived flow wording.
  - Moved onboarding/readiness center-panel synchronization policy out of the
    presentation observer into a navigation application controller. The widget
    now observes onboarding/incident inputs only; panel-stack mutation and
    readiness/incident routing decisions live behind the controller boundary.
    Added a tripwire preventing that policy from returning to the observer.
  - Moved conversation graph status sheet refresh/build/logging actions into a
    conversation-graph application action controller. The status sheet now
    renders buttons and local spinner/hover state only; provider invalidation,
    manual graph build execution, summary/health refresh, and status run
    logging live behind the action boundary. Added a tripwire preventing those
    details from returning to the presentation sheet.
  - Moved sidebar retry refresh invalidation out of contact hero and message
    heatmap widget builders into feature-local application action providers.
    Sidebar widgets now render retry controls and invoke typed refresh actions;
    provider invalidation remains behind resolver/action boundaries. Added a
    tripwire preventing direct provider invalidation from returning to sidebar
    widget builders.
  - Moved onboarding dev-panel reset/recheck sequencing into an onboarding
    application action provider. The dev panel now renders its reset button and
    invokes a typed action; reset-service calls and environment recheck
    sequencing no longer live in presentation. Added a tripwire preventing
    those details from returning to the dev panel.
  - Routed grouped contact picker retry refresh through the existing contact
    sidebar refresh action provider. The picker continues to watch its typed
    view model and render retry UI, but provider invalidation is no longer
    owned by presentation. Added a focused tripwire for this picker boundary.
  - Moved sidebar parked overlay center-panel cancellation onto the navigation
    panel action boundary. The overlay now renders the parked/cancel affordance
    and invokes `PanelActions`; direct panel-stack mutation remains in
    navigation application state. Added a focused tripwire for the overlay.
  - Tightened the contact favourite read-provider contract so it names
    `ContactFavoriteActions` as the owner of favourite mutation invalidation,
    rather than preserving generic caller-owned invalidation wording. Added a
    tripwire preventing that stale contract language from returning.
  - Renamed the parked center-panel action boundary from generic clear-panel
    vocabulary to `cancelParkedCenterOperation`. The parked overlay now reports
    the semantic user intent, while navigation application state still owns the
    panel-stack mutation. Added a tripwire preventing the old clear-panel
    vocabulary from returning to this boundary.
  - Moved parked-overlay onboarding readiness re-check behavior behind an
    onboarding application action boundary. The parked overlay still renders
    readiness copy from typed state, but clearing developer simulations and
    refreshing the onboarding environment now live in
    `OnboardingReadinessActions`. Added a tripwire preventing that repair logic
    from returning to the overlay.
  - Routed the onboarding dev panel's Refresh Diagnostics button through the
    same `OnboardingReadinessActions` boundary. The panel still renders
    diagnostics state, but environment refresh ownership now stays in the
    onboarding application layer. Extended the existing dev-panel tripwire to
    catch direct refresh calls.
  - Moved production onboarding overlay button callbacks behind
    `OnboardingOverlayActions`. The overlay still watches onboarding gate state
    for rendering, but Full Disk Access, re-check, import, abort, and dismiss
    intents now cross an application action boundary. Added a tripwire
    preventing direct gate-notifier calls from returning to the overlay.
  - Routed onboarding dev-panel gate lifecycle buttons through
    `OnboardingOverlayActions` as well. The dev panel still observes gate state
    for diagnostic rendering, but Open Settings, start import, and dismiss
    callbacks no longer call the gate notifier directly. Extended the dev-panel
    tripwire to guard that boundary.
  - Moved top-level Messages/Settings mode selection behind
    `AppModeActions`. The toggle still renders the active mode, but selected
    mode mutation and associated cleanup now cross a navigation action
    boundary. Added a tripwire preventing direct active-mode mutation from
    returning to the toolbar widget.
  - Moved contact picker filter mutation behind `PickerFilterActions`. The
    segmented control still renders the selected filter mode, but persisted
    filter selection now crosses a contact application action boundary. Added a
    tripwire preventing direct picker-filter notifier mutation from returning
    to the presentation widget.
- Moved app-shell toolbar mutations behind `AppShellActions`. `MacosAppShell`
  still renders developer-mode and theme controls from observed state, but
  developer-mode toggling and theme cycling now cross a navigation action
  boundary. Added a tripwire preventing direct toolbar provider mutation from
  returning.
- Moved environment-readiness and pipeline-incident panel lifecycle mutations
  behind feature-owned action boundaries. The panels still render readiness,
  incident, and diagnostic export state, but re-check/import/open-settings,
  developer simulation cleanup, retry, and dismiss intents no longer call the
  underlying onboarding or incident notifiers directly. Added tripwires for
  both panels.
- Moved conversation favourite toggle writes behind
  `ConversationFavouriteActions`. The reusable favourite button still renders
  current favourite state, but the user-intent mutation now crosses an explicit
  action boundary. Added a tripwire preventing direct controller mutation from
  returning to the widget. Added provider-level test coverage proving Core
  favourite toggles cross the action boundary before reaching overlay-backed
  state.
- Moved contact handle-filter selection/unlinking behind `HandleFilterActions`.
  The handle-filter widget now renders menu controls only; handle selection,
  overlay unlinking, and the follow-up sidebar route decision are owned by the
  contact feature action boundary. Added a tripwire preventing direct manual
  link or sidebar-dispatch mutation from returning to the widget.
- Moved message-display attachment recovery prioritization behind
  `AttachmentRecoveryActions`. Shared message media widgets still render
  unavailable attachment controls, but user recovery-priority writes now cross
  the attachments feature action boundary rather than invoking the archive
  service directly from presentation.
- Moved stray-handle sidebar open/filter/mode/dismiss/restore intents behind
  `StrayHandleSidebarActions`. The handle sidebar cassettes now render review
  controls and report typed UI events; sidebar dispatch, intent construction,
  and handle normalization are owned by the handles application boundary.
- Moved recovered-message sidebar month/open navigation behind
  `RecoveredMessageNavigationActions`. Recovered heatmaps and no-handle
  sidebar buttons now render controls only; sidebar intent construction and
  dispatch live in the messages application boundary.
- Moved contact-derived conversation-card selection behind
  `ContactConversationNavigationActions`. The contact conversation section now
  renders display-ready signature cards and reports selected conversation ids;
  sidebar intent construction and dispatch stay in the messages application
  boundary.
- Moved conversation-signature row selection behind
  `ConversationNavigationActions`. The conversation signature sidebar now
  renders favourite/normal signature rows and reports selected conversation ids;
  sidebar intent construction and dispatch stay in the messages application
  boundary.
- Moved message heatmap month/projection navigation behind
  `MessageHeatmapNavigationActions`. The heatmap widget now renders global and
  contact heatmaps, while month-focus and all-messages/by-conversation sidebar
  intent construction live in the messages application boundary. Added refresh
  action coverage proving global and selected contact heatmap invalidation stay
  behind `MessageHeatmapRefreshActions`.
- Moved contact message-scope toggle navigation behind
  `ContactMessageScopeActions`. The segmented control now renders current vs
  recovered scope state and reports the selected scope; cassette-indexed
  sidebar intent construction stays in the contacts application boundary.
- Moved contact-picker selection, change-contact navigation, and prewarm
  behavior behind `ContactPickerActions`. Flat, grouped, recents, and change
  controls now render choices and forward user intent; contact prewarm and
  cassette-indexed sidebar intent construction stay in the contacts
  application boundary.
- Moved message/settings top-menu selection behind `SidebarTopMenuActions`.
  The reusable sidebar utility menu widgets still render current choices and
  graph-readiness prompt state, but top-menu intent mapping and sidebar
  dispatch now live behind a sidebar-utilities application boundary.
- Moved settings action-list dispatch behind `SettingsActionListActions`.
  Settings action rows still render descriptor labels and tone, but
  enabled-state dispatch and settings sidebar intent construction now live in
  the settings application boundary.
- Moved chat selection dispatch behind `ChatSelectionActions`. The chats view
  model keeps its public selection API for existing callers, but conversation
  sidebar intent construction and dispatch now live in the chats application
  boundary.
- Moved generic sidebar dropdown dispatch behind `SidebarBodyModelActions`.
  `SidebarBodyModelContent` now renders typed dropdown body models and forwards
  selected options; disabled-option policy and sidebar dispatch live in the
  sidebar application boundary.
- Moved unfamiliar-source handle lens link/create/dismiss side effects behind
  `HandleLensActions`. `HandleLensView` now renders evidence, dialog/form
  inputs, and busy/error state only; manual-link writes, review dismissal, and
  warning logging stay behind a messages application action boundary.
- Moved onboarding dev-panel simulation toggles behind
  `OnboardingDevPanelActions`. The dev panel still renders current simulated
  readiness state, but Full Disk Access/database/source-history/pipeline
  simulation mutations now cross the onboarding application action boundary.
  Extended the dev-panel tripwire to prevent direct dev-override or readiness
  action mutation from returning to presentation.
- Moved historical archive workflow UI actions behind
  `HistoricalArchivesWorkflowActions`. The settings panel and archive-source
  sidebar supplement still render workflow state, but folder selection, clear
  selection, begin import, and remove-imported-archive-data intents no longer
  call the workflow notifier directly from UI code. Added a tripwire guarding
  this workflow action boundary.
- Routed the conversation graph status sheet's diagnostic open-chat action
  through the chats feature action boundary. The status sheet still renders
  graph diagnostics and selected chat rows, but chat selection/navigation now
  crosses `ChatSelectionActions` instead of mutating the chats view model
  directly. Extended the graph-status-sheet tripwire for this boundary. Added
  provider-level coverage proving chat selection dispatches the semantic
  conversation sidebar intent, including anchor message and search query
  context.
- Moved panel-stack tab activation, tab close, and diagnostic build logging
  behind `PanelActions`. `PanelStackSurface` now renders tabs/pages and
  forwards user intent only; panel-stack mutation and logger writes stay in
  navigation application code. Added a tripwire preventing those details from
  returning to the render surface.
- Moved conversation signature filter/sort mutations behind
  `ConversationSignaturePreferencesActions`. The conversation signatures
  widget still renders search/filter/sort controls and observes preference
  state, but persisted preference mutation now crosses a messages application
  action boundary. Added a tripwire guarding that boundary.
- Centralized live `attachment_ss_id` to retained archive-key derivation on
  `ArchiveCompatibilityKey.fromLiveAttachmentSsId(...)`, reducing direct
  `SourceScopedRowKey` unpacking at archive lookup/diagnostic call sites.
  Tightened the archive-key construction tripwire so the overlay archive lookup
  no longer remains an allowed direct constructor site.
- Added `ArchiveCompatibilityKey.liveSourceAttachmentRowId` for source-path
  refresh logic. Attachment archive application code now asks the retained key
  for the semantic live attachment ROWID instead of repeating retained
  `import_attachment_id` storage terminology at the path-lookup boundary.
- Added `ArchiveCompatibilityKey.supportsLiveGraphEndpoints(...)` so live-only
  archive compatibility checks are owned by the typed key boundary rather than
  repeated in archive lookup repositories.
- Routed graph health current-source archive diagnostics through
  `ArchiveCompatibilityKey.fromLiveAttachmentSsId(...)`, removing the last
  direct source-row unpacking from graph health's archive-key construction path.
- Added focused `VideoThumbnailCacheService` coverage for missing source
  videos, cached thumbnail reuse, generator failure, and concurrent in-flight
  request coalescing.
- Extended archive compatibility key tests so both message and attachment
  endpoints must be live-source graph ids before retained archive bridge logic
  treats them as compatible.
- Added focused tests for top-level navigation action boundaries:
  `AppShellActions`, `AppModeActions`, and `PanelActions`. The tests verify
  that developer-mode/theme, sidebar mode, and panel-stack mutations remain
  callable through application action boundaries rather than presentation-owned
  provider mutation.
- Added focused tests for sidebar preference and conversation navigation action
  boundaries. Picker filter, conversation signature preferences, conversation
  selection, and contact-conversation selection now have executable coverage
  proving widgets can invoke semantic actions without owning notifier mutation
  or sidebar dispatch.
- Added focused tests for message heatmap, recovered-message, contact message
  scope, and contact handle-filter navigation action boundaries. Month focus,
  recovered scope focus, no-handle recovered opening, contact projection,
  recovered-contact scope, and handle-filter selection now have executable
  coverage through semantic actions and derived sidebar flow state.
- Removed hard-coded personal external-drive recovery paths from graph health
  provider wiring. Historical MessageLens and recovered Messages backup probes
  are now opt-in diagnostic sources supplied through Dart defines, and an
  architecture tripwire prevents personal backup paths from returning to active
  `lib/` code.
- Aligned current database, onboarding/archive, project overview, and pipeline
  invariant docs with the retired-storage policy: `macos_import.db` and
  `working.db` are retired cleanup/diagnostic files, not active compatibility
  systems or projection targets.
- Tightened current migration status docs so the remaining database-file work
  is described as retired storage reduction under explicit retention criteria,
  not a live compatibility subsystem.
- Clarified architecture-test wording around handle blacklist overlay
  precedence: exact graph-id overlay intent wins over retired-storage
  compatibility variants.
- Replaced a test fake's `UnimplementedError` marker with an explicit
  `StateError`, preserving test behavior while keeping unfinished-code markers
  out of active test code.
- Moved onboarding infrastructure warning logs out of provider initialization.
  `onboardingDatabaseProbeReader`, `onboardingFailureStorage`, and
  `fullDiskAccess` still construct the same infrastructure boundaries, but
  callback logging is now deferred until after provider build so logger state
  mutation cannot occur during another provider's initialization.
- Renamed the reset-service combined database deletion inventory from
  `derivedMessageDataDatabaseBaseNames` to
  `messageDataResetDatabaseBaseNames`. Reset still deletes both active graph
  files and retired cleanup files, but the name no longer implies
  `macos_import.db` / `working.db` remain derived graph data.
- Added a reset-service regression test that requires active graph rebuild
  files and retired cleanup files to remain disjoint reset categories.
- Renamed the retained database health query boundary to
  `RetiredCleanupSqliteFileHealthQueryLayer`, making it explicit that direct
  SQLite file inspection is for retired cleanup diagnostics only.
- Changed onboarding graph-projection failure persistence to write the
  graph-named overlay key
  `onboarding_last_graph_projection_result`. The historical
  `onboarding_last_migration_result` key remains readable and clearable only
  as a persisted compatibility fallback.
- Tightened `canonicalLiveChatGraphId` so invalid placeholder ids are
  preserved instead of being packed into graph identity. This keeps source-row
  compatibility normalization aligned with the `SourceScopedRowKey` contract:
  only positive live `chat.db` ROWIDs can be converted to graph ids.
- Moved message URL opening behind `ExternalLinkActions`. Message evidence
  widgets still render tappable URL previews, but external-launch side effects
  now cross the external-links action boundary instead of reading the lower
  level opener service directly. Added provider coverage and an architecture
  tripwire for this boundary.
- Moved native URL-preview metadata loading behind the external-links provider
  boundary. `UrlPreviewWidget` still owns visual loading/fallback/rendering,
  but it no longer instantiates the platform `NativeLinkPreviewService`
  directly. The existing URL-preview architecture tripwire now guards both
  browser-opening and metadata-loading boundaries.
- Added a current `PipelineIncidentStage.graphProjection` value while
  preserving the historical persisted `migration` stage for old overlay rows.
  JSON parsing now keeps old incident records readable without forcing current
  graph-projection incidents to use retired terminology.
- Added an architecture tripwire preventing active `lib/` code from creating
  new `PipelineIncidentStage.migration` incidents outside the logging domain
  compatibility parser.
- Added an architecture tripwire keeping the historical
  `onboarding_last_migration_result` overlay key confined to the onboarding
  failure persistence fallback. Current onboarding failure writes use
  graph-projection terminology.
- Removed direct `importAttachmentId` field reads from
  `AttachmentArchiveService`; the service now asks `ArchiveCompatibilityKey`
  for the semantic live source attachment ROWID when producing labels/log
  context. Stored tuple construction remains inside explicit archive
  compatibility boundaries.
- Renamed cross-snapshot mapped attachment read-model output from
  `currentImportAttachmentId` to `currentAttachmentSourceRowId`. Historical
  archive mapping now exposes current source identity language while
  `ArchiveCompatibilityKey` remains responsible for translating that value to
  the retained overlay archive tuple.
- Cleaned onboarding/reset tests so they reference the source-scoped import
  database filename through the public feature-level boundary instead of
  reaching into `source_scoped_import/infrastructure/import_database_provider`
  solely for constants.
- Added an architecture tripwire preventing onboarding application tests from
  importing source-scoped import infrastructure solely for filename constants.
  They must use the public source-scoped feature-level API, preserving the same
  boundary expected of production onboarding code.
- Clarified graph health diagnostic local naming so retained overlay
  `import_attachment_id` storage is interpreted as an archive compatibility
  attachment id, not current import ownership. Added a matching tripwire
  preventing cross-snapshot mapping read models from regressing to
  `currentImportAttachmentId` terminology.
- Removed the concrete conversation graph database type import from the
  Settings feature-level provider. Settings composition now watches the public
  database provider boundary and passes inferred graph DB values into named
  infrastructure repositories. The Settings graph-read architecture tripwire
  now also guards the feature-level provider against direct concrete graph DB
  imports.
- Added `ArchiveCompatibilityKey.archiveCompatibilityAttachmentId` as the
  semantic name for retained archive tuple attachment identity when code is not
  directly reading or writing the persisted overlay column. Graph health,
  archive file fallback paths, and graph archive candidate lookup now use this
  alias instead of spreading `importAttachmentId` outside schema-facing code.
- Added an architecture tripwire that keeps direct
  `ArchiveCompatibilityKey.importAttachmentId` property reads inside the
  archive compatibility key and schema-facing overlay/archive storage
  repositories. Non-schema graph/archive code must use semantic aliases.
- Clarified current archive documentation and the typed
  `ArchiveCompatibilityKey` comment so archive compatibility lookup is not
  described as retained storage. The retained overlay tuple remains a schema
  compatibility detail, while active graph/archive code talks in terms of the
  typed archive compatibility boundary.
- Clarified archive compatibility architecture-test failure messages so they
  forbid primitive archive key pairs and import-attachment identity leakage
  without implying the typed graph-facing compatibility key is itself retained
  storage.
- Clarified the conversation-graph import-ledger naming tripwire so it
  distinguishes active source-scoped ledger ownership from retired import
  database-file naming, rather than describing a live retained compatibility
  storage subsystem.
- Updated the topology invariant documentation from proof-era shadow
  controller language to the current graph path:
  `chat.db.chat_message_join -> macos_import_ss.chat_to_message ->
  working_ss.chat_to_message`. The invariant now says conversation graph
  projectors own working relationship projection and must preserve
  source-scoped, occurrence-preserving endpoints.
- Updated the message semantic preservation model now that attachment topology
  exists. Attachment presence is documented as derived from
  `message_to_attachment` in graph/query/evidence layers, not fabricated by
  message import and not automatically added as a message-table flag without a
  measured read-model need.
- Updated the `chat_handle_join` source-database note from future-importer
  language to the current graph invariant: chat participant topology is a
  source relationship fact preserved through source-scoped import and projected
  as canonical `chat_to_handle` graph edges.
- Added an architecture tripwire that keeps feature-level source-scoped identity
  conversion centralized in named contact, handle, message-evidence, and
  recovered-message identity helpers. Widgets, repositories, and ad hoc read
  models must not rebuild graph ids directly from retained row ids.
- Added an attachment architecture tripwire that keeps source-scoped graph
  identity reads for archive/recovery inside named attachment infrastructure
  repositories. Attachment widgets and application services must consume typed
  archive/recovery boundaries instead of importing source-scoped identity
  primitives directly.
- Updated the retired incremental-mode flag note so its refresh-contract
  rationale describes old in-flight working-DB readers historically, not as
  current retained readers. Graph streams and explicit data-version signals
  remain the current refresh mechanism.
- Updated `messageDataVersionProvider` documentation to describe explicit
  version bumps rather than provider invalidation, and added an architecture
  tripwire requiring handwritten graph/message refresh code to call the
  notifier `bump()` path instead of directly invalidating the provider.
- Removed stale comments that described graph id normalization as a search
  compatibility path. Search is graph-native; the remaining normalization
  helpers are for explicitly bounded overlay/navigation compatibility inputs.
- Regenerated Riverpod outputs after the message data version documentation
  change so generated provider comments and hashes match current source and
  generator output.
- Clarified graph health status wording from "source-retained rows without
  current topology" to "imported rows without current graph edges" so the dev
  panel describes the graph condition directly rather than implying a separate
  recovery source.
- Clarified the graph recovered-message repository comment with the same
  language: recovered evidence is imported graph messages without current
  conversation edges, not a separate retained-storage read path.
- Updated the overlay independence documentation example so post-write UI
  refresh is routed through a named action boundary instead of demonstrating
  raw provider invalidation in sample code.
- Marked pre-graph manual-handle-linking invalidation examples as retired and
  redirected the notes toward named action/service boundaries plus graph/message
  data-version signals.
- Added an architecture tripwire that scans project instruction docs for
  copyable raw provider-invalidation examples, preserving the current guidance
  that refresh ownership belongs to named action boundaries or explicit
  data-version signals.
- Added a historical-status preface to `99-ROADMAP` so its early
  provider-switch and legacy-UI language is read as superseded by the current
  graph migration docs and execution checklist.
- Updated pipeline invariant and onboarding proposal wording so retired
  `macos_import.db` / `working.db` files are described as cleanup/diagnostic
  storage, not active compatibility databases.
- Centralized contact/handle graph-id conversion behind conversation-graph
  identity helpers. Contact and handle overlay bridges now use those helpers
  instead of importing `SourceScopedRowKey` directly, and the architecture
  tripwire now enforces the stricter boundary.
- Moved message evidence id normalization through the same live-chat graph
  identity boundary. The feature-level source-scoped conversion tripwire now
  allows only recovered-message domain source identity.
- Replaced the placeholder `ContactPickerDialog` widget test with a real
  interaction test that opens the dialog, filters contacts through the provider
  boundary, selects a contact, and verifies the returned participant id.
- Added an architecture tripwire preventing placeholder/no-op test coverage
  from returning (`expect(true, isTrue)`, disabled-test notes, or manual-only
  coverage claims).
- Routed Historical Archives workflow access to `dbMaintenanceLockProvider`
  through the central DB feature boundary, while preserving the guard that
  settings application code must not open graph storage directly. Added a
  tripwire preventing direct imports of the maintenance-lock provider island.
- Removed the last active source comment describing the global messages route
  as ordered by a "global ordinal index". `MessagesSpec.globalTimeline` now
  points at the graph evidence timeline model, and the retired timeline
  tripwire prevents that old ordinal-index phrase from returning in active
  `lib/` code.
- Replaced ambiguous active-source comments that used "old archive pair",
  "old archive key", "old method", or "old spec" with current boundary
  language. Added a targeted architecture tripwire so those shorthand phrases
  do not return to active `lib/` code.
- Extended that exact-phrase cleanup to central retired database filename
  comments and message evidence id normalization comments, replacing "old
  files" / "old live" shorthand with retired-file and older rowid-keyed
  language.
- Renamed onboarding failure-store APIs from import-result / graph-projection-
  result wording to source-import-failure / graph-projection-failure wording.
  The persisted overlay keys remain backward-compatible, but the active
  contract no longer exposes retained result concepts for failure records.
- Added an architecture tripwire preventing those retired onboarding
  failure-store result-style API/class names from returning in active `lib/`
  code.
- Renamed the active Historical Archives panel's private placeholder-named
  button widget to an action-button name. The UI behavior is unchanged, but the
  active presentation code no longer suggests that the real archive workflow
  controls are placeholder scaffolding.
- Renamed the reset service's combined post-reset database inspection list to
  `messageDataResetPostCleanupCheckBaseNames`, preserving the active graph
  derived-file versus retired historical cleanup-file split in code. Reset
  behavior is unchanged; the naming now makes clear that retained
  `macos_import.db` / `working.db` files are only cleanup-check targets.
- Aligned active Historical Archives settings copy with the source-scoped graph
  path. The sidebar and workflow now describe older Messages folders as
  source-scoped import facts projected into the conversation graph and shared
  message evidence surfaces, not as a separate canonical message ledger or
  future-only app visibility path.
- Added an architecture tripwire that prevents retired Historical Archives UI
  wording from returning to active `lib/` code. Banned phrases include
  "canonical ledger", "canonical import", "app-visible data", "normal app
  surfaces", and provider-visible `working.db` wording.
- Normalized Historical Archives workflow phase labels and focused tests to use
  source-scoped import, graph projection, and shared evidence-surface language.
  Internal source-scoped "import ledger" terminology remains valid inside graph
  status/repository boundaries, but user-facing workflow copy no longer implies
  retained `macos_import.db` / `working.db` authority.
- Made the root macOS window delegate lifetime explicit by retaining its
  delegate handle in a named owner instead of suppressing an unused-local
  warning. Removed a stale navigation placeholder-removal comment, and added an
  architecture tripwire preventing hand-written Dart from reintroducing
  `unused_local_variable` ignores.
- Replaced the root window-state background-save silent swallow with a
  structured warning through the app logger. Save failures remain non-fatal,
  but now surface with context instead of disappearing behind imperative
  cleanup behavior.
- Retired an unreferenced `core/extension_methods/datetime_extensions.dart`
  utility after confirming no active imports or extension-member uses remained.
  This removed stale calendar-replacement wording and file-level analyzer
  suppressions from dormant code.
- Removed the remaining root `main.dart` file-level analyzer suppressions by
  deleting a no-op window-resize override and renaming the delegate container
  injection method to an action-shaped `attachContainer` method.
- Replaced sidebar flow preference chain swallow handlers with structured
  app-logger warnings. Contact-context and navigation preference persistence
  remain best-effort, but failed restores or writes are now observable instead
  of disappearing behind empty catches.
- Retired unused root-provider-era sidebar index, boolean dark-mode, color
  watcher, and selected-screen-tag providers after reference scans found no
  active consumers. Removed the old `config/colors.dart` enum surface that was
  only reachable through the retired color watcher, and regenerated Riverpod
  outputs.
- Replaced the message display `MsgTheme` static utility class with named
  shared presentation metrics. Message bubbles, attachment evidence tiles, and
  URL previews still share the same sizing/radius vocabulary, but no longer
  require a hand-written analyzer suppression in active presentation code.
- Replaced the contact handle-filter unlink action's ignored failure branch
  with a structured app-logger warning. The action remains overlay-only and
  success behavior is unchanged, but a failed unlink is now observable instead
  of silently disappearing.
- Broadened the architecture tripwire from unused-local suppressions to all
  analyzer suppressions in active hand-written Dart, excluding generated/FRB
  surfaces. Active code must now fix ownership, derivation, or code shape
  instead of hiding diagnostics with `ignore` comments.
- Added structured logging around the fire-and-forget conversation favourites
  restore path. Favourites remain overlay-owned and optimistic writes still
  flow through the action boundary, but restore failures are now visible
  instead of becoming unobserved async errors.
- Added the same restore discipline to conversation-signature preferences and
  contact-picker filter mode: restore failures are logged, and delayed overlay
  restores cannot overwrite a local user choice made after the controller
  becomes active.
- Added structured logging around contact picker background prewarm failures.
  Contact selection remains non-blocking, but failed profile or message prewarm
  is now visible through the app logger instead of disappearing as an
  unobserved background future.
- Added structured logging around diagnostic group-profile chat-open failures.
  The graph status sheet still forwards selection through the chat action
  boundary, but a failed open no longer disappears as an unobserved background
  future.
- Made on-demand attachment archive attempts explicitly fire-and-forget and
  observable. Attachment resolution still returns promptly, but unexpected
  archive-copy failures now log through the app logger with the typed archive
  compatibility key.
- Made conversation-signature filter/sort persistence failures observable at
  the overlay preference controller boundary. Local sidebar state still updates
  immediately, but failed overlay writes no longer disappear through
  fire-and-forget UI actions.
- Made conversation-favourite persistence failures observable at the global
  user-intent controller boundary. Favourite toggles remain optimistic and
  overlay-owned, but failed overlay writes no longer disappear through
  fire-and-forget star taps.

### Exit Criteria

Done means:

- every deleted system is listed in the dependency matrix or this checklist.
- every preserved system has a current classification.
- no ordinary user-facing read depends on legacy working/import identity.
- legacy import/projection execution is retired; any remaining retired database
  access is explicitly classified as diagnostic, recovery, cleanup, or
  storage-retention infrastructure.

## Update Rule

Update this checklist when:

- a slice starts.
- a slice exits review.
- a blocker is discovered.
- a compatibility bridge is removed.
- a legacy dependency is reclassified.
- tests or smoke steps change.
