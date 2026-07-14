---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2026-04-02
source_of_truth: doc
links:
  - ../../00-PROJECT/02-architecture-overview.md
  - ../../50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/00-cross-surface-spec-system.md
  - ../../52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/00-universal-spec-handling-pattern.md
  - ../../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md
  - ../../56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/00-view-spec-panel-architecture.md
  - ../sidebar-flow-state-introduction/PROPOSAL.md
  - ../global-messages-timeline/PROPOSAL.md
tests: []
feature: messages-workspace-decoupling
status: proposed
created: 2026-04-02
---

# Feature Proposal - Messages Workspace Decoupling

**Proposed Branch**: `Ftr.messages-workspace-decoupling`
**Status**: Proposed
**Created**: 2026-04-02

---

## Overview

Restructure the messages workspace so cheap control paths stay cheap.

Today, the message-reading experience still lets low-cost UI concerns depend too directly on high-cost content work:

- sidebar meaning is partly reconstructed across multiple owners
- panel routing and sidebar flow can still reconcile each other after the fact
- visible-month tracking can be pulled back toward row hydration
- row hydration still pulls attachment and archive-resolution work into the same path as message rendering
- recovered deleted surfaces still behave like a sibling timeline engine rather than the same engine under a different scope

This proposal introduces a more coherent split:

- one canonical messages route authority
- one lightweight timeline index plane for scrolling, anchoring, and visible-month state
- one row-local hydration plane for expensive message content work
- one dedicated media-availability service for live-path versus archive-path resolution
- one shared timeline engine for regular, recovered, and later global/search-adjacent message surfaces

The goal is not just speed.

The goal is to make control responsiveness, scroll behavior, and surface meaning deterministic even when archive-backed media or large historical datasets are present.

## User Value

### Problem

Recent runtime behavior exposed the same underlying weakness in several different forms:

- sidebar controls such as `Change contact...` could become sticky or stale under broader timeline pressure
- heat-map month tracking could work briefly, then stop updating after scrolling
- recovered deleted messages used a different month-tracking path than the normal timeline
- archive-backed media made the app feel materially worse even when the underlying data recovery was successful
- local fixes improved individual symptoms, but the workspace still remained vulnerable because control state and expensive content state were not cleanly separated

This makes the app hard to trust and hard to extend.

### Proposed User-Facing Outcome

This feature should make the messages workspace feel stable under load:

- changing contact, scope, or handle stays responsive even while rows are hydrating
- heat-map and month-jump behavior stays live while the timeline scrolls
- recovered deleted and normal message browsing feel like the same product, not two near-duplicate systems
- archive-backed media can exist at scale without forcing control surfaces through expensive file-resolution work
- new message surfaces can be added with clearer ownership boundaries

### Benefits

- fewer sticky or dead controls
- fewer stale cross-surface states
- less duplicate timeline logic
- a safer base for archive-backed attachments, global timelines, and search-context work
- clearer architectural ownership for future contributors

---

## Existing Architecture Summary

- View navigation is already spec-driven, but the messages workspace still distributes meaning across sidebar flow state, panel state, list listeners, and surface-local state.
- The timeline already has the beginnings of an ordinal/index model, but too much cheap UI still reaches back into hydrated row data.
- Row hydration currently remains responsible for more than message content alone; attachment and archive-path work can ride the same path.
- Normal contact-scoped messages and recovered deleted messages do not yet fully share the same timeline engine or month-tracking rules.
- Recent fixes improved specific hot spots, but they did not remove the deeper multi-owner coupling.

## Assumptions

1. The app should keep the ViewSpec and cross-surface spec architecture rather than replacing it with local widget-managed navigation.
2. `working.db` remains a projection of source data only; user intent and archive metadata remain overlay-owned.
3. Recovered deleted messages remain a distinct semantic scope, but they should not require a separate timeline architecture.
4. The first implementation focus is runtime resilience and ownership clarity, not a broad visual redesign.
5. It is acceptable to land this in phases so the route split and timeline split stabilize before deeper media refactors finish.

## Hard Invariants

1. Do not violate overlay versus working-db separation.
2. Do not suppress anomalous records because they are expensive or awkward to render.
3. Do not let sidebar widgets or panel widgets become the primary owners of messages-route meaning.
4. Do not let visible-month, jump-anchor, or control responsiveness depend on full message hydration.
5. Do not keep a second, separately-owned recovered timeline engine after this feature is complete.
6. Do not bypass centralized database providers or the documented ViewSpec routing pattern.

---

## Scope

### Phase 1 - Canonical Messages Route Authority

1. **Introduce one route owner**
   Define a canonical route model for the messages workspace that carries the user-meaningful state needed to derive sidebar and panel behavior.

2. **Derive surfaces from route state**
   Make the sidebar cassette branch and center-panel ViewSpec a deterministic projection of the same messages route meaning.

3. **Stabilize control-state ownership**
   Ensure that contact changes, handle selection, recovered/regular mode switches, and month-jump intent are represented as explicit transitions instead of multi-owner repair.

### Phase 2 - Timeline Index Plane

1. **Separate index metadata from row content**
   Move scrolling, top-visible tracking, ordinal anchoring, and month lookup onto a lightweight timeline index plane.

2. **Keep cheap reads cheap**
   Visible-month and jump logic should work from lightweight timeline metadata such as ordinal, message id, and `sent_at_utc`, not hydrated row models.

3. **Preserve display-version semantics**
   Import refreshes and display-version freezes should not recreate controllers or replay initial jump behavior incorrectly.

### Phase 3 - Row-Local Hydration Plane

1. **Hydrate rows by message id**
   Make row hydration a local, cancelable concern keyed by stable row identity.

2. **Stop using hydration as control infrastructure**
   Hydrated message rows should enrich what the user sees, but they should not be the dependency path for route, month, or scroll ownership.

3. **Handle partial readiness honestly**
   Rows should be able to render skeleton, text-ready, attachment-ready, and diagnostic states without blocking the rest of the workspace.

### Phase 4 - Dedicated Media Availability Service

1. **Split media resolution out of row mapping**
   Live attachment path checks, archive path checks, and metadata caching should move into a dedicated service layer.

2. **Cache and dedupe file availability work**
   Archive-backed media should not trigger repeated synchronous existence checks during normal widget rebuilds.

3. **Return stable availability models**
   Message rows and display widgets should consume an explicit media-availability result rather than performing ad hoc resolution.

### Phase 5 - Recovered Timeline Unification

1. **Reuse the same timeline engine**
   Recovered deleted messages should use the same route, index, and hydration structure as the normal timeline, with a different query strategy and chrome.

2. **Unify visible-month behavior**
   Regular and recovered surfaces should follow the same month-tracking rules and control contracts.

3. **Reduce branch-specific drift**
   Scope-specific UI should live in route meaning and widget composition, not in separate scroll and state engines.

### Out Of Scope

- redesigning the visual identity of the messages UI
- changing import or migration schema unless a narrowly targeted supporting field is required
- rewriting unrelated sidebar branches outside the messages workspace
- reintroducing thread-centric UI that the app intentionally removed
- solving every future search or global timeline feature in this first pass

---

## Proposed Direction

### Core Principle

The messages workspace should be driven by declared route meaning and lightweight timeline metadata first, with expensive content hydration layered on afterward.

### Route Layer

Introduce a canonical messages-route model that answers questions such as:

- which top-level message surface is active
- which contact, if any, is active
- whether all handles or one handle are selected
- whether the route is regular, recovered, deleted, global, or search-adjacent
- whether there is an explicit jump anchor such as a month or target message

The important point is not the exact field list.

The important point is that the route model becomes the shared meaning from which sidebar and panel surfaces are projected.

### Timeline Index Layer

The timeline index layer should own:

- ordered row identity
- lightweight row metadata needed for scroll/jump/month work
- top-visible tracking
- anchor restoration behavior
- frozen display-version coordination

It should not own full attachment or message-content enrichment.

### Hydration Layer

Hydration becomes a row-local enrichment step:

- fetch message text and participant presentation data
- fetch attachment metadata
- request media availability from the media service
- emit a stable row-ready model for rendering

If a row hydrates slowly, the list should still scroll and the rest of the workspace should still respond.

### Media Availability Layer

Archive-backed media resolution should become its own provider/service boundary.

That layer should answer questions like:

- is there a live local path
- is there an archived local path
- what is the best currently readable file candidate
- what dimensions or preview metadata are already known

This avoids forcing each message-row mapping pass or widget rebuild to rediscover the same file facts.

### Surface Unification

Recovered deleted messages should stop being a sibling implementation with its own scroll and month semantics.

Instead:

- the route decides the scope
- the query strategy decides the backing dataset
- the shared timeline engine handles index and hydration
- feature-level chrome decides how the surface is explained to the user

That keeps the app honest about scope differences without paying for duplicate machinery.

---

## Architecture Impact

| Area | Planned Change |
| --- | --- |
| Sidebar flow / panel routing | derive from one canonical messages-route owner |
| Timeline ordinal state | narrow to lightweight index metadata and anchoring |
| Visible-month tracking | depend on index metadata only |
| Row hydration | become row-local, cancelable enrichment keyed by message id |
| Attachment/media resolution | move into a dedicated availability service with caching |
| Recovered deleted surface | reuse the shared timeline engine rather than maintaining a sibling implementation |
| Diagnostics | add instrumentation around hydration latency, media resolution work, and route/index churn |

---

## Risks

1. **Refactor overlap risk**
   Route, timeline, and media code touch many of the same surfaces, so phase boundaries need to stay disciplined.

2. **Temporary duplication risk**
   During migration, the app may briefly carry both legacy and new paths. That should be explicit and short-lived.

3. **Invalidation risk**
   A badly shaped route or index provider could still trigger broad rebuilds. The new split must reduce churn, not rename it.

4. **Media cache correctness risk**
   Archive/live-path caching must stay accurate when files appear, disappear, or recover.

5. **Recovered-surface parity risk**
   Unifying the engine without losing the recovered surface's special semantics requires careful scope boundaries.

---

## Scope Decisions Needed

1. Confirm the minimum phase-1 route fields, especially whether visible month belongs in canonical route state or remains derived index state.
2. Confirm whether recovered deleted unification is required in the same implementation stream or can follow once route and index separation land.
3. Confirm whether search and global timelines should adopt the new engine immediately or only once the contact/recovered surfaces are stable.

## Acceptance Criteria

- changing contact, handle, or scope remains responsive while rows hydrate and archive-backed media loads
- visible-month and month-jump behavior do not depend on full row hydration
- recovered deleted messages use the same core timeline engine as the normal surface
- archive-backed media no longer causes repeated synchronous availability work during ordinary scrolling
- sidebar and panel meaning remain coherent because both derive from the same route authority
- the feature lands in phases with tests that protect route, index, hydration, and media boundaries separately