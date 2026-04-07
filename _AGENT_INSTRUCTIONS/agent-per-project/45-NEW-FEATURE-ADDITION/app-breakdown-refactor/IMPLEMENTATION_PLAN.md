# MessageLens App Breakdown Refactor - Implementation Plan

## Purpose

This document operationalizes the architectural verdict in `agent-seed.txt` and
the target model in `before-after-diagram.txt`.

It is a formal, sequential implementation program for restoring the app to a
strictly declarative architecture where invalid cross-surface states cannot be
constructed.

This is not a bug-fix plan.
This is an authorship-refactor plan.

## Governing Constraints

The refinements in `plan-revisions.txt`, `foundational-constraints.txt`, and
`pr-review-rubric.txt` are mandatory. The implementation plan is therefore
governed by these execution constraints:

1. Transitional adapters are allowed only as pure translators from legacy data
  shape to canonical semantic payload shape.
2. For the flow-managed messages branch, `PanelStack` is a render container,
  not an author of center-panel meaning.
3. Right-panel existence must be derivable from current center-spec
  compatibility with no hidden incompatible persistence.
4. Recovered timelines must be unified at all layers, not merely presented
  through a unified shell.
5. Complex feature UI remains allowed only when it is constructed at the render
  edge from immutable semantic payload plus render-time reconstruction of typed
  semantic actions.
6. Targeted repair constructs must be removed or reduced to debug-only
  assertions. Renaming or wrapping them is not acceptable.
7. Broken legacy pathways must not be preserved for compatibility.
8. No executable callback, builder, controller, `Ref`, `BuildContext`, or
  equivalent runtime UI object may cross a coordination boundary.
9. Resolver/spec/application layers must not depend on widget or presentation
  layers except for explicitly tracked temporary migration exceptions.
10. Every refactor PR must be reviewed against `pr-review-rubric.txt` before it
  is considered ready.

## Architecture Summary

The current system already contains the right semantic primitives, but they do
not yet fully control the rendered UI.

### Existing semantic pieces

- `SidebarFlowState`
  Intended canonical meaning for the messages-mode branch
- `CassetteRackState`
  Sidebar cassette ordering and cascade projection
- `PanelsViewState` and `PanelStack`
  Center and right panel state containers
- `ViewSpec` and feature-specific spec classes
  Typed navigation meaning for panels
- `MessageTimelineScope`
  Semantic scope for message surfaces
- Ordinal providers and strategies
  Stable timeline access layer
- Hydration and attachment-resolution pipeline
  Runtime message and attachment realization

### Current architectural problem

Those semantic pieces coexist with competing sources of meaning:

- transported feature widget subtrees
- reconciliation logic
- deferred clear logic
- special-case recovered-message pathways
- widget inspection used to infer layout behavior

This creates a mixed-authority system where semantic truth and rendered truth
can diverge.

## Assumptions

These assumptions govern the plan unless superseded by a later explicit design
decision.

1. This refactor will be executed across multiple small PRs, not as one large
   rewrite.
2. Phases must run in strict order; later phases may refine earlier ones but
   must not bypass them.
3. No database schema version change is required for the core sidebar/panel
   authorship refactor.
4. Overlay-versus-working database rules remain unchanged.
5. Existing sealed spec case names should remain stable unless a later approved
   design explicitly changes them.
6. The app must remain runnable between phases, but temporary transitional
  adapters are allowed only if they are pure translators and can be removed
  without changing behavior.
7. Runtime invariant breaches in debug/test builds should fail loudly rather
   than being silently repaired.

## Hard Invariants

These are non-negotiable.

1. `SidebarFlowState` is the only owner of messages-branch meaning.
2. No `Widget` or widget subtree may cross coordination boundaries as payload.
3. Widgets are terminal render outputs, not semantic transport.
4. Attachment provenance affects hydration only, never message identity or
   message scope.
5. Recovered timelines must converge onto the same pipeline shape as other
   message scopes.
6. Invalid cross-surface combinations must become unrepresentable.
7. Riverpod providers remain generated and pure.
8. Drift schema, overlay semantics, and persistence contracts remain unchanged
   unless a separate approved migration plan says otherwise.
9. For the flow-managed messages branch, `PanelStack` must not store or author
  center meaning independently of `SidebarFlowState.projectedCenterSpec`.
10. Incompatible right-panel state must not survive while hidden.
11. Recovered timelines may not require special-case logic outside the scope
   definition itself.
12. Payload graphs must be inert and serializable in spirit, even if they are
  never literally serialized.
13. The boundary may carry meaning, but it may not carry execution.

## Program Structure

The refactor will proceed in six phases.

### Phase 0 - Baseline and Guard Rails

This is a preparation phase, not a semantic redesign phase.

#### Objective

Freeze a measurable baseline before structural changes begin.

#### Work

- Capture the current focused regression suite as the baseline gate.
- Record the current special-case counts and code hotspots.
- Add explicit debug assertions where they help reveal invariant breaches
  without introducing repair logic.
- Create any missing phase-local test scaffolding needed for later steps.
- Record whether flow-managed center meaning can currently survive inside
  `PanelStack` independently of canonical semantic state.
- Record whether incompatible right-panel state can currently survive while not
  visible.
- Install anti-drift enforcement scaffolding before large-scale resolver
  rewrites begin.

#### Phase 0 enforcement foundation

The refactor may not proceed into large-scale resolver rewrites until the
following enforcement work is installed or explicitly tracked as the current
blocking task:

- formalize a central resolver contract whose legal return space is data-only
  payload rather than widget output
- define a sealed payload hierarchy for sidebar cassette transport objects and
  equivalent cross-boundary models
- define a render-dispatch contract where rendering is selected by payload
  type, render kind, and explicit feature render variant rather than by
  transported builder callbacks
- define a semantic action descriptor model so boundaries carry typed intent,
  not callbacks or closures
- define intended import boundaries between semantic/application layers and
  presentation/render layers
- add first-pass static checks for forbidden imports and forbidden payload field
  types
- add first-pass architecture test scaffolding for boundary purity,
  dependency-direction, and escape-hatch removal
- add law-style comments at architectural choke points only:
  central resolver interface, payload base types, render-dispatch host,
  enforcement test files, and temporary adapters if any exist
- create a central temporary-exception tracking file
- require every refactor PR to include an `Architecture Review (Required)`
  section derived from `pr-review-rubric.txt`

#### Baseline metrics to capture

- Current `featureComplex` call sites in `lib/**/*.dart`: 3
  - contact chooser
  - stray handles review
  - messages heatmap
- Current active panel repair hooks in runtime code:
  - `SidebarFlow._syncProjectedCenterPanel()`
  - `_schedulePanelClearIfNoProjectedCenter()`
  - `reconcileSidebarPanels(...)`
- Current `PanelStack` behavior on the flow-managed branch is still repair-
  mediated rather than purely derived:
  - `PanelsViewState` still exposes direct `show`, `push`, and `clear`
    mutation on center and right stacks.
  - `centerPanelWidget` still watches `reconcileSidebarPanelsProvider(mode)`
    before reading the center stack.
  - `_withUpdatedPanel()` clearing the right stack on center updates is still
    cleanup behavior inside panel state, not derivation from canonical flow
    semantics.
- Current right-panel behavior still permits hidden incompatible persistence:
  - `rightPanelWidget` always renders from the right `PanelStack`.
  - `shouldShowEndSidebar(...)` hides the shell only when the right stack is
    empty or the current center spec is incompatible.
  - `_EndSidebarSyncObserver` then toggles macOS end-sidebar visibility from
    that provider result.
  - Therefore right-panel state can still exist while hidden, and cleanup is
    still required to remove it.
- Current recovered special casing includes:
  - `RecoveredListOrdinalStrategy`
  - recovered-specific branching in `message_timeline_ordinal_provider.dart`
  - recovered-specific scaffold handling in `messages_timeline_view.dart`

#### Baseline snapshot captured on 2026-04-04

- `featureComplex` runtime call sites:
  - `lib/features/contacts/application/sidebar_cassette_spec/resolvers/contact_chooser_resolver.dart`
  - `lib/features/handles/application/sidebar_cassette_spec/resolvers/stray_handles_review_resolver.dart`
  - `lib/features/messages/application/sidebar_cassette_spec/resolvers/heatmap_resolver.dart`
- Active repair hooks and authorship backstops:
  - `lib/essentials/sidebar/application/sidebar_flow_state_provider.dart`
    still invokes `_syncProjectedCenterPanel()` across messages-branch
    transitions and still invokes `_schedulePanelClearIfNoProjectedCenter()`
    during chooser reset.
  - `lib/essentials/navigation/application/panel_widget_providers.dart`
    still defines `reconcileSidebarPanels(...)`, and
    `centerPanelWidget(...)` still watches it before rendering.
  - `lib/essentials/navigation/application/panels_view_state_provider.dart`
    still permits direct center/right stack mutation via `show`, `push`, and
    `clear`.
- Hidden right-panel persistence is confirmed in structure:
  - `lib/essentials/navigation/application/panel_widget_providers.dart`
    computes end-sidebar visibility from both right-stack emptiness and center
    compatibility.
  - `rightPanelWidget(...)` still renders from the right stack even when
    `shouldShowEndSidebar(...)` resolves false.
  - `lib/essentials/navigation/presentation/view/macos_app_shell.dart`
    applies visibility afterward through `_EndSidebarSyncObserver`.
- Recovered timeline special casing is still present in multiple layers:
  - `lib/features/messages/application/strategies/recovered_list_ordinal_strategy.dart`
  - `lib/features/messages/presentation/view_model/timeline/ordinal/message_timeline_ordinal_provider.dart`
  - `lib/features/messages/presentation/view/messages_timeline_view.dart`
- Focused baseline suite status on 2026-04-04: green after one narrow
  stabilization fix.
  - Fixed regression:
    `test/essentials/sidebar/application/sidebar_cassette_sectioning_test.dart`
  - Root cause:
    `sidebarCassetteSectionTopSpacing(...)` had drifted into adding
    same-section spacing even though ordinary intra-section rhythm is authored
    separately through cassette payload spacing.
  - Guard rail added:
    `lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart`
    now asserts in debug/test builds that contiguous same-section cassettes do
    not receive additional spacing from the sectioning layer.

#### Exit gate

- Baseline test suite is green.
- Baseline counts are recorded in `TESTS.md`.
- Enforcement foundation is installed or explicitly tracked as the active
  blocking work item.
- No semantic behavior is changed in this phase.

### Phase 1 - Eliminate Widget Transport

This phase addresses Violation A and implements Law 2.

#### Objective

Remove feature-owned widget subtree transport across sidebar coordination
boundaries, starting with the contact chooser and ending with full removal of
`featureComplex` as an API.

#### Why first

The contact chooser is the most obvious point where stale UI can survive a
semantic change because it still crosses the sidebar payload boundary as a built
widget subtree.

If this remains in place, later panel and timeline refactors will still be
resting on an impure sidebar pipeline.

#### Planned sub-steps

##### Step 1A - Contact chooser payload rewrite

- Replace the chooser's feature-owned widget payload with a data-only payload.
- Represent chooser mode, sections, selection, recents/favorites state, and
  interaction affordances as immutable payload data or an essentials-governed
  sidebar body model.
- Ensure the render host, not the resolver, builds the final chooser widget.
- Keep complex feature UI legal only at the render edge, constructed from
  immutable semantic payload plus render-time reconstruction of typed semantic
  actions.

##### Step 1B - Remove remaining `featureComplex` call sites

- Migrate stray-handles review to the same data-only transport model.
- Migrate the messages heatmap sidebar payload to the same model.
- Remove `SidebarBodyRenderKind.featureComplex` and
  `SidebarCassetteCardViewModel.featureComplex` once no runtime caller remains.

#### Candidate files and layers

- `lib/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart`
- `lib/essentials/sidebar/domain/sidebar_body_model.dart`
- `lib/essentials/navigation/application/panel_widget_providers.dart`
- `lib/features/contacts/application/sidebar_cassette_spec/resolvers/contact_chooser_resolver.dart`
- chooser resolver tools and render builders in the contacts feature
- `lib/features/handles/.../stray_handles_review_resolver.dart`
- `lib/features/messages/.../heatmap_resolver.dart`

#### Structural success metrics

- `SidebarCassetteCardViewModel.featureComplex` removed.
- `SidebarBodyRenderKind.featureComplex` removed.
- `grep featureComplex lib/**/*.dart` returns zero runtime uses.
- Sidebar payload transport contains only specs, IDs, layout roles, and
  immutable render payload data.
- Any temporary adapter can be deleted without changing behavior because it was
  translation only.

#### Automated test gate

- Existing tests remain green:
  - `test/essentials/sidebar/application/cassette_widget_coordinator_provider_test.dart`
  - `test/essentials/sidebar/application/sidebar_flow_state_provider_test.dart`
  - `test/essentials/navigation/application/panel_widget_providers_test.dart`
- Add or expand tests for chooser semantics:
  - resolver/provider test for chooser payload shape
  - widget test covering All/Favourites toggle correctness after canonical
    state changes
  - regression test proving chooser UI updates when payload changes, without
    retaining stale subtree state
  - adapter-removal proof where applicable: removing the adapter does not alter
    behavior because it never acted as a semantic writer

#### Manual runtime gate

- Contacts picker: All/Favourites switching always changes visible content.
- Selecting a contact replaces picker content deterministically.
- Returning to chooser state never retains stale rows or stale toggle view.

#### Risks

- Overfitting chooser payloads to current widget implementation
- Accidentally recreating widget transport under a different name
- Letting essentials presentation absorb feature meaning that belongs in
  semantic state

#### Stop condition

If Phase 1 requires panel repair logic changes for correctness, stop and split
the work. Phase 1 must solve transport purity first, not collapse authorship
layers prematurely.

### Phase 2 - Collapse Panel Writing to a Single Path

This phase addresses Violation B and implements Law 1 for the center panel.

#### Objective

Make flow-managed center-panel content a pure projection of canonical semantic
state.

#### Required outcome

For flow-managed message branches, the normal execution path becomes:

`SidebarFlowState -> projectedCenterSpec -> render host (via PanelStack container)`

For this branch, `PanelStack` must behave as a render container only. It must
not independently store or preserve center meaning.

#### Planned sub-steps

##### Step 2A - Separate flow-managed from sidebar-independent panel behavior

- Preserve the existing panel system for sidebar-independent surfaces.
- Introduce a clear derived path for flow-managed message content so it does not
  rely on imperative panel mutation.
- Explicitly separate flow-managed derivation from any pathway that treats
  `PanelStack` as an independent holder of center meaning.

##### Step 2B - Demote repair helpers

- Remove `_syncProjectedCenterPanel()` as an active authoring path.
- Remove `_schedulePanelClearIfNoProjectedCenter()` as normal behavior.
- Demote `reconcileSidebarPanels(...)` to a debug assertion or fail-fast
  invariant check, or eliminate it entirely if derivation is sufficient.

##### Step 2C - Express center content as derivation

- Make the center host or an adjacent derived provider render the correct panel
  surface from the canonical projected spec.
- Ensure a null projected center state renders as no flow-managed center content
  without repair logic.
- Ensure `PanelStack` cannot display flow-managed content that is not derivable
  from `SidebarFlowState.projectedCenterSpec`.

#### Candidate files and layers

- `lib/essentials/sidebar/application/sidebar_flow_state_provider.dart`
- `lib/essentials/navigation/application/panel_widget_providers.dart`
- `lib/essentials/navigation/application/panels_view_state_provider.dart`
- `lib/essentials/navigation/application/panel_coordinator_provider.dart`
- tests under `test/essentials/sidebar/application/` and
  `test/essentials/navigation/application/`

#### Structural success metrics

- No normal execution path calls `_syncProjectedCenterPanel()`.
- No normal execution path uses deferred clear scheduling.
- `reconcileSidebarPanels(...)` is either removed or converted to fail-fast
  validation only.
- Reading canonical flow state is enough to predict the active flow-managed
  center panel.
- `PanelStack` cannot retain flow-managed center meaning that is not derivable
  from `SidebarFlowState.projectedCenterSpec`.

#### Automated test gate

- Existing tests remain green:
  - `test/essentials/sidebar/application/sidebar_flow_state_provider_test.dart`
  - `test/essentials/navigation/application/panel_widget_providers_test.dart`
- Add or expand deterministic projection tests:
  - contact chosen -> center spec is contact timeline
  - choose another contact -> center content disappears without repair hooks
  - recovered branch -> center spec is recovered timeline
  - top-menu changes never leave stale flow-managed center content visible
  - `PanelStack` does not retain incompatible flow-managed center meaning when
    canonical projected spec changes

#### Manual runtime gate

- "Change contact..." clears center content immediately by derivation, not by
  post-frame rescue.
- Switching branches never leaves stale message surfaces visible.

#### Risks

- Breaking non-flow panel behaviors while simplifying flow-managed behavior
- Accidentally replacing one imperative writer with a disguised second writer
- Losing tab/stack semantics for surfaces that legitimately use `PanelStack`

#### Stop condition

If the phase cannot remove active repair behavior without regressing runtime
correctness, the derived-center design is incomplete and must be redesigned
before proceeding.

### Phase 3 - Enforce Right-Panel Derivation

This phase implements Law 1 and Law 6 for the right panel.

#### Objective

Make right-panel existence a direct consequence of center-spec capability.

#### Required outcome

The right panel should not maintain independent semantic persistence for the
messages branch.

Hidden incompatible persistence is also forbidden.

#### Planned sub-steps

- Define right-panel eligibility strictly from the active center spec.
- If a compatible right-panel spec exists, render it.
- If not, the right panel does not exist.
- Remove normal cleanup logic that clears the right panel after the fact.
- Remove any hidden incompatible right-panel persistence, not only visible
  stale rendering.

#### Candidate files and layers

- `lib/essentials/navigation/application/panel_widget_providers.dart`
- any provider or coordinator that still stores right-panel state beyond what
  the center spec allows
- recovered attachment sidebar integration points

#### Structural success metrics

- Right-panel visibility is derived, not repaired.
- No normal execution path clears the right panel as a cleanup step.
- Unsupported center specs cannot coexist with a visible right panel.
- No incompatible right-panel state object exists when current center spec does
  not support it.

#### Automated test gate

- Expand `test/essentials/navigation/application/panel_widget_providers_test.dart`
  to cover:
  - compatible center spec -> right panel visible
  - incompatible center spec -> right panel absent
  - switching away from recovered-capable center specs removes the right panel
    by derivation, not manual cleanup
  - incompatible center spec -> no hidden retained right-panel state remains

#### Manual runtime gate

- Opening and closing recovered-attachment context tracks center-surface
  meaning exactly.
- No stale right sidebar remains after changing center scope.

#### Risks

- Confusing render absence with state clearing while hidden persistence remains
- Preserving hidden right-panel state that can reappear with stale meaning

### Phase 4 - Unify Recovered Timelines

This phase addresses Violation C and implements Law 5.

#### Objective

Make recovered timelines first-class scopes in the same message pipeline:

`scope -> ordinal -> hydration -> render`

#### Required outcome

Recovered timelines stop using bespoke surface behavior or hidden special-case
plumbing behind a unified shell.

#### Planned sub-steps

##### Step 4A - Standardize ordinal contract

- Replace `RecoveredListOrdinalStrategy` special-case handling with a standard
  ordinal contract that satisfies the same interface as other scopes.
- The source of recovered data may still be different, but the scope should no
  longer require special UI branching.
- Remove branching inside ordinal providers for recovered versus normal flow.

##### Step 4B - Remove recovered-specific scaffolding

- Eliminate dedicated recovered placeholder scaffolds in the unified timeline
  view.
- Make recovered scopes render through the same `MessagesTimelineView` surface
  contract as other scopes.
- Eliminate recovered-only rendering branches outside the scope definition
  itself.

##### Step 4C - Preserve semantics while unifying plumbing

- Recovered scope meaning remains distinct.
- The plumbing ceases to be distinct.
- There must not be parallel recovered-only pipelines hidden behind a shared
  surface wrapper.

#### Candidate files and layers

- `lib/features/messages/application/strategies/recovered_list_ordinal_strategy.dart`
- `lib/features/messages/presentation/view_model/timeline/ordinal/message_timeline_ordinal_provider.dart`
- `lib/features/messages/presentation/view/messages_timeline_view.dart`
- recovered message providers and metadata providers

#### Structural success metrics

- `RecoveredListOrdinalStrategy` removed or reduced to a hidden implementation
  detail only if no special-case logic remains outside the scope definition
  itself.
- `messages_timeline_view.dart` no longer contains recovered-only scaffold
  branches such as "Recovered timelines use a dedicated surface."
- Recovered timelines use the same render path as global/contact/chat scopes.
- Ordinal providers, hydration, and rendering contain no recovered-specific
  branching outside the scope definition itself.

#### Automated test gate

- Existing tests remain green:
  - `test/features/messages/presentation/view_model/timeline/ordinal/message_timeline_index_coordinator_provider_test.dart`
  - `test/features/messages/presentation/view/recovered_visible_month_key_test.dart`
  - `test/features/messages/application/strategies/recovered_list_ordinal_strategy_test.dart`
- Add or replace tests so recovered scope is validated through the unified
  pipeline:
  - recovered scope ordinal access
  - recovered scope month jumps
  - recovered scope row hydration
  - recovered scope rendering through the main timeline surface

#### Manual runtime gate

- Recovered timelines scroll, jump, and render like other message surfaces.
- Switching from regular to recovered and back fully replaces UI semantics.

#### Risks

- Smuggling special-case behavior into the ordinal provider under a new name
- Preserving a unified view shell while still branching into hidden recovered-
  only render paths

### Phase 5 - Remove Widget-Based Layout Inference

This phase addresses Violation D.

#### Objective

Make sidebar layout decisions depend on resolved cassette descriptors rather
than inspecting already-built widgets.

#### Planned sub-steps

- Move pinned-control, expansion, and layout-role decisions into explicit
  descriptor data.
- Refactor `_LeftSidebarSurface` to operate on resolved layout metadata.
- Remove helper functions that unwrap widgets in order to infer behavior.

#### Candidate files and layers

- `lib/essentials/navigation/application/panel_widget_providers.dart`
- `lib/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart`
- sidebar sectioning and layout contracts

#### Structural success metrics

- `unwrapSidebarCassetteCard(...)` removed.
- `isPinnedAppControlCassette(Widget)` removed.
- `shouldExpandSidebarCassette(Widget)` removed.
- Sidebar host layout can be reasoned about from descriptors without inspecting
  rendered widget types.

#### Automated test gate

- Existing tests remain green:
  - `test/essentials/sidebar/application/sidebar_cassette_sectioning_test.dart`
  - `test/essentials/navigation/application/panel_widget_providers_test.dart`
- Add layout-contract tests covering:
  - pinned controls
  - expanding content
  - content-zone ordering
  - role-based spacing and sectioning from descriptors only

#### Manual runtime gate

- Sidebar layout remains visually identical where intended.
- No regressions in pinned controls, content expansion, or section spacing.

#### Risks

- Accidentally reintroducing layout meaning into widget classes through hidden
  fields
- Changing visual layout while attempting a purely architectural cleanup

### Adapter Rule for All Phases

If a temporary adapter is introduced anywhere in this program, it must satisfy
all of the following:

- it translates old data shape to new canonical payload shape only
- it does not cache UI state
- it does not retain previous widget trees
- it does not infer semantic meaning from widget structure
- it does not perform panel mutation
- it does not delay or reorder semantic updates
- removing it does not change behavior

### Phase 6 - Final Hardening and Fail-Fast Invariants

This phase converts the architecture from merely cleaner to explicitly enforced.

#### Objective

Make invariant breaches loud and measurable.

#### Planned sub-steps

- Add debug assertions around impossible cross-surface combinations.
- Remove any remaining compatibility shims that exist only to preserve broken
  pathways.
- Re-run the full targeted suite and a manual runtime scenario matrix.
- Document remaining debt explicitly if any exists.

#### Structural success metrics

- No alternate semantic writer remains in normal execution paths.
- Invalid states fail fast in debug/test builds.
- The app can be reasoned about from semantic state and derived projections
  alone.
- No hidden state persists outside canonical semantic state for the
  flow-managed branch.

#### Automated test gate

- All focused phase tests remain green.
- Any newly introduced invariant tests are green.

#### Manual runtime gate

- Contact chooser, branch switches, recovered timelines, heatmap, and
  attachment-driven message rendering all behave deterministically.

#### Risks

- Declaring victory while silent transitional paths still exist

## Delivery Model

Each phase should ship as its own contained change set with:

- a short design note in the PR description
- a before/after explanation tied to the phase objective
- explicit structural metrics
- explicit test results
- explicit statement of what alternate pathways were removed

## Go / No-Go Rule

Do not start the next phase unless the current phase has passed:

1. structural gate
2. automated test gate
3. manual runtime gate

If a phase passes tests but still requires repair logic to look correct at
runtime, the phase is not complete.

The same is true if correctness still depends on hidden incompatible state or
preserved broken pathways.