# 30 - Essentials

Essentials contains app-level systems that coordinate surfaces, durable flow,
shared infrastructure, and shell behavior. It is not a dumping ground for
feature logic.

This folder is currently a high-level entry point, not yet a full subsystem
doc set.

For spec-driven surface work, read this folder together with
[`../42-SPEC-SYSTEM/`](../42-SPEC-SYSTEM/). The canonical pipeline is:

```text
Spec → Coordinator → Resolver → Payload / ViewModel → Rendering
```

## TL;DR

Essentials owns app orchestration. Features provide domain content and approved
feature-owned spec interpretation.

Essentials owns:

* global flow state and app mode
* sidebar cassette rack projection and topology dispatch
* panel stacks, panel surface orchestration, and sidebar parking
* onboarding gate state, onboarding overlay lifecycle, and readiness-panel sync
* shared search service and search indexing infrastructure
* app shell, window state, logging, database infrastructure, import/migration
  orchestration, and shared cross-cutting services

Features must not take ownership of app-level orchestration, global flow state,
panel stack policy, sidebar topology, shared chrome, or cross-surface
reconciliation.

## Current Essentials Structure

Current `lib/essentials/` top-level areas include:

| Area | Current responsibility |
| --- | --- |
| `navigation/` | App shell, active sidebar mode, center/right panel stacks, `ViewSpec` routing, sidebar parking, panel host widgets. |
| `sidebar/` | `CassetteSpec`, stable cassette rack projection, ephemeral cassette projection, topology dispatch, cassette payload resolution, shared sidebar rendering. |
| `search/` | Shared message search service, FTS/simple indexers, search index orchestration and metrics. |
| `onboarding/` | Full Disk Access and import/migration gate state, onboarding overlay lifecycle, environment reports, reset/recovery behavior. |
| `db/` | Centralized database access providers and database infrastructure. |
| `db_importers/` | Import orchestration and import UI/view models. |
| `db_migrate/` | Migration orchestration and migration services. |
| `logging/` | Application logging and diagnostic export support. |
| `window_state/` | Window persistence and platform window-management services. |
| `config/`, `debug/`, `services/`, `tooltips/`, `contacts/` | Shared app infrastructure and smaller cross-cutting systems. |

Do not infer feature ownership from an import path alone. Some feature-specific
content is routed through essentials because essentials owns the surface.
Path location alone does not determine architectural ownership; some
contact-related logic is shared infrastructure while other contact-related
logic remains feature-owned.

## Global Flow State

`sidebar/application/sidebar_flow_state_provider.dart` is the current durable
flow-state owner for the messages/sidebar flow.

It records durable semantic state such as:

* active top menu branch
* chosen contact
* selected handle
* persistent settings context
* optional scroll target
* regular vs recovered message scope

It also projects flow-managed center-panel specs through
`SidebarFlowState.projectedCenterSpec`.

Rules:

* Durable flow meaning belongs in semantic state, not rendered widgets.
* Do not reconstruct durable meaning by scanning built sidebar widgets.
* Do not treat the cassette rack as the source of durable truth.
* When flow changes, incompatible center/right panel content must be cleared or
  replaced.
* Transient settings actions must not be stored in persistent flow state.

## Sidebar Topology And Cassette Rack

The sidebar is a specialization of the spec system.

Current shape:

* `CassetteSpec` is the essentials-owned top-level sidebar spec.
* Feature-owned inner specs are wrapped by `CassetteSpec` variants.
* `CassetteRackState` owns the stable ordered rack per `SidebarMode`.
* `cascade/` owns pure parent-to-child topology.
* `EphemeralCassetteProjection` appends temporary cassette projections after
  the stable rack.
* `RenderableSidebarCassetteSpec` combines stable and ephemeral projection for
  resolution.
* `CassetteWidgetCoordinator` resolves specs into `SidebarCassettePayload`.
* `sidebar_cassette_render_router.dart` performs the terminal widget rendering
  from resolved payloads.

Topology must answer only:

```text
current spec + minimal durable context -> next spec or null
```

It must not procedurally rebuild whole branches, infer state from rendered
widgets, read repositories, watch providers, or perform UI work.

Stable and ephemeral projection are separate:

* Stable rack state represents reconstructable sidebar projection.
* Ephemeral projection represents temporary action flows such as settings
  actions.
* Visible order is stable cassettes first, then ephemeral cassettes.
* Ephemeral behavior must not leak into stable rack or global flow state.

Essentials owns shared sidebar chrome, sectioning, render-kind routing,
placement constraints, expansion behavior, and pinned controls. Features may
provide payload data and approved body content inside that envelope.

## Panel Stack And Panel Content Orchestration

`navigation/domain/entities/view_spec.dart` defines the current top-level
panel navigation currency:

* `ViewSpec.messages`
* `ViewSpec.import`
* `ViewSpec.environmentReadiness`
* `ViewSpec.onboarding`

`PanelsViewState` owns center/right panel stacks per `SidebarMode`.
`panel_widget_providers.dart` derives effective center/right panel stacks,
projects flow-managed center content from `SidebarFlowState`, parks the sidebar
for sidebar-independent specs, and hides incompatible right-panel content.

Panel rules:

* Panel state stores `ViewSpec`, not arbitrary widgets.
* Flow-managed messages panels are projections of global flow state.
* Import, environment readiness, and onboarding specs are explicitly
  sidebar-independent and can park the normal sidebar.
* Right-panel content is subordinate to center-panel compatibility.
* Features may interpret their approved inner specs, but essentials owns panel
  stack policy and cross-surface reconciliation.

### Legacy/current-state panel boundary

Current `PanelCoordinator` and some feature view-spec coordinators still return
widgets synchronously. This is a current implementation and migration boundary,
not an approved pattern for new work.

New panel work must preserve the canonical data boundary:

* coordinators route specs and return structured data, payloads, or view models
* feature resolution remains distinguishable from widget construction
* rendering remains terminal and downstream
* no new widget-returning coordinator pattern should be introduced or spread

When changing existing panel code, preserve runtime behavior unless the task
explicitly includes migrating the panel coordinator boundary.

## Search Ownership

Search infrastructure is essentials-owned.

Current essentials search responsibilities:

* `SearchService` searches global, contact, and chat message scopes.
* search indexers and `SearchIndexOrchestrator` own shared indexing behavior.
* search reads the centralized working database and overlay database providers.

Feature responsibilities are narrower:

* `features/messages` owns timeline UI/search query state for message views and
  calls the essentials search service.
* contacts-specific picker filtering remains feature-local where it is not the
  shared message search/indexing system.

Do not create a separate feature-level message search infrastructure that
competes with `lib/essentials/search`.

## Onboarding Ownership

Onboarding lifecycle is essentials-owned.

Current essentials onboarding responsibilities:

* `OnboardingGate` owns Full Disk Access and import/migration gate state.
* `OnboardingOverlay` owns the blocking overlay lifecycle for import,
  migration, reimport, completion, and recovery.
* `OnboardingCenterPanelSyncObserver` synchronizes FDA/user-action onboarding
  states into the center panel with `ViewSpec.environmentReadiness`.
* `OnboardingStatus` and environment reports classify readiness and recovery
  states.

The `features/environment_readiness` feature owns readiness panel content for
the approved `EnvironmentReadinessSpec`. It does not own the onboarding gate,
app shell overlay policy, active sidebar mode, or panel stack orchestration.

## Essentials vs Feature Boundaries

Essentials may:

* define top-level specs such as `CassetteSpec` and `ViewSpec`
* own app mode, global flow state, panel stacks, sidebar racks, shared chrome,
  and shell behavior
* route top-level specs to feature-owned coordinators
* reconcile sidebar, panel, onboarding, and related surfaces
* provide shared infrastructure such as search, logging, database providers,
  import/migration orchestration, and window state

Features may:

* define feature-owned inner specs
* interpret their approved spec variants
* resolve domain data and return payloads/view models
* render terminal feature content inside essentials-owned surface contracts
* keep local UI state that does not compete with durable app flow

Features must not:

* own global flow state or active app mode
* own cassette rack topology or panel stack policy
* introduce new widget-returning coordinator patterns
* mutate cross-surface state outside approved essentials APIs
* bypass `ViewSpec` for panel navigation
* bypass `CassetteSpec` and payload resolution for sidebar content
* smuggle rendering callbacks, `BuildContext`, `WidgetRef`, controllers, or
  widgets through payloads/view models

## Cross-Surface Coordination Rules

For any work touching sidebar, panels, onboarding, settings, or search-driven
navigation, use the canonical spec architecture:

* [`../42-SPEC-SYSTEM/README.md`](../42-SPEC-SYSTEM/README.md)
* [`../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/10-cross-surface-model.md`](../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/10-cross-surface-model.md)
* [`../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md`](../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md)
* [`../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md`](../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md)
* [`../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/40-feature-responsibilities.md`](../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/40-feature-responsibilities.md)
* [`../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md`](../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md)

If older docs describe a feature owning app-level orchestration, a panel
coordinator returning widgets as the desired pattern, or a sidebar rack acting
as durable truth, treat that wording as legacy/transitional unless current code
and canonical architecture explicitly confirm it.
