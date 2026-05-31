---
tier: project
scope: source-scoped-graph-migration
status: active
last_reviewed: 2026-05-30
depends_on:
  - 70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md
  - 71-LEGACY-DEPENDENCY-MATRIX.md
---

# 72 - Graph Choke Points and Retirement Blockers

## Purpose

The roadmap explains the destination.

The dependency matrix explains what remains.

This document identifies the smallest remaining systems whose migration unlocks
the largest downstream simplification.

The goal is not to chase every legacy reference. The goal is to collapse the
right dependencies in the right order so `working.db`, `macos_import.db`, and
legacy read models can be retired deliberately.

This is an architectural planning document only. It does not authorize
implementation.

## Architectural Choke Points

An architectural choke point is a relatively small subsystem whose migration,
replacement, or completion removes a disproportionately large number of
downstream legacy dependencies.

### Choke Point Summary

| Choke point | Current state | Dependencies blocked | Estimated leverage | Recommended relative order |
| --- | --- | --- | --- | --- |
| `SearchService` | Still queries `working.db` `messages`, `messages_fts`, `contact_message_index`, saved GUIDs, and tag GUIDs. | Search All, search result context, saved/tagged message retrieval, evidence selection identity. | Very high | First after checkpoint. |
| Search identity model | Search results still depend on legacy IDs and GUID bridges in places. | Prevents clean `MessageEvidenceScope` construction from search, saved, and tagged overlays. | Very high | Same slice as SearchService or immediately before it. |
| Display Identity Resolver | Graph-aware resolver exists, but app-wide adoption and old contact/handle providers are incomplete. | Contact picker, hero card, conversation titles, sender labels, handle labels, search labels. | Very high | After search identity or parallel if small. |
| Contact Identity Layer | Contact/profile/handle menus still read legacy participants, canonical handles, and handle aliases. | Removes contact graph repository bridges, handle selector bridges, favourite contact drift, raw-handle display leakage. | Very high | Before lifecycle hardening. |
| MessageEvidenceScope construction | Evidence spine exists, but some scopes are still bridged from legacy selection identity. | Search, global timeline, handle scopes, recovered scopes, future tagged/favourite scopes. | High | Evolves with search/contact migration. |
| Graph Readiness Provider | `workingProjectionReadinessProvider` checks `working.db`; graph health exists but is not the central app gate. | Onboarding, auto-sync eligibility, graph UI readiness, reset/maintenance, stale graph prevention. | Very high | After identity/search choke points, before legacy lifecycle retirement. |
| `ChatDbChangeMonitor` | Polls live `chat.db`, triggers legacy import/migration and attachment sweep. | Live graph freshness, automatic incremental graph build, app launch consistency. | Very high | With lifecycle orchestration. |
| `ConversationGraphBuildService` | Production-shaped build service exists; currently exposed as a service and used by proof/dev panel paths, not complete app lifecycle. | Normal graph build, idempotent incremental projection, post-build invalidation, readiness state. | Very high | With lifecycle orchestration. |
| Graph lifecycle orchestration | Build service, readiness, onboarding, reset, monitor, and invalidation are not one production state machine. | Prevents graph from becoming app spine even if UI is graph-backed. | Highest production leverage | After search/contact identity ambiguity is reduced. |
| Attachment archive/recovery identity mapping | Archive and deterministic recovery still map through message GUIDs, import attachment IDs, and legacy working/import DBs. | Blocks retirement of recovery/archive legacy dependencies and historical source ingestion. | High but hazardous | Later, after ordinary graph path is stable. |
| Overlay identity key strategy | Overlay tables use mixed identity forms: working IDs, GUIDs, normalized strings, and graph IDs in settings. | Blocks safe migration of favourites, tags, saved flags, manual links, handle dismissal, message annotations. | Very high | Audit before search/contact migration; implement as part of those migrations. |
| Message data invalidation | `messageDataVersionProvider` is still tied to legacy import/migration completion. | Graph evidence refresh, search refresh, contact metrics refresh, stale UI prevention. | High | With graph lifecycle orchestration. |
| Graph health diagnostics | Existing graph health is useful but not yet the authoritative readiness guard. | Safe promotion, rebuild detection, repair state, support diagnostics. | Medium-high | With readiness provider. |

### Choke Point Details

#### SearchService

**Description**

Search is a selection system, not merely a read model. It decides which message
identity becomes the evidence scope.

**Current state**

`SearchService` still reads legacy `working.db` tables and returns legacy
message IDs in ordinary search paths.

**Dependencies blocked**

- Search All Messages
- search result context
- saved-message filtering
- tag-based search overlays
- future legal/investigative search workflows

**Estimated leverage**

Very high. Migrating search removes the most dangerous ordinary split-brain
path.

**Recommended migration order**

First after checkpoint, paired with explicit search identity model decisions.

#### Search Identity Model

**Description**

Defines what a search hit is in the graph world.

**Current state**

Legacy search results are message IDs from `working.db`; newer overlay saved
and tag state is keyed by message GUID. The graph evidence spine wants stable
`ss_id` message identity.

**Dependencies blocked**

- graph-native search
- saved/tagged graph result scopes
- full-scope skeletons for search contexts
- removal of legacy `messages_fts`

**Estimated leverage**

Very high. Without this, migrating `SearchService` risks simply moving legacy
identity ambiguity into a new repository.

**Recommended migration order**

Immediately before or inside SearchService migration.

#### Display Identity Resolver

**Description**

The semantic resolver answers: what should the user see?

**Current state**

A graph-aware resolver exists, but not every contact, sender, handle, and
conversation label path depends on it exclusively.

**Dependencies blocked**

- conversation titles
- contact picker display names
- contact hero cards
- sender lines
- handle labels
- search result labels
- unfamiliar-source promotion labels

**Estimated leverage**

Very high. It removes many local name-resolution patches and prevents raw
handles from winning over known contacts.

**Recommended migration order**

Immediately after search identity, or in parallel if the implementation remains
strictly read-model scoped.

#### Contact Identity Layer

**Description**

The layer that maps contacts, handles, aliases, manual links, virtual contacts,
and overlay display intent into one app-facing identity model.

**Current state**

Contact/profile/handle providers still use legacy `working.db` participants,
canonical handles, handle-to-participant rows, and alias tables.

**Dependencies blocked**

- contact picker migration
- contact hero/profile migration
- handle selector migration
- graph repository compatibility bridge removal
- favourite contact migration
- manual handle linking migration

**Estimated leverage**

Very high. This is the biggest reducer of legacy read pressure after search.

**Recommended migration order**

After graph-native search, before lifecycle hardening if feasible.

#### MessageEvidenceScope Construction

**Description**

The boundary where a sidebar/source-specific selection becomes a typed message
evidence universe.

**Current state**

The evidence spine is in place and most views use it, but some scopes are still
fed by legacy selector identity or recovery-specific legacy models.

**Dependencies blocked**

- source-specific renderer retirement
- search result context migration
- global timeline migration
- consistent saved/tagged scopes
- future theme/favourite/message-set projections

**Estimated leverage**

High. The mechanism exists; the remaining work is making every selector produce
graph-native scopes.

**Recommended migration order**

Advance alongside search and contact identity; do not make it a separate large
abstraction pass.

#### Graph Readiness Provider

**Description**

The central app answer to whether graph data exists, is current, is building,
or needs repair.

**Current state**

Readiness remains centered on `working.db` projection state. Graph health exists
but is not yet the app-level gate.

**Dependencies blocked**

- onboarding graph awareness
- safe app startup
- graph UI gating
- automatic rebuild/repair decisions
- legacy readiness retirement

**Estimated leverage**

Very high.

**Recommended migration order**

After search/contact identity choke points are reduced, before legacy lifecycle
retirement.

#### ChatDbChangeMonitor

**Description**

The live source-change detector that should eventually trigger graph import and
projection.

**Current state**

It detects live `chat.db` changes, triggers legacy import/migration, bumps
legacy message data version, and runs attachment archive sweeps.

**Dependencies blocked**

- automatic graph freshness
- replacing manual graph build workflows
- productionizing incremental graph updates
- legacy import/migration retirement

**Estimated leverage**

Very high.

**Recommended migration order**

With graph lifecycle orchestration, after graph build readiness semantics are
defined.

#### ConversationGraphBuildService

**Description**

The orchestrated graph build path for source-scoped import, enrichment,
projection, and topology edges.

**Current state**

It already composes importers, rich-text enrichment, topology importers, and
projectors. It lacks full lifecycle state, readiness integration, reset
integration, and automatic monitor integration.

**Dependencies blocked**

- production graph import/projection
- idempotent live graph build
- graph data invalidation
- onboarding graph build
- legacy build retirement

**Estimated leverage**

Very high.

**Recommended migration order**

With graph lifecycle orchestration.

#### Graph Lifecycle Orchestration

**Description**

The combined production state machine around graph build, graph readiness,
onboarding, reset, live updates, failures, and evidence invalidation.

**Current state**

Pieces exist, but they are not a single production lifecycle.

**Dependencies blocked**

- making graph the default app spine
- stopping manual/dev-panel graph rebuilds
- retiring legacy import/projection
- reliable first-run and incremental behavior

**Estimated leverage**

Highest production leverage.

**Recommended migration order**

After search and contact identity if the goal is to avoid cementing temporary
bridges into lifecycle. Before archive/recovery migration.

#### Attachment Archive / Recovery Identity Mapping

**Description**

The identity bridge between source attachments, archived files, recovered
Messages folders, and displayed evidence.

**Current state**

Archive overlay records use `message_guid + import_attachment_id`. Historical
recovery maps through legacy `macos_import.db` and `working.db`.

**Dependencies blocked**

- retiring legacy import DB for archive recovery
- importing recovered Messages folders as graph sources
- source-scoped attachment provenance
- long-term forensic archive workflows

**Estimated leverage**

High, but hazardous. This is data-integrity work and should not lead the
ordinary app migration.

**Recommended migration order**

After ordinary graph evidence, search, identity, and lifecycle are stable.

## Compatibility Bridges

A compatibility bridge is temporary logic whose purpose is to connect legacy
identity, lifecycle, or selection systems to graph-native systems.

Bridges are not inherently bad. The danger is forgetting which bridges are
intentional and allowing them to become permanent architecture.

| Bridge owner | Source side | Destination side | Why it exists | Intentional? | Removal condition |
| --- | --- | --- | --- | --- | --- |
| `SqliteContactGraphRepository` | legacy participant IDs, `handle_to_participant`, `handles_canonical_to_alias` | graph handle/message scopes | Contact UI still selects legacy contact identity while evidence is graph-backed. | Yes | Contact identity layer produces graph-native contact and handle scopes. |
| `SqliteMessageGraphRepository` | legacy canonical handle aliases | graph handle message scopes | Handle-oriented surfaces may still pass legacy handle IDs. | Yes | Handle selectors and unfamiliar-source surfaces pass graph canonical handle identity. |
| `contactTimelineProvider` fallback | legacy `contact_message_index` | graph contact evidence skeleton fallback | Preserves contact timeline behavior while graph contact scope stabilizes. | Yes, temporary | Graph contact timeline covers all selected scopes and tests prove no latest-N regression. |
| `recentChatsProvider` legacy mode | legacy `workingChats` and related tables | `RecentChatSummary` | Supports older chat read-model mode while Conversations becomes graph-first. | Partially intentional | Product route no longer depends on legacy chats; graph conversation summaries cover required diagnostics. |
| `SearchService` | legacy message IDs and `messages_fts` | graph evidence views downstream | Search has not yet migrated to graph identity. | No longer desirable | Search returns graph `ss_id` scopes and saved/tag filters are graph-compatible. |
| `handleDisplayNameProvider` | legacy handle/participant rows | user-facing handle label | Name resolution has not fully centralized on graph display identity. | Temporary | Display identity resolver owns handle/contact labels everywhere. |
| `strayHandlesProvider` | legacy canonical handles and message counts | unfamiliar-source workflow | Stray-handle workflows predate graph handles. | Temporary | Graph handle inventory and graph message counts drive unfamiliar-source workflows. |
| `manualLinkingProvider` | legacy canonical handle IDs and participant IDs | overlay handle links | Manual linking UI still targets legacy identity. | Temporary but sensitive | Overlay link identity migrates to graph contact/handle identity with explicit bridge for existing rows. |
| `spamManagementProvider` | legacy handle IDs and chat counts | overlay visibility/blacklist | Visibility UI still reads legacy handle inventory. | Temporary | Visibility overlays target graph handle identity or stable normalized handle identity. |
| `message_user_flags` / `message_user_tags` | message GUID | graph message evidence | GUID was stable across working rebuilds and useful before `ss_id` graph identity. | Intentional bridge, future risk | Source-scoped message overlay key strategy exists; duplicate GUID behavior is explicit. |
| `message_annotations` | legacy working message ID | overlay message annotations | Older annotation system predates graph identity. | Legacy debt | Either migrate to `ss_id` or retire if unused. |
| `chat_overrides` | legacy working chat ID | conversation display overrides | Older chat custom-name system predates graph conversations. | Legacy debt | Migrate to graph conversation identity or retire if unused. |
| `favorite_contacts` | legacy participant ID | contact favourite state | Contact favourites predate graph contact identity. | Temporary | Contact identity layer provides graph contact IDs and overlay migration path. |
| `conversation_favourites` overlay setting | graph conversation ID stored as comma-separated setting | conversation favourite state | First graph-native favourite implementation used lightweight settings storage. | Acceptable temporary | Replace with typed overlay table when tags/groups expand or before broad overlay migration. |
| `archived_attachments` | `message_guid + import_attachment_id` | attachment archive availability | Archive must survive working rebuilds and historical recovery. | Intentional | Graph/source-scoped attachment identity maps archive availability without losing existing archive records. |
| `CrossSnapshotMapper` | historical snapshot + legacy import/working identity | current archive identity | Recovered attachment mapping predates graph source registry. | Intentional recovery bridge | Historical sources import into source-scoped graph and archive mapping uses graph attachment identity. |

## Retirement Blockers

This section names what prevents each legacy layer from being retired.

### `working.db`

| Blocker | Affected systems | Removal criteria | Recommended sequencing |
| --- | --- | --- | --- |
| Search still selects legacy message IDs | Search All, search result context, saved/tagged search | Search returns graph `ss_id` scopes; saved/tag overlays resolve safely. | First. |
| Contact/profile/handle providers still read working participants/handles | contact picker, hero card, handle menu, manual link UI | Graph contact identity layer covers contact summaries, handle lists, overrides, favourites. | After search or parallel. |
| Legacy readiness gates app startup | onboarding, contact providers, global heatmap | Graph readiness provider replaces working projection readiness for graph paths. | Lifecycle phase. |
| `ChatDbChangeMonitor` triggers legacy migration | live update path, message data version bump | Monitor triggers graph build and graph invalidation; legacy path becomes compatibility/diagnostic. | Lifecycle phase. |
| Archive/recovery maps through working identity | deterministic recovery, archived attachment lookup | Source-scoped attachment identity and graph recovery mapping exist. | Later. |
| Overlay tables reference working IDs | favourites, display overrides, handle links, message annotations, chat overrides | Overlay key strategy and migration bridge exist. | Begin before search/contact migration; complete before retirement. |

### `macos_import.db`

| Blocker | Affected systems | Removal criteria | Recommended sequencing |
| --- | --- | --- | --- |
| Legacy import remains production source ledger | onboarding import, incremental import, migration | Source-scoped import is production import path and passes parity tests. | Lifecycle phase. |
| Attachment archive reads legacy import attachments | batch archiving, archive sweep, recovery hints | Source-scoped import attachment facts power archive service. | Later, after lifecycle. |
| Deterministic recovery maps historical sources through legacy import DB | recovered attachment import | Graph/source-scoped historical source import replaces mapper. | Archive/recovery phase. |
| Health audit assumes legacy import/working pair | support diagnostics | Graph health covers source/import/working graph and legacy layers are reference only. | Lifecycle/diagnostic phase. |

### Legacy Read Models

| Blocker | Affected systems | Removal criteria | Recommended sequencing |
| --- | --- | --- | --- |
| Search index/read models remain legacy | all search surfaces | Graph search index/query path exists. | First. |
| Contact read models remain legacy | contact picker, contact hero, handle filters | Graph contact summaries and handle scopes exist. | Second. |
| Global heatmap remains legacy | global message timeline | Graph full-scope global skeleton exists. | After search/contact. |
| Old chat summary providers remain fallback | recent/age/unmatched chats | Graph conversation summaries cover required views or old views are retired. | After frontmost graph conversation path is stable. |
| Recovered message provider remains legacy/recovery-specific | recovered deleted messages | Either graph evidence source import exists or provider is documented as recovery-only. | Later. |

### Legacy Projection Systems

| Blocker | Affected systems | Removal criteria | Recommended sequencing |
| --- | --- | --- | --- |
| Graph build is not normal lifecycle | whole app | Onboarding/reset/monitor/readiness all understand graph build. | Lifecycle phase. |
| Legacy migrators encode semantic parity | contacts, handles, attachments, message semantics | Graph parity tests prove equivalent behavior where semantics matter. | Continuous; do not shortcut. |
| Overlay references legacy IDs | user intent preservation | Overlay bridge/migration strategy is proven. | Before deleting working DB. |
| Recovery/archive depends on legacy identity | evidence archive | Recovery plan moves to graph/source-scoped identity. | Last major blocker. |

## Overlay Identity Audit

Overlay data is user intent and must survive graph rebuilds. The migration
cannot simply replace read models without deciding how overlay identity keys
map to graph identity.

### Known Overlay Identity Forms

| Overlay area | Current identity form | Current stability | Target identity direction | Bridge strategy required |
| --- | --- | --- | --- | --- |
| `participant_overrides` | legacy `participant_id` | Stable only while legacy participants persist | graph contact identity plus exactly one display-name override | Read old rows through legacy-to-graph contact bridge; migrate when graph contacts are stable. |
| `favorite_contacts` | legacy `participant_id` | Stable only while legacy participants persist | graph contact identity or overlay virtual participant identity | Preserve favorite state through contact identity migration. |
| `handle_to_participant_overrides` | legacy canonical `handle_id`, legacy `participant_id`, overlay `virtual_participant_id` | Mixed; virtual IDs are overlay-stable, handle/participant IDs are legacy-stable only | graph canonical handle identity and graph contact identity; virtual participant remains overlay-owned | Bridge legacy handle/participant IDs to graph IDs before changing write path. |
| `handle_visibility_overrides` | legacy canonical `handle_id` | Stable only while legacy canonical handle IDs persist | graph canonical handle identity or normalized handle identity | Decide whether visibility belongs to canonical graph handle or stable normalized handle string. |
| `dismissed_handles` | normalized handle string | Relatively stable and graph-independent | likely remains normalized handle string | Verify normalization matches graph canonicalization. |
| `message_user_flags` | message GUID | Stable within one source; unsafe as global identity across sources | graph `message_ss_id` for source-derived occurrence identity | Read legacy GUID flags as compatibility; define duplicate-GUID behavior before multi-source search. |
| `message_user_tags` | message GUID + tag | Stable within one source; unsafe globally | graph `message_ss_id` + tag | Same as saved flags; search migration must account for this. |
| `message_annotations` | legacy working `message_id` | Legacy-only | graph `message_ss_id` or retirement | Verify whether this feature remains product-active before migration. |
| `chat_overrides` | legacy working `chat_id` | Legacy-only | graph conversation ID / chat `ss_id` if custom conversation names survive | Verify current product need; likely retire or migrate later. |
| `conversation_favourites` in `overlay_settings` | comma-separated graph conversation IDs | Graph-oriented but weakly typed | typed overlay table keyed by conversation ID and favourite/tag group | Accept temporarily; table needed before arbitrary tags/groups. |
| `archived_attachments` | `message_guid + import_attachment_id` | Stable for current live source and legacy archive | graph attachment identity and/or `message_ss_id + attachment_ss_id` | Maintain compatibility lookup until archive records are migrated or bridged. |
| `overlay_settings` | string keys/values | Depends on each key | typed tables for durable entity overlays | Audit key-by-key before changing identity-bearing settings. |

### What Identity Forms Should Exist

Preferred long-term identity forms:

- source-derived messages: `message_ss_id`
- source-derived conversations/chats: `conversation_id` / `chat_ss_id`
- source-derived handles: graph canonical handle identity, with alias records
- source-derived contacts: graph contact identity
- virtual contacts: overlay-owned virtual contact identity
- dismissed unknown handles: normalized handle string may remain acceptable
- archived files: attachment graph identity plus content-addressed archive path

Forms that should not remain primary for graph-era overlays:

- legacy working message IDs
- legacy working chat IDs
- legacy working participant IDs
- legacy working canonical handle IDs
- bare message GUID as global message identity

GUIDs may remain bridge metadata. They should not become canonical overlay
identity once multi-source imports exist.

### Verification Areas

Before migrating Search and Contact Identity, verify:

- whether `message_annotations` is still product-active or historical.
- whether `chat_overrides` is still product-active or historical.
- how saved flags and tags should behave when duplicate GUIDs appear across
  sources.
- whether contact favourites must preserve order and recency across graph
  contact migration.
- whether handle visibility should attach to graph canonical handle identity or
  normalized handle string.
- whether conversation favourites need a typed table before arbitrary tags are
  introduced.
- whether archive availability can be resolved through graph attachment identity
  without breaking existing archive records.

## Leverage-Based Migration Order

The roadmap sequence emphasizes production safety:

```text
Lifecycle
→ Search
→ Contact Identity
```

The dependency matrix suggests a leverage-first adjustment:

```text
Search
→ Contact Identity
→ Lifecycle
```

### Evaluation

Lifecycle is the dominant production risk. The graph cannot become the app
spine until onboarding, reset, readiness, live change monitoring, build state,
and invalidation are graph-aware.

However, hardening lifecycle while Search and Contact Identity still depend on
legacy bridges risks making those bridges part of the new production spine.
That would preserve split-brain identity at the exact layer that should remove
it.

Search and Contact Identity are smaller choke points than lifecycle, and they
remove ambiguity from the graph read layer before lifecycle is promoted.

Therefore the recommended order is:

1. **Checkpoint current branch.**
   Establish a known-good baseline before any more migration or deletion.

2. **Overlay identity key audit and bridge design.**
   This is not a broad implementation pass. It is the minimum needed to avoid
   search/contact migration corrupting user intent.

3. **Graph-native Search and Search Identity.**
   Search must select graph evidence directly. Saved/tagged overlays need an
   explicit bridge from GUID-based legacy overlay state.

4. **Graph-native Contact and Handle Identity.**
   Contact picker, contact hero/profile, handle menus, manual links, and
   display labels move to graph facts plus overlay intent.

5. **MessageEvidenceScope cleanup.**
   Remove remaining legacy-selector-fed evidence scopes exposed by Search and
   Contact paths. Preserve the evidence spine invariant.

6. **Graph lifecycle orchestration.**
   Productionize graph build/readiness/onboarding/reset/change-monitor
   behavior after selector identity is graph-native.

7. **Remaining ordinary read migration.**
   Global heatmap, old chat summary fallbacks, and settings-facing handle lists
   migrate or retire.

8. **Archive/recovery identity migration.**
   Move deterministic recovery and archive mapping to source-scoped attachment
   identity.

9. **Legacy retirement.**
   Delete legacy import/projection/read models only when blockers are closed.

## Closure Criteria

### SearchService and Search Identity

Done means:

- ordinary search returns graph `message_ss_id` evidence scopes.
- search result context builds a full logical graph skeleton, not a latest-N
  batch.
- saved-message filtering works against graph message identity.
- tag search works against graph message identity or an explicit GUID bridge
  with documented duplicate-GUID behavior.
- no ordinary search path requires `working.db` message IDs.

### Display Identity Resolver

Done means:

- all user-facing contact, participant, sender, handle, and conversation labels
  use one resolver/read model.
- user display-name override wins everywhere.
- raw handles appear as primary labels only for truly unfamiliar sources or
  explicit handle-scope controls.
- widgets render typed identity data and do not resolve names directly.

### Contact Identity Layer

Done means:

- contact picker/profile/hero/read models use graph facts plus overlay intent.
- handle menus use graph canonical handle identity and aliases.
- manual links preserve overlay-only writes.
- contact favourites preserve user intent after graph migration.
- graph repositories no longer need legacy participant/handle bridge lookups
  for ordinary contact evidence.

### MessageEvidenceScope Construction

Done means:

- every ordinary message-bearing route starts from a typed
  `MessageEvidenceScope`.
- no source-specific renderer is introduced.
- timeline-like scopes preserve the full selected logical universe.
- limits apply only to hydration windows.

### Graph Readiness Provider

Done means:

- graph readiness distinguishes not built, building, ready, stale, failed, and
  maintenance unavailable.
- graph readiness is exposed through the central database dependency entry
  point.
- graph UI does not masquerade missing graph data as "no messages".
- legacy working readiness is compatibility/reference only for remaining legacy
  subsystems.

### ChatDbChangeMonitor

Done means:

- live `chat.db` changes trigger source-scoped import and graph projection.
- graph evidence invalidation occurs after successful graph build.
- legacy import/migration is no longer the only automatic live-update path.
- attachment archive sweep behavior is either preserved or deliberately split
  from graph message build.

### ConversationGraphBuildService

Done means:

- graph build is idempotent.
- graph build resumes from source-scoped cursor positions.
- graph build reports state and errors through lifecycle/readiness providers.
- graph build never reads or mutates overlay.
- dev panel uses the same production build service as instrumentation, not as
  the only entry point.

### Graph Lifecycle Orchestration

Done means:

- onboarding can build or validate graph data.
- reset/maintenance deliberately handles source-scoped import DB and graph DB.
- app startup can detect stale or missing graph data.
- automatic updates keep graph evidence current.
- graph failures are visible and actionable.

### Attachment Archive / Recovery Identity Mapping

Done means:

- archive availability can resolve from graph attachment identity.
- existing archive records remain usable.
- recovered Messages folders can be ingested or mapped without depending on
  legacy working identity.
- source-scoped attachment provenance is preserved.

### Overlay Identity Key Strategy

Done means:

- each overlay table has an explicit graph-era identity key.
- existing legacy-keyed overlay rows have a read bridge or migration path.
- duplicate GUID behavior is defined before multi-source search/tag/favourite
  use.
- overlay writes remain overlay-only.
- import/projection never consults overlay.

## Planning Conclusion

The next high-leverage migration work should not be random legacy deletion.

The correct pressure points are:

```text
overlay identity clarity
→ graph-native search
→ graph-native contact/handle identity
→ graph lifecycle orchestration
→ remaining ordinary reads
→ archive/recovery
→ legacy retirement
```

This ordering keeps the app moving toward a single graph spine without
hardening temporary bridges into production architecture.
