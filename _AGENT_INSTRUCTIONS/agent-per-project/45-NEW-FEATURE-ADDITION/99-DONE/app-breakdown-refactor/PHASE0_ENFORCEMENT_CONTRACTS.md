# Phase 0 Enforcement Contracts

This document turns the anti-drift principles in `foundational-constraints.txt`
into concrete implementation contracts for the sidebar refactor.

It is intentionally grounded in primitives that already exist in the codebase,
so the refactor can harden current structure instead of inventing a parallel
architecture.

## Purpose

The immediate goal is to remove transported widget subtrees without replacing
them with builder callbacks, closures, or other runtime behavior smuggled
through payload objects.

The guiding rule is:

`meaning may cross the boundary; execution may not`

## Current Leverage Points Already Present

The codebase already contains three useful foundations:

1. `SidebarCassettePayload`
   The app-level cassette coordinator already routes specs to feature
   coordinators and receives a payload object rather than a wrapped sidebar
   widget.
2. `SidebarBodyModel`
   The sidebar domain already contains multiple inert body descriptors such as
   list, dropdown, segmented control, heat map, info, hero, and composite
   models.
3. `SidebarActionIntent` plus `SidebarActionDispatcher`
   The sidebar domain already carries typed semantic intents, and execution is
   already centralized in the dispatcher rather than embedded as callbacks.

These primitives should be hardened, not bypassed.

## Contract 1 - Central Resolver Return Contract

### Rule

Sidebar resolvers must return data-only transport objects.

### Target shape

- coordinator return type: `Future<SidebarCassettePayload>`
- resolver return type: a concrete subtype of `SidebarCassettePayload`
- forbidden return types:
  - `Widget`
  - widget subtree containers
  - `WidgetBuilder`
  - `dynamic`
  - open-ended object maps that can carry arbitrary runtime behavior

### Enforcement intention

A future resolver implementation should have no legal way to return a widget
subtree without deliberately violating the type contract.

## Contract 2 - Inert Payload Transport

### Rule

Every transported cassette payload must be inert.

Allowed contents:

- IDs
- enums
- layout roles
- render discriminators
- immutable lists, records, and maps of data
- semantic action descriptors
- content descriptors
- inert metadata

Forbidden contents:

- `Widget`
- `WidgetBuilder`
- `BuildContext`
- `Ref` or `WidgetRef`
- controllers, notifiers, listeners
- focus or scroll state objects
- streams used as UI state carriers
- function fields
- closures
- any object whose primary purpose is to execute UI behavior later

### Immediate implication for current sidebar payloads

`SidebarCassetteCardViewModel.featureComplex` is incompatible with this
contract because it transports a prebuilt widget subtree through the payload.

## Contract 3 - Render-Dispatch Contract

### Rule

Rendering must be selected by payload type, payload render kind, and explicit
feature render variant.

### Current implementation status

The sidebar host should centralize dispatch in one router:

- primary dispatch by `SidebarCassetteRenderKind`
- secondary dispatch by inert payload subtype when a render kind represents a
  feature-owned family such as placement-governed cassettes

This makes the render contract explicit in code and avoids smuggling render
selection through transported builders or prebuilt subtrees.

Rendering must not be selected by transporting:

- a runtime builder callback
- a feature-supplied render closure
- a prebuilt subtree

### Practical meaning

The builder contract must exist in code structure, not as a runtime object in a
payload field.

Valid pattern:

- resolver returns inert chooser payload
- render host switches on payload render kind, then payload type/render variant
- feature-owned render builder constructs the widget tree at render time

Invalid pattern:

- resolver returns `builder: (...) => ...`
- resolver returns a callback that later builds UI from captured state

## Contract 4 - Semantic Action Transport

### Rule

User actions may cross the boundary only as typed semantic intent.

The current `SidebarActionIntent` and `SidebarActionDescriptor` model is the
preferred baseline for this refactor.

Good:

- `ContactChosen(contactId: 42)`
- `ContactMessageScopeChanged(contactId: 42, scope: ...)`
- `HeatMapMonthFocused(monthAnchor: ..., contactId: 42)`

### Current implementation status

The current sidebar semantic action boundary is:

- `SidebarActionIntent` as the sealed meaning carrier
- `SidebarActionDescriptor` as the inert render-edge wiring descriptor
- body/list/dropdown/segment models that reference intents and descriptors only

These transport types must remain data-only and must not gain callback fields,
dispatcher references, or widget/runtime execution types.

Bad:

- `onTap: () => ...`
- callback fields that capture stale semantic state
- payload fields containing dispatcher objects

### Practical meaning

Payloads may describe interaction, but they may not carry execution.

Execution belongs at render time through `SidebarActionDispatcher` or an
equivalent render-edge dispatcher.

## Contract 5 - Import Boundaries

### Target rule

Resolver/spec/application coordination layers must not import widget or
presentation layers after their migration phase is complete.

Intended dependency direction:

- semantic/spec/application
  -> payload models
  -> render/presentation

Forbidden dependency direction:

- resolver/application/spec
  -> feature widget implementations

### Transitional rule

Any temporary violation must be tracked in `TEMPORARY_EXCEPTIONS.md` with a
removal phase.

## Contract 6 - Contact Chooser First Application

The contact chooser is the first proving ground for these contracts.

### What must stop crossing the boundary

- `ContactFlatListWidget`
- `ContactGroupedPickerWidget`
- any widget subtree built inside the chooser resolver

### What should cross instead

- chooser render variant such as `flat` or `grouped`
- selected contact identity
- section descriptors
- row/item descriptors
- any immutable metadata needed to render recents, favourites, or grouping
- typed semantic intents for selection and scope changes

### What must be reconstructed at render time

- the actual widget tree
- action dispatch wiring
- any ephemeral widget-only state that belongs to rendering rather than
  semantic transport

## Phase 0 Deliverables Derived From These Contracts

Before the chooser refactor begins in earnest, we should produce the following:

1. a formalized resolver return signature using `SidebarCassettePayload`
2. a documented ban on `featureComplex`-style widget transport
3. a documented ban on callback or builder transport-by-stealth
4. first-pass static checks for forbidden imports and forbidden payload fields
5. architecture tests focused on payload purity and render-edge discipline
6. choke-point comments on the resolver boundary, payload base type, and render
   dispatch host

## Non-Goals

This contract document does not force all complex sidebar UI into essentials.

Feature-owned complex UI remains valid.
The restriction is only this:

- features may own the render implementation
- features may not transport prebuilt UI or executable runtime behavior across
  coordination boundaries
