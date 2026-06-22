---
tier: project
scope: source-scoped-graph-migration
owner: agent-per-project
last_reviewed: 2026-06-02
source_of_truth: roadmap
links:
  - ./30-INVARIANTS.md
  - ./64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md
  - ./65-SOURCE-SCOPED-SS-GRAPH-CHECKPOINT.md
  - ./66-SS-MIGRATION-STRATEGY.md
  - ./67-SS-LEGACY-PARITY-AUDIT.md
  - ./68-SS-MESSAGE-SEMANTIC-PRESERVATION-MODEL.md
  - ./69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md
  - ../00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md
tests: []
---

# 70 - Graph System Completion Roadmap

## Purpose

This document pauses the source-scoped graph migration and records:

- where MessageLens is now
- which architectural bets have been proven
- which legacy systems still matter
- what must be completed before the graph becomes the production data spine
- the safest order for finishing the migration

The goal is not to keep adding graph features indefinitely.

The goal is to finish converting MessageLens into:

```text
source facts
→ source-scoped import ledger
→ lean working conversation graph
→ typed read/evidence scopes
→ shared projection-oriented UI
```

while retiring legacy read/presentation paths only when their graph
replacement preserves the hard-won behavior.

---

# Current High-Level State

The source-scoped architecture has moved past proof-of-concept.

It now supports real app workflows:

- graph-backed conversations
- graph-backed contact timelines
- graph-backed handle timelines
- graph-backed global message evidence
- graph-backed conversation signatures
- graph-backed message attachments
- graph-backed sender/contact display resolution in key message surfaces
- shared message evidence header and row rendering
- full-scope timeline skeletons with visible-row hydration

The migration is therefore no longer primarily about proving that the graph can
work.

The remaining work is about:

- making the graph the production default everywhere
- preserving legacy data-integrity behavior
- integrating graph import/projection into normal app lifecycle
- converting remaining legacy read surfaces
- deleting retired code deliberately
- ensuring future features can only enter through the graph/evidence spines

---

# Core Architectural Invariants

These invariants must remain binding while completing the migration.

## Source-Scoped Identity

`SourceScopedRowKey` / `ss_id` is canonical working-row identity for
source-derived projected rows.

It is:

- deterministic
- collision-free within documented bounds
- occurrence-preserving
- provenance-preserving

It is not:

- a hash
- a GUID surrogate
- a semantic deduplication key
- a merge identity

Future deduplication, contact matching, semantic grouping, or merge views must
live above base row identity.

## Database Split

The source-scoped split is:

```text
macos_import_ss.db = source facts + provenance
working_ss.db      = lean app graph
user_overlays.db   = user intent
```

`working_ss.db` should not accumulate import-ledger provenance columns such as
`source_id`, `source_rowid`, or `batch_id` unless there is a separately
approved diagnostic reason.

## Relationship Projection

Working graph relationships use `ss_id` endpoints.

Examples:

- `chat_to_message.chat_ss_id`
- `chat_to_message.message_ss_id`
- `chat_to_handle.chat_ss_id`
- `chat_to_handle.handle_ss_id`
- `message_to_attachment.message_ss_id`
- `message_to_attachment.attachment_ss_id`
- `messages.sender_canonical_handle_ss_id`
- `messages.associated_message_ss_id`

Source-local endpoints are transformed mechanically into source-scoped working
identity before entering the graph.

## User Intent Overlay

User intent belongs only in the overlay database.

Examples:

- contact display-name override
- favourites
- manual contact/handle links
- future tags
- dismissals and review decisions

Import and projection must not read overlay state to decide working graph
truth.

Readers may merge graph facts and overlay intent at read time, with overlay
winning for user-facing intent.

## Message Evidence Spine

All message-bearing center-panel surfaces must converge through the Message
Evidence Spine.

Source-specific scopes are allowed.

Source-specific evidence renderers are not.

Timeline-like scopes must preserve the full selected logical message universe.

```text
Pagination is not timeline navigation.
```

Limits may apply to hydration windows, not selected scope size.

## Display Identity

Identity resolution is semantic, not relational.

The display resolver answers:

```text
What should the user see?
```

not:

```text
Which database row owns this name?
```

Known contacts must display using:

```text
user display-name override
→ known app/contact identity
→ imported AddressBook display name
→ raw handle only as fallback
```

Handles remain useful metadata and explicit scope selectors. They must not
become the primary label for a known person.

## DDD and Query Boundaries

Raw SQL is acceptable inside Drift-backed infrastructure repositories when it
implements named repository methods with typed outputs.

Raw SQL is not acceptable in:

- widgets
- view builders
- application coordinators
- semantic resolvers

The constitutional boundary is layer ownership, not query syntax.

---

# Proven Architecture

## Source-Scoped Import Spine

Production-shaped source-scoped import code now exists under:

```text
lib/essentials/source_scoped_import/
```

Current imported source domains include:

- messages
- rich text enrichment for missing text
- chats
- handles
- contacts
- attachments
- chat-message joins
- chat-handle joins
- message-attachment joins

The import database is currently:

```text
macos_import_ss.db
```

The source-scoped import spine preserves source facts and source provenance.
It intentionally keeps GUIDs and source-specific metadata as source facts, not
working identity.

## Conversation Graph Projection Spine

Graph projection code now exists under:

```text
lib/essentials/conversation_graph/
```

The graph database is currently:

```text
working_ss.db
```

It is opened through the central database dependency entry point:

```text
lib/essentials/db/feature_level_providers.dart
```

Current graph domains include:

- messages
- chats
- handles
- canonical handles
- handle aliases
- contacts
- contact-to-handle links
- attachments
- chat-to-message topology
- chat-to-handle topology
- message-to-attachment topology
- conversation signatures
- conversation favourites
- graph health/readiness diagnostics

This is the right spine placement. It avoids `lib/new/` and avoids parallel
feature trees such as `messages_ss/` or `contacts_ss/`.

## Message Evidence Spine

The message UI migration has made strong progress.

The active evidence path is:

```text
MessageEvidenceScope
→ messageEvidenceTimelineSkeletonProvider
→ MessageEvidenceTimelineSkeleton
→ messageEvidenceRowProvider
→ MessageEvidenceRowData
→ messageEvidenceAttachmentsProvider
→ MessageAttachmentEvidence
→ MessageEvidenceTimelineView
→ MessageEvidenceRow
→ TextMessageTile / MessageAttachmentEvidenceTiles
```

Current graph-backed evidence surfaces include:

- Contact / All Messages
- Contact / selected handle
- Contact / conversation selection
- Conversations sidebar selection
- Global messages
- Search all messages evidence presentation
- Handle messages
- Unfamiliar-source handle evidence
- Search result context windows
- Recovered-message evidence presentation

Ordinary selection and search now use graph evidence scopes. Remaining legacy
source-data dependencies are recovery/archive or lifecycle compatibility
concerns, not separate message presentation paths.

## Conversation-First UI Direction

The app has validated a stronger product direction:

```text
Conversations as the frontmost navigation model.
Contacts as an important secondary lens.
```

The Conversations sidebar now acts as a graph topology navigator rather than a
center-panel dashboard. It shows reusable conversation signature cards, graph
glyphs, favourites, and sidebar-only filtering/sorting.

Contact mode remains valuable for:

- "all messages from this person"
- heatmap navigation
- handle-specific filtering
- contact-specific conversation lists

The graph makes both modes views over the same communication space rather than
separate data models.

---

# Remaining Legacy Dependencies

The graph transition is advanced, but legacy remains in several important
places.

These should not all be deleted at once. Some are still gold-standard sources
for data integrity or recovery behavior.

## Legacy Import and Migration

Existing import/migration systems still operate around:

```text
macos_import.db
working.db
```

They remain important because they encode years of fixes around:

- AddressBook import quirks
- handle canonicalization
- attachment archiving
- recovered/deleted messages
- onboarding
- reset/maintenance flows
- incremental updates
- historical archive workflows

The source-scoped implementation should continue using legacy behavior as a
semantic reference, but not by recreating legacy schema shape blindly.

## Onboarding and Auto-Sync

Current app lifecycle is graph-aware but still retains legacy compatibility
systems:

- onboarding gate
- import control panel
- reset service
- `ChatDbChangeMonitor`
- retained legacy import/migration compatibility boundaries

The graph build service, readiness providers, onboarding checks, reset flows,
and live monitor are now wired into the app-facing graph path.

Current status update:

- onboarding and settings reimport build the source-scoped graph directly
- live `chat.db` polling imports/projects the graph directly
- retained legacy import/migration no longer runs as the live-update tail
- Historical Archives import/removal now uses source-scoped graph services
  directly; the retained archive pipeline bridge has been retired

The remaining issue is retained cleanup/diagnostic retirement: old
`macos_import.db` / `working.db` files may still exist for diagnostics,
historical inventory, or user-safe cleanup, but ordinary production
ownership now belongs to source-scoped import and graph projection.

## Search

The shared message evidence presentation is graph-oriented, and ordinary search
now selects graph `message_ss_id` evidence scopes.

This means:

- evidence rendering is unified through the Message Evidence Spine
- ordinary search identity no longer depends on legacy working IDs
- saved/tag GUID compatibility bridges remain explicit transitional inputs

Future search work should add graph scopes rather than reopening legacy
`working.db` search indices.

## Contacts and Handles

Display identity resolution and ordinary contact/handle reads now flow through
graph facts plus overlay intent. Contact lists, contact profiles, handle lists,
stray handle workflows, manual linking reads, and spam management reads are
graph-backed for ordinary UI.

Future contact/handle work should preserve the invariant that user override
names win everywhere and overlay writes remain overlay-only.

## Chats Feature

Conversation sidebar/signature and recent-chat product reads are graph-backed.
Any remaining legacy chat/read-model code is diagnostic/historical or retained
legacy schema, not an ordinary product conversation model.

## Attachments and Recovery

Graph attachments are functioning in message evidence.

However, attachment archive overlay rows still use legacy-compatible archive
keys, and historical recovery still needs carefully bounded graph-to-overlay
compatibility mapping.

This is acceptable temporarily because the attachment archive is a high-value
data-integrity system and should not be rewritten casually.

The long-term target is:

```text
graph attachment facts
→ archive availability evidence
→ shared attachment media tiles
```

with historical recovery sources feeding the source-scoped import/archive
process explicitly.

## Settings and Historical Archives

Historical archive dry-run tools now compare selected archive `chat.db`
evidence against the conversation graph. Retained `macos_import.db` /
`working.db` may remain as cleanup/diagnostic files, but they are no longer the
ordinary archive dry-run comparison source.

---

# Completion Definition

The graph migration is complete when these are all true.

## Data Spine

- Source-scoped import is the normal import path.
- Conversation graph projection is the normal working projection path.
- Incremental live updates populate `macos_import_ss.db` and `working_ss.db`.
- Existing data reset/onboarding/maintenance flows understand the graph DBs.
- Legacy `macos_import.db` and `working.db` are no longer required for ordinary
  app use.

## User-Facing Reads

- Conversations sidebar reads graph facts.
- Contacts sidebar reads graph facts plus overlay intent.
- Contact all-messages reads graph evidence.
- Contact handle-filtered messages reads graph evidence.
- Conversation messages read graph evidence.
- Global messages read graph evidence.
- Handle messages read graph evidence.
- Search results resolve to graph message scopes.
- Recovered/deleted message review reads graph-orphan evidence through the
  shared evidence spine.

## Presentation

- Every message-bearing center-panel surface uses the Message Evidence Spine.
- There is one shared message header renderer.
- There is one shared row/media evidence renderer.
- There are no contact-only, conversation-only, search-only, or recovered-only
  message renderers in production UI.

## Identity

- User display-name override wins everywhere.
- Conversation titles, sender labels, contact hero cards, search labels, and
  recovered-message context labels all use the same display identity resolver.
- Raw handles are primary only for truly unfamiliar sources or explicit
  handle-oriented controls.

## User Intent

- Contact favourites, conversation favourites, display-name overrides, manual
  links, dismissals, and future tags live only in overlay.
- Import/projection does not consult overlay state.
- Read models merge graph facts and overlay intent.

## Diagnostics and Health

- Graph health report covers source/import/working graph integrity.
- Graph readiness distinguishes "not built", "building", "ready", and
  "needs repair" states.
- Legacy-vs-graph comparison reports are diagnostic only.
- Critical graph health failures block unsafe graph promotion.

## Retirement And Retention

- Retired legacy execution code should be deleted when it no longer owns any
  named behavior.
- Retired `macos_import.db` / `working.db` files are historical storage,
  not ordinary app authority.
- Remaining retired code or storage is explicitly classified as:
  - retired cleanup/diagnostic storage
  - recovery/archive dependency
  - diagnostic/reference path
  - deletion/export/freeze candidate
- Deletion is not the default for retained user data. Retained files are
  reduced only after the retention register's user-safe criteria are met.

---

# Recommended Completion Strategy

Do not try to replace every legacy system at once.

The safest order is:

```text
stabilize current graph branch
→ productionize graph build lifecycle
→ migrate remaining read/query surfaces
→ migrate search and identity fully
→ migrate archive/recovery flows
→ retire legacy import/projection execution
→ reduce retired historical storage under explicit retention criteria
```

The reason is simple:

- message evidence is already mostly graph-backed
- user-facing value is already visible
- the largest remaining risk is not UI capability
- the largest remaining risk is lifecycle/data-integrity convergence

---

# Phase 0 - Stabilize the Current Graph Transition Branch

## Goal

Turn the current graph migration work into a reliable checkpoint before adding
more feature behavior.

## Why This Comes First

The branch currently contains many intertwined changes:

- graph import/projection work
- message evidence spine work
- retained legacy reduction work
- identity display work
- conversation topology UI work
- header/presentation work

Before larger architectural slices continue, the repository needs a clean
validated checkpoint.

## Work

1. Run code generation where generated providers are stale.
2. Run `dart analyze` / `flutter analyze` on affected areas.
3. Run focused graph/evidence/contact/identity tests.
4. Run a real graph import + projection.
5. Smoke test:
   - Conversations sidebar
   - Contact all messages
   - Contact by conversation
   - Contact handle filter
   - Search all messages
   - Unfamiliar sources
   - Recovered messages
   - Attachments/media evidence
6. Update retirement docs to match actual deleted code.
7. Commit the graph transition checkpoint.

## Exit Criteria

- The branch is analyzable.
- Core tests pass.
- The app launches.
- The graph build can run.
- Primary message evidence views work.
- The worktree is clean after commit.

---

# Phase 1 - Productionize Graph Build Lifecycle

## Goal

Make the source-scoped import and graph projection a first-class app lifecycle
path rather than a dev-panel proof flow.

## Current State

There is a `ConversationGraphBuildService` that runs:

```text
import chats
import handles
import contacts
import messages
enrich missing text
import attachments
import topology joins
project graph entities
project graph edges
```

This is the right conceptual shape.

Current status update:

- graph build/readiness/update flow is production-owned for ordinary app use.
- onboarding and settings reimport call the graph build controller directly.
- `ChatDbChangeMonitor` triggers source-scoped graph import/projection after
  live `chat.db` changes.
- reset/clear flows deliberately close and clear source-scoped graph stores.
- evidence surfaces refresh through graph/message data-version invalidation.

The remaining lifecycle work is not ordinary graph ownership. It is retained
cleanup/diagnostic policy for old `macos_import.db` / `working.db` files and
continued hardening of diagnostics around the graph lifecycle.

## Completed Work

1. Define graph build state:
   - not built
   - building
   - ready
   - needs incremental update
   - failed
   - maintenance unavailable
2. Integrate graph build state into the central database/readiness providers.
3. Make onboarding aware of graph readiness.
4. Make reset/clear flows clear graph DBs deliberately, not accidentally.
5. Make the existing change monitor trigger graph import/projection after live
   `chat.db` changes.
6. Ensure `messageDataVersionProvider` or its successor invalidates graph
   evidence surfaces after graph projection completes.
7. Keep the dev panel as instrumentation, not the only way to run graph build.

## Guardrails

- Do not let graph build mutate overlay.
- Do not make widgets trigger graph repair imperatively.
- Do not mix legacy and graph import in one unclear executor.
- Do not hide graph build errors behind "no data" UI.

## Tests

- graph build service idempotence
- graph build after one new source message
- graph build state transitions
- readiness provider behavior
- evidence invalidation after graph projection
- reset/maintenance closes providers cleanly

---

# Phase 2 - Finish Graph Read Surface Migration

## Goal

Remove ordinary user-facing reliance on `working.db` read models.

## Current State

Message evidence views are graph-backed for ordinary product surfaces.

Closed ordinary read migrations:

- search service
- contact list/profile providers
- handle/stray/manual-link providers
- older chat/recent-chat providers
- global/contact heatmaps
- recovered deleted/no-handle evidence presentation

Remaining legacy dependencies are no longer ordinary reads. They are lifecycle,
archive/recovery, diagnostics/settings, retained legacy schema, or tests for
retained systems.

## Recommended Order

### 2A - Search

Search is high priority because it selects message evidence.

Target:

```text
search query
→ graph message ids / graph context scopes
→ MessageEvidenceScope
→ shared evidence spine
```

Search now avoids legacy `working.db` message identity for ordinary message
results.

Search may still query overlay for saved/tagged/user-intent filters through
named graph-compatible overlay bridges.

### 2B - Contacts

Contact picker, contact hero, and contact profile surfaces should read from:

```text
working_ss.db graph facts
∪ user_overlays.db user intent
```

The contact view should not depend on legacy `working.db` for ordinary
navigation once graph contact projection is stable.

Status: complete for ordinary UI. Future contact work should extend graph
identity/display resolvers rather than reintroducing legacy participant reads.

### 2C - Handles

Handle management should migrate carefully because handles are where graph
identity, canonicalization, aliases, manual links, and unfamiliar-source
workflows meet.

Target:

- handle list from graph handles/canonical handles
- unfamiliar-source evidence from graph handle scopes
- manual contact/handle links in overlay
- spam/dismissal flags in overlay

Status: complete for ordinary UI. Future handle work should preserve the
distinction between graph handle identity, canonical aliases, normalized
address semantics, and overlay user intent.

### 2D - Chats / Recent Chats

The legacy chats feature should either become a graph conversation summary view
or be retired.

Avoid preserving two concepts:

```text
legacy chat
graph conversation
```

as separate product entities.

The product-facing entity should be conversation.

Status: complete for ordinary product conversation reads. Legacy chat concepts
remain only as retained schema/diagnostic reference until broader legacy
retirement.

### 2E - Recovered Messages

Recovered-message evidence now uses graph-orphan message evidence and the
shared Message Evidence Spine.

Long-term, recovered sources should become additional source-scoped imports
with their own `source_id`, allowing recovered messages and attachments to
enter the graph without special presentation logic.

---

# Phase 3 - Normalize Display Identity

## Goal

Create one app-wide semantic answer to:

```text
What name should the user see?
```

## Current State

A graph-aware display identity resolver exists and ordinary product identity
surfaces now resolve through graph facts plus overlay intent.

User override names win in contact picker, hero/profile, conversation
signatures, conversation headers, sender labels, handle displays, and ordinary
message evidence surfaces. Raw handles remain visible as explicit handle-scope
controls, unfamiliar-source labels, developer diagnostics, or fallback
metadata.

The remaining work is stewardship: keep future surfaces on the resolver,
continue retiring old name-variant fields/bridges where safe, and prevent raw
handle fallback from becoming the primary label for known contacts.

## Completed Work / Guardrails

1. Ensure every user-facing name path uses the resolver:
   - conversation signatures
   - conversation headers
   - contact hero cards
   - contact picker rows
   - sender lines
   - search results
   - recovered-message labels
   - unfamiliar-source promotion/linking flows
2. Preserve exactly one user-defined contact name override:
   - `participant_overrides.display_name_override`
3. Deprecate old user-facing name variants such as short-name/nickname if they
   are no longer product concepts.
4. Keep raw handles visible only as:
   - explicit handle scope controls
   - unfamiliar-source labels
   - developer diagnostics
   - secondary metadata where useful

## Tests

- user display override wins in contact picker
- override wins in conversation signature
- override wins in conversation header
- override wins in message sender line
- raw handle is used only when no known contact exists
- explicit handle filter still displays the selected handle

---

# Phase 4 - Preserve and Migrate Data-Integrity Semantics

## Goal

Move hard-won legacy semantics into graph architecture without recreating the
legacy schema.

Legacy parity does not mean field parity.

## Required Semantic Areas

### Message Semantics

Already preserved or partly preserved:

- rich text extraction
- semantic kind
- item kind
- system/sparse artifact flags
- associated message `ss_id`
- attributed body presence
- message summary info presence
- payload presence
- error code

Continue to preserve source facts in `macos_import_ss.db` and lightweight
query-oriented semantics in `working_ss.db`.

Do not resurrect large Apple payload structures without a named product or
investigative use case.

### Handle Canonicalization

The graph now includes:

- handles
- canonical handles
- handle aliases

This must preserve the legacy insight:

```text
multiple Apple handles may represent the same reachable person/channel
```

Graph topology should link chats/messages through canonical handle semantics
where that is the intended product behavior, while retaining alias records for
traceability.

### Contacts

Graph contact projection must preserve meaningful contacts, not only contacts
that already have current chat handles.

Filtering out all non-chat contacts during projection risks losing future
attribution when a known contact later texts.

Projection may omit meaningless AddressBook rows, such as rows with no useful
display identity, but it should not throw away meaningful contacts merely
because they currently have no messages.

### Attachments

Graph attachments exist, but archive/recovery semantics remain high risk.

Attachment work should preserve:

- source attachment facts
- message-to-attachment topology
- archive availability
- local/source path hints
- deterministic recovery provenance

Do not treat missing attachment files as message absence.

---

# Phase 5 - Multi-Source and Historical Archive Import

## Goal

Promote the architecture from "live chat.db plus graph" to real multi-source
support.

## Why This Matters

The entire source-scoped identity model exists to make this safe:

```text
source 1 row 42 != source 2 row 42
```

The graph should eventually accept:

- live `~/Library/Messages/chat.db`
- recovered Messages folders
- historical backups
- multiple device exports
- later archive sources

without GUID collision bugs or endpoint remapping layers.

## Work

1. Replace `known_sources.dart` constants with a real source registry when
   archive import arrives.
2. Keep `source_id` numeric and stable.
3. Import source facts into `macos_import_ss.db` by source.
4. Project every source occurrence into source-scoped graph identity.
5. Do not merge duplicate conversations/messages at base row identity.
6. Add semantic duplicate/grouping overlays later if needed.
7. Define source provenance read models for forensic/legal workflows.

## Attachment Archive Priority

Historical MessageLens `attachment_archive` backups should be treated as the
highest-value recovery source because they represent files already archived by
the app.

Recovered `Messages/Attachments` folders remain useful secondary recovery
sources, especially where the current live folder has iCloud-evicted files.

Both import paths must be idempotent.

---

# Phase 6 - Retire Legacy Import/Projection

## Goal

Remove legacy data spines only after graph lifecycle and graph read surfaces
are production-ready.

## Current Status

Legacy import/projection execution has been retired for ordinary app behavior:

- onboarding and settings reimport build the source-scoped graph directly.
- live change monitoring builds/invalidates the source-scoped graph.
- search/contact/handle/message evidence surfaces use graph selectors.
- Historical Archives import/removal uses source-scoped graph services.
- retained `working.db` has no central app provider.

The remaining retirement question is retained file/storage policy, not ordinary
execution ownership. Old `macos_import.db` / `working.db` files may still exist
for diagnostics, historical interpretation, reset cleanup, archive metadata, or
user-safe retention.

## Do Not Delete Retained Files Yet If

- archive/recovery identity or archive lookup still requires retained metadata.
- support diagnostics lack graph/source-scoped equivalents.
- historical-reference value has not been migrated, exported, or explicitly
  rejected.
- no user-safe backup/retention path exists for users who may still need old
  recovery data.

## Retirement Sequence

Completed for execution code:

1. Mark legacy user-facing read providers as diagnostic/reference only.
2. Move ordinary import/projection to source-scoped graph lifecycle.
3. Convert Historical Archives import/removal to source-scoped graph services.
4. Stop ordinary app flows from creating/updating `working.db`.
5. Remove old presentation code and providers.
6. Remove old read repositories.
7. Remove old import/migration execution code.

Remaining for retained cleanup/diagnostic storage:

1. Keep retained storage uses registered and bounded.
2. Replace retained metadata keys with graph/source-scoped equivalents where
   practical.
3. Preserve or export historical-reference value before deletion.
4. Define a user-safe backup/retention cleanup path.

## Important Constraint

Legacy importers and migrators are not disposable until their data-integrity
semantics have been audited and either:

- preserved in the graph pipeline, or
- intentionally rejected with a documented reason.

This constraint has been satisfied for the retired ordinary execution paths.
Keep applying it to any future retained-storage deletion or archive/recovery
rewrite.

---

# Completed High-Leverage Slices

The following early roadmap slices are now complete for ordinary app behavior:

- branch checkpointing and dependency matrix
- graph-native search/search identity
- graph-native contact and handle identity
- graph lifecycle integration
- ordinary read migration
- archive/recovery identity planning
- retained import/projection execution retirement

## Remaining Recommended Slices

1. Retained cleanup/diagnostic policy:
   decide what to keep, export, or delete for old `macos_import.db` /
   `working.db` files.
2. Archive overlay key evolution:
   continue moving archive lookup toward graph/source-scoped identity while
   preserving existing archive records.
3. Historical/recovered source intake:
   keep recovered Messages folders as explicit source-scoped sources, not
   ordinary legacy projection inputs.
4. Diagnostic hardening:
   keep graph health, support bundles, and retained-file reports accurate
   without giving retained files app-authority semantics.

---

# Risk Register

## Risk: Retained Storage Policy Lags Behind Graph Ownership

Ordinary app behavior now runs through the graph, but old `macos_import.db` and
`working.db` files can still exist for retained metadata, diagnostics,
historical interpretation, reset cleanup, or user-safe retention. If those
roles stay vague, future work may accidentally treat retained files as
authoritative again.

Mitigation:

- keep retained file purposes registered and bounded.
- move archive/recovery metadata toward graph/source-scoped identity where
  practical.
- do not delete retained files until backup/export/retention criteria are
  explicit.

## Risk: Retained Storage Deletion Before Semantic Capture

Some legacy systems encode hard-won behavior that is easy to miss.

Mitigation:

- use the legacy parity audit
- preserve semantics, not field shape
- delete/export/freeze retained storage only after graph tests prove equivalent
  behavior and user-safe retention criteria are met

## Risk: Reintroducing Pagination as Timeline Navigation

This regression already happened once.

Mitigation:

- every timeline-like surface must use full-scope skeletons
- tests must fail if a selected logical scope is silently capped

## Risk: Identity Resolver Bypass

Conversation titles and sender labels can drift back to raw handles if widgets
format participant data directly.

Mitigation:

- keep display identity semantic and centralized
- widgets render typed display data only

## Risk: Overlay/Working Cross-Contamination

Favourites, names, manual links, and dismissals are user intent. If projection
starts consulting overlay, graph reproducibility is lost.

Mitigation:

- import/projection never reads overlay
- read models merge overlay after graph facts exist

## Risk: Attachment Recovery Becomes a Distraction

Attachment recovery is important, but it can consume the project before the
basic graph app is production-complete.

Mitigation:

- keep graph attachment evidence working
- document recovery sources
- defer historical recovery import until the core graph app path is stable

---

# Architectural Tests to Add or Preserve

## Graph Identity

- `ss_id` survives import and projection unchanged.
- duplicate GUIDs across sources do not collide.
- relationship endpoints project to `ss_id` endpoints.

## Graph Build

- graph build is idempotent.
- graph build resumes from source-scoped cursor positions.
- graph build imports one new live message and projects it.
- graph build does not mutate overlay.

## Evidence Spine

- every message-bearing route builds a `MessageEvidenceScope`.
- every timeline-like route uses a full skeleton.
- visible rows hydrate by stable message ID.
- attachments hydrate outside widgets.
- search matches apply to full scope, not loaded rows.

## Identity

- display override wins everywhere.
- raw handle wins only for unfamiliar/handle-specific contexts.
- conversation titles use resolved participant identity.

## Overlay

- conversation favourite appears everywhere that conversation appears.
- contact favourite appears everywhere that contact appears.
- overlay survives graph rebuild.

## Legacy Retirement

- no production message renderer uses deleted legacy `MessageCard` or
  `MessagesTimelineView`.
- no new feature imports legacy message repositories.
- remaining legacy DB access is classified and documented.

---

# Recommended End State

The intended end state is:

```text
Apple / archive sources
→ source-scoped import ledger
→ source-scoped conversation graph
→ semantic read models
→ shared evidence and topology presentation
→ overlay user intent merged at read time
```

At that point:

- Conversations can be the launch/default mode.
- Contacts remain a powerful secondary lens.
- Handles remain searchable metadata and unfamiliar-source anchors.
- Search becomes graph-native.
- Attachments are graph evidence with archive availability.
- Historical archives become additional source-scoped inputs.
- Legacy `working.db` becomes unnecessary for ordinary app use.

The app then stops feeling like a Messages database viewer and becomes the
intended product:

```text
a traversable communication graph and evidence exploration system
```
