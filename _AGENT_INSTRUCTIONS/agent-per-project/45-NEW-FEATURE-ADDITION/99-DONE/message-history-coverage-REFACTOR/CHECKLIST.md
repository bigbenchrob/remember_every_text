# Checklist: Message History Coverage Refactor

## Phase 1: Durable Routing And Baseline Panel

- [ ] Convert `Message history coverage…` from transient settings transport to durable settings context.
- [ ] Update stable settings topology so the coverage cassette becomes a durable child of the settings root.
- [ ] Add a settings-owned center-panel spec and route it through the global `ViewSpec` pipeline.
- [ ] Extend center-panel reconciliation so settings mode can derive a flow-managed center spec from durable state.
- [ ] Add a baseline Message History Coverage center panel using the existing coverage report facts.
- [ ] Keep the existing sidebar coverage cassette working as the stable child for this phase.
- [ ] Add focused routing tests for settings selection, stable sidebar topology, and derived settings center-panel state.

## Phase 2: Presentation View Model

- [ ] Define `MessageCoveragePanelViewModel` and related segment/action models.
- [ ] Move status-label, headline, notes, and overlap handling into the view-model shaping layer.
- [ ] Add tests for complete, overlap, incomplete import, incomplete source history, unknown, zero-message, and null-date cases.

## Phase 3: Rich Reconciliation Panel

- [ ] Replace the baseline panel body with hero status, accounting bar, reconciliation statement, timeline coverage strip, and recovered-message explanation.
- [ ] Keep `missing = 0` as the primary trust anchor even when `accounted > chatDbTotal`.
- [ ] Add or adapt actions for export and any approved follow-on routes.

## Phase 4: Sidebar Simplification And Final Polish

- [ ] Reduce the sidebar Message History Coverage surface to compact status plus entry.
- [ ] Confirm troubleshooting copy remains calm and does not imply data loss when local coverage is complete.
- [ ] Perform manual validation across complete, incomplete import, incomplete source history, and unknown states.
- [ ] Update `pubspec.yaml` version and `CHANGELOG.md` for the user-facing refactor before merge.

## Guardrails

- [ ] No database access from widgets.
- [ ] No new top-level `features/support` namespace in this slice.
- [ ] No import, migration, or schema changes.
- [ ] No panel routing shortcuts outside the spec pipeline.

\*\*\* Add File: /Users/rob/Development/FlutterProjects/remember_every_text/\_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/message-history-coverage-REFACTOR/DESIGN_NOTES.md

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

\*\*\* Add File: /Users/rob/Development/FlutterProjects/remember_every_text/\_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/message-history-coverage-REFACTOR/TESTS.md

# Tests: Message History Coverage Refactor

## Phase 1: Durable Routing

### Settings Menu Semantics

- Verify `Message history coverage…` dispatches durable settings selection rather than transient action transport.
- Verify `sendLogs` and `resetMessageData` remain transient.

### Stable Sidebar Topology

- Verify durable settings context `messageHistoryCoverage` reconstructs the Message History Coverage sidebar child.
- Verify transient settings actions still do not appear as durable stable children.

### Derived Center Panel

- Verify settings-mode effective center-panel state derives `ViewSpec.settings(SettingsViewSpec.messageHistoryCoverageReport())` when durable context is selected.
- Verify clearing or changing durable settings context removes the derived Message History Coverage center-panel route.
- Verify settings-mode center panel host renders the settings feature coordinator output for the derived coverage spec.

### Dispatcher

- Verify dispatching `SettingsPersistentContextChosen(actionId: messageHistoryCoverage)` updates flow state and stable sidebar cascade.
- Verify the same dispatch does not rely on ephemeral settings projection.

## Phase 2: Presentation Shaping

- Verify complete state produces a reassuring headline.
- Verify overlap state keeps the headline complete and emits a small overlap note instead of foregrounding `accounted > total`.
- Verify incomplete import makes `missing` visible and changes the headline accordingly.
- Verify incomplete source history emphasizes local-source limits rather than app loss.
- Verify unknown state preserves export availability and explanatory copy.
- Verify zero-message and null-date states remain valid.

## Phase 3: Rich Panel Rendering

- Verify the accounting bar never exceeds 100% total width.
- Verify the missing segment is omitted or minimized when missing is zero.
- Verify the timeline coverage strip shows earliest and latest labels clearly.
- Verify recovered-message explanation does not describe recovered rows as lost.

## Manual Validation

### Complete Coverage

- Open Settings -> Message History Coverage.
- Confirm the sidebar selection persists as durable settings context.
- Confirm the center panel opens automatically.
- Confirm the panel communicates that every message on this Mac has been accounted for.

### Incomplete Import

- Validate the center panel says some source messages could not be accounted for.
- Confirm missing count is visible and not drowned out by other counts.

### Incomplete Source History

- Confirm the panel communicates that MessageLens accounted for all messages available on this Mac while making it clear the Mac's history starts later than expected.
- Confirm troubleshooting guidance points users to other devices / sync checks, not destructive actions.

### Unknown / FDA Blocked

- Confirm the panel fails gracefully and still offers the approved export or follow-up path.

## Regression Checks

- Existing coverage report logic and export tests continue to pass or are updated intentionally.
- Existing settings-sidebar transient action behavior remains correct for `sendLogs` and `resetMessageData`.
- No widgets perform direct database access.
