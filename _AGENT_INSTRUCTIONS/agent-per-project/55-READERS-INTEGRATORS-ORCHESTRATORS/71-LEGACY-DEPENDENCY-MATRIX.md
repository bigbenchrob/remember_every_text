---
tier: project
scope: source-scoped-graph-migration
status: active
last_reviewed: 2026-06-06
depends_on:
  - 66-SS-MIGRATION-STRATEGY.md
  - 67-SS-LEGACY-PARITY-AUDIT.md
  - 69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md
  - 70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md
  - 81-LEGACY-STORAGE-RETENTION-REGISTER.md
---

# 71 - Legacy Dependency Matrix

## Purpose

This document inventories remaining `working.db`, `macos_import.db`, legacy
repository, and legacy presentation dependencies after the graph migration work
crossed from proof stage into production-spine migration.

This is a safety tool. It exists to prevent two opposite mistakes:

- deleting legacy systems that still own production lifecycle or recovery
  behavior
- keeping ordinary user-facing reads on legacy identity after graph equivalents
  exist

Legacy parity does not mean field parity. The goal is to preserve semantic
behavior, data integrity, lifecycle reliability, and investigative capability
while moving ordinary app reads to the source-scoped conversation graph.

## Classification Key

Every remaining dependency should be classified as one of:

- **Ordinary user-facing read**: a normal app view or provider still reads
  `working.db` / `macos_import.db` to show user-facing data.
- **Production lifecycle**: import, migration, onboarding, reset, readiness,
  monitoring, or projection code still required to build or maintain app data.
- **Recovery/archive**: attachment archive, historical recovery, recovered
  message, or cross-snapshot behavior. These are data-integrity systems and
  should not be deleted casually.
- **Diagnostic/settings**: health reports, dev panels, migration panels,
  comparison reports, or settings tools.
- **Deletion candidate**: code that appears unused or superseded and should be
  removed only after references and tests are checked.

Compatibility bridges are recorded inside the closest category. For example,
a graph repository that reads legacy handle aliases to support a graph-facing
view is an ordinary user-facing read dependency with bridge semantics.
Graph/legacy overlay key translation is centralized in
`lib/essentials/conversation_graph/application/identity/retained_overlay_identity_bridge.dart`;
feature repositories should consume those typed key variants rather than
duplicating source-scoped pack/unpack compatibility math. The bridge currently
covers contact ids, handle ids, and live `chat.db` message rowids used by
message overlay fallback and bounded-search context anchoring.

## Current Findings - 2026-06-06

Fresh retention-oriented scans on 2026-06-06 confirmed the June 4 conclusion:
no ordinary app-facing feature/read surface was found opening retained legacy
`working.db` / `macos_import.db` providers. A later cleanup slice removed the
central retained `working.db` provider entirely; retained `working.db` now
exists only as file/schema storage for reset, diagnostics, and eventual storage
retirement review.

The remaining direct legacy provider/database usages are now explicitly
classified:

- retained archive-compatible import/projection execution
- historical archive settings workflow
- onboarding reset / derived-data maintenance
- database health and support diagnostics
- retained import database schema tests
- source-scoped graph import/projectors using the graph-era
  `ImportDatabase` provider, not the retained legacy import DB

This means the next retirement step is not ordinary UI migration. It is
storage-retention review: decide which retained DB files, schema references, and
tests must remain for archive/recovery compatibility and which can be deleted
only after that compatibility is replaced or intentionally abandoned.

See `81-LEGACY-STORAGE-RETENTION-REGISTER.md` for the removal criteria for
each retained storage bucket.

## Current Findings - 2026-06-04

1. **No remaining ordinary app-facing `working.db` read was found.**
   Search, contact identity, handle identity, conversation summaries, global
   timelines, contact timelines, and ordinary message evidence now route
   through the graph/evidence spine or graph-backed read models.

   Fresh scans on 2026-06-02 and 2026-06-04 found the remaining tracked legacy
   references concentrated in retained lifecycle, archive/recovery,
   diagnostics/settings, legacy database definitions, and tests for retained
   systems.

   The 2026-06-04 direct-provider scan found no ordinary feature/read surface
   opening the retained working/import providers. The retained working provider
   was later removed; remaining retained import provider reads are historical
   archive settings metadata, onboarding reset/maintenance, and retained import
   schema/tests.

2. **The remaining legacy DB references are concentrated in four categories.**
   They are production lifecycle, archive/recovery, diagnostics/settings, and
   legacy database definitions/tests. This means additional deletion should be
   blocker-driven, not opportunistic.

3. **Archive/recovery is now the main semantic blocker.**
   Attachment archive lifecycle, deterministic historical recovery, and
   historical archive workflow still use legacy import/working identity in
   specific compatibility paths. Recovered deleted-message presentation is now
   graph-backed, and its retained parity diagnostic bridge has been retired.
   Recovery systems preserve evidence, so remaining legacy references need
   source-scoped identity plans rather than opportunistic deletion.

4. **Legacy import/migration is no longer the app-facing lifecycle path.**
   Live update, first-run onboarding, and settings-triggered reimport now build
   the source-scoped graph directly. Remaining legacy import/migration
   references are retained lifecycle, archive/recovery, diagnostics/settings,
   schema, and test references. Treat them as compatibility/reference systems,
   not ordinary production evidence authority.

5. **Diagnostics intentionally see both worlds.**
   Database health audit, import/migration audit logs, support bundles, and
   historical archive preflights still inspect retained DB files. These are
   legitimate compatibility/reference uses and should not be confused with
   ordinary app reads.

6. **The old shadow incremental-update package is retired.**
   `lib/essentials/incremental_update/**` and its tests were removed after a
   reachability scan showed no production imports. Its documentation now
   remains only as architecture lineage.

7. **A stale contacts essentials template stub was retired.**
   `lib/essentials/contacts/feature_level_providers.dart` contained only
   commented example/Supabase template code and had no imports. Active contacts
   providers live under `lib/features/contacts/feature_level_providers.dart`.

## Ordinary User-Facing Reads

Fresh scan status: **closed for known `working.db` / `macos_import.db`
consumers**.

| Surface | Current state | Classification | Notes |
| --- | --- | --- | --- |
| Search All / scoped search / saved-tag search | Graph search returns graph `message_ss_id` scopes | Graph-backed ordinary read | Legacy search indexers and legacy-ID APIs have been removed. |
| Contact picker, hero, profile, handle selector | Graph contacts/handles plus overlay intent | Graph-backed ordinary read | User override wins; raw handles remain explicit metadata/fallback only. |
| Conversation sidebar/signatures | Graph conversation summaries | Graph-backed ordinary read | No legacy recent-chat fallback remains in product providers. |
| Global/contact/handle/conversation message evidence | Message Evidence Spine over graph scopes | Graph-backed ordinary read | Timeline-like scopes use full graph skeletons; hydration is windowed. |
| Global/contact heatmaps | Graph timeline data only | Graph-backed ordinary read | Legacy `global_message_index` / `contact_message_index` fallback retired. |
| Unfamiliar sources / manual linking / spam management | Graph canonical handles plus overlay intent | Graph-backed settings/user-facing read | Overlay writes remain overlay-only. |
| Recovered deleted messages | Graph orphan evidence feeds the shared evidence spine | Graph-backed recovery/archive read | Retained legacy parity diagnostics retired; legacy recovered storage remains only as historical data until retained storage retirement. |

## Production Lifecycle Dependencies

These are not deletion candidates until the graph import/projection lifecycle is
first-class and tested.

| Consumer | Legacy dependency | Current role | Classification | Migration direction |
| --- | --- | --- | --- | --- |
| `lib/essentials/db/feature_level_providers.dart` | Central providers for `macos_import.db`, `working.db`, `working_ss.db`, overlay | Database dependency entry point | Production lifecycle | Keep centralization. Add graph readiness/build semantics here rather than creating provider islands. |
| `lib/essentials/db/feature_level_providers/working_db_populated_provider.dart` | Retired in favor of graph readiness | Former sidebar readiness gate | Deletion candidate closed | Sidebar gating now uses `conversationGraphPopulatedProvider`. |
| `lib/essentials/db/feature_level_providers/working_projection_readiness_provider.dart` | Retired | Former `working.db` readiness gate | Deletion candidate closed | Removed. Retained diagnostics now report legacy recovered evidence unavailability directly instead of using a central `working.db` readiness provider. |
| `lib/essentials/db_migrate/infrastructure/repositories/drift_legacy_projection_status_repository.dart` | Retired | Former ad hoc “does legacy working.db have messages?” readiness check | Deletion candidate closed | Removed after onboarding/readiness moved to source-scoped graph readiness. The later retained archive pipeline and its private legacy rebuild check have also been retired; graph readiness is the app-facing readiness boundary. |
| `lib/essentials/db_migrate/application/migrators/app_settings_migrator.dart` and empty `domain/policies/migration_order_policy.dart` | Retired | Unimplemented/empty migration scaffolding | Deletion candidate closed | Removed because they had no callers and were not part of any retained compatibility boundary. |
| `lib/essentials/db_importers/**` | Retired folder | Former mixed import/extractor/monitor/debug location | Deletion candidate closed | Removed. Source-scoped extractor/provider ownership moved to `lib/essentials/source_scoped_import/`; live `chat.db` monitoring moved to `lib/essentials/conversation_graph/application/monitor/`; retained DB debug settings moved to `lib/essentials/db/application/`. Architecture tests fail if the retired folder returns. |
| `lib/essentials/db_importers/application/services/retained_legacy_archive_pipeline_provider.dart` | Retired | Former retained diagnostic import-control bridge | Deletion candidate closed | Removed after Historical Archives import/removal moved to source-scoped graph services and import-control stopped offering legacy import execution. |
| `lib/essentials/db_importers/application/services/orchestrated_ledger_import_service.dart` | Retired | Former high-level retained `macos_import.db` import orchestrator | Deletion candidate closed | Removed after live, onboarding, settings, and Historical Archives paths all moved to source-scoped graph import/projection. Source-scoped rich-text enrichment now uses `sourceScopedMessageExtractorProvider` from `source_scoped_import`. |
| `lib/essentials/db_importers/application/importers/**`, `lib/essentials/db_importers/infrastructure/sqlite/importers/**`, and old `ImportOrchestrator`/`IImportContext` framework | Retired | Former retained table-importer implementation details | Deletion candidate closed | Removed after the old ledger orchestrator was deleted and caller scans confirmed no active runtime path. Source-scoped importers now own graph facts directly; contact import uses shared handle normalization instead of the old importer utility wrapper. |
| `lib/essentials/db_migrate/**` | Retired | Former retained `working.db` projection execution stack | Deletion candidate closed | Removed after Historical Archives import/removal moved to source-scoped graph services, old legacy import/projection execution was retired, and caller scans confirmed no active production owner. Retained `working.db` schema/provider remains a separate storage-retirement question. |
| `lib/essentials/conversation_graph/application/monitor/chat_db_change_monitor_provider.dart` | Source-scoped graph build controller plus graph attachment archive source-row range | Live change monitor | Production lifecycle | Keep as live source detector. Live polling now builds the app-facing graph and archives graph source-row ranges; it no longer runs legacy import/migration maintenance. |
| `lib/essentials/db_importers/application/services/legacy_compatibility_maintenance_service.dart` | Retired | Former live-update legacy import/migration tail | Deletion candidate closed | Removed after live polling proved graph import/projection plus graph attachment archiving as the production update path. |
| `lib/essentials/onboarding/application/onboarding_gate_provider.dart` | Source-scoped graph build controller; derived-data reset through centralized lifecycle boundaries; graph-build failure recorded in overlay failure state | First-run and settings reimport lifecycle | Production lifecycle | Keep. First-run onboarding and settings reimport now build the graph directly and no longer invoke the retained legacy import/migration control path. Graph-build failures are persisted as onboarding semantic failures rather than legacy migration result entities. |
| `lib/essentials/onboarding/application/database_existence_checker.dart` | Legacy compatibility DB probes plus graph readiness | Startup data-state detection | Production lifecycle | Keep while startup must distinguish retained legacy compatibility data from graph readiness. Ordinary app readiness should remain graph-first. |
| `lib/essentials/onboarding/application/message_data_reset_service.dart` | Legacy and graph derived DB reset behavior | Data reset/maintenance | Production lifecycle | Keep; deliberately handles legacy DBs, graph DBs, and overlay separation. |
| `lib/essentials/onboarding/application/onboarding_environment_report_provider.dart` | Source probes, source-scoped import/graph readiness, overlay onboarding failure summaries | Environment diagnostics for onboarding | Production lifecycle | Keep; graph readiness is now app-facing readiness. The report consumes onboarding-owned failure summaries, not legacy import/migration result entities. |
| `lib/essentials/db/infrastructure/data_sources/local/working/working_database.dart` | Retired Drift `working.db` schema | Deletion candidate closed | No production blocker | Removed after the central retained working provider was retired and scans confirmed no app code instantiates `WorkingDatabase`. Existing `working.db` files may still exist in user data folders and can be deleted by reset or inspected read-only by diagnostics. |
| `lib/essentials/db/infrastructure/data_sources/local/import/retained_archive_metadata_database.dart` | Retained `macos_import.db` archive metadata schema | Transitional compatibility metadata storage | Archive-source workflow metadata plus retained-file reset/storage compatibility | Source-scoped import is the ordinary production ledger. Keep this concrete adapter only behind the central DB provider. Feature infrastructure should depend on `RetainedArchiveMetadataStore`, not the adapter class. Do not add ordinary import-ledger helpers here. Full removal requires the retained-storage criteria in Document 81. |
| Supabase mirror runtime/service/provider/repository/migrator stubs | Retired | Former external mirror/export path | Deletion candidate closed | Removed after reference scan confirmed no active caller and the service was stub-only. Legacy `working.db` Supabase table definitions remain until the retained `working.db` schema itself is retired, avoiding schema churn for no product gain. |

## Recovery and Archive Dependencies

These systems preserve evidence and historical recoverability. Migrate them
after the ordinary graph path is reliable.

| Consumer | Legacy dependency | Current role | Classification | Migration direction |
| --- | --- | --- | --- | --- |
| `lib/features/attachments/application/attachment_archive_service_provider.dart` | Graph source-range archiving; graph-backed sweep queries; overlay archive records keyed with legacy-compatible `(message_guid, import_attachment_id)` pairs | Continuous attachment archiving and recovery hints | Recovery/archive | Legacy import-batch archiving is retired. Preserve archive overlay compatibility keys until archive rows become graph-keyed or permanently bridged. |
| `lib/features/attachments/application/deterministic_recovery_provider.dart` | `macos_import_ss.db`; `working_ss.db`; overlay archive records | Historical attachment recovery workflow | Recovery/archive | Graph/source-scoped mapper is now used for deterministic recovery. Keep overlay compatibility key until archive rows become graph-keyed or permanently bridged. |
| `lib/features/attachments/application/graph_cross_snapshot_mapper.dart` | Source-scoped import attachment GUIDs and `working_ss.db` topology | Maps recovered Messages snapshots to current graph attachment identity | Recovery/archive | Active deterministic recovery mapper. Preserve overlay archive compatibility key until archive rows become graph-keyed or permanently bridged. |
| Old `lib/features/attachments/domain/entities/attachment.dart`, `AttachmentId`, and `AttachmentStatus` model | Retired | Former generic Freezed attachment entity/value object | Deletion candidate closed | Removed after reference scans confirmed active attachment behavior uses graph attachment evidence, archive rows, `AttachmentInfo`, and `ResolvedAttachment`. Archive/recovery services remain retained. |
| `lib/features/messages/infrastructure/repositories/recovered_unlinked_messages_provider.dart` | `working_ss.messages` graph-orphan evidence | Recovered/deleted message review | Recovery/archive | Production recovered evidence is graph-backed. Keep reviewing recovered source/archive identity before deleting retained storage. |
| `lib/features/settings/infrastructure/repositories/historical_archive_sources_repository.dart` | `macos_import.db.historical_archive_sources` compatibility metadata through `RetainedArchiveMetadataStore` | Historical archive source UI | Recovery/archive plus settings | Keep as a quarantined archive-source bridge until source-scoped multi-source archive import owns archive-source metadata. Application/sidebar code consumes typed metadata, not the retained DB record or concrete adapter. |
| `lib/features/settings/application/sidebar_cassette_spec/resolvers/message_history_coverage_settings_resolver.dart` | Graph conversation-linked and graph-orphan counts | Coverage settings | Graph-backed settings | Legacy recovered-message count fallback retired. Keep source `chat.db` read as the comparison baseline until source-scoped live import owns the source summary. |
| `lib/features/settings/presentation/view_model/historical_archives_workflow_panel_model_provider.dart` | Historical archive workflow state; source-scoped archive import/removal services; conversation graph dry-run duplicate estimates; retained metadata bridge | Recovery workflow UI | Recovery/archive plus settings | Keep. Forward import and removal now use source-scoped archive graph services. Retained `macos_import.db` use is limited to archive-source metadata until that metadata gets a source-scoped home. |

## Diagnostic and Settings Dependencies

These may continue to read legacy systems as long as they are explicitly
diagnostic/reference and not the ordinary app truth.

| Consumer | Legacy dependency | Current role | Classification | Migration direction |
| --- | --- | --- | --- | --- |
| `lib/essentials/db/application/database_health_audit/**` | `macos_import.db`; `working.db`; source-scoped import; graph; overlay | Phase 1 database health report | Diagnostic/settings | Keep broad inventory while legacy lifecycle/recovery exists. Legacy layers are compatibility/reference, not app truth. |
| `lib/essentials/incremental_update/**` | Shadow import/projection DBs, old shadow update flow | Retired earlier incremental-update research package | Retired | Removed after graph lifecycle replaced the shadow runtime entry points. Historical docs remain as architecture lineage, not active implementation instructions. |
| `lib/essentials/incremental_update_ss/**` | Retired proof folder | Former source-scoped proof instrumentation | Deletion candidate closed | Remaining waveform diagnostics moved under `conversation_graph` ownership. Production graph lifecycle does not depend on manual dev panel actions. |
| `lib/essentials/db_importers/presentation/view_model/db_import_control_provider.dart` and related panels | Retired | Former legacy import/progress/maintenance panel | Deletion candidate closed | Removed after reset/clear ownership moved to `MessageDataResetService`, onboarding/dev controls, and sidebar action dispatch. The `ViewSpec.import` route and `ImportSpec` tag are also retired. |
| `lib/essentials/db_migrate/presentation/view/db_migration_panel.dart` | Retired | Former standalone legacy migration UI | Deletion candidate closed | Removed after graph lifecycle became app-facing production build path and onboarding/settings reimport were moved to direct graph builds. |
| `lib/essentials/logging/application/import_audit_writer.dart` and `migration_audit_writer.dart` | Retired | Former legacy import/projection audit writers | Deletion candidate closed | Removed after old import/projection execution was retired. Support bundles may still attach historical `import_log` / `migrate_log` files if they exist in older data folders, but no active writer produces them. |
| `PipelineIncidentStage.migration` | Persisted overlay incident stage value | Retained compatibility incident identity | Diagnostic/settings compatibility | Keep enum storage value for backward compatibility, but display it as “Retained historical projection” so user-facing language does not imply the app-facing graph lifecycle is legacy migration. |
| `lib/debug_install/*` | Retired static/debug logs | Debug artifacts under `lib` | Deletion candidate closed | Removed after reference scan confirmed no build/runtime path reads them. Runtime logs remain in Application Support / `~/Library/Logs` paths. |
| Retained recovered parity diagnostic bridge | Retired | Former `working.db.recovered_unlinked_*` comparison path | Deletion candidate closed | Removed after production recovered evidence cutover and user acceptance of the remaining legacy-only retention caveats. |

## Legacy Presentation Consumers

Current branch work has removed or replaced ordinary legacy message
presentation components. Recovered deleted messages now route through graph
orphan evidence and the shared Message Evidence Spine. Legacy recovered tables
remain only as historical storage inside retained DB files until broader storage
retirement.

| Consumer | Current state | Classification | Action |
| --- | --- | --- | --- |
| `lib/features/messages/application/view_spec/widget_builders/messages_for_handle_builder.dart` | Routes handle messages into graph evidence view | Ordinary user-facing read, graph-backed | Keep. Ensure input identity becomes graph-native rather than legacy bridged. |
| `lib/features/messages/application/view_spec/widget_builders/global_timeline_builder.dart` | Routes global messages to graph evidence view | Ordinary user-facing read, graph-backed | Keep. Global scope uses graph timeline/evidence data; legacy heatmap/index fallback is retired. |
| `lib/features/messages/application/view_spec/widget_builders/messages_for_contact_builder.dart` | Routes contact messages to graph evidence view | Ordinary user-facing read, graph-backed | Keep. Contact scope uses graph timeline/evidence data; legacy fallback is retired. |
| `lib/features/messages/application/view_spec/widget_builders/recovered_unlinked_messages_builder.dart` | Routes graph-orphan recovered messages to evidence view | Recovery/archive, graph-backed | Keep. Recovered source folders still need a future source-scoped import strategy, but production recovered evidence no longer reads legacy recovered tables. |

## Deletion Candidates

Deletion candidates should not be removed merely because they look old. Remove
only after `rg` reference checks, focused tests, and graph replacement coverage.

| Candidate | Evidence | Classification | Action |
| --- | --- | --- | --- |
| Legacy chat repository/timeline scaffolds and old message timeline/ordinal/hydration widgets | Removed in current branch; no active imports found in fresh scan | Deletion candidate closed | Keep closed; ordinary chat/message presentation is graph/evidence-spine based. |
| `lib/debug_install/*` | Removed after reference scan found only documentation references | Deletion candidate closed | Keep closed; static debug output does not belong under production `lib`. |
| Unused `lib/essentials/contacts/domain/entities/` contact aggregate/value-object files | Removed after reference scan found no runtime imports. The later scan also removed unused `ContactId` / `MessageId` Freezed value objects and their unreferenced JSON converters; graph/contact/message identity is now expressed by source-scoped integer ids and typed graph/evidence read models. | Deletion candidate closed | Keep closed; graph contact summaries, message evidence scopes, and overlay identity resolvers own production identity/display behavior. |
| Unused `ManualHandleLink` domain entity | Removed after reference scan found no runtime imports. Manual linking is now service-owned and graph/overlay read-model backed. | Deletion candidate closed | Keep closed; do not recreate a separate manual-link aggregate unless a real domain behavior requires it. |
| Empty repository-interface stubs in retired feature/domain shells | Removed after reference scan found no runtime imports for the generic `i_repositories/repository_interface.dart` placeholders under contacts essentials, database domain, attachments, handles, and reactions. | Deletion candidate closed | Keep closed; real repository contracts now live at named graph/search/archive/evidence boundaries rather than empty DDD templates. |
| Unused reactions feature shell | Removed after reference scans found no imports of `lib/features/reactions/feature_level_providers.dart`, `Reaction`, `ReactionId`, or `ReactionKind`. Retained legacy reaction tables/migrators and graph message semantic fields remain separate. | Deletion candidate closed | Keep reaction semantic preservation in message import/projection and retained legacy schemas. Do not recreate a reactions feature/domain model until reactions become an app-facing graph feature. |
| Placeholder cross-surface feature coordinator shells | Removed unused "coming soon" feature-level providers for attachments/chats and the unreferenced handles ViewSpec coordinator after reference scans found only placeholder tests. | Deletion candidate closed | Keep active attachment archive, chat/conversation, and handle settings/read paths in their real application/infrastructure files. Reintroduce public feature barrels only when they export actual spec/coordinator behavior. |
| Superseded handle placeholder cassette branch | Removed old `unmatchedHandlesList`, `strayPhoneNumbers`, and `strayEmails` cassette variants plus placeholder payload/resolver/widget files. | Deletion candidate closed | Keep the current unified handle triage flow: info card -> type switcher -> mode switcher -> `strayHandlesReview`. |
| Unreachable handles settings cassette shell | Removed the unreferenced `HandlesSettingsSpec` coordinator, inert manual-link/spam payload resolvers, and placeholder settings widgets. Reference scan found no sidebar topology or runtime caller; current handle work is the unified triage flow and graph/overlay operation providers. | Deletion candidate closed | Keep the semantic manual-link/spam providers until their future product role is decided, but do not recreate a separate handles settings cassette shell without an actual settings route. |
| Duplicate chats heatmap timeline model | Removed `features/chats/domain/calendar_heatmap_timeline_data.dart` and the always-null `RecentChatSummary.calendarHeatmapTimelineData` field. Production heatmap/timeline data lives under the message evidence/sidebar heatmap path. | Deletion candidate closed | Keep conversation-browser summaries lean; do not add a second timeline model under `features/chats` unless it is populated and rendered by a real graph read surface. |
| Old AddressBook folder presentation widgets/view model, candidate-selection providers, duplicate data source, and obsolete failure wrappers | Removed `features/address_book_folders/presentation/**`, unused `AddressBookFolderListDataSource`, `BadAddresses`, `ChosenAddressFolderPathRepository`, `FolderAggregateRepository`, unreferenced `AddressBookFolderFailure.folderFavouriteNotStored`, and the generic `more_failures/Failure` Freezed union after reference scans found no active imports for its unused variants. | Deletion candidate closed | Keep `futureGetFolderAggregateProvider`, active `FolderRetrievalFailure`, domain entities, `AddressBookFolderPathsFinder`, and `AddressBookFolderRepository`. AddressBook path resolution remains required by onboarding and source-scoped contact import. Existing stored folder preference key remains readable for compatibility. |
| Tests that instantiate or parse `WorkingDatabase` solely for legacy schema coverage | Retired | Deletion candidate closed | Removed with the retained Drift schema implementation. Retained `working.db` is now file-level storage only, not an app schema surface. |

## High-Danger Areas

### Recovery and Attachment Archive

Historical recovery depends on old import/working identity. This is acceptable
for now because recovery is a data-integrity subsystem, but it should not
become the model for ordinary graph evidence. This is now the main remaining
semantic blocker.

### Retained Legacy Import/Migration Compatibility

Ordinary app lifecycle is now graph-first: onboarding, settings reimport, and
live `chat.db` polling build the source-scoped graph directly. Remaining legacy
import/migration code is retained for archive-compatible rebuilds, diagnostics,
legacy schema storage, and tests for those retained systems. Retiring
`working.db` now depends primarily on archive/recovery identity closure, not
ordinary UI cleanup or live-update migration.

### Diagnostic Code Becoming Production Truth

The SS proof panels and comparison reports are useful, but they must not become
the only way graph build runs. Production lifecycle belongs in central database
and orchestration providers.

## Recommended Migration Order

1. **Checkpoint current graph migration work.**
   Run analyzer and focused graph/evidence/contact tests before further
   deletion.

2. **Plan archive/recovery source-scoped identity.**
   This is the main remaining semantic blocker. Existing archives must remain
   resolvable while recovered sources gain graph identity.

3. **Retire retained legacy compatibility deliberately.**
   Onboarding, reset, readiness, live updates, and message data invalidation now
   use the graph lifecycle. Remaining legacy import/projection references should
   be removed only when archive/recovery and retained diagnostics no longer need
   legacy `working.db` identity.

4. **Classify or retire remaining legacy diagnostics.**
   Supabase mirror runtime stubs have been retired. Remaining diagnostics
   should not block ordinary app graph usage, but they must not be mistaken for
   production graph requirements.

5. **Retire legacy import/projection after blockers close.**
   Delete `macos_import.db` / `working.db` systems only after recovery/archive
   and lifecycle have source-scoped replacements or explicit preservation
   decisions.

7. **Delete legacy scaffolds and retired renderers only after matrix rows are
   closed.**
   Deletion should follow evidence, not optimism.

## Tests Needed Before Retiring Legacy Reads

- Graph search returns graph `ss_id` scopes for global, contact, conversation,
  handle, and saved/tagged searches.
- Contact list/profile/handle menu can be built from graph facts plus overlay
  only.
- User display-name override wins across contact picker, hero card,
  conversation titles, sender labels, and search results.
- Global heatmap uses a full graph skeleton, not pagination.
- Conversation/contact/handle/global message evidence all use the same evidence
  spine.
- Graph build imports and projects one new live message without manual dev-panel
  intervention.
- Reset and onboarding explicitly handle source-scoped import DB and graph DB.
- Recovery/archive workflows remain intact or are explicitly marked legacy
  recovery-only.

## Retirement Rule

No remaining `working.db` or `macos_import.db` consumer should be removed until
it is either:

1. replaced by graph/source-scoped behavior with tests,
2. explicitly demoted to diagnostic/reference behavior, or
3. proven unused and listed as a deletion candidate here.

This matrix should be updated whenever a legacy dependency is removed,
reclassified, or intentionally preserved.
