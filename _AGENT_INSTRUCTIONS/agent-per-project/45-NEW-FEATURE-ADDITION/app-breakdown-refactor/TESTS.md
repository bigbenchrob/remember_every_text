# MessageLens App Breakdown Refactor - Metrics and Tests

> Current conformance note (2026-06-06): this test plan is historical. The
> architectural test posture remains useful, but current message evidence tests
> should target graph-backed `MessageEvidenceScope`, full selected logical
> skeletons, viewport hydration, and shared evidence rendering. Do not recreate
> retired `MessagesTimelineView` or retained `working.db` timeline test paths.

## Purpose

This document defines how each refactor phase is judged.

The refactor is not complete because a phase feels cleaner. A phase is complete
only when:

- structural metrics are satisfied
- automated tests are green
- manual runtime scenarios pass
- no repair logic is required for correctness
- no hidden state persists outside canonical semantic state

## Testing Philosophy

This program is testing for architectural determinism, not only for local
behavior.

That means we must verify:

1. meaning comes from one semantic writer
2. projections are deterministic
3. stale UI cannot persist
4. provenance affects rendering details only
5. recovered and normal timelines share one pipeline shape
6. hidden incompatible state cannot survive behind visible derivation
7. transported payloads remain inert and contain no executable UI behavior

## Enforcement Track

These checks are part of the refactor, not optional reviewer memory.

### Static and CI checks

- fail if resolver/spec/application layers import widget or presentation layers
  outside tracked migration exceptions
- fail if payload transport models reference forbidden types such as `Widget`,
  `WidgetBuilder`, `BuildContext`, `Ref`, controllers, notifiers, focus or
  scroll objects, or function-typed UI callbacks
- fail if banned legacy constructs remain active after their removal phase:
  - `featureComplex`
  - `_syncProjectedCenterPanel`
  - `_schedulePanelClearIfNoProjectedCenter`
  - `reconcileSidebarPanels`

### Architecture test categories

- boundary purity tests
- dependency boundary tests
- single-writer tests
- derived-right-panel tests
- recovered-unification tests

## Baseline Focused Suite

These are the existing test surfaces that should remain green throughout the
refactor.

### Sidebar and panel tests

- `test/essentials/sidebar/application/sidebar_flow_state_provider_test.dart`
- `test/essentials/sidebar/application/cassette_widget_coordinator_provider_test.dart`
- `test/essentials/sidebar/application/sidebar_action_dispatcher_test.dart`
- `test/essentials/sidebar/application/sidebar_cassette_sectioning_test.dart`
- `test/essentials/navigation/application/panel_widget_providers_test.dart`

### Message timeline tests

- `test/features/messages/presentation/view_model/timeline/ordinal/current_visible_month_provider_test.dart`
- `test/features/messages/presentation/view_model/timeline/ordinal/message_timeline_index_coordinator_provider_test.dart`
- `test/features/messages/presentation/view/recovered_visible_month_key_test.dart`
- `test/features/messages/presentation/widgets/message_card_test.dart`
- `test/features/messages/application/strategies/recovered_list_ordinal_strategy_test.dart`
- `test/features/messages/application/view_spec/widget_builders/messages_view_builder_keys_test.dart`

### Attachments tests

- `test/features/attachments/application/historical_snapshot_reader_test.dart`
- `test/features/attachments/application/cross_snapshot_mapper_test.dart`

## Baseline Structural Metrics

Record these before Phase 1 begins.

### Baseline snapshot captured on 2026-04-04

#### Current widget transport baseline

- `featureComplex` runtime call sites: 3
  - `lib/features/contacts/application/sidebar_cassette_spec/resolvers/contact_chooser_resolver.dart`
  - `lib/features/handles/application/sidebar_cassette_spec/resolvers/stray_handles_review_resolver.dart`
  - `lib/features/messages/application/sidebar_cassette_spec/resolvers/heatmap_resolver.dart`

### Current widget transport baseline

- `featureComplex` runtime call sites: 3
  - contact chooser
  - stray handles review
  - messages heatmap

### Current panel authorship baseline

- Active center-panel repair hooks exist in runtime code:
  - `_syncProjectedCenterPanel()`
  - `_schedulePanelClearIfNoProjectedCenter()`
  - `reconcileSidebarPanels(...)`
- Confirmed structural evidence:
  - `lib/essentials/navigation/application/panels_view_state_provider.dart`
    still exposes direct center/right mutation through `show`, `push`, and
    `clear`.
  - `lib/essentials/navigation/application/panel_widget_providers.dart`
    still makes `centerPanelWidget(...)` watch
    `reconcileSidebarPanelsProvider(mode)` before rendering.
  - `lib/essentials/sidebar/application/sidebar_flow_state_provider.dart`
    still invokes `_syncProjectedCenterPanel()` as part of normal
    messages-branch transitions.
- Baseline conclusion:
  - Flow-managed center meaning is not yet a pure projection from
    `SidebarFlowState.projectedCenterSpec`; `PanelStack` state is still policed
    by active repair paths.

### Current hidden right-panel persistence baseline

- Confirmed structural evidence:
  - `lib/essentials/navigation/application/panel_widget_providers.dart`
    computes `shouldShowEndSidebar(...)` by first checking whether the right
    stack is empty and then checking center-spec compatibility.
  - `rightPanelWidget(...)` still reads and builds from the right stack
    independently of `shouldShowEndSidebar(...)`.
  - `lib/essentials/navigation/presentation/view/macos_app_shell.dart`
    applies shell visibility afterward through `_EndSidebarSyncObserver`.
- Baseline conclusion:
  - Incompatible right-panel state can survive while hidden. Visibility is not
    yet equivalent to semantic existence.

### Current recovered special-case baseline

- `RecoveredListOrdinalStrategy` exists
- recovered-specific branching exists in ordinal provider
- recovered-specific scaffold behavior exists in timeline view
- Confirmed locations:
  - `lib/features/messages/application/strategies/recovered_list_ordinal_strategy.dart`
  - `lib/features/messages/presentation/view_model/timeline/ordinal/message_timeline_ordinal_provider.dart`
  - `lib/features/messages/presentation/view/messages_timeline_view.dart`

### Baseline focused suite status on 2026-04-04

- Result: green after one narrow stabilization fix
- Fixed failing test:
  - `test/essentials/sidebar/application/sidebar_cassette_sectioning_test.dart`
- Fixed regression:
  - `sidebarCassetteSectionTopSpacing returns no extra spacing for first cassette in a section run`
  - previous failure: expected `0`, actual `8.0`
- Root cause:
  - `sidebarCassetteSectionTopSpacing(...)` was incorrectly authoring
    same-section rhythm even though that spacing belongs to cassette payload
    spacing or card chrome.
- Added debug-only assertion:
  - `lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart`
    now fails loudly if the sectioning layer tries to add spacing between
    contiguous cassettes in the same semantic section.
- Interpretation:
  - The focused Phase 0 baseline suite is now green, and the suite can serve
    as the active gate for subsequent refactor phases.

### Baseline focused suite rerun on 2026-04-04 after Phase 0 contract hardening

- Result: green
- Aggregate result: 42 passed, 0 failed
- Covered surfaces:
  - sidebar flow / cassette coordinator / action dispatcher / cassette sectioning
  - panel widget derivation
  - message timeline ordinal and rendering keys
  - recovered visible-month behavior
  - attachment snapshot readers and cross-snapshot mapping
- Interpretation:
  - The Phase 0 enforcement and boundary-hardening slices did not introduce an
    automated semantic regression in the documented focused baseline suite.

## Phase Gates

## Phase 0 - Baseline and Guard Rails

### Structural metrics

- Baseline counts recorded
- Resolver and payload enforcement contracts defined or explicitly tracked as
  the active blocking task
- No semantic behavior changes introduced

### Automated gate

- Baseline focused suite green
- Initial enforcement scaffolding exists for static checks and architecture
  tests, even if some checks begin as TODO-tracked stubs

### Manual gate

- Known regression scenarios still reproduce in the same way before the refactor
  begins

## Phase 1 - Eliminate Widget Transport

### Structural metrics

- `SidebarCassetteCardViewModel.featureComplex` removed
- `SidebarBodyRenderKind.featureComplex` removed
- `grep featureComplex lib/**/*.dart` returns zero runtime uses
- Contact chooser payload transport contains data only
- Contact chooser payload transport contains no callback, builder, or stateful
  runtime object disguised as payload
- Any temporary adapter is behaviorally removable because it is translation
  only

### Automated gate

Keep baseline suite green and add these tests:

- New chooser payload test
  - suggested location:
    `test/features/contacts/application/sidebar_cassette_spec/resolvers/contact_chooser_resolver_test.dart`
- New chooser UI-state regression test for All/Favourites switching
  - suggested location:
    `test/features/contacts/presentation/widgets/contact_grouped_picker_test.dart`
- Expand `test/essentials/sidebar/application/cassette_widget_coordinator_provider_test.dart`
  to assert data-only payload transport for chooser, heatmap, and stray-handle
  pathways
- Add architecture tests or static checks proving chooser payload models do not
  reference forbidden runtime UI types
- If temporary adapters exist, add adapter-removal proof tests or equivalent
  provider tests showing they are pure shape translation only

### Manual gate

- All/Favourites toggle always updates visible contacts immediately
- Returning to chooser state never shows a stale previous subtree

## Phase 2 - Collapse Panel Writing to a Single Path

### Structural metrics

- `_syncProjectedCenterPanel()` removed from normal execution
- `_schedulePanelClearIfNoProjectedCenter()` removed from normal execution
- `reconcileSidebarPanels(...)` reduced to fail-fast validation only or removed
- flow-managed center content is derivable from `SidebarFlowState` alone
- `PanelStack` cannot hold flow-managed center meaning that is not derivable
  from `SidebarFlowState.projectedCenterSpec`

### Automated gate

Keep baseline suite green and add or expand:

- `test/essentials/sidebar/application/sidebar_flow_state_provider_test.dart`
  to prove projected center derivation for all messages-branch transitions
- `test/essentials/navigation/application/panel_widget_providers_test.dart`
  to prove no stale center content remains after contact reset or branch change
- provider-level tests proving incompatible flow-managed center content cannot
  persist inside `PanelStack`

### Manual gate

- "Change contact..." removes center content without post-frame rescue
- switching branch from contacts to global timeline never leaves stale contact
  messages visible

## Phase 3 - Enforce Right-Panel Derivation

### Structural metrics

- right-panel visibility derived solely from center-spec compatibility
- no cleanup path required to remove stale right-panel content
- no incompatible hidden right-panel state object exists while the current
  center spec is unsupported

### Automated gate

Expand `test/essentials/navigation/application/panel_widget_providers_test.dart`
with:

- compatible center spec -> right panel visible
- incompatible center spec -> right panel absent
- switching center capability removes right panel by derivation
- incompatible center spec -> no hidden retained right-panel state survives

### Manual gate

- recovered attachment sidebar appears only when supported by active center spec
- switching away from recovered-capable center content removes right sidebar
  immediately

## Phase 4 - Unify Recovered Timelines

### Structural metrics

- recovered scope uses standard pipeline shape
- recovered-only scaffold branch removed from `messages_timeline_view.dart`
- recovered timeline behavior no longer depends on a dedicated surface contract
- no recovered-specific branching remains in ordinal providers, hydration, or
  rendering outside the scope definition itself

### Automated gate

Replace or expand tests so recovered scope is tested through the same pipeline:

- update `test/features/messages/application/strategies/recovered_list_ordinal_strategy_test.dart`
  or replace it with a unified recovered-scope ordinal contract test
- expand
  `test/features/messages/presentation/view_model/timeline/ordinal/message_timeline_index_coordinator_provider_test.dart`
  to cover recovered scope under unified behavior
- add a unified timeline widget test
  - suggested location:
    `test/features/messages/presentation/view/messages_timeline_view_test.dart`
- add code-review gate: recovered support may exist in the scope definition,
  but must not require recovered-only `if recovered` logic elsewhere in
  ordinal providers or render scaffolds

### Manual gate

- recovered timeline can scroll, jump, and render via the main timeline surface
- switching between regular and recovered scopes fully replaces semantics and UI

## Phase 5 - Remove Widget-Based Layout Inference

### Structural metrics

- widget-unwrapping layout helpers removed
- sidebar layout operates on explicit descriptors only

### Automated gate

Expand:

- `test/essentials/sidebar/application/sidebar_cassette_sectioning_test.dart`
- `test/essentials/navigation/application/panel_widget_providers_test.dart`

Add descriptor-driven layout regression tests proving:

- pinned controls
- expanding content
- role-based spacing
- authored order after the pinned-control block

### Manual gate

- sidebar visual layout remains unchanged where intended
- control pinning and expansion still work correctly

## Phase 6 - Final Hardening

### Structural metrics

- no alternate semantic writer remains in normal execution
- invalid cross-surface combinations fail loudly in debug/test
- no hidden incompatible state persists for flow-managed center or right-panel
  behavior

### Automated gate

- all focused tests green
- any newly added invariant/assertion tests green

### Manual gate

- full runtime matrix passes:
  - choose contact
  - change contact
  - switch All/Favourites
  - switch global vs contact vs recovered
  - open and close recovered attachment sidebar
  - render message images via live and archived provenance

## Golden Acceptance Criteria

The full refactor is complete only when all six statements are true.

1. Reading `SidebarFlowState` predicts sidebar structure, center content, and
   right-panel presence for flow-managed message branches.
2. No stale UI survives any semantic transition.
3. No normal execution path relies on repair logic.
4. Attachment provenance changes do not alter scope, identity, or timeline
   structure.
5. Recovered and normal timelines share one pipeline shape.
6. Inspecting `SidebarFlowState` is sufficient to predict sidebar contents,
  center content, right-panel existence, and message scope for the
  flow-managed branch without relying on widget code, prior UI state, or
  reconciliation.
