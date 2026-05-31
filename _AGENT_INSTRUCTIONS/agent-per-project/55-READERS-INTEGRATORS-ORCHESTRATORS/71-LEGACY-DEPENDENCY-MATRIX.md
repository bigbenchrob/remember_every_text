---
tier: project
scope: source-scoped-graph-migration
status: active
last_reviewed: 2026-05-30
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

## Immediate Findings

1. **Search is the highest-risk ordinary read still shaped by legacy IDs.**
   `SearchService` still resolves result identity through `working.db`
   `messages`, `messages_fts`, `contact_message_index`, and saved GUIDs.
   This creates the clearest split-brain risk because search selects evidence.

2. **Contact identity is still partially legacy-backed.**
   Several contact/profile/handle providers still resolve participant and
   handle identity through `working.db` and overlay merges. This must migrate to
   graph facts plus overlay intent, preserving user override precedence.

3. **Graph evidence views still contain deliberate legacy bridges.**
   The graph repositories use legacy `handle_to_participant` and
   `handles_canonical_to_alias` semantics to map legacy contact/handle selection
   into graph `ss_id` scopes. These bridges are acceptable temporarily, but
   should disappear once graph contact identity is first-class.

4. **Lifecycle is not graph-first yet.**
   Onboarding, import control, migration, readiness, change monitoring, and
   reset still center on `macos_import.db` and `working.db`. This code is
   production lifecycle, not deletion material.

5. **Recovery/archive dependencies are legitimate and should be slowed down.**
   Historical attachment recovery and recovered message review still depend on
   legacy import/working data. They should migrate after ordinary graph paths
   and graph lifecycle are reliable.

6. **Legacy message presentation is mostly retired in the current worktree.**
   The dangerous leftover category is no longer old bubble widgets so much as
   legacy data selection feeding graph evidence surfaces.

## Ordinary User-Facing Reads

| Consumer | Legacy dependency | Current role | Classification | Migration direction |
| --- | --- | --- | --- | --- |
| `lib/essentials/search/application/search_service.dart` | `driftWorkingDatabaseProvider`; `workingMessages`; `messages_fts`; `contact_message_index`; saved GUID lookup | Search All Messages, scoped search, saved-message filtering | Ordinary user-facing read | Build graph-native search that returns graph `ss_id` evidence scopes. Keep tag/saved overlay semantics, but map them through graph identity. |
| `lib/essentials/search/feature_level_providers.dart` and `lib/essentials/search/indexing/search_indexer.dart` | `WorkingDatabase` search index context | Search indexing lifecycle | Ordinary user-facing read plus lifecycle | Replace or supplement with graph-backed search index. Do not keep search result identity on legacy IDs. |
| `lib/features/messages/application/sidebar_cassette_spec/resolver_tools/global_messages_heatmap_provider.dart` | `global_message_index` in `working.db` | Global message heatmap / global message evidence selection | Ordinary user-facing read | Replace with graph full-scope skeleton and graph month counts. |
| `lib/features/messages/application/sidebar_cassette_spec/resolver_tools/contact_timeline_provider.dart` | Graph-first, but falls back to `contact_message_index` in `working.db` | Contact all-messages heatmap and skeleton | Ordinary user-facing read with compatibility fallback | Remove fallback only after graph contact identity and graph timeline tests cover full selected scopes. |
| `lib/essentials/conversation_graph/application/contacts/contact_graph_provider.dart` and `lib/essentials/conversation_graph/infrastructure/repositories/contact_graph_repository.dart` | `driftWorkingDatabaseProvider`; `handle_to_participant`; `handles_canonical_to_alias` | Converts legacy contact/handle selection into graph handle scopes | Ordinary user-facing read compatibility bridge | Replace with graph-native contact identity and graph contact-to-handle associations. |
| `lib/essentials/conversation_graph/application/messages/message_graph_reader_provider.dart` and `lib/essentials/conversation_graph/infrastructure/repositories/message_graph_repository.dart` | `driftWorkingDatabaseProvider`; legacy canonical handle alias lookup | Handle-scoped message evidence and bridge selection | Ordinary user-facing read compatibility bridge | Pass graph handle/canonical handle identity directly from callers. Keep bridge until handle selectors are graph-native. |
| `lib/features/contacts/infrastructure/repositories/contacts_list_repository.dart` | `workingParticipants`; `handlesCanonical`; `handleToParticipant`; `workingMessages`; `chatToHandle` | Contact picker/list metrics | Ordinary user-facing read | Move contact list to graph facts plus overlay intent. User override wins; imported contact name is fallback. |
| `lib/features/contacts/infrastructure/repositories/contact_profile_provider.dart` | `workingParticipants`; overlay overrides | Contact hero/profile summary | Ordinary user-facing read | Move profile summary to canonical display identity resolver backed by graph identity plus overlay. |
| `lib/features/contacts/infrastructure/repositories/handles_for_contact_provider.dart` | `handlesCanonical`; `handleToParticipant`; overlay overrides | Contact handle selector and explicit handle scope menu | Ordinary user-facing read | Move to graph canonical handles and graph contact-handle associations. Preserve explicit handle metadata display. |
| `lib/features/contacts/infrastructure/repositories/recent_contacts_repository.dart` | Working contact/message metrics | Recent contact surfaces | Ordinary user-facing read | Migrate to graph contact summaries or retire if no active surface needs it. |
| `lib/features/handles/infrastructure/repositories/handle_display_name_provider.dart` | `handlesCanonical`; `handleToParticipant`; `workingParticipants` | Handle label resolution | Ordinary user-facing read | Fold into the canonical display identity resolver. Raw handle is fallback only. |
| `lib/features/handles/infrastructure/repositories/stray_handles_provider.dart` | `handlesCanonical`; `workingMessages`; `handleToParticipant`; overlay dismissal/link state | From unfamiliar sources / stray handle workflows | Ordinary user-facing read plus settings | Move stray-handle candidate selection to graph handles and graph message evidence scopes. Overlay remains user intent. |
| `lib/features/handles/application/settings_cassette_spec/resolver_tools/manual_linking_provider.dart` | `handlesCanonical`; `handleToParticipant`; `workingParticipants`; `chatToHandle` | Manual handle linking settings | Ordinary user-facing read plus settings | Keep overlay writes. Replace candidate reads with graph handle/contact identity once graph contacts are first-class. |
| `lib/features/handles/application/settings_cassette_spec/resolver_tools/spam_management_provider.dart` | `handlesCanonical`; `chatToHandle`; `workingChats` | Handle visibility/spam management | Diagnostic/settings with user-facing impact | Preserve overlay intent. Move handle inventory and chat counts to graph. |
| `lib/features/chats/presentation/view_model/recent_chats_provider.dart` | Graph mode exists; legacy mode reads `workingChats`, `workingMessages`, `chatToHandle`, `handlesCanonical`, `workingParticipants` | Recent chats/conversation summaries | Ordinary user-facing read with legacy fallback | Keep graph path. Remove or demote legacy mode after graph conversation signatures are production default. |
| `lib/features/chats/application/chats_by_age_provider.dart` | `workingChats`; `workingMessages`; `chatToHandle`; `handlesCanonical`; `workingParticipants` | Alternate chat browsing / unmatched chat summaries | Ordinary user-facing read or diagnostic | Replace with graph conversation queries or retire if no production surface needs it. |

## Production Lifecycle Dependencies

These are not deletion candidates until the graph import/projection lifecycle is
first-class and tested.

| Consumer | Legacy dependency | Current role | Classification | Migration direction |
| --- | --- | --- | --- | --- |
| `lib/essentials/db/feature_level_providers.dart` | Central providers for `macos_import.db`, `working.db`, `working_ss.db`, overlay | Database dependency entry point | Production lifecycle | Keep centralization. Add graph readiness/build semantics here rather than creating provider islands. |
| `lib/essentials/db/feature_level_providers/working_db_populated_provider.dart` | Retired in favor of graph readiness | Former sidebar readiness gate | Deletion candidate closed | Sidebar gating now uses `conversationGraphPopulatedProvider`. |
| `lib/essentials/db/feature_level_providers/working_projection_readiness_provider.dart` | `working.db` readiness | App read gate | Production lifecycle | Evolve into graph-aware readiness with explicit legacy compatibility state. |
| `lib/essentials/db_importers/**` | `macos_import.db` import path | Current production import ledger | Production lifecycle | Treat legacy importers as semantic reference until source-scoped import is fully lifecycle-integrated. |
| `lib/essentials/db_migrate/**` | `working.db` migration path | Current production projection | Production lifecycle | Preserve until graph projection is normal app projection and parity tests pass. |
| `lib/essentials/db_importers/application/monitor/chat_db_change_monitor_provider.dart` | Legacy incremental import trigger | Live change monitor | Production lifecycle | Eventually trigger graph import/projection as the production update path. |
| `lib/essentials/onboarding/application/onboarding_gate_provider.dart` | Import/migration control, `working.db` readiness | First-run and recovery lifecycle | Production lifecycle | Make onboarding graph-aware before retiring legacy build. |
| `lib/essentials/onboarding/application/database_existence_checker.dart` | Legacy DB existence/population | Startup data-state detection | Production lifecycle | Include graph DBs and source-scoped import DBs. |
| `lib/essentials/onboarding/application/message_data_reset_service.dart` | Legacy DB reset behavior | Data reset/maintenance | Production lifecycle | Ensure reset deliberately handles graph DBs, legacy DBs, and overlay separation. |
| `lib/essentials/onboarding/application/onboarding_environment_report_provider.dart` | Legacy import/working state | Environment diagnostics for onboarding | Production lifecycle | Add graph readiness and graph failure states. |
| `lib/essentials/db/infrastructure/data_sources/local/working/working_database.dart` | Drift `working.db` schema | Legacy working projection | Production lifecycle | Keep until ordinary reads and lifecycle no longer require `working.db`. |
| `lib/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart` | Sqflite `macos_import.db` schema | Legacy import ledger | Production lifecycle | Keep until source-scoped import ledger replaces production import. |

## Recovery and Archive Dependencies

These systems preserve evidence and historical recoverability. Migrate them
after the ordinary graph path is reliable.

| Consumer | Legacy dependency | Current role | Classification | Migration direction |
| --- | --- | --- | --- | --- |
| `lib/features/attachments/application/attachment_archive_service_provider.dart` | `sqfliteImportDatabaseProvider`; `working.db` sweep queries; overlay archive records | Continuous attachment archiving and recovery hints | Recovery/archive | Move source facts to source-scoped import/graph attachment facts. Preserve archive overlay as user/evidence state. |
| `lib/features/attachments/application/deterministic_recovery_provider.dart` | `macos_import.db`; `working.db`; overlay archive records | Historical attachment recovery workflow | Recovery/archive | Redesign as graph/source-scoped recovery after ordinary graph attachment evidence is stable. |
| `lib/features/attachments/application/cross_snapshot_mapper.dart` | Import DB attachment GUIDs and `working.db` runtime identity | Maps recovered Messages snapshots to current attachment identity | Recovery/archive | Replace legacy runtime identity with graph `ss_id` plus source-scoped attachment identity. |
| `lib/features/messages/infrastructure/repositories/recovered_unlinked_messages_provider.dart` | `recoveredUnlinkedMessages`; `recoveredUnlinkedAttachments`; `handlesCanonical`; `handleToParticipant` | Recovered/deleted message review | Recovery/archive | Move to graph evidence spine or explicitly keep as recovery subsystem until graph import owns recovered sources. |
| `lib/features/settings/application/sidebar_cassette_spec/providers/historical_archives_sidebar_known_sources_provider.dart` | Historical archive settings and legacy-backed recovery assumptions | Historical archive source UI | Recovery/archive plus settings | Keep until source-scoped multi-source archive import exists. |
| `lib/features/settings/application/sidebar_cassette_spec/resolvers/message_history_coverage_settings_resolver.dart` | Legacy coverage/readiness concepts | Coverage settings and archive workflow | Recovery/archive plus settings | Update after graph source inventory and archive import are designed. |
| `lib/features/settings/presentation/view_model/historical_archives_workflow_panel_model_provider.dart` | Historical archive workflow state | Recovery workflow UI | Recovery/archive plus settings | Keep, then rebase on source-scoped archive imports. |

## Diagnostic and Settings Dependencies

These may continue to read legacy systems as long as they are explicitly
diagnostic/reference and not the ordinary app truth.

| Consumer | Legacy dependency | Current role | Classification | Migration direction |
| --- | --- | --- | --- | --- |
| `lib/essentials/db/application/database_health_audit/**` | `macos_import.db`; `working.db`; overlay | Phase 1 database health report | Diagnostic/settings | Add graph database layers and clearly mark legacy layers as compatibility/reference once graph is default. |
| `lib/essentials/incremental_update/**` | Shadow import/projection DBs, old shadow update flow | Retired earlier incremental-update research package | Retired | Removed after graph lifecycle replaced the shadow runtime entry points. Historical docs remain as architecture lineage, not active implementation instructions. |
| `lib/essentials/incremental_update_ss/**` | SS proof/dev panel, comparison providers | Source-scoped proof instrumentation | Diagnostic/settings | Keep dev instrumentation, but ensure production graph lifecycle does not depend on manual dev panel actions. |
| `lib/essentials/db_importers/presentation/view_model/db_import_control_provider.dart` and related panels | Legacy import/migration control | Import/migration UI and lifecycle entry | Production lifecycle plus diagnostic/settings | Replace with graph-aware build lifecycle, not with ad hoc dev controls. |
| `lib/essentials/db_migrate/presentation/view/db_migration_panel.dart` | Legacy migration UI | Migration diagnostics | Diagnostic/settings | Keep until legacy migration retires, then delete. |
| `lib/essentials/logging/application/import_audit_writer.dart` and `migration_audit_writer.dart` | Legacy import/migration logs | Audit diagnostics | Diagnostic/settings | Either add graph audit writers or retire with legacy lifecycle. |
| `lib/debug_install/import_log` and `lib/debug_install/migrate_log` | Static/debug logs | Debug artifacts under `lib` | Deletion candidate | Remove if no build/runtime path reads them. |

## Legacy Presentation Consumers

Current branch work has already removed or replaced most legacy message
presentation components. The remaining danger is data-selection leakage rather
than old bubble widgets.

| Consumer | Current state | Classification | Action |
| --- | --- | --- | --- |
| Deleted/retired message widgets such as `messages_timeline_view.dart`, `message_card.dart`, old hydration providers, and old ordinal strategies | Current worktree marks these as deleted | Deletion candidate, pending checkpoint | Before commit, verify no active imports remain and focused evidence tests pass. |
| `lib/features/messages/application/view_spec/widget_builders/messages_for_handle_builder.dart` | Routes handle messages into graph evidence view | Ordinary user-facing read, graph-backed | Keep. Ensure input identity becomes graph-native rather than legacy bridged. |
| `lib/features/messages/application/view_spec/widget_builders/global_timeline_builder.dart` | Routes global messages to graph evidence view | Ordinary user-facing read, graph-backed | Keep. Verify global scope no longer depends on legacy heatmap/index after migration. |
| `lib/features/messages/application/view_spec/widget_builders/messages_for_contact_builder.dart` | Routes contact messages to graph evidence view | Ordinary user-facing read, graph-backed | Keep. Remove legacy fallback after graph contact scope is stable. |
| `lib/features/messages/application/view_spec/widget_builders/recovered_unlinked_messages_builder.dart` | Routes recovered messages to evidence view | Recovery/archive | Keep, but document recovery-specific data source until graph archive import exists. |

## Deletion Candidates

Deletion candidates should not be removed merely because they look old. Remove
only after `rg` reference checks, focused tests, and graph replacement coverage.

| Candidate | Evidence | Classification | Action |
| --- | --- | --- | --- |
| `lib/features/chats/domain/i_repositories/repository_interface.dart` | Only paired with an unused repository provider scaffold in current search | Deletion candidate | Verify no external imports, then remove scaffold if still unused. |
| `lib/features/chats/infrastructure/chats_repository_provider.dart` and `.g.dart` | Provider only builds `SqliteChatsRepository`; no active callers found in current search | Deletion candidate | Remove after reference check or replace with graph conversation repository if a public feature provider is needed. |
| `lib/features/chats/infrastructure/repositories/sqlite_chats_repository.dart` | Stub repository scaffold | Deletion candidate | Delete if unused. |
| Old message timeline/ordinal/hydration files currently marked deleted | Current worktree indicates retirement already underway | Deletion candidate | Commit only after tests prove message evidence spine covers contact, conversation, handle, global, search, and recovered views. |
| `lib/debug_install/import_log` and `lib/debug_install/migrate_log` | Debug artifacts under production `lib` tree | Deletion candidate | Delete if unused and not intentionally packaged as fixtures. |

## High-Danger Areas

### Search Identity Split-Brain

Search still returns legacy message IDs in key paths. Because search is a
message-selection mechanism, this is more dangerous than a passive read. A
legacy search result that later has to be bridged into graph evidence can
reintroduce identity ambiguity and stale selection behavior.

### Contact and Handle Identity

Contact identity is semantic, not merely relational. The user-facing question
is "what should the user see?", not "which row owns this name?" Until graph
contacts and handle aliases become first-class, providers must not let raw
handles win over known contact identity except as explicit metadata or fallback.

### Lifecycle Drift

The app can now display graph-backed evidence well, but lifecycle still knows
legacy import/projection best. A production UI on top of manual/dev graph build
flows would create a fragile app.

### Recovery and Attachment Archive

Historical recovery depends on old import/working identity. This is acceptable
for now because recovery is a data-integrity subsystem, but it should not
become the model for ordinary graph evidence.

### Diagnostic Code Becoming Production Truth

The SS proof panels and comparison reports are useful, but they must not become
the only way graph build runs. Production lifecycle belongs in central database
and orchestration providers.

## Recommended Migration Order

1. **Checkpoint current graph migration work.**
   Run analyzer and focused graph/evidence/contact tests before further
   deletion.

2. **Make Search graph-native.**
   This removes the highest-risk legacy identity selector.

3. **Move contact/profile/handle read models to graph plus overlay.**
   This removes the bridge pressure inside graph repositories and stabilizes
   display identity.

4. **Productionize graph build lifecycle.**
   Onboarding, reset, readiness, live updates, and message data invalidation
   must understand source-scoped import and graph projection.

5. **Migrate global heatmap and remaining chat summary fallbacks.**
   Remove ordinary `working.db` user-facing reads after graph equivalents are
   covered.

6. **Plan recovery/archive migration separately.**
   Keep historical recovery and attachment archiving conservative until graph
   ordinary paths are boring and reliable.

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
