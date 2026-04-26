# Design Notes: Message History Coverage Refactor

## Architecture Summary

The current Message History Coverage flow has two useful assets already in place:

- a canonical coverage report computation path in the settings feature
- a typed settings entry point in the sidebar troubleshooting menu

What it lacks is a durable center-panel route and a presentation contract strong enough to support a trust-building report.

The refactor therefore keeps ownership inside `features/settings`, adds a settings-owned center-panel branch, and reuses the existing report facts rather than re-solving coverage computation.

## Why Keep Ownership In Settings

The attached wiring document suggests a new `features/support` namespace.

That is broader than this slice requires because:

- the current entry point already belongs to Settings / Support
- the codebase does not currently have a support feature module or `ViewSpec.support(...)` branch
- a new namespace would add review and maintenance surface before the richer panel value is delivered

The narrow path is:

- `ViewSpec.settings(...)`
- a settings-owned panel spec family
- a settings feature coordinator for center-panel content

If broader support diagnostics later accumulate, the route can be extracted then.

## Phase 1 Delivery Shape

Phase 1 is intentionally infrastructural.

It should establish:

- durable settings selection semantics for Message History Coverage
- stable sidebar child reconstruction from that durable selection
- a settings-owned center-panel route derived from flow state
- a baseline panel that shows the current coverage facts in the center panel

Phase 1 should not attempt the full visual redesign yet. The goal is to prove the durable route and center-panel ownership before the richer presentation lands.

## Sidebar Strategy During Transition

The final design wants a compact sidebar card. That is not required to land the routing slice.

For Phase 1:

- keep the existing sidebar Message History Coverage cassette as the stable child of the settings root
- add the center panel in parallel
- avoid expanding the existing sidebar copy further

This creates a safe intermediate state:

- durable selection works
- center-panel report exists
- later phases can simplify the sidebar without reopening routing work

## Center-Panel Routing Strategy

The center panel should be derived from flow state, not opened procedurally by widget code.

Recommended contract:

- `SidebarFlowState` gains a settings-mode projection for Message History Coverage
- `effectiveCenterPanelStackProvider(SidebarMode.settings)` resolves that derived spec similarly to message-mode flow-managed panels
- `ViewSpec.settings(...)` becomes the durable center-panel identity

This preserves the repo's current navigation model of state -> spec -> coordinator -> feature surface.

## Panel Contract For Phase 1

Phase 1 can use a baseline panel contract that is smaller than the final view model described in the seed.

The baseline panel should still:

- avoid database access in widgets
- centralize headline/body derivation outside the widget where practical
- be easy to replace with the richer view-model-driven layout later

That means Phase 1 may use a narrow panel model or provider-backed presentation contract as a stepping stone, so long as the final richer view model remains the target for later phases.

## Compatibility Rules

- `messageHistoryCoverage` becomes durable settings context.
- `sendLogs` and `resetMessageData` remain transient settings actions.
- settings stable topology should continue to derive child cassettes only from durable state.
- the center panel should treat the new settings coverage panel as flow-managed content for compatibility and reset decisions.

## Risks To Watch

### Mixed Durable / Transient Semantics

If Message History Coverage remains partly transient and partly durable, the settings flow will become harder to reason about.

### Duplicate Storytelling Across Sidebar And Panel

If the sidebar continues to carry most of the report detail after the center panel exists, the product outcome will still feel diluted.

### Cross-Cutting Exhaustiveness

Adding `ViewSpec.settings(...)` will require updates in every exhaustive `when`, `map`, and default-title path. Missing one of those will create runtime or compile failures that are easy to miss without focused validation.

## Release Metadata

This is a significant user-facing refactor. Before merge, the same change set must update:

- `pubspec.yaml`
- `CHANGELOG.md`

Phase 1 implementation can proceed first, but the release metadata must not be forgotten before the refactor branch is finalized.
