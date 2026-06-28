---
tier: project
scope: source-scoped-graph-migration
status: active
last_reviewed: 2026-06-28
depends_on:
  - 69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md
  - 70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md
  - 71-LEGACY-DEPENDENCY-MATRIX.md
  - 72-GRAPH-CHOKE-POINTS-AND-RETIREMENT-BLOCKERS.md
  - 73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md
  - 74-OVERLAY-IDENTITY-KEY-AUDIT.md
  - 75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md
  - 76-RECOVERED-MESSAGE-GRAPH-IDENTITY-PLAN.md
  - 77-RECOVERED-MESSAGE-GRAPH-PARITY-AUDIT.md
---

# 78 - Graph Migration Pause and Remaining Work

## Purpose

This document records the current state of the MessageLens graph migration at a
natural pause point.

The source-scoped graph architecture is no longer experimental. The main user
surfaces now demonstrate that the app can operate from graph identity,
graph-backed evidence scopes, and shared message presentation.

The remaining work is therefore not more proof work. It is controlled
productionization, retirement of compatibility bridges, and careful preservation
of data-integrity behavior that legacy systems still provide.

## Executive Summary

MessageLens has crossed from:

```text
Can source-scoped graph identity support the app?
```

to:

```text
How do we make the source-scoped graph the sole production spine safely?
```

The major architectural questions are answered:

- `SourceScopedRowKey` / `ss_id` is canonical working-row identity.
- `macos_import_ss.db` preserves source facts and provenance.
- `working_ss.db` is the lean app graph.
- relationships use `ss_id` endpoints.
- user intent remains in overlay storage.
- message evidence converges through one spine.
- conversation-first navigation is viable and materially better than the
  legacy contact-first experience.

The remaining risks are concentrated in a finite set of choke points:

- graph lifecycle orchestration
- legacy database retirement
- archive/recovery identity bridging
- overlay identity finalization
- production readiness diagnostics

## What Is Now Established

### Source-Scoped Identity

`SourceScopedRowKey` is the canonical identity of source-derived projected
working rows.

It is:

- deterministic
- collision-free within documented bounds
- source-occurrence preserving
- provenance preserving by construction

It is not:

- a hash
- a GUID surrogate
- a semantic merge key
- a deduplication identity

Semantic grouping, duplicate detection, contact matching, and merge views must
remain above base row identity.

### Import and Working Graph Split

The graph-era database split is established:

```text
macos_import_ss.db = source facts + provenance
working_ss.db      = lean canonical app graph
user_overlays.db   = user intent
```

The import ledger keeps source-specific facts such as source row IDs, GUIDs,
raw relationship endpoints, and source metadata.

The working graph keeps app-ready graph entities and graph edges:

- messages
- chats
- handles
- canonical handles and aliases
- contacts
- attachments
- chat/message edges
- chat/handle edges
- message/attachment edges
- contact/handle edges

Relationship projection now works by transforming source-local endpoints into
`ss_id` endpoints. This restored the useful simplicity of the original
single-source Apple topology while remaining multi-source safe.

### Message Import, Enrichment, and Projection

Messages now follow the intended staged architecture:

```text
source message
→ import source facts
→ enrich missing text
→ project lean graph message
→ hydrate evidence rows on demand
```

Rich-text extraction is a separate enrichment stage, not part of the main
message importer. This preserves the import boundary while still making
attributed-body text available to graph evidence surfaces.

Message semantic preservation is now guided by the principle:

```text
semantic parity, not field parity
```

The graph must preserve source facts and useful semantics, but it must not
recreate legacy schema baggage merely because legacy once carried a field.

### Conversation Graph

The conversation graph is now a first-class read model.

It supports:

- conversation summaries
- conversation signatures
- participant-derived grouping
- canonical conversation message evidence
- contact-derived conversation lists
- favourites as user overlay intent
- search/filter/sort in the conversation sidebar

The Conversations mode now presents conversation signatures in the sidebar and
conversation messages in the center panel. This restores the desired grammar:

```text
sidebar = navigation / topology
center  = message evidence
```

Conversation signature display has also converged toward a shared
presentation widget that can be used in the Conversations sidebar and contact
conversation lists.

### Message Evidence Spine

The Message Evidence Spine is the most important UI/data convergence achieved
so far.

Message-bearing surfaces now route through typed message evidence scopes and a
shared presentation system.

The spine preserves the hard timeline invariant:

```text
full lightweight skeleton first
local row/media hydration second
```

Timeline-like scopes preserve the full selected logical message universe even
when visible rows and media are hydrated incrementally.

The heatmap, jumps, match navigation, and temporal orientation all coordinate
with the full skeleton.

```text
Pagination is not timeline navigation.
```

The following surfaces now use the graph-backed/shared evidence path:

- Contact All Messages
- Contact selected-handle messages
- Contact By Conversation
- Conversations sidebar selections
- Global timeline
- Search result contexts
- Unfamiliar source / handle evidence
- Recovered deleted messages
- Recovered no-handle messages

The shared header and shared row rendering now give these surfaces a coherent
evidence-reading vocabulary.

### Attachments and Media Evidence

Graph message evidence now hydrates attachment facts outside presentation.

Conversation messages and other evidence surfaces can render:

- image attachments
- video attachments
- URL preview payload attachments
- fallback attachment evidence

The graph side reads attachment facts and archive availability through named
boundaries rather than presentation-layer hacks.

The existing `attachment_archive/` folder remains the shared physical archive.
Graph-era code currently uses compatibility lookup against existing archive
overlay records where necessary.

### Search

Search is now graph-native for ordinary evidence selection.

`SearchService` is a facade over graph search scopes rather than a legacy
working-row-id search service.

Search results select `message_ss_id` evidence and then route through the
Message Evidence Spine.

Intra-scope search also uses the selected logical scope, not just currently
hydrated visible rows.

### Contact and Display Identity

Display identity now has an explicit semantic resolver direction:

```text
What should the user see?
```

not:

```text
Which row owns this name?
```

The intended display precedence is:

```text
user-edited display name
→ known graph/contact identity
→ imported AddressBook display name
→ raw handle fallback
```

Known contacts should not appear as raw handles except in explicit handle-scope
controls or diagnostic contexts.

Short-name/nickname drift has been retired as a conceptual path. The user edit
point on the contact hero card is the single app-level override.

### Overlay Separation

The overlay database remains the home for user intent.

Examples:

- display-name overrides
- favourites
- manual contact/handle links
- saved/tag message intent
- dismissals

Import and graph projection must not read overlay state.

Readers merge graph facts and overlay intent at read time, with overlay intent
winning for user-facing display or selection.

## Remaining Work

### 1. Graph Lifecycle and Production Ownership

Current status update:

This choke point is now closed for ordinary app lifecycle. Onboarding, settings
reimport, live `chat.db` polling, graph readiness, and graph evidence
invalidation are graph-owned. Retained legacy import/migration remains only for
archive/recovery compatibility, diagnostics, legacy schema storage, and tests
for those retained systems.

Historical framing:

The graph UI and graph evidence path work, but the app must not remain
dependent on proof-panel or compatibility lifecycle behavior.

Remaining work:

- make graph import/projection the ordinary production lifecycle path
- ensure first-run, reset, rebuild, live update, and error recovery are
  graph-owned
- make graph readiness app-facing and actionable
- retire widget-triggered or dev-panel-triggered repair assumptions
- ensure `ChatDbChangeMonitor` and graph build orchestration are boring and
  reliable

Done means:

- the app can keep `working_ss.db` current without manual intervention
- graph readiness is centrally reported
- stale or failed graph state is visible and recoverable
- legacy import/projection no longer owns ordinary UI freshness

### 2. Legacy Database Retirement

Ordinary user-facing reads have largely moved to graph-backed systems.

However, legacy databases still matter in controlled areas:

- compatibility lifecycle
- archive/recovery bridges
- diagnostics/settings
- retained historical storage
- tests and definitions awaiting deletion

Remaining work:

- use `71-LEGACY-DEPENDENCY-MATRIX.md` as the deletion gate
- remove ordinary consumers first
- keep compatibility bridges named and bounded
- delete legacy definitions only after their blockers are closed

Done means:

- `working.db` and `macos_import.db` are not needed for ordinary app use
- remaining old DB/file references are cleanup/diagnostic inventory or
  explicitly bridged archive/overlay identity
- no feature silently depends on legacy identity

### 3. Archive and Recovery Identity

Attachment and recovered-message systems are data-integrity systems, not just
UI systems.

They should remain conservative.

Current state:

- graph attachments render in evidence rows
- existing `attachment_archive/` remains usable
- graph archive lookup can bridge to existing overlay archive records
- recovered deleted/no-handle message views are now graph-backed evidence
- historical recovered storage is still a retirement consideration

Remaining work:

- decide whether archive overlay identity should migrate to source-scoped
  attachment identity or retain an explicit compatibility key
- preserve all attachments archived since Apple began evicting files from
  `~/Library/Messages/Attachments`
- define import strategy for recovered Messages folders and historical
  MessageLens archive folders
- keep cross-snapshot mapping based on source-scoped identity where possible
- avoid treating recovered folder import as ordinary live-source import until
  its source identity rules are explicit

Done means:

- archived attachments remain reachable after retained storage retirement
- recovered-source imports can be linked to graph message/attachment identity
- archive/recovery bridges are either retired or documented as permanent
  compatibility boundaries

### 4. Overlay Identity Finalization

Overlay identity has been audited, but final retirement work remains.

Remaining areas:

- message annotations
- chat overrides
- saved/tag compatibility rows
- contact favourites
- manual links
- archive overlay records

Remaining work:

- ensure every overlay row has a graph-era identity target
- preserve user intent through any migration
- make duplicate-GUID behavior explicit and safe
- remove legacy-key bridges only after graph-keyed reads and writes are proven

Done means:

- overlay identity is graph-native or explicitly bridged
- no user intent depends on accidental legacy row identity
- overlay writes remain overlay-only

### 5. Product/UI Polish After Spine Stabilization

The conversation-first app is now usable and substantially stronger than the
legacy contact-first view.

Remaining polish should follow, not precede, lifecycle and dependency cleanup.

Likely future polish:

- richer conversation favourite/tag model
- further conversation signature refinement
- full contact/address-book identity integration into graph-native displays
- unified multi-participant message row language
- spam/handle visibility management as a real graph/overlay feature
- improved archive/recovery management UI

The shared header and evidence row systems should remain the only place for
evidence presentation changes.

## Current Risk Posture

The main risk is no longer that the graph model is wrong.

The main risks are:

- leaving lifecycle split between graph and legacy systems
- deleting legacy systems before archive/recovery blockers are resolved
- allowing compatibility bridges to become unnamed permanent architecture
- reintroducing source-specific message renderers
- reintroducing handle/GUID identity shortcuts
- treating pagination as timeline navigation
- letting overlay intent leak into import/projection

The project should now bias toward consolidation, not feature expansion.

## Recommended Next Order

1. **Stabilize graph lifecycle**

   Make graph build/readiness/update the production owner. This unlocks safe
   retirement more than any individual UI cleanup.

2. **Re-run the legacy dependency matrix against current code**

   The branch has moved quickly. Confirm the remaining legacy consumers before
   another deletion pass.

3. **Close archive/recovery identity decisions**

   Do not broadly delete legacy recovery/archive code until attachment archive
   and recovered-source identity rules are explicit.

4. **Finish overlay identity migration decisions**

   Make sure user intent has graph-native keys or named bridges.

5. **Retire legacy DB/read code in gated passes**

   Delete only after each dependency class has a closed blocker.

6. **Resume UI/product polish**

   Continue conversation-first polish after the data/lifecycle spine is boring.

## Non-Negotiable Invariants To Preserve

- `ss_id` is canonical working-row identity.
- GUIDs are metadata or bridge fields, not identity.
- import ledger preserves source facts and provenance.
- working graph remains lean and relationship-oriented.
- graph relationships use `ss_id` endpoints.
- user intent lives only in overlay storage.
- import/projection never consult overlay state.
- source-specific scopes are allowed; source-specific evidence renderers are
  not.
- timeline-like scopes preserve the full logical selected message universe.
- hydration limits are not scope limits.
- pagination is not timeline navigation.
- display identity is semantic, not relational.
- user-edited display name wins wherever a known contact is shown.
- raw SQL is acceptable inside named infrastructure repositories, not in
  widgets or application coordinators.

## Handoff Checklist

Before the next implementation burst:

1. Confirm the current branch is committed.
2. Smoke test:
   - Conversations sidebar
   - Conversation message evidence
   - Contact All Messages
   - Contact selected handle
   - Contact By Conversation
   - Search All Messages
   - Unfamiliar Sources
   - Recovered deleted messages
   - Recovered no-handle messages
   - media attachments
3. Re-run a targeted legacy dependency search.
4. Choose the next slice from lifecycle or archive/recovery blockers, not UI
   polish.
5. Treat every remaining legacy reference as one of:
   - retained lifecycle/archive compatibility
   - archive/recovery bridge
   - diagnostic/settings support
   - deletion candidate

## Bottom Line

The graph architecture has succeeded.

The app now has a coherent direction:

```text
source-scoped import ledger
→ lean working graph
→ graph evidence scopes
→ shared evidence presentation
→ overlay-only user intent
```

The remaining work is to make that direction the production default while
retiring legacy systems carefully enough that no data-integrity behavior is
lost.
