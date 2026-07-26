TL;DR

Panel content is selected by `ViewSpec`, stored in panel stacks, resolved through coordinators, and rendered downstream. The panel is part of the same cross-surface system as the sidebar; it must not become an independent second source of flow truth.

# Panel ViewSpec System

## Role in the broader spec system

The panel system applies the shared pipeline to center and right panels:

Spec → Coordinator → Resolver → Payload / ViewModel → Rendering

The panel differs from the sidebar because it displays full panel content rather than cassette cards. That difference changes the surface contract, but not the architectural rule that selection, resolution, and rendering must remain distinct.

## View specs

`ViewSpec` is the essentials-owned top-level spec for panel content. It wraps feature-owned or system-owned inner specs.

`ViewSpec` is the only navigation currency for panels.

Allowed:

* update panel state with a `ViewSpec`
* push, show, activate, close, or clear pages through panel state APIs
* let feature-owned spec variants describe feature-specific panel content

Forbidden:

* direct widget insertion into panel state
* string route names as panel truth
* context-based navigation that bypasses `ViewSpec`
* feature-owned panel state that competes with global flow state

## Panel stacks

Each panel owns an immutable stack of pages.

A page carries:

* stable page identity
* active `ViewSpec`
* title or metadata needed by the panel surface
* closability and stack behavior

The stack controls panel presentation mechanics. It does not own durable app meaning for flow-managed branches.

For flow-managed messages behavior, the active panel spec is a projection of the same global flow state that drives the sidebar.

## View selection, resolution, and rendering

These responsibilities must stay separate.

View selection:

* chooses a `ViewSpec`
* belongs to global flow transitions, panel state APIs, or explicit system navigation
* must be coherent with sidebar/onboarding state when the surface is dependent

Resolution:

* interprets the feature-owned inner spec
* resolves the data or view model needed by the panel
* must not own app-level navigation

Rendering:

* builds widgets at the panel surface or feature render edge from resolved data
* watches reactive data where the panel contract requires self-loading views
* must not become the source of semantic truth

## Relationship to the cross-surface model

The center panel is often a projection of the active sidebar flow.

Examples:

* chosen contact + regular message scope -> contact timeline view spec
* chosen contact + recovered scope -> recovered messages view spec
* global branch -> global timeline view spec
* onboarding gate -> explicit onboarding or readiness surface

The right panel is commonly subordinate to center panel content. If the active
investigation no longer supports stored right-panel context, that context must
cease to be effective. It does not necessarily need to be deleted.

## Total presentation projections

An active investigation should project a truthful center presentation even
when it has no selected target. Absence is appropriate when the investigation
itself is inactive, not merely when the user has not yet selected an item.

Where an investigation supports selection, prefer one feature-owned outer
ViewSpec with an explicit target union such as `idle | selected item`. Do not
add a separate `isIdle` flag, a second feature-owned ViewSpec, or synthetic
layout reservations. The idle target is application state with real
presentation, not a layout workaround.

Unknown Sources is the first implemented example. Its Messages-owned ViewSpec
contains the opaque investigation identity, the Handles-owned investigation
kind, and either an idle or selected-source target. Initial entry, incompatible
filter changes, investigation switching, and successful dismissal therefore
retain a nonempty center projection while the investigation remains active.
The selected-source target continues to render the established evidence
surface and actions.

## Stored and effective panel state

Stored panel state and effective panel presentation are deliberately distinct.

Stored state preserves a panel request so temporary navigation away from its
originating context does not destroy useful work. Effective state is derived by
checking whether that stored request is compatible with the current durable
context or investigation.

The governing rules are:

* incompatible stored state remains stored unless an owner explicitly replaces
  it for an independent reason
* effective panel providers expose only compatible state
* panel visibility derives from effective state
* downstream anchors and projections must read effective state, not stored
  state
* callers must not scatter imperative panel-clearing commands to repair missing
  compatibility rules

A Search-created subordinate presentation is effective only while its opaque
originating Search investigation identity remains current. Navigating away and
returning without changing that investigation may therefore restore the stored
presentation. Replacing the investigation makes the old presentation
ineffective even when the new query parameters later equal the old ones.

Panel content is independent only when that independence is explicitly declared by system flow.

## Message display pipeline inside the panel model

Message panels have their own internal pipeline, but it still starts with semantic panel selection.

Message display should be understood as:

1. semantic scope from `ViewSpec` / `MessagesSpec`
2. ordinal access within that scope
3. row hydration and attachment provenance
4. row rendering

The scope layer determines which messages exist on screen. Hydration and rendering must not change that semantic scope.

Attachment availability is part of hydration, not navigation. A message remains the same message whether its attachment is loaded from the live Messages path, the app archive, or a deterministic historical import.

## Legacy/current-state migration boundary

Some older panel reference material describes synchronous widget-returning feature coordinators. That reflects a legacy/current-state implementation boundary in parts of the app.

That wording is not an approved pattern for new work.

Canonical panel work must preserve the data-only coordinator boundary:

* panel coordinators route `ViewSpec` values and return structured data, payloads, or view models
* feature resolution is distinguishable from widget construction
* widgets are terminal render output, not transported state
* new panel patterns must not deepen widget leakage across coordinator boundaries

When changing existing panel code, preserve current runtime behavior unless the task explicitly includes migration. Do not spread the legacy widget-returning contract to new variants, surfaces, or abstractions.

## Reference material

Use these for detail:

* [REFERENCE/56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/](../REFERENCE/56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/)
* [REFERENCE/58-COORDINATED-SPEC-DRIVEN-CONTENT-SYSTEM/20-message-display-pipeline.md](../REFERENCE/58-COORDINATED-SPEC-DRIVEN-CONTENT-SYSTEM/20-message-display-pipeline.md)
* [Search interactions and investigation compatibility](../../40-FEATURES/search/INTERACTIONS_AND_NAVIGATION.md)
* [Unknown Sources total center projection](../../45-NEW-FEATURE-ADDITION/10-UNKNOWN_SOURCES/PROPOSAL.md#implemented-investigation-provenance)
