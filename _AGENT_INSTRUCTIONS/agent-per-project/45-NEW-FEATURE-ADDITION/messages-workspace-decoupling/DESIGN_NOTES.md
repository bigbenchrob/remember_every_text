---
tier: feature
scope: design
owner: agent-per-project
last_reviewed: 2026-04-02
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ../sidebar-flow-state-introduction/PROPOSAL.md
  - ../global-messages-timeline/PROPOSAL.md
tests: []
---

# Design Notes - Messages Workspace Decoupling

## 1. Problem Framing

The recent regressions did not come from one bad widget.

They came from a structural pattern:

- route meaning is shared across sidebar flow state, panel state, and surface-local behavior
- lightweight controls still depend too much on heavier timeline state
- timeline state still depends too much on hydrated row content
- media availability still leaks into row-mapping and widget-build paths

That architecture can look acceptable on small data and still fail once archive-backed media and long historical timelines enter the picture.

## 2. Proposed Ownership Model

### 2.1. One Messages Route Authority

Introduce a canonical feature-owned route state for the messages workspace.

Candidate responsibilities:

- active message surface kind
- selected contact id
- selected handle id or all-handles mode
- recovered versus regular scope
- explicit jump target such as month key or message id
- any route discriminator needed to derive the sidebar branch and center-panel ViewSpec

Important non-goal:

- this state is not a dump of every transient UI field
- it should store only the meaning needed to derive surfaces deterministically

### 2.2. Projection Instead Of Repair

From this route owner, derive:

- the sidebar cassette branch
- the center-panel `MessagesSpec`
- any contextual sidebar spec needed for the active route

The workspace should stop depending on multiple stores repairing each other after user actions.

If the route is valid, the surface projection should be valid by construction.

## 3. Timeline Split

### 3.1. Index Plane

The index plane owns the cheap, scroll-critical facts:

- ordinal ordering
- stable row keys
- top visible ordinal
- month lookup metadata
- anchor restoration
- display-version coordination

The index plane should be able to answer:

- what row is at ordinal `N`
- what month key corresponds to the top visible row
- what ordinal should a month jump target
- how should the list restore after a scoped data refresh

None of those operations should require attachment hydration.

### 3.2. Hydration Plane

The hydration plane owns expensive, per-row enrichment:

- message text shaping
- participant and sender presentation
- attachment metadata
- media availability lookup
- diagnostic states for partial readiness

This plane should be keyed by stable row identity so it can be canceled or discarded when the row scrolls away or the route changes.

## 4. Media Availability Service

### 4.1. Why It Must Be Separate

Live attachment resolution and archive attachment resolution are not just row-mapping details.

They are a separate concern with their own costs:

- file existence checks
- archive-path lookup
- preview/dimension caching
- fallback order between live and archived locations

Keeping that work inside row mapping makes every timeline improvement fragile, because the heavy path can leak back into cheap control behavior through incidental dependencies.

### 4.2. Service Contract Direction

The media-availability layer should return explicit states such as:

- live file available
- archive file available
- both available
- metadata known but file not readable
- unresolved or error state

Message rows and display widgets can then render against an explicit result instead of probing the filesystem during rebuild.

## 5. Recovered Timeline Unification

Recovered deleted messages should remain a distinct user-facing scope, but they should not keep their own scroll and visible-month engine.

Target model:

- one shared timeline shell
- one shared visible-month contract
- one shared ordinal/index contract
- one shared row-hydration contract
- different dataset/query strategy based on route scope
- different explanatory chrome based on route scope

This reduces duplicate bugs and makes future performance work benefit both surfaces automatically.

## 6. Candidate Implementation Order

### 6.1. Route First

First, make route meaning explicit and projected:

- formalize the messages route state
- derive sidebar and panel outputs from it
- remove the most important multi-owner repair paths

This gives the rest of the refactor a clean place to land.

### 6.2. Index Second

Next, make visible-month and scroll ownership rely only on index metadata.

This should include:

- stable controller ownership
- month lookup via lightweight fields
- explicit anchor restoration rules
- no fallback to full message hydration for control behavior

### 6.3. Hydration Third

Once route and index are stable, move the expensive per-row work behind row-local hydration boundaries.

### 6.4. Media Fourth

Then pull archive/live attachment resolution into the dedicated service and remove synchronous file-resolution habits from ordinary widget paths.

### 6.5. Recovered Unification Fifth

Finally, migrate the recovered deleted surface onto the shared engine and delete the remaining sibling logic.

## 7. Files Likely To Change

This is directional, not exhaustive.

Likely change areas include:

- messages route / spec coordination providers
- sidebar flow projection providers for the messages branch
- panel widget reconciliation inputs where messages meaning is currently repaired indirectly
- timeline ordinal and visible-month providers
- row hydration providers keyed by message id
- attachment and archive availability helpers
- recovered deleted surface adapters and heat-map integration

## 8. What Success Looks Like

The architecture is healthier when these statements are true:

- changing contact or scope does not wait on row hydration
- month tracking does not need hydrated `MessageListItem` objects
- attachment resolution is not performed opportunistically in multiple layers
- recovered deleted and normal message browsing differ by scope and chrome, not by engine design
- a future global or search-adjacent timeline can reuse the same route/index/hydration structure

## 9. Open Questions

1. Should phase 1 route state include an explicit month-jump target, or should month remain fully index-derived except during one-shot transitions?
2. Should the shared engine absorb the global timeline immediately after contact and recovered parity, or remain a follow-on feature?
3. What is the smallest media-availability contract that removes synchronous file probing from widget builds without overdesigning the first slice?