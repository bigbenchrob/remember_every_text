---
tier: project
scope: source-scoped-graph-migration
status: active
last_reviewed: 2026-05-31
depends_on:
  - 66-SS-MIGRATION-STRATEGY.md
  - 67-SS-LEGACY-PARITY-AUDIT.md
  - 69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md
  - 70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md
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

## Current Findings - 2026-05-31

1. **No remaining ordinary app-facing `working.db` read was found.**
   Search, contact identity, handle identity, conversation summaries, global
   timelines, contact timelines, and ordinary message evidence now route
   through the graph/evidence spine or graph-backed read models.

2. **The remaining legacy DB references are concentrated in four categories.**
   They are production lifecycle, archive/recovery, diagnostics/settings, and
   legacy database definitions/tests. This means additional deletion should be
   blocker-driven, not opportunistic.

3. **Archive/recovery is now the main semantic blocker.**
   Attachment archive sweeps, deterministic historical recovery, recovered
   deleted messages, and historical archive workflow still use
   `macos_import.db` / `working.db` identity. This is acceptable for now because
   these systems preserve evidence, but it is the next architectural area that
   needs a source-scoped identity plan.

4. **Legacy import/migration is the main lifecycle blocker.**
   The app-facing graph is production-used, but first-run/reimport/live update
   still uses the legacy import and migration pipeline as the upstream source
   before building the graph. This is production lifecycle, not dead code.

5. **Diagnostics intentionally see both worlds.**
   Database health audit, import/migration audit logs, support bundles, and
   historical archive preflights still inspect legacy DBs. These are legitimate
   compatibility/reference uses and should not be confused with ordinary app
   reads.

6. **The old shadow incremental-update package is retired.**
   `lib/essentials/incremental_update/**` and its tests were removed after a
   reachability scan showed no production imports. Its documentation now
   remains only as architecture lineage.

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
| Recovered deleted messages | Legacy recovered-message tables feed the shared evidence spine | Recovery/archive, not ordinary read | Keep until recovered sources are imported into source-scoped graph identity. |

## Production Lifecycle Dependencies

These are not deletion candidates until the graph import/projection lifecycle is
first-class and tested.

| Consumer | Legacy dependency | Current role | Classification | Migration direction |
| --- | --- | --- | --- | --- |
| `lib/essentials/db/feature_level_providers.dart` | Central providers for `macos_import.db`, `working.db`, `working_ss.db`, overlay | Database dependency entry point | Production lifecycle | Keep centralization. Add graph readiness/build semantics here rather than creating provider islands. |
| `lib/essentials/db/feature_level_providers/working_db_populated_provider.dart` | Retired in favor of graph readiness | Former sidebar readiness gate | Deletion candidate closed | Sidebar gating now uses `conversationGraphPopulatedProvider`. |
| `lib/essentials/db/feature_level_providers/working_projection_readiness_provider.dart` | `working.db` readiness | Retained legacy diagnostic and legacy lifecycle gate | Diagnostic/lifecycle compatibility | No longer gates production recovered evidence. Keep only while retained diagnostics and legacy lifecycle still need `working.db` readiness. Do not use as ordinary app readiness. |
| `lib/essentials/db_importers/**` | `macos_import.db` import path | Current production import ledger | Production lifecycle | Treat legacy importers as semantic reference until source-scoped import is fully lifecycle-integrated. |
| `lib/essentials/db_migrate/**` | `working.db` migration path | Current production projection | Production lifecycle | Preserve until graph projection is normal app projection and parity tests pass. |
| `lib/essentials/db_importers/application/monitor/chat_db_change_monitor_provider.dart` | Legacy incremental import trigger plus graph build controller | Live change monitor | Production lifecycle | Keep until source-scoped import/project becomes the production update path. |
| `lib/essentials/onboarding/application/onboarding_gate_provider.dart` | Import/migration control and derived DB cleanup | First-run and reimport lifecycle | Production lifecycle | Graph-aware already; still upstreams through legacy import/migration. |
| `lib/essentials/onboarding/application/database_existence_checker.dart` | `macos_import.db` plus graph readiness | Startup data-state detection | Production lifecycle | Keep until production import ledger is source-scoped. |
| `lib/essentials/onboarding/application/message_data_reset_service.dart` | Legacy and graph derived DB reset behavior | Data reset/maintenance | Production lifecycle | Keep; deliberately handles legacy DBs, graph DBs, and overlay separation. |
| `lib/essentials/onboarding/application/onboarding_environment_report_provider.dart` | Legacy import state plus graph readiness | Environment diagnostics for onboarding | Production lifecycle | Keep; graph readiness is now app-facing readiness. |
| `lib/essentials/db/infrastructure/data_sources/local/working/working_database.dart` | Drift `working.db` schema | Legacy working projection | Production lifecycle | Keep until ordinary reads and lifecycle no longer require `working.db`. |
| `lib/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart` | Sqflite `macos_import.db` schema | Legacy import ledger | Production lifecycle | Keep until source-scoped import ledger replaces production import. |
| `lib/essentials/db_migrate/application/application_providers/supabase_mirror_sync_service_provider.dart` and related Supabase mirror classes | `working.db` projection | External mirror/export path | Production lifecycle or diagnostic integration | Classify before removal; likely retire or rebase after graph lifecycle completion. |

## Recovery and Archive Dependencies

These systems preserve evidence and historical recoverability. Migrate them
after the ordinary graph path is reliable.

| Consumer | Legacy dependency | Current role | Classification | Migration direction |
| --- | --- | --- | --- | --- |
| `lib/features/attachments/application/attachment_archive_service_provider.dart` | `sqfliteImportDatabaseProvider` for current legacy import-batch lifecycle; graph-backed sweep queries; overlay archive records | Continuous attachment archiving and recovery hints | Recovery/archive | Keep graph-backed sweeps. Retire legacy import-batch dependency when source-scoped import becomes the production live-update ledger. Preserve archive overlay as user/evidence state. |
| `lib/features/attachments/application/deterministic_recovery_provider.dart` | `macos_import_ss.db`; `working_ss.db`; overlay archive records | Historical attachment recovery workflow | Recovery/archive | Graph/source-scoped mapper is now used for deterministic recovery. Keep overlay compatibility key until archive rows become graph-keyed or permanently bridged. |
| `lib/features/attachments/application/graph_cross_snapshot_mapper.dart` | Source-scoped import attachment GUIDs and `working_ss.db` topology | Maps recovered Messages snapshots to current graph attachment identity | Recovery/archive | Active deterministic recovery mapper. Preserve overlay archive compatibility key until archive rows become graph-keyed or permanently bridged. |
| `lib/features/messages/infrastructure/repositories/recovered_unlinked_messages_provider.dart` | `working_ss.messages` graph-orphan evidence | Recovered/deleted message review | Recovery/archive | Production recovered evidence is graph-backed. Keep reviewing recovered source/archive identity before deleting retained legacy storage. |
| `lib/features/settings/application/sidebar_cassette_spec/providers/historical_archives_sidebar_known_sources_provider.dart` | Historical archive settings and legacy-backed recovery assumptions | Historical archive source UI | Recovery/archive plus settings | Keep until source-scoped multi-source archive import exists. |
| `lib/features/settings/application/sidebar_cassette_spec/resolvers/message_history_coverage_settings_resolver.dart` | Graph conversation-linked and graph-orphan counts | Coverage settings | Graph-backed settings | Legacy recovered-message count fallback retired. Keep source `chat.db` read as the comparison baseline until source-scoped live import owns the source summary. |
| `lib/features/settings/presentation/view_model/historical_archives_workflow_panel_model_provider.dart` | Historical archive workflow state | Recovery workflow UI | Recovery/archive plus settings | Keep, then rebase on source-scoped archive imports. |
| `lib/features/contacts/infrastructure/repositories/participant_merge_utils.dart` | `WorkingDatabase` helper used only by retained legacy recovered parity diagnostics | Legacy participant-name compatibility helper | Diagnostic compatibility | Retire with retained legacy recovered parity diagnostics. No longer used by production recovered views. |

## Diagnostic and Settings Dependencies

These may continue to read legacy systems as long as they are explicitly
diagnostic/reference and not the ordinary app truth.

| Consumer | Legacy dependency | Current role | Classification | Migration direction |
| --- | --- | --- | --- | --- |
| `lib/essentials/db/application/database_health_audit/**` | `macos_import.db`; `working.db`; source-scoped import; graph; overlay | Phase 1 database health report | Diagnostic/settings | Keep broad inventory while legacy lifecycle/recovery exists. Legacy layers are compatibility/reference, not app truth. |
| `lib/essentials/incremental_update/**` | Shadow import/projection DBs, old shadow update flow | Retired earlier incremental-update research package | Retired | Removed after graph lifecycle replaced the shadow runtime entry points. Historical docs remain as architecture lineage, not active implementation instructions. |
| `lib/essentials/incremental_update_ss/**` | SS proof/dev panel, comparison providers | Source-scoped proof instrumentation | Diagnostic/settings | Keep dev instrumentation, but ensure production graph lifecycle does not depend on manual dev panel actions. |
| `lib/essentials/db_importers/presentation/view_model/db_import_control_provider.dart` and related panels | Legacy import/migration control | Import/migration UI and lifecycle entry | Production lifecycle plus diagnostic/settings | Replace with graph-aware build lifecycle, not with ad hoc dev controls. |
| `lib/essentials/db_migrate/presentation/view/db_migration_panel.dart` | Legacy migration UI | Migration diagnostics | Diagnostic/settings | Keep until legacy migration retires, then delete. |
| `lib/essentials/logging/application/import_audit_writer.dart` and `migration_audit_writer.dart` | Legacy import/migration logs | Audit diagnostics | Diagnostic/settings | Either add graph audit writers or retire with legacy lifecycle. |
| `lib/debug_install/import_log` and `lib/debug_install/migrate_log` | Static/debug logs | Debug artifacts under `lib` | Deletion candidate | Remove if no build/runtime path reads them. |

## Legacy Presentation Consumers

Current branch work has removed or replaced ordinary legacy message
presentation components. The remaining message view that still reads legacy
tables is recovered deleted messages, which is classified as recovery/archive
until recovered sources become source-scoped graph sources.

| Consumer | Current state | Classification | Action |
| --- | --- | --- | --- |
| `lib/features/messages/application/view_spec/widget_builders/messages_for_handle_builder.dart` | Routes handle messages into graph evidence view | Ordinary user-facing read, graph-backed | Keep. Ensure input identity becomes graph-native rather than legacy bridged. |
| `lib/features/messages/application/view_spec/widget_builders/global_timeline_builder.dart` | Routes global messages to graph evidence view | Ordinary user-facing read, graph-backed | Keep. Verify global scope no longer depends on legacy heatmap/index after migration. |
| `lib/features/messages/application/view_spec/widget_builders/messages_for_contact_builder.dart` | Routes contact messages to graph evidence view | Ordinary user-facing read, graph-backed | Keep. Remove legacy fallback after graph contact scope is stable. |
| `lib/features/messages/application/view_spec/widget_builders/recovered_unlinked_messages_builder.dart` | Routes recovered messages to evidence view | Recovery/archive | Keep, but document recovery-specific data source until graph archive import exists. |

## Deletion Candidates

Deletion candidates should not be removed merely because they look old. Remove
only after `rg` reference checks, focused tests, and graph replacement coverage.

| Candidate | Evidence | Classification | Action |
| --- | --- | --- | --- |
| Legacy chat repository/timeline scaffolds and old message timeline/ordinal/hydration widgets | Removed in current branch; no active imports found in fresh scan | Deletion candidate closed | Keep closed; ordinary chat/message presentation is graph/evidence-spine based. |
| `lib/debug_install/import_log` and `lib/debug_install/migrate_log` | Debug artifacts under production `lib` tree | Deletion candidate | Delete if unused and not intentionally packaged as fixtures. |
| Tests that instantiate `WorkingDatabase` solely for legacy migrators/importers | Test-only coverage of retained lifecycle/recovery code | Not production blocker | Keep while corresponding lifecycle/recovery code exists. Delete with the code they cover. |

## High-Danger Areas

### Recovery and Attachment Archive

Historical recovery depends on old import/working identity. This is acceptable
for now because recovery is a data-integrity subsystem, but it should not
become the model for ordinary graph evidence. This is now the main remaining
semantic blocker.

### Legacy Import/Migration Lifecycle

The app can now display graph-backed evidence well, but lifecycle still knows
legacy import/projection best. Current production graph builds are triggered
after legacy import/migration succeeds. Retiring `working.db` requires a
source-scoped production import/project lifecycle, not more UI cleanup.

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

3. **Productionize source-scoped import/project lifecycle.**
   Onboarding, reset, readiness, live updates, and message data invalidation
   already understand graph readiness, but upstream import/projection still
   depends on legacy DBs.

4. **Classify or retire Supabase mirror and remaining legacy diagnostics.**
   These should not block ordinary app graph usage, but they must not be
   mistaken for production graph requirements.

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
