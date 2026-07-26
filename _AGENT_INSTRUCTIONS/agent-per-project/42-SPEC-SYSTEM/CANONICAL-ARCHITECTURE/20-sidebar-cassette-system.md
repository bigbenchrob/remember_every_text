TL;DR

Sidebar cassette specs are the sidebar-specific specialization of the broader spec system. The sidebar renders a rack of cassette specs, but durable flow meaning belongs in global flow state. The rack is a projection, not the app's durable truth.

# Sidebar Cassette System

## Role in the broader spec system

The sidebar cassette system applies the shared pipeline to the left sidebar:

Spec → Coordinator → Resolver → Payload / ViewModel → Rendering

It is surface-specific because the sidebar has unique constraints:

* vertical cassette composition
* cascade topology
* shared card chrome
* pinned controls and content zones
* stable and ephemeral projection layers

It is not isolated. Sidebar projection must remain coherent with panel projection and global flow state.

## Cassette specs

`CassetteSpec` is the essentials-owned top-level spec for the sidebar. It wraps feature-owned inner specs such as contacts, messages, handles, settings, or utility specs.

The two-level shape matters:

* essentials owns the surface routing and sidebar composition contract
* features own their inner spec definitions and interpretation
* cross-feature links are expressed through approved topology, not feature imports

Specs declare sidebar content. They do not build sidebar widgets.

## Rack and topology

The cassette rack is an ordered projection of cassette specs for a sidebar mode.

The rack answers:

* which cassettes are visible
* in what order
* with what immediate cascade relationship

Topology answers only one local question:

What is the next child of this cassette spec?

Topology must not assemble full branches procedurally. It must not scan the rack to recover meaning. It must not decide multiple future successors at once.

Correct topology model:

Current spec + minimal durable state -> next spec or null

## Durable flow vs rendered rack

Durable sidebar meaning belongs in global flow state, not in the rendered rack.

For messages/contacts flow, durable meaning includes:

* active top-menu branch
* chosen contact
* selected handle
* regular vs recovered message scope
* optional scroll target or compatible projection state

The rack is still important, but it is a projection required by the cassette coordinator and renderer. If the rack is lost, stable sidebar structure should be reconstructable from durable flow state.

Do not reverse-engineer durable meaning by scanning visible cassette specs.

## Stable and ephemeral sidebar behavior

The sidebar has two projection layers:

1. Stable projection
2. Ephemeral projection

Stable projection:

* derives from durable flow state
* is reconstructable
* participates in persistent sidebar meaning

Ephemeral projection:

* supports temporary action flows such as send logs, reset confirmation, or future one-off prompts
* is rendered through normal cassette specs and payloads
* is not durable
* is terminal
* is cleared when incompatible durable context changes

Visible sidebar order is:

stable specs first, ephemeral specs second

Ephemeral specs may cascade to ephemeral specs. They may not spawn stable specs below them.

## Coordinator and payload boundary

The sidebar coordinator resolves cassette specs into `SidebarCassettePayload` objects.

Feature cassette coordinators may:

* interpret their feature-owned cassette spec
* call exactly one resolver per variant
* return `Future<SidebarCassettePayload>`

Feature cassette coordinators must not:

* return widgets
* construct card chrome
* mutate rack state directly
* coordinate panel flow outside approved spec dispatch

`SidebarCassettePayload` is the boundary contract. It carries semantic content and layout roles. Essentials-owned rendering reads the payload and applies sidebar chrome.

## Essentials-owned layout and composition

Essentials owns:

* cassette rack state and topology dispatch
* outer sidebar rails
* card chrome
* section spacing
* pinned controls vs content composition
* render-kind routing
* expansion behavior

Features may own complex body content only inside the frame essentials provides. A feature-owned body may tune internal lanes, gutters, and local composition, but it must not redefine the sidebar's outer geometry.

Trailing action space must have one owner. If a feature-owned body reserves and
renders its own row action rail, its payload uses the ordinary inset envelope.
The essentials-owned trailing-gutter placement mode is reserved for bodies
whose action occupies the shared outer gutter. Combining both contracts
double-reserves the same space and clips narrow-sidebar content.

## Sidebar and panel coordination

Sidebar changes can invalidate panel content.

When canonical flow changes:

1. durable flow state changes
2. stable cassette projection changes
3. projected panel `ViewSpec` changes
4. effective center/right panel content is re-derived

An incompatible stored panel spec may remain stored so unchanged originating
context can later restore it. It must cease to be effective immediately.
Sidebar widgets must not compensate for missing compatibility rules by issuing
imperative panel-clearing commands.

Sidebar widgets may dispatch panel navigation only by sending a `ViewSpec` through the panel state provider. They must verify their cassette context is still current before doing automatic post-render dispatch.

Widget timing guards are not sufficient by themselves. Essentials-level reconciliation must still prevent stale panel content from surviving incompatible sidebar transitions.

## Reference material

Use these for deeper detail:

* [REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/](../REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/)
* [REFERENCE/55-EPHEMERAL-SPEC-HANDLING/](../REFERENCE/55-EPHEMERAL-SPEC-HANDLING/)
* [REFERENCE/58-COORDINATED-SPEC-DRIVEN-CONTENT-SYSTEM/10-sidebar-panel-coordination.md](../REFERENCE/58-COORDINATED-SPEC-DRIVEN-CONTENT-SYSTEM/10-sidebar-panel-coordination.md)
