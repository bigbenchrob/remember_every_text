---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2026-04-19
source_of_truth: doc
links:
  - ../../50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/settings-menu-semantics.md
  - ../settings-sidebar-redesign/PROPOSAL.md
   - ../ephemeral-sidebar-projection/PROPOSAL.md
   - ../ephemeral-sidebar-projection/DESIGN_NOTES.md
  - ../../52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/00-universal-spec-handling-pattern.md
  - ../../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md
  - ../../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/INVIOLATE_RULES.md
tests: []
feature: settings-menu-semantic-revision
status: superseded
created: 2026-04-17
---

# Feature Proposal — Settings Menu Semantic Revision

Historical note: this proposal predates the stable/ephemeral sidebar projection split and is retained only as pre-migration context.

Do not use this file as current implementation guidance. The shipped direction lives under `../ephemeral-sidebar-projection/`.

**Proposed Branch**: `Ftr.settings-menu-semantics`
**Status**: Proposed
**Created**: 2026-04-17

---

## Overview

Revise the Settings top-menu system so that it obeys the semantic contract defined in [settings-menu-semantics.md](../../50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/settings-menu-semantics.md).

This proposal is not a visual redesign. The flat mixed-row menu can remain intact.

The change is semantic and architectural:

- persistent settings context must be represented as durable global flow state
- transient actions must behave like temporary sidebar-local flows
- the menu label must only represent persistent context derived from global flow state
- transient action cassettes must own their own heading and lifecycle
- transient flows must remain non-modal and must not freeze the menu

This proposal formalizes behavior that is currently only partially implemented and brings the settings menu into alignment with the cross-surface spec model.

## User Value

### Problem

The current Settings top menu is visually flat and grouped correctly, but it does not yet respect the semantic distinction between persistent context and transient command.

Current behavior gaps include:

1. Transient actions behave like persistent selections in menu chrome.
   - choosing `Send logs…` or `Reset message data…` leaves that label in the closed menu state
   - this incorrectly implies the user is in a persistent settings context

2. Transient action cassettes currently under-own their context.
   - the menu label is still doing context work that transient cassettes should own themselves
   - the semantic guide requires transient action cassettes to carry their own heading

3. Reset still relies on blocking confirmation behavior.
   - the semantic guide explicitly requires transient action flows to remain sidebar-local and non-modal
   - a blocking confirmation dialog violates that contract

4. The current state model still blurs durable and temporary meaning.
   - persistent context is not yet modeled as first-class global flow state
   - transient actions are still too close to stored selection state instead of derived cassette expansion

This leaves the UI workable, but semantically ambiguous. It also makes future settings growth harder because the system cannot yet cleanly separate durable navigation state from temporary command flows.

### Proposed User-Facing Outcome

After this revision:

- persistent settings context remains selected in the menu and defines ongoing sidebar context
- transient actions do not remain selected in the menu label
- transient action cassettes render with their own heading, explanatory copy, and explicit action controls
- resolving a transient action returns the menu to the placeholder state: `Choose setting or action`
- the menu remains usable while a transient cassette is present

### Benefits

- the menu label becomes semantically trustworthy
- transient action flows stop masquerading as persistent sidebar state
- state ownership becomes explicit and testable
- future persistent settings sections can be added without redesigning the model again
- global flow state remains cleaner because temporary operations do not pollute it

---

## Existing Architecture Summary

- The visible Settings top menu is resolved by `SettingsRootResolver`.
- The open menu already supports a flat mixed-row structure through `SettingsTopMenuRow`:
  - `SettingsTopMenuGroupHeaderRow`
  - `SettingsTopMenuActionRow`
- The menu payload currently stores `selectedActionId`, and the widget renders that label directly in the closed menu chrome.
- `SettingsTopMenuActionRow` currently carries only:
  - `label`
  - `actionId`
- There is no semantic field distinguishing persistent contexts from transient actions.
- `Send logs…` and `Reset message data…` already resolve into single-cassette info-plus-action payloads.
- Those transient cassettes currently omit their own heading because the selected menu label is still doing context work.
- Reset confirmation is still owned by a blocking confirmation dialog instead of a sidebar-local cassette lifecycle.

### Current Semantic Mismatch

The current system treats all action rows as if they were the same kind of state.

That is the core problem.

The semantic guide requires two different behaviors:

- persistent context in global flow state
- transient action as derived cassette expansion

The current menu state model still centers a single selected action concept.

That mismatch leaks into menu chrome, cassette titles, and action lifecycle.

---

## State Ownership

- Global flow state owns persistent settings context.
- The Settings menu is a projection of that global flow state.
- Persistent context must remain intact while transient cassettes are present.
- Transient flows layer on top of existing persistent context and must not replace or clear it.
- Transient actions do not create persistent state.
- More precisely, a transient action is realized as an ephemeral projection in the cassette stack, not as stored state.
- Transient flows exist only as cassette stack expansions derived from dispatched intent.
- Transient cassette expansion must be derived directly from the most recent dispatched intent and must not depend on any stored transient flag in flow state.
- Transient flows are not persisted, bookmarkable, or reconstructible from stored flow state.
- Transient action lifecycle is owned by the dispatcher and topology, not by the menu widget.
- The menu triggers transient intent, but does not track transient progress or completion.

---

## Assumptions

1. `sendLogs` and `resetMessageData` are transient actions and should remain so.
2. The settings menu should remain flat; this proposal changes semantics, not hierarchy.
3. The current single-cassette structure for transient actions is the correct base and should be preserved rather than re-expanded.
4. Moving reset confirmation into the sidebar is preferable to preserving a modal dialog that violates the documented contract.
5. A persistent settings context such as `Appearance` should be introduced in a subsequent phase, but this proposal does not require that addition in order to establish correct state semantics.

---

## Hard Invariants

1. Follow the existing cross-surface contract: spec -> coordinator -> resolver -> payload -> widget builder.
2. The settings top menu remains a flat mixed-row menu with inert group headers.
3. Group headers remain non-selectable and non-semantic.
4. Only persistent settings context derived from global flow state may remain visible as the selected menu label.
5. Persistent settings context must live only in global flow state as a first-class field.
6. The Settings menu must not own or persist selection state; it must project the current persistent context from flow state.
7. Transient actions must not be stored in global flow state.
8. Transient actions must be expressed only as derived cassette stack expansions resulting from dispatched intent.
9. Transient cassette expansion must be derived directly from the most recent dispatched intent and must not depend on any stored transient flag in flow state.
10. Transient flows must not be persisted, bookmarked, or reconstructible from stored state.
11. Persistent context must remain intact while transient cassettes are present.
12. Transient flows layer on top of existing persistent context and must not replace or clear it.
13. Transient action cassettes must own their own heading and interaction lifecycle.
14. Transient action flows must remain sidebar-local and non-modal.
15. The top menu must remain usable while a transient cassette is present.
16. Do not regress the current one-cassette semantic unit for `Send logs…` and `Reset message data…`.

---

## Scope

### In Scope

1. Extend the settings menu row model to encode action semantics.
2. Replace stored menu-selection thinking with explicit state ownership rules.
3. Model persistent settings context as first-class global flow state.
4. Revise menu label behavior so only persistent context derived from flow state is shown as selected.
5. Ensure transient settings actions resolve only as cassette stack expansions and never as stored state.
6. Add required transient cassette headings for current transient settings actions.
7. Replace reset's blocking confirmation dialog with a sidebar-local transient cassette flow.
8. Update dispatcher and topology behavior so transient flows clear after completion without ever becoming persisted state.
9. Add focused tests for state ownership, menu-label semantics, transient lifecycle, and non-modal reset flow.

### Out Of Scope

- redesigning the visual style of the menu widget
- introducing a full new persistent settings section as part of this proposal
- changing the underlying `SendLogsRequested()` or reset service side effects
- revisiting the broader settings information architecture beyond semantic correctness

---

## Proposed Direction

### 1. Add Explicit Semantic Classification To Action Rows

`SettingsTopMenuActionRow` should grow an explicit semantic field:

- `persistentState`
- `transientAction`

Why:

- the menu cannot implement the documented rules without knowing which category a row belongs to
- classification must be explicit, not inferred from label text or downstream behavior

This classification informs dispatch behavior, title behavior, and whether a user gesture mutates global flow state or only produces a derived cassette expansion.

### 2. Move Persistent Context Into Global Flow State

Persistent context must be stored in the global flow state as a first-class field.

The Settings menu must not own selection state. It must reflect the current persistent context derived from flow state.

Transient actions must not write to this field.

Why:

- the placeholder text is semantically meaningful and should only be replaced by durable context
- durable context belongs in the same flow model that drives the rest of sidebar state
- transient actions must not contaminate persisted or bookmarkable state

### 3. Make Transient Actions Derived-Only Ephemeral Projections

Transient actions must exist only as cassette stack expansions derived from dispatched intent.

More precisely, they are ephemeral projections in the cassette stack rather than stored state or navigation state.

They must not:

- create a stored selected-action field
- persist in global flow state
- be bookmarkable
- be reconstructible from saved or restored sidebar state
- depend on any stored transient flag in flow state

Why:

- transient action is not navigation state
- derived expansion is the correct architectural representation for temporary flows in the cassette system

### 4. Make Transient Action Cassettes Self-Contained

Current transient settings cassettes should carry their own title.

Examples:

- `Send Logs`
- `Reset Message Data`

These cassettes should continue to own:

- explanatory copy
- primary action controls
- cancel or dismiss behavior when applicable

Why:

- the semantic guide requires transient cassettes to own their context
- this removes reliance on menu chrome as a substitute heading

### 5. Replace Reset's Blocking Confirmation Dialog With Sidebar-Local Flow

Reset should no longer require a blocking modal dialog.

Instead, the transient reset cassette should own the confirmation flow inside the sidebar surface.

That cassette should provide:

- heading
- explanatory risk copy
- explicit confirm control
- explicit cancel control

On cancel:

- the derived transient cassette disappears
- the menu returns to placeholder state unless a persistent context is already active

On confirm:

- `ResetMessageDataRequested()` executes
- the transient cassette lifecycle ends as the app exits

Why:

- the semantic document makes non-modal behavior a hard requirement
- sidebar-local flow is the correct projection of state in this architecture

### 6. Defer New Persistent Context Introduction To A Follow-Up Phase

A persistent settings context such as `Appearance` should be introduced in a subsequent phase.

This proposal does not require that change in order to establish correct semantics and state ownership.

Why:

- state ownership should be corrected first
- coupling semantic correctness to a broader settings-surface addition creates unnecessary risk

---

## Minimal Implementation Plan

### Step 1 — Extend The Menu Row Model

Add semantic classification to `SettingsTopMenuActionRow` and update the resolver to declare the correct semantics for each action row.

Why this step is necessary:

- all downstream behavior depends on explicit action type

Primary risk:

- partial adoption could leave the UI with mixed old/new assumptions about semantics

### Step 2 — Store Persistent Context Only In Global Flow State

Introduce a first-class persistent settings context field in global flow state.

The Settings menu must project that state and must not own its own durable selection field.

Transient actions must never write to persistent context.

Why this step is necessary:

- this is the core ownership correction
- it prevents transient commands from polluting persisted or bookmarkable state

Primary risk:

- if any local menu field still behaves like durable selection, the semantics will remain ambiguous

### Step 3 — Route Transient Actions Only Through Dispatcher And Topology

Transient lifecycle must be owned by dispatcher and topology, not by the menu widget.

The menu triggers intent. Dispatcher and topology derive the cassette expansion and clear it when the flow ends.

Why this step is necessary:

- derived-only transient behavior requires a single lifecycle owner
- widget-local tracking would quietly reintroduce stored transient state

Primary risk:

- split ownership between widget and dispatcher would produce sticky or partially restorable transient flows

### Step 4 — Add Required Titles To Transient Cassettes

Update the current transient settings payload path so transient cassettes carry their own title and remain self-contained.

Why this step is necessary:

- the current menu label must stop doing semantic work for transient flows

Primary risk:

- the render path could accidentally duplicate headings if transient and persistent rules are not kept separate

### Step 5 — Move Reset Confirmation Into The Sidebar

Replace the blocking reset confirmation dialog with a sidebar-local transient cassette lifecycle that includes cancel and confirm controls.

Why this step is necessary:

- the current dialog violates the non-modal contract

Primary risk:

- confirmation logic could drift between cassette UI and dispatcher behavior if ownership is not clearly defined

### Step 6 — Add Focused Semantic Tests

Add tests covering:

- persistent context stored in global flow state
- menu label projection from global flow state
- transient label non-retention
- transient cassette title presence
- transient flows not reconstructible from persisted state
- reset non-modal sidebar-local confirmation behavior
- transient cleanup after cancellation or completion

Why this step is necessary:

- semantic regressions are easy to reintroduce because the UI can still look fine while behaving incorrectly

Primary risk:

- inadequate tests would allow future menu additions to silently violate state ownership rules

---

## Likely Implementation Surface

Expected files or areas to change include:

- `lib/features/sidebar_utilities/domain/settings_top_menu_row.dart`
- `lib/features/sidebar_utilities/application/sidebar_cassette_spec/resolvers/settings_root_resolver.dart`
- `lib/features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/settings_top_menu_widget.dart`
- `lib/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart`
- settings-mode sidebar topology files under `lib/essentials/sidebar/domain/entities/cascade/`
- sidebar flow-state definitions and reducers under `lib/essentials/sidebar/`
- settings transient payload/resolver files under `lib/features/settings/application/sidebar_cassette_spec/`
- reset confirmation UI flow under `lib/features/settings/presentation/`
- focused sidebar and settings resolver/render tests under `test/`

---

## Risks

1. **Selection-state ambiguity**
   If persistent context is not moved fully into global flow state, the menu will continue to leak temporary meaning into durable UI chrome.

2. **Hidden transient persistence**
   If transient lifecycle is tracked by widget or local payload state, temporary actions may become accidentally restorable.

3. **Modal backsliding**
   Reset confirmation may be reintroduced as a dialog because it is simpler to wire, but that would directly violate the documented contract.

4. **Phase coupling**
   If this work is coupled to a larger `Appearance` rollout, the state ownership fix may stall behind unrelated settings-surface decisions.

---

## Acceptance Criteria

- Every actionable settings menu row explicitly declares whether it is `persistentState` or `transientAction`.
- Persistent settings context exists only as first-class global flow state.
- The Settings menu is a projection of persistent global flow state and does not own durable selection state.
- Choosing a transient action does not write persistent context and does not leave that label in the closed menu chrome.
- Transient settings actions exist only as derived cassette stack expansions.
- Transient settings flows are not persisted, bookmarkable, or reconstructible from stored sidebar state.
- Transient settings cassettes render their own heading.
- `Send logs…` remains a single semantic unit rendered as one cassette.
- `Reset message data…` remains a single semantic unit rendered as one sidebar-local flow without a blocking modal dialog.
- Cancelling a transient settings action clears the derived transient cassette without mutating persistent context.
- The top menu remains usable while a transient cassette is present.
- Focused tests enforce the persistent-vs-transient state ownership contract.

---

## Summary

This proposal does not change what the settings menu looks like first.

It changes what the menu *means* and where that meaning is allowed to live.

The core revision is to enforce the documented distinction between:

- persistent settings context stored only in global flow state
- transient sidebar-local command flow expressed only as derived cassette expansion

That state ownership split is the foundation for making future settings behavior correct, scalable, and architecturally coherent.