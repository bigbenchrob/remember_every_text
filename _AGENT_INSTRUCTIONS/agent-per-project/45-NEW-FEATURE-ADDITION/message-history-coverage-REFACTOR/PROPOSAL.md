---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2026-04-26
source_of_truth: doc
links:
  - ../../00-PROJECT/02-architecture-overview.md
  - ../../10-DATABASES/00-all-databases-accessed.md
  - ../message-history-coverage-check/PROPOSAL.md
  - ./seed.txt
  - ./coordinator-and-view-spec-wiring.txt
  - ./view-model-and-rendering-contract
tests: []
feature: message-history-coverage-refactor
status: approved
created: 2026-04-26
---

# Feature Proposal - Message History Coverage Center-Panel Refactor

**Branch**: `Ftr.msg-hist`
**Status**: Approved
**Created**: 2026-04-26

## Overview

Refactor the current Message History Coverage feature from a sidebar-heavy troubleshooting cassette into a stronger trust-building center-panel report.

The current implementation already computes useful reconciliation facts:

- total messages in this Mac's `chat.db`
- visible messages in normal MessageLens timelines
- recovered or unlinked messages
- missing-message count
- earliest and latest source dates
- a narrow JSON export

What it does not yet do is turn those facts into a calm, visual answer to the user's real question:

"Did MessageLens account for every message that exists on this Mac?"

This refactor should keep the existing Settings / Support entry point, keep the export path, and move the full trust experience into a durable center panel that reads as a reconciliation report rather than a debug summary.

## Problem

The current sidebar implementation is technically correct but product-wise underpowered.

It puts too much narrative weight on a transient settings cassette, which has three consequences:

1. The most reassuring message is visually competing with support-style sidebar chrome instead of being presented as a primary report.
2. Important distinctions such as visible vs recovered vs missing are present, but not organized into a strong visual explanation.
3. The existing exportable facts are not being used to create a strong in-app confidence moment.

As a result, MessageLens can still feel uncertain exactly when the numbers should be building trust.

## User Value

After this refactor, a user should be able to open Message History Coverage and immediately understand:

- how many messages exist in this Mac's local Messages database
- how many are visible in normal MessageLens timelines
- how many are recovered but not linked to ordinary chat timelines
- whether any source messages are actually missing from MessageLens
- what date range this Mac's local Messages history covers

The intended emotional takeaway is:

"MessageLens accounted for everything this Mac has. Nothing disappeared."

## Existing Architecture Summary

- The current Message History Coverage entry point lives in the Settings troubleshooting sidebar flow.
- The existing implementation is routed as an ephemeral settings cassette spec and rendered in the sidebar, not the center panel.
- Coverage computation already exists as a dedicated report-producing path in the settings feature and reads source and working data without involving widgets.
- Center-panel content elsewhere in the app is driven through durable `ViewSpec` state stored in `panelsViewStateProvider(...)` and rendered by `PanelCoordinator`.
- Feature-owned panel content follows the established pattern: spec -> coordinator -> resolver -> widget builder / presentation.
- The settings feature currently exposes sidebar cassette APIs but does not yet own a center-panel `ViewSpec` branch.

The controlling architectural choice for this refactor is therefore not how to compute the report, but how to move the report into the durable panel pipeline without widening scope unnecessarily.

## Evaluation Of The Attached Direction

The seed and supporting docs are directionally correct on the product outcome:

- keep Settings / Support as the entry point
- move the full report burden into the center panel
- introduce a presentation-specific view model
- keep widgets pure and move interpretation logic out of rendering
- normalize the accounting bar when `accounted > chatDbTotal`

One place where I recommend a narrower implementation than the supporting document proposes is feature ownership.

The document suggests a new `features/support` spec family. The current codebase does not have a support feature module or a support branch in the global `ViewSpec` union. Creating that new namespace now would add extra surface area that the refactor does not require.

**Recommended plan**: keep ownership under `features/settings` for this refactor, and add a durable settings-owned center-panel route. That delivers the desired product experience while minimizing structural churn. If a broader support center-panel family emerges later, the route can be extracted then.

## Assumptions

1. This refactor should preserve the existing coverage-report computation and export behavior wherever possible, rather than replacing them.
2. The center panel should be durable and spec-driven, not another ephemeral sidebar projection.
3. The sidebar should still expose a compact entry or status surface, but it should no longer carry the full numerical and visual burden.
4. A presentation-specific view model is the correct place to normalize overlap, format labels, and derive user-facing notes.
5. The first refactor slice can stay single-source and describe only "this Mac's local Messages history," while leaving room for future multi-source coverage.
6. It is acceptable for Troubleshooting / Next Steps to be shown inline in the panel rather than hidden behind a second navigation layer if that keeps state simple.

## Hard Invariants

1. Do not move database access into widgets.
2. Do not make coordinators watch providers or return ad hoc layout logic outside the existing panel architecture.
3. Do not bypass centralized database providers for `working.db` access.
4. Do not change import, migration, or overlay-write behavior in this refactor.
5. Do not keep this feature as sidebar-only once the refactor is complete; the full report must live in the center panel.
6. Do not present `accounted > chatDbTotal` as the headline story; `missing == 0` is the trust anchor.
7. Do not describe recovered or unlinked messages as lost messages.
8. Do not add business logic to the rendering widgets; all interpretive logic belongs in resolver and view-model shaping layers.

## Scope

### In Scope

1. Replace the sidebar-heavy coverage experience with a center-panel report.
2. Keep the Settings / Support entry point.
3. Add a durable panel route for Message History Coverage.
4. Create a coverage panel view model and normalized segment model.
5. Render a richer panel including hero status, accounting bar, reconciliation counts, timeline coverage, explanation, and actions.
6. Preserve or adapt the existing export action so it remains available from the new report.
7. Add tests for panel routing and view-model shaping, especially overlap normalization and edge cases.

### Out Of Scope

- changing source-data import rules
- implementing Historical Archive Merge
- iCloud sync or cross-device state detection
- per-contact coverage
- attachment coverage
- redesigning the entire Settings system
- introducing a broad new support feature domain unless review explicitly asks for it

## Recommended Direction

### 1. Make The Settings Entry Durable Rather Than Ephemeral

The current feature is wired as a transient troubleshooting action. That is the wrong transport for a report that is meant to function as a durable center-panel destination.

The refactor should change Message History Coverage from an ephemeral settings action into a durable Settings support selection that can derive a center-panel spec.

Why this is necessary:

- the user should be able to perceive this as a real report destination, not a side-effecting sidebar action
- the center panel should be derived from state, not pushed procedurally from widget code
- the sidebar can then shrink down to entry and status responsibilities only

Risk:

- changing a currently transient row into durable state may touch settings flow semantics and cassette topology in more than one place

### 2. Add A Settings-Owned Center-Panel Spec

Add a new settings-owned panel route to the global `ViewSpec` pipeline, rather than creating a new top-level `support` feature family in this slice.

Recommended shape:

- `ViewSpec.settings(...)`
- feature-owned `SettingsPanelSpec.messageHistoryCoverageReport()` or equivalent
- settings feature gains a `view_spec` coordinator path parallel to existing sidebar-cassette handling

Why this is necessary:

- the app already has a durable panel navigation system; this report should use it
- feature ownership stays coherent with the existing entry point and data logic
- this minimizes churn compared with introducing a brand-new support feature namespace

Risk:

- adding a new `ViewSpec` branch is cross-cutting and will require disciplined updates to panel coordination and tests

### 3. Keep Report Computation Canonical And Add A Presentation View Model

Reuse the existing coverage report as the canonical facts model, then add a dedicated panel view model that shapes it for presentation.

The panel view model should own:

- status label
- hero headline
- summary text
- formatted count labels
- normalized visible / recovered / missing segments
- overlap note when visible + recovered exceeds source total
- earliest / latest / generated-at labels
- notes and actions

Why this is necessary:

- the current report entity is a data fact model, not a presentation contract
- the seed explicitly calls for "zero business logic in widgets"
- overlap handling and trust-preserving copy should be centralized and testable

Risk:

- if presentation shaping is split between resolver and widget, the panel will drift into logic-heavy rendering

### 4. Simplify The Sidebar To A Compact Support Card

The sidebar representation should become a compact status and entry card rather than the full report.

Expected content:

- title: `Message History Coverage`
- brief status label
- one-sentence reassurance or concern summary
- primary action / affordance that opens the center-panel report

Why this is necessary:

- it preserves the existing Settings / Support discoverability
- it removes the current burden from sidebar text blocks
- it lets the panel own the high-value storytelling

Risk:

- too much summary detail in the sidebar will recreate the same problem this refactor is trying to solve

### 5. Build The Center Panel As A Reconciliation Report

The center panel should render the following sections from the panel view model:

1. hero status
2. accounting bar and legend
3. reconciliation statement / counts
4. timeline coverage strip
5. recovered-message explanation
6. next steps / troubleshooting guidance when useful
7. actions such as export, and optionally recovered-message exploration if the current route fits cleanly

Why this is necessary:

- this is the product outcome requested by the seed
- it turns existing statistics into a confidence-building report
- it creates a reusable diagnostics-panel pattern for future trust features

Risk:

- without strict view-model shaping, the widget can become a second business-logic layer

### 6. Preserve Export And Adapt Actions To The New Surface

`Export Coverage Report` should remain available from the center panel.

`Explore Recovered Messages` is a good candidate follow-on action because the recovered surface already exists elsewhere in the app, but the exact action should be included only if it can be wired through existing typed navigation without inventing a new subsystem.

`Show Troubleshooting Steps` should be kept inline unless review specifically prefers a second destination.

Why this is necessary:

- export is already part of the feature contract
- recovered-message explanation becomes stronger when paired with a legitimate navigation path
- inline troubleshooting keeps navigation and state simple

Risk:

- action creep can turn the panel into a secondary diagnostics hub if too many follow-up routes are added in one slice

## Proposed Implementation Plan

1. **Routing refactor**
   Convert Message History Coverage selection from transient settings transport to durable settings support state, and derive a center-panel `ViewSpec` from that state.

   Why: this is the minimal architectural change that unlocks a true center-panel report.

   Primary risk: settings flow semantics and panel routing can drift if the mapping from state -> spec is not kept deterministic.

2. **Settings-owned panel surface**
   Add a settings-owned panel spec, settings view-spec coordinator, and panel routing integration.

   Why: the report needs a feature-owned center-panel path that stays within current repo conventions.

   Primary risk: this introduces a new settings panel lane and must not blur the boundary between panel coordination and widget rendering.

3. **View-model layer**
   Add `MessageCoveragePanelViewModel`, `CoverageSegmentViewModel`, and mapping logic from the existing report entity.

   Why: overlap normalization, copy selection, and edge-case handling belong in a testable data-shaping layer, not the widget.

   Primary risk: if the existing report logic and new panel shaping overlap unclearly, responsibility boundaries will become muddy.

4. **Center-panel widget builder**
   Implement the panel presentation using the view model only.

   Why: this is where the trust-building visual hierarchy is delivered.

   Primary risk: visual work can tempt business logic into the widget unless the contract remains strict.

5. **Sidebar simplification**
   Reduce the sidebar experience to compact status plus entry.

   Why: this keeps the report discoverable without making the sidebar a second full report surface.

   Primary risk: if the sidebar still carries too much data, the refactor will not materially improve the UX.

6. **Action adaptation**
   Rewire export to the center panel and decide whether recovered-message exploration is included in the same slice.

   Why: the report should remain actionable, not just informative.

   Primary risk: overextending into adjacent feature work.

7. **Verification**
   Add routing tests, panel view-model tests, and focused rendering or coordinator tests for complete, incomplete import, incomplete source history, unknown, zero-message, null-date, and overlap cases.

   Why: the trust message depends on correct interpretation of a small number of edge cases.

   Primary risk: narrow resolver tests alone will miss panel-routing regressions.

## Approved Defaults For Execution

The following review decisions are now locked for implementation unless you redirect the work later:

1. Keep this refactor under `features/settings` rather than introducing a new top-level `features/support` namespace in this slice.
2. Make `Message history coverage` a durable settings support selection, not a transient settings action.
3. Keep troubleshooting guidance inline in the center panel rather than introducing a second destination in the first pass.
4. Defer `Explore Recovered Messages` unless Phase 1 or Phase 2 reveals a clean existing route with low additional scope.
5. Treat Phase 1 as routing plus a baseline panel experience, with richer visual storytelling landing in later phases.

## Phase Breakdown

### Phase 1 - Durable Routing And Baseline Panel

- convert the settings row to durable selection semantics
- derive a settings-owned center-panel `ViewSpec` from durable flow state
- add a settings-owned panel spec and coordinator path
- render a baseline center-panel report using the existing coverage facts and copy
- keep the current sidebar coverage cassette available as the stable child for now so routing can land without blocking on the final compact-sidebar redesign

### Phase 2 - Presentation Contract

- introduce the richer message-coverage panel view model
- normalize overlap handling for the accounting bar contract
- move additional copy/notes derivation into the view-model shaping layer

### Phase 3 - Rich Reconciliation Panel

- replace the baseline panel with the richer hero/accounting/timeline layout
- add panel actions and richer recovered-message explanation

### Phase 4 - Sidebar Simplification And Polish

- reduce the sidebar surface to compact status plus entry
- complete final copy review, manual state validation, and regression checks

## Planned File Scope After Approval

Likely edit areas:

- `lib/essentials/navigation/domain/entities/view_spec.dart`
- `lib/essentials/navigation/application/panel_coordinator_provider.dart`
- `lib/features/settings/feature_level_providers.dart`
- `lib/features/settings/domain/...` for a panel spec family
- `lib/features/settings/application/view_spec/...`
- existing Message History Coverage resolver / report / export files
- settings sidebar-flow and settings-topology files that currently treat coverage as transient
- focused tests under `test/essentials/navigation/`, `test/essentials/sidebar/`, and `test/features/settings/`

Off-limits for this refactor unless review expands scope:

- import/migration orchestrators
- database schemas
- overlay persistence rules
- source extraction / Rust code
- unrelated settings features

## Risks

1. **Too much architectural churn**
   Adding a new top-level feature namespace or overhauling settings flow would make the refactor larger than necessary.

2. **Trust regression from overlap math**
   If the panel foregrounds `accounted > chatDbTotal`, it will undermine the core reassurance even when no messages are missing.

3. **Widget logic creep**
   The panel will be visually richer than the current cassette, which raises the risk of formatting and interpretation logic leaking into rendering.

4. **Sidebar / panel duplication**
   If the sidebar still shows most of the numbers, the user will not experience a clear product improvement.

5. **Navigation ambiguity**
   If the same feature behaves partly as a persistent settings context and partly as an action, the state model will become harder to reason about.

## Acceptance Criteria

The refactor is successful when:

1. Selecting Message History Coverage from Settings opens a durable center-panel report.
2. The sidebar no longer carries the full report burden.
3. Complete status shows an immediately reassuring headline.
4. The accounting bar is driven by normalized data and never overflows past 100%.
5. `missing == 0` remains the primary trust anchor, including overlap cases.
6. The panel clearly explains recovered messages as accounted-for, not lost.
7. Earliest and latest source dates are shown clearly as this Mac's local history range.
8. Export Coverage Report remains available.
9. Widgets remain presentation-only.
10. Tests cover complete, overlap, incomplete import, incomplete source history, unknown, zero-message, and null-date cases.

## Open Questions For Review

1. Do you want this refactor to stay under `features/settings` as proposed, or do you want the broader `features/support` namespace introduced now?
2. Should `Explore Recovered Messages` be included in the first refactor slice if the existing recovered route can be reused cleanly?
3. Should troubleshooting remain inline in the panel, or do you want it as a second destination or expandable action despite the extra state complexity?
4. Should the sidebar selection itself become persistent, or would you prefer a compact sidebar card with an explicit `Open Coverage Report` action while leaving the top menu semantics closer to today's behavior?

Implementation is approved to begin from Phase 1.

\*\*\* Add File: /Users/rob/Development/FlutterProjects/remember_every_text/\_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/message-history-coverage-REFACTOR/CHECKLIST.md

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
