# MessageLens App Breakdown Refactor - Checklist

This checklist is the execution companion to `IMPLEMENTATION_PLAN.md`.

Do not check a phase complete until every structural, automated, and runtime
gate for that phase has been satisfied.

---

## Active Runtime Context

- [x] Capture second-opinion context for the contact-timeline inertial-scroll
                  freeze in `CONTACT_TIMELINE_INERTIAL_SCROLL_FREEZE_NOTE.md`
      Status 2026-04-06: scroll-driven row suppression was removed after it caused
      blank placeholder rows; lightweight neighbor grouping metadata replaced full
      neighbor hydration; inertial scroll still freezes immediately, which now
      points most strongly to current-row attachment/media work rather than the
      viewport shell itself.
- [x] Record the follow-on second-opinion directive in
      `INERTIAL_SCROLL_FREEZE_2ND_OPINION.TXT` as the active investigation
      posture for the freeze
      Status 2026-04-06: the second opinion explicitly rejects another
      symptom-masking view-layer patch, requires instrumentation before the next
      fix attempt, frames the issue as a message-row hot-path architecture
      problem, and favors one narrow next slice: identify whether inertial
      churn is dominated by invalidation fan-out, current-row
      attachment/provenance recomputation, heavyweight media activation, or a
      combination of the three.

---

## Phase 0 - Baseline and Guard Rails

- [x] Record baseline `featureComplex` call sites and locations
- [x] Record baseline panel-repair hooks and locations
- [x] Record baseline recovered special-case locations
- [x] Freeze focused baseline suite in `TESTS.md`
- [x] Add any missing debug assertions that expose invariant breaches without
      repairing them
- [x] Record whether flow-managed center meaning can survive inside
      `PanelStack` independently of canonical semantic state
- [x] Record whether incompatible right-panel state can survive while hidden
- [x] Formalize central resolver return contract as data-only payload
      Status 2026-04-07: app-level cassette coordination now routes through
      `Future<SidebarCassettePayload>`, feature coordinators/resolvers return
      payloads rather than widgets, and the sidebar render router selects rendering
      from explicit payload render kind plus payload subtype at the render edge.
- [x] Define sealed inert payload hierarchy for cross-boundary transport
      Status 2026-04-07: sidebar transport is now explicitly split into
      `InertSidebarCassettePayload`, `PlacementGovernedSidebarCassettePayload`,
      `FeatureInfoSidebarCassettePayload`, and
      `SharedBodyModelSidebarCassettePayload`, with no remaining tracked widget
      payload exception in the architecture tripwire.
- [x] Define render-dispatch contract by payload type/render kind, not builders
- [x] Define semantic action descriptor model with no executable callbacks
      Status 2026-04-04: `SidebarActionIntent` remains the sealed semantic
      meaning carrier, `SidebarActionDescriptor` is now explicitly an inert final
      descriptor type, and architecture tests freeze the sidebar semantic action
      transport files against callback, dispatcher, widget, and Riverpod/runtime
      execution drift.
- [x] Define intended import boundaries between semantic and render layers
      Status 2026-04-04: semantic-layer import boundaries are documented in
      `PHASE0_ENFORCEMENT_CONTRACTS.md`, temporary violations are tracked in
      `TEMPORARY_EXCEPTIONS.md`, and growth is frozen by architecture tests.
- [x] Add first-pass forbidden import and forbidden type checks
- [x] Create architecture test suite scaffold for boundary purity and
      single-writer enforcement
  Status 2026-04-04: the current scaffold covers boundary purity and frozen
  legacy import growth. Single-writer enforcement coverage is still pending in
  later architecture tests.
- [x] Add law-style comments at central resolver, payload, and render-dispatch
      choke points
- [x] Create and maintain central temporary-exception tracking file
- [ ] Require `Architecture Review (Required)` usage for every refactor PR
- [x] Confirm no semantic behavior changed in this phase
      Status 2026-04-04: the documented Phase 0 focused baseline suite was rerun
      after the resolver/payload/render/action contract-hardening slices and
      remained green at 42 passed, 0 failed.

## Phase 1 - Eliminate Widget Transport

### Contact chooser first

- [x] Rewrite contact chooser to use data-only sidebar payload transport
- [x] Ensure chooser mode, sections, and selection state are represented
      semantically, not as transported widgets
- [x] Render chooser only at the render edge
- [x] Ensure any temporary adapter is a pure shape translator only
- [x] Ensure chooser payload contains no widget, builder, callback, or stateful
      runtime object by stealth
  Status 2026-04-04: `ContactChooserCassettePayload` now carries picker mode,
  current filter mode, chosen contact selection, and precomputed filtered
  sections; the app-level cassette coordinator explicitly watches chooser
  filter/section inputs; and the render adapter only selects the concrete
  widget family at the render edge.
- [x] Add regression coverage for All/Favourites switching
- [x] Verify chooser no longer retains stale subtree state
      Status 2026-04-04: chooser widget coverage now proves that replacing the
      chooser subtree with non-chooser content and returning with a different
      semantic payload does not resurrect stale rows or stale toggle meaning.

### Remove remaining `featureComplex` pathways

- [x] Migrate stray handles review away from `featureComplex`
- [x] Migrate messages heatmap away from `featureComplex`
- [x] Remove `SidebarCassetteCardViewModel.featureComplex`
- [x] Remove `SidebarBodyRenderKind.featureComplex`
- [x] Verify `grep featureComplex lib/**/*.dart` returns zero runtime uses
      Status 2026-04-04: stray-handles review and heatmap both resolve to
      placement-governed inert payloads, the runtime `featureComplex` symbol is
      gone from `lib`, and focused resolver/coordinator/render tests cover the
      migrated paths.
- [x] Verify no renamed helper or wrapped pathway preserves `featureComplex`
      behavior in normal execution
      Status 2026-04-07: the shared sidebar render contract now has only
      `placementGovernedFeature`, `featureInfo`, and `sharedBodyModel`, the
      router dispatches placement-governed payloads directly to feature-owned
      body builders, and focused heatmap/handles resolver tests continue to
      prove direct inert payload resolution with no `featureComplex` symbol,
      legacy widget payload, or alternate wrapped render family left in `lib`.

### Phase 1 gate

- [x] Sidebar payload transport contains no `Widget` or widget subtree
      Status 2026-04-07: `test/architecture/forbidden_imports_test.dart` now
      expects zero tracked widget-payload exceptions, matching the current inert
      payload base types.
- [x] Sidebar payload transport contains no builder callback or executable
                  runtime object by stealth
      Status 2026-04-07: the payload tripwire remains focused on forbidden runtime
      UI types, and the current sidebar payload base plus feature payload files are
      widget-free and callback-free.
- [x] Any temporary adapter can be removed without behavior change
      Status 2026-04-09: the shared sidebar layer now resolves cassettes
      independently instead of funnelling the whole rack through one async
      value, so the chooser-specific render-edge snapshot upgrade has been
      removed again. Focused sidebar/navigation and chooser coordinator tests
      are green, and live runtime verification confirmed the picker still
      appears and works in the sidebar with the adapter-free path.
- [x] Focused tests pass
      Status 2026-04-07: the documented focused baseline suite was rerun after
      the chooser snapshot/payload cleanup and remained green at 71 passed,
      0 failed across sidebar, panel, message timeline, recovered timeline,
      message card, and attachment snapshot surfaces.
- [x] Live picker behavior is deterministic
      Status 2026-04-09: live runtime verification confirmed that the picker
      appears and works in the sidebar after restoring the adapter-free path on
      top of the per-cassette shared resolution flow.

## Phase 2 - Collapse Panel Writing to a Single Path

- [x] Separate flow-managed center-panel behavior from sidebar-independent panel
      behavior
      Status 2026-04-08: effective center rendering remains derived from
      `SidebarFlowState.projectedCenterSpec`, sidebar-independent and
      compatible non-flow surfaces still ride the stored center stack, and the
      flow notifier now clears incompatible stored flow-managed center pages at
      transition time so the two ownership modes do not leak into each other.
- [x] Replace normal center-panel mutation path with derivation from
      `SidebarFlowState.projectedCenterSpec`
      Status 2026-04-08: the active contacts/messages sidebar flow now routes
      through `SidebarFlowState.projectedCenterSpec` and the effective center
      panel providers rather than imperative center-panel writes. The remaining
      direct center writes are sidebar-independent or non-flow navigation
      surfaces, not the canonical messages flow.
- [x] Restrict flow-managed `PanelStack` usage to render-container behavior only
      Status 2026-04-08: focused navigation tests now prove that a conflicting
      stored flow-managed messages page cannot override the derived effective
      center spec, and overlay/observer logic reads the effective center spec
      instead of the raw stored center stack.
- [x] Remove `_syncProjectedCenterPanel()` from normal execution
      Status 2026-04-08: the legacy helper is no longer present anywhere in
      `lib` or `test`; flow-managed center projection now runs through
      `SidebarFlowState.projectedCenterSpec` and the effective center panel
      providers instead.
- [x] Remove `_schedulePanelClearIfNoProjectedCenter()` from normal execution
      Status 2026-04-08: the old clear-helper name is no longer present
      anywhere in `lib` or `test`; center clearing is no longer driven by a
      sidebar-flow repair hook.
- [x] Demote or delete `reconcileSidebarPanels(...)` as active repair logic
      Status 2026-04-08: the compatibility provider has been removed from
      normal execution and focused sidebar/navigation tests now watch the
      effective derived center/right panel providers directly instead of a
      no-op reconciliation hook.
- [x] Verify no renamed or wrapped helper preserves the same repair behavior
      Status 2026-04-08: the remaining messages-mode center show/clear sites
      are direct user or system navigation entry points (toolbar import /
      onboarding, chat selection, date-range jumps, stray-handle lens) rather
      than hidden sidebar-flow repair helpers. Feature-side readers that only
      need the active center meaning now consume `effectiveCenterPanelSpec`
      instead of inspecting the stored center stack directly.
- [x] Verify canonical flow state predicts the flow-managed center surface
      Status 2026-04-08: `effectiveCenterPanelSpec` is now the shared source
      for panel-state reasoning in the parked overlay and onboarding observer,
      and focused tests prove canonical flow wins over conflicting stored
      flow-managed center pages.

### Phase 2 gate

- [x] No stale center content can persist after branch transitions
      Status 2026-04-08: focused sidebar flow tests now cover
      `chooseAnotherContact()` with a conflicting stored flow-managed center
      page already present and confirm both the effective center surface and
      the stored center stack clear on the branch reset.
- [x] `PanelStack` cannot retain incompatible flow-managed center meaning
      Status 2026-04-08: flow-managed messages pages that diverge from the
      canonical projected center spec are now cleared at the single
      `SidebarFlow` transition point, preventing stale contact/global/recovered
      meanings from lingering in the stored center stack.
- [x] Focused sidebar/navigation tests pass
      Status 2026-04-08: focused Phase 2 coverage is green across the derived
      center/right provider tests, sidebar flow/action dispatch tests, the
      onboarding center sync observer tests, and the stray-handles review
      cassette regression that now reads `effectiveCenterPanelSpec` instead of
      the stored center stack. Latest focused rerun: 32 passed, 0 failed.
- [x] Manual "Change contact..." scenario clears by derivation, not rescue logic
      Status 2026-04-08: manual runtime validation confirmed that the Change
      Contact flow clears both the center panel and end sidebar cleanly with no
      visible stale content or rescue-style repair behavior.

## Phase 3 - Enforce Right-Panel Derivation

- [x] Define right-panel eligibility strictly from active center-spec capability
      Status 2026-04-07: the live right-panel surface now flows through
      `effectiveRightPanelStack` / `effectiveRightPanelSpec`, so both right
      rendering and end-sidebar visibility are derived from the active
      effective center surface instead of the stored right stack alone.
- [x] Remove normal cleanup logic that clears right panel after incompatibility
      Status 2026-04-07: `SidebarFlow` now clears stored right-panel state at
      the point where `projectedCenterSpec` changes, and
      `reconcileSidebarPanels` no longer mutates panel state during normal
      runtime.
- [x] Ensure unsupported center specs cannot coexist with a visible right panel
      Status 2026-04-07: `effectiveRightPanelSpec` still derives visibility
      strictly from the effective center surface, so unsupported center specs
      cannot render a visible right panel even if stale stored state exists.
- [x] Ensure incompatible right-panel state cannot survive while hidden
      Status 2026-04-07: the stored right panel is cleared immediately on
      flow-managed center transitions, so incompatible hidden right state no
      longer persists behind derived visibility.
- [x] Add deterministic right-panel derivation tests
      Status 2026-04-07: focused navigation/sidebar tests now assert both
      derived right-surface visibility and transition-time clearing of stored
      right state.

### Phase 3 gate

- [x] Right panel exists only when center spec supports it
- [x] No incompatible hidden right-panel state object survives
- [x] No stale right sidebar remains after center-scope changes
- [x] Focused navigation tests pass

## Phase 4 - Unify Recovered Timelines

- [ ] Replace recovered special casing with a standard scope -> ordinal ->
      hydration -> render pipeline
      Status 2026-04-07: recovered scopes now resolve both ordinal state and
      row hydration through the shared timeline provider contract, and
      recovered search/filter semantics now flow through the shared
      `MessageTimelineViewModel`. The shared `MessagesTimelineView` now also
      owns the recovered scaffold contract, so the remaining divergence is the
      recovered-specific scaffold and row/search-result chrome internal to that
      shared surface rather than a separate center-panel widget contract.
      Recovered rows now render through the shared `_MessageRow` /
      `_SearchResultRow` pathways instead of a dedicated recovered list widget.
- [x] Remove recovered-only scaffold behavior from the unified timeline surface
- [x] Remove ordinal-provider branching for recovered vs normal outside the
      scope definition itself
      Status 2026-04-07: `message_timeline_ordinal_provider.dart` now resolves
      ordinal strategies through `message_timeline_scope_ordinal_extensions.dart`,
      so the recovered-vs-normal fork no longer lives inside the ordinal
      provider itself. Recovered row hydration is now also resolved through the
      shared providers, and `RecoveredListOrdinalStrategy` is only constructed
      from the scope-resolution extension.
- [ ] Remove recovered-only rendering branches outside the scope definition
      itself
      Status 2026-04-07: the remaining recovered-only branches are localized to
      `MessagesTimelineView` for scaffold copy, legend/chrome, recovered row
      presentation, recovered search-result hydration, and attachment-viewer
      affordances. Recovered ordinal/search lookup now flows through one shared
      resolved-row path and recovered scaffold copy/state is centralized behind
      a local presentation config. Recovered row chrome now also resolves
      through a local presentation object instead of carrying selection,
      labeling, and color decisions inline in the widget. Legend and
      attachment-chip styling now also render from local presentation data.
      The recovered content wrapper now receives a single content-presentation
      object instead of raw count and legend inputs, and the recovered
      scaffold delegates async/filter/body branching to one local section
      widget. The old dedicated recovered center-surface contract is the only
      part that is fully gone.
- [ ] Remove or internalize `RecoveredListOrdinalStrategy` only if no
      recovered-specific logic remains outside the scope definition itself
      Status 2026-04-07: `RecoveredListOrdinalStrategy` has already been
      reduced to a scope-owned ordinal helper and is only instantiated from
      `message_timeline_scope_ordinal_extensions.dart`. This remains open until
      the last recovered-specific rendering branches are either internalized
      further or deemed the final intentional surface-specific behavior.
- [ ] Ensure recovered timelines use the same render path as other message
      scopes
      Status 2026-04-07: recovered timelines now share the center-surface shell
      plus the `_MessageRow` / `_SearchResultRow` entry points, but they do not
      yet share the full render path because recovered scaffolding and
      recovered-item presentation still branch inside `MessagesTimelineView`.

### Phase 4 gate

- [x] Recovered timelines no longer use a dedicated surface contract
- [ ] Recovered timelines are not a unified shell over parallel pipelines
- [x] Recovered scope tests pass through the unified pipeline
      Status 2026-04-07: focused tests now cover scope-based ordinal
      resolution, recovered ordinal strategy behavior, recovered builder-key
      routing, and unified-surface search/filter plus recovered attachment
      right-panel behavior.
- [x] Manual recovered-message browsing matches normal timeline behavior
      Status 2026-04-08: manual runtime validation completed across global
      recovered, contact-scoped recovered, and recovered no-handle-from-me
      flows. Search/filter behavior, row rendering, scope switching, and the
      recovered attachment sidebar now match the expected unified behavior,
      including archive-aware attachment resolution in the right sidebar.

## Phase 5 - Remove Widget-Based Layout Inference

- [x] Move pinned/expand/layout decisions into explicit descriptor data
- [x] Remove widget-unwrapping helpers from the sidebar host
- [x] Prove layout can be computed from resolved descriptors only
- [x] Add layout-contract regression tests

### Phase 5 gate

- [x] `unwrapSidebarCassetteCard(...)` removed
- [x] Widget inspection is no longer required for sidebar layout
- [x] Visual layout remains correct in runtime checks

## Phase 6 - Final Hardening and Fail-Fast Invariants

- [x] Add or preserve fail-fast assertions for impossible cross-surface states
- [x] Remove remaining compatibility shims for broken pathways
      Status 2026-04-10: the stale chooser temporary exception has been
      removed from tracking, the shared sidebar layer now depends only on the
      feature-owned `contactChooserCassetteStateProvider`, and essentials no
      longer reach into contacts-internal chooser resolver tools or invalidation
      paths.
- [ ] Re-run the full focused suite and manual scenario matrix
      Status 2026-04-10: the documented focused suite reran green at 119
      passed, 0 failed across sidebar, panel, message timeline, recovered
      timeline, message card, and attachment surfaces. Manual scenario-matrix
      verification still remains.
- [x] Document any residual debt explicitly
      Status 2026-04-10: no active runtime compatibility shims or temporary
      exceptions remain. The remaining Phase 6 debt is explicit and non-code:
      complete the manual scenario matrix and confirm the mandatory PR review
      rubric was applied to each refactor PR.
- [ ] Confirm PR review rubric was applied to every refactor PR

### Final gate

- [ ] One semantic writer governs messages-branch meaning
- [ ] One projection path produces each surface outcome
- [ ] Invalid states fail loudly rather than silently repairing themselves
- [ ] No hidden state persists outside canonical semantic state
- [ ] All targeted tests and runtime checks pass