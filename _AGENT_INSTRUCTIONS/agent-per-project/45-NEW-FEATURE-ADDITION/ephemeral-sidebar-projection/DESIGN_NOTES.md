---
tier: feature
scope: design
owner: agent-per-project
last_reviewed: 2026-04-19
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ../../55-EPHEMERAL-SPEC-HANDLING/00-ephemeral-spec-handling-architecture.md
  - ../../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md
tests: []
feature: ephemeral-sidebar-projection
status: proposed
created: 2026-04-18
---

# Design Notes - Ephemeral Sidebar Projection

## Core Decision

Temporary sidebar action flow must stop being modeled as a stable cassette expansion.

Stable projection and ephemeral projection are separate layers with separate storage and separate responsibilities.

The visible sidebar is always:

- stable projection
- followed by ephemeral projection

## What Gets Replaced

The prior settings-only path treated transient action flow as if it were a special kind of stable settings-menu expansion.

That approach introduced three architecture smells:

- the stable settings root spec carried temporary action meaning in the stable layer
- the dispatcher forced downstream rediscovery of durability
- mode exit required a settings-specific cleanup path to prevent transient UI from behaving like durable state

All three should be removed.

## Stable Projection

Stable projection remains the essentials-owned cassette stack derived from durable meaning.

In implementation terms, the existing `cassetteRackStateProvider(mode)` remains that stable projection provider.

This work does not replace it.

It should:

- be keyed by `SidebarMode`
- reconstruct from durable flow state
- derive each successor through the topology rule for the current spec
- remain safe to retain in providers
- never contain temporary one-off action flow

It may continue to be maintained through explicit rack mutations such as `replaceAtIndexAndCascade` where that is how the current stable branch expresses derivation.

That is acceptable as long as durable meaning never exists only in the rack.

It should not:

- encode send-logs or reset-message-data expansion
- depend on temporary UI lifecycle
- be scanned to recover durable meaning that already belongs in flow state
- perform list assembly or other imperative branch construction outside topology

## Ephemeral Projection

Ephemeral projection is a second cassette-spec layer used only for temporary sidebar-local flows.

It should:

- be keyed by `SidebarMode`
- store a live-only cassette chain derived from an ephemeral root spec
- be replace-only
- be cleared on mode change or when durable context makes the current temporary UI invalid

Even if the underlying stored value reuses the current `CassetteRack` shape, the ephemeral provider should expose a smaller public mutation surface than the stable rack provider.

The intended public operations are:

- replace the current ephemeral projection
- clear the current ephemeral projection

The ephemeral layer should not expose non-topological stable-rack editing operations or index-relative mutation as part of its public contract.

It should not:

- write to `SidebarFlowState`
- serialize into any stable settings spec
- become the source of truth for application meaning

It must also not feed back into stable topology, stable projection updates, or durable state transitions.

## Intent Ownership

Durability belongs to semantic intent.

That means the UI should emit typed intents directly.

The row model may still declare whether a row is persistent or ephemeral for render and mapping convenience, but the dispatcher should not receive a generic intent plus a durability hint. It should receive a persistent intent type or an ephemeral intent type.

Inert rows such as group headers should produce no intent at all. They are not persistent choices and they are not ephemeral actions.

## Coordinator Composition

The coordinator remains the single app-level sidebar composition point.

It should:

1. read stable projection for the active mode
2. read ephemeral projection for the active mode
3. obtain one merged stable-first ordered visible-spec list from a small essentials helper/provider above the resolution loop
4. resolve every spec through the existing feature coordinator pipeline

This preserves the existing render architecture while changing only projection ownership.

That helper/provider is the recommended owner of the merged ordered list before resolution. The coordinator remains the only composition point that turns those specs into payloads.

## Topology Split

Stable topology and ephemeral topology must not share meaning.

Stable topology derives durable branches from durable context.

Ephemeral topology derives temporary chains from an ephemeral root.

Ephemeral topology must be explicitly isolated as its own topology path. It may reuse helper patterns from stable topology, but it must not be threaded through the same resolution path.

The important rule is that stable topology must never descend from an ephemeral root. Ephemeral projection is terminal.

Stable topology must never consult ephemeral provider state.

Stable topology may consult durable flow state, but only for the immediate next-child decision of the current spec.

That consultation is intentionally narrow. A topology rule may read only the durable fact required to answer, "what comes next from here?" It must not widen that into branch construction, chain prediction, truncation, omission logic, or any other multi-step reasoning.

Ephemeral topology may consult stable context when it needs rendering context, but it must never convert that consultation into durable branch meaning.

## Cassette Index Debt

Current `cassetteIndex` and previous-cassette index behavior should be treated as migration debt rather than an architectural building block.

The new projection split should minimize index-coupled logic and avoid introducing new behavior that depends on rack position to derive meaning.

Where existing index-based mechanics are still required to preserve current behavior, they should be kept narrowly scoped and called out as temporary constraints.

## First Migration Slice

The first slice should migrate the current settings one-off flows:

- send logs
- reset message data

The opening sequence should be constrained deliberately:

1. introduce the new ephemeral projection provider with the narrow API
2. introduce the small merged-spec helper/provider above the coordinator
3. update the coordinator to consume the merged ordered list
4. add the typed persistent and typed ephemeral base intent classes
5. migrate only the Settings menu emission path for send logs and reset message data
6. keep stable settings behavior unchanged except where required to isolate transient flows from the stable path

That slice is enough to prove the architecture if it also removes:

- transient action meaning from the stable settings root
- the mixed settings menu selection transport
- the settings-mode exit cleanup hack

## Testing Strategy

The old testing model assumed there was one authoritative rack.

The new testing model should separate:

- stable provider assertions
- ephemeral provider assertions
- resolved visible order assertions

The most important regressions to protect are:

- ephemeral replacement instead of accumulation
- no stable child beneath ephemeral roots
- mode change clears ephemeral projection only
- durable state still reconstructs stable settings context
- stable logic never consults ephemeral projection
- stable topology rules consult only the local durable fact needed for the current spec's immediate child
