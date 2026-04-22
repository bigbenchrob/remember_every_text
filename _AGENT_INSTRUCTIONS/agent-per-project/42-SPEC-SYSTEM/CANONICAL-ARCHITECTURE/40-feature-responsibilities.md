TL;DR

Features provide content and feature-specific interpretation. They do not own app-level orchestration, surface topology, shared chrome, or global flow. Coordinators route and resolve; rendering stays downstream.

# Feature Responsibilities

## The core boundary

Features participate in the spec system through approved spec variants and feature coordinators.

The boundary is:

Features provide content.
Essentials controls flow.

This boundary is not stylistic. It prevents each feature from creating its own private navigation, topology, and rendering system.

## What features may own

Features may own:

* feature-specific domain concepts
* feature-owned inner spec classes
* interpretation of their own spec variants
* feature-level coordinators for approved surfaces
* resolvers for feature data and view model construction
* resolver tools and pure helpers
* feature-specific render-edge components where the surface contract allows them
* feature presentation views used downstream of resolved content

Feature-owned specs must remain domain data. They must not import application, infrastructure, or presentation code.

## What features must not own

Features must not own:

* app-level navigation flow
* global flow state
* sidebar rack topology outside approved topology files
* panel stack state
* shared sidebar chrome
* outer surface layout
* cross-surface reconciliation
* direct imports into other features' coordinators, resolvers, or builders
* hidden durable state that competes with global flow state

If a feature needs another surface to change, it dispatches a spec through that surface's state API. It does not call another surface's coordinator or manipulate another surface's internals.

## Coordinator responsibilities

Coordinators route. They do not render.

Feature coordinators may:

* pattern-match the feature-owned spec
* extract explicit values from the spec
* call the correct resolver
* return the surface-approved structured result

Feature coordinators must not:

* perform IO
* contain business logic
* construct widgets as an orchestration shortcut
* assemble shared chrome
* choose app-level navigation
* inspect unrelated surface state to recover meaning

No widget leakage across the coordinator boundary is permitted for new canonical work.

### Panel legacy note

Older panel reference material may describe synchronous widget-returning feature coordinators. Treat that as a legacy/current-state migration boundary only.

For new work:

* coordinators must preserve the data-only boundary
* features must return structured data, payloads, or view models from coordination/resolution stages
* widget construction must stay downstream at the render edge
* the legacy panel contract must not be copied into new variants, surfaces, or abstractions

## Resolver responsibilities

Resolvers produce resolved data.

Resolvers may:

* fetch or derive domain data using approved providers and repositories
* compute labels, body text, counts, scopes, and layout roles
* construct payloads or view models
* encode empty and error states as content

Resolvers must not:

* receive whole specs when the coordinator can pass explicit values
* mutate global flow state
* coordinate other surfaces
* return shared chrome widgets
* swallow failures that should become explicit empty/error payload state

## Builder and rendering responsibilities

Builders and presentation views are render-edge code.

They may:

* build widgets from already-decided inputs
* watch reactive data when the surface contract requires self-loading views
* implement feature-specific presentation inside an essentials-owned frame

They must not:

* interpret specs
* make topology decisions
* perform IO that belongs in a resolver
* decide durable navigation flow
* redefine shared outer layout

## Essentials-owned responsibilities

Essentials owns the shared system:

* top-level spec classes such as `CassetteSpec` and `ViewSpec`
* surface state models such as cassette racks and panel stacks
* app-level coordinators
* global flow state and semantic transitions
* topology dispatch and approved cross-feature links
* shared sidebar layout and chrome
* panel stack surfaces and cross-surface reconciliation
* navigation barrels and public feature entry boundaries

Essentials may route to features. Features may not reach back into essentials internals except through approved public providers and spec dispatch APIs.

## Approved feature participation pattern

The standard feature structure is:

* `domain/spec_classes/` for feature-owned specs
* `application/<surface>_spec/coordinators/` for routing
* `application/<surface>_spec/resolvers/` for resolution
* `application/<surface>_spec/resolver_tools/` for helpers
* `application/<surface>_spec/widget_builders/` for render-edge assembly
* `feature_level_providers.dart` as the only public feature entry point

External code imports the feature barrel only. It must not import resolvers, resolver tools, widget builders, or internal providers directly.

## Interpreting approved spec variants

Features may interpret only their own inner spec variants.

Allowed:

* `MessagesSpec.forContact(...)` interpreted by messages feature code
* `ContactsCassetteSpec.contactChooser(...)` interpreted by contacts feature code
* feature coordinator exhaustively handling feature-owned variants

Forbidden:

* a feature pattern-matching top-level `ViewSpec` or `CassetteSpec` outside its approved surface boundary
* a feature inferring sidebar branch meaning by scanning the rack
* a feature creating a second navigation path because it already has enough data to build a widget

## Operational rule

When placing new logic, ask:

* Is this durable meaning? Put it in global flow state or the relevant semantic state owner.
* Is this a surface declaration? Put it in a spec.
* Is this routing? Put it in a coordinator.
* Is this data derivation? Put it in a resolver.
* Is this final widget construction? Put it at the render edge.

If the logic answers more than one of those questions, split it.

## Reference material

Use [REFERENCE/52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/](../REFERENCE/52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/) for deeper conventions and historical current-state details.
