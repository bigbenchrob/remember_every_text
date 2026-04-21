
Ephemeral Spec Handling Architecture

Purpose

This document defines how the sidebar handles ephemeral cassette specs.

Ephemeral cassette handling exists to solve a specific architectural problem:

* some sidebar content represents durable context
* some sidebar content represents temporary one-off action flow

These must not be modeled the same way.

Examples:

* durable: chosen contact, selected handle, active message scope, active persistent settings context
* ephemeral: send logs flow, reset message data confirmation, future one-off prompts or temporary action chains

The sidebar must preserve durable context across rebuilds and mode switches.
The sidebar must not preserve ephemeral action flows as though they were durable state.

This document defines the rules, ownership boundaries, data flow, and anti-patterns for that separation.

⸻

Core Principle

The sidebar has two projection layers:

1. stable projection
2. ephemeral projection

Stable projection represents sidebar structure that is deterministically derived from durable flow state.

Ephemeral projection represents temporary cassette specs that are rendered in the sidebar but are not durable meaning and must never be treated as such.

The visible sidebar is:

stable projection first, ephemeral projection second

Ephemeral projection is always terminal.

No stable cassette may be derived beneath an ephemeral cassette.

⸻

Why This Exists

The stable cassette rack already exists because the sidebar coordinator needs an ordered list of specs to resolve into payloads and widgets. The existing cassette system documents that rack state is the rendered sidebar artifact, while canonical flow meaning belongs elsewhere when a branch has durable semantics.

That architecture is correct for durable meaning.

However, one-off action flows introduce a second category of sidebar content:

* they must be rendered as specs so the coordinator can resolve them
* but they must not become durable flow meaning
* and they must not be reconstructible from persisted or bookmarkable state

If stable and ephemeral specs are stored together in one retained rack, ephemeral UI can masquerade as durable state. This is a bug.

The correct solution is not to special-case Settings. The correct solution is to separate:

* durable stable projection
* ephemeral temporary projection

This document formalizes that separation.

⸻

Architectural Summary

Durable meaning

Durable meaning lives in flow state.

Flow state remains the single source of truth for persistent sidebar meaning.

Examples of durable flow-state fields include:

* active top-menu branch
* chosen contact
* selected handle
* message scope
* persistent settings context

Everything durable must be reconstructible from flow state.

Stable projection

Stable projection is the cassette-spec stack derived from durable flow state for the active sidebar mode.

This is the projection that behaves like the stabilized messages/contacts branch:

durable flow state
→ stable cassette spec stack
→ sidebar payloads
→ sidebar widgets

Stable projection is the sidebar’s durable spec layer.

Ephemeral projection

Ephemeral projection is a separate cassette-spec stack for temporary sidebar action flows.

It is:

* rendered through the same coordinator/payload/render pipeline as stable specs
* stored only as live provider state
* never written into durable flow state
* never serialized
* never bookmarkable
* never reconstructible from restored durable state

Ephemeral projection exists only to support temporary sidebar-local flows.

⸻

Non-Negotiable Rules

Rule 1 — Durable meaning lives only in flow state

The sidebar must not recover durable meaning by scanning either the stable rack or the ephemeral rack.

If a value is durable, it belongs in flow state.

Rule 2 — Stable projection is derived from flow state

Stable cassette specs are not a second source of truth.

They are a working projection required by the cassette coordinator and render pipeline.

If stable projection is lost, it must be reconstructible from durable flow state.

Rule 3 — Ephemeral actions never write to flow state

Ephemeral actions do not create durable meaning.

Examples:

* Send logs
* Reset message data
* future one-off prompts or confirmation chains

These must never be stored as persistent context or reconstructible branch state.

Rule 4 — Stable and ephemeral projections are stored separately

Stable and ephemeral specs must not be mixed into one retained rack.

There must be a stable projection provider and an ephemeral projection provider, both keyed by SidebarMode.

Conceptually:

* stableCassetteRackProvider(mode)
* ephemeralCassetteRackProvider(mode)

Rule 5 — Visible sidebar order is stable first, ephemeral second

The visible sidebar spec list is:

stable specs
followed by
ephemeral specs

The coordinator may consume them separately and concatenate them, or consume a combined list created at the essentials layer. The semantic order is fixed.

Rule 6 — Ephemeral projection is terminal

Ephemeral specs may cascade to other ephemeral specs.

Ephemeral specs may not parent or spawn stable specs.

No stable cassette may be derived beneath an ephemeral cassette.

Rule 7 — New ephemeral root replaces the current ephemeral projection

Dispatching a new ephemeral action clears the current ephemeral projection and derives a new ephemeral chain from that new root.

Ephemeral projections do not accumulate unrelated branches.

Rule 8 — Durable context changes clear incompatible ephemeral projection

When durable flow state changes in a way that makes the current ephemeral projection invalid or misleading, the ephemeral projection must be cleared.

This rule exists to keep temporary UI from outliving the context that made it relevant.

Rule 9 — Sidebar mode change clears ephemeral projection

Switching SidebarMode always clears the ephemeral projection for the mode being left.

Durable state survives mode changes.
Ephemeral projection does not.

This rule applies uniformly across Messages, Settings, and any future sidebar mode.

Rule 10 — Features do not bypass the cassette system

Ephemeral cassettes still participate in the same essentials-owned sidebar system documented in the cassette architecture:

* specs
* coordinators
* resolvers
* payloads
* render router
* chrome
* layout rules

Nothing about ephemeral handling allows features to return widgets directly or bypass shared chrome/layout rules.

⸻

Provider Model

Stable provider

stableCassetteRackProvider(mode) stores the durable cassette projection for a given sidebar mode.

It behaves like the current stable cassette rack concept:

* seeded by the mode’s root cassette
* extended by topology
* reconstructible from durable flow state

Ephemeral provider

ephemeralCassetteRackProvider(mode) stores only the live temporary cassette projection for a given sidebar mode.

It exists because the cassette coordinator still needs specs to resolve and render temporary sidebar flows.

It is not durable state.
It must never be treated as authoritative meaning.

Why two providers instead of one mixed rack

A single retained rack containing both durable and ephemeral specs makes ephemeral UI look durable whenever the provider is kept alive.

Two providers solve this cleanly:

* stable provider may be retained freely
* ephemeral provider may be retained only as live UI state and may be cleared on mode change or incompatible durable transition
* no ambiguity exists about what may or may not survive

This is simpler and more general than special-casing the Settings mode.

⸻

Intent Taxonomy

The durable/ephemeral distinction belongs to the semantic intent layer, not to feature specs and not to render-edge action descriptors.

The menu or other emitting control already knows the meaning of the user’s selection. It should emit a typed intent whose durability class is intrinsic.

Recommended shape:

* SidebarActionIntent
    * SidebarPersistentIntent
    * SidebarEphemeralIntent

Concrete intents must inherit from the appropriate branch.

Examples:

* ShowTextSettings → persistent
* SendLogsChosen → ephemeral
* ResetMessageDataChosen → ephemeral

Avoid mixed intents such as TopMenuChanged(choice) when choice could represent either durable context or ephemeral action. In that design, durability must be rediscovered later by inspecting a payload field. That is weaker and should be avoided.

The emitting widget should map a user-facing choice directly to the correct typed intent.

The dispatcher should not have to rediscover whether an intent is stable or ephemeral.

⸻

Dispatcher Responsibilities

The dispatcher accepts SidebarActionIntent and routes based on intent meaning.

For persistent intents

Persistent intents may:

* update durable flow state
* trigger recomputation or replacement of stable projection
* clear incompatible ephemeral projection if required

For ephemeral intents

Ephemeral intents must:

* never write ephemeral meaning into durable flow state
* derive an ephemeral root cassette spec
* write that root into the ephemeral projection provider
* allow ephemeral topology to derive any child ephemeral specs beneath it

The dispatcher may also trigger domain side effects as needed, but domain side effects do not change the architecture of sidebar projection ownership.

⸻

Topology Rules

Stable topology and ephemeral topology are conceptually parallel, but they do not operate over the same source of truth.

Stable topology

Stable topology derives durable cassette chains from stable meaning.

Examples:

* current messages branch
* chosen contact
* selected handle
* persistent settings context

Stable topology must remain reconstructible from durable flow state.

Ephemeral topology

Ephemeral topology derives temporary cassette chains from the current ephemeral root spec.

Examples:

* a send logs explanation card followed by a second explanatory card followed by a final confirm/cancel card
* a reset message data warning chain

Ephemeral topology must never consult flow state as though the transient action were durable context.

Ephemeral topology may depend on the current stable context when rendering is contextual, but it must not convert its own existence into durable branch state.

Cross-layer rule

Stable topology may not descend from ephemeral specs.
Ephemeral topology may be layered after stable topology.

This is the meaning of “ephemeral projection is terminal.”

⸻

Coordinator Responsibilities

The cassette widget coordinator already watches rack state and resolves each spec to a payload via feature coordinators.  

With ephemeral handling, the coordinator must conceptually do this for the active mode:

1. read the stable projection specs
2. read the ephemeral projection specs
3. build the visible sidebar spec list in this order:
    * stable first
    * ephemeral second
4. resolve all specs through the existing feature coordinator pipeline
5. route resulting payloads through the shared render router and essentials-owned chrome

The coordinator must not infer durability from individual specs.
It already knows the layer because the specs came from the stable or ephemeral provider.

⸻

Rendering and Layout

Ephemeral cassette handling does not create a separate rendering system.

Ephemeral cassettes:

* use normal CassetteSpec
* resolve to normal SidebarCassettePayload
* use the shared render router
* obey the same layout and chrome rules as all sidebar cassettes

Essentials still owns sidebar layout, chrome, rails, spacing, and card wrappers. Features still may not invent new chrome or alternate layout systems.

The only new concept is projection ownership, not presentation ownership.

⸻

Stable vs Ephemeral Examples

Example 1 — Persistent Messages flow

User chooses Messages from contacts.

This is persistent context.

The action emits a persistent intent.
The dispatcher updates durable flow state.
Stable topology derives the stable cassette branch.
If the mode is left and later revisited, the stable branch returns from durable state.

No ephemeral provider involvement is required.

Example 2 — Send Logs

User chooses Send logs... from the Settings top menu.

This is ephemeral action.

The top menu emits an ephemeral intent.
The dispatcher does not write sendLogs into durable flow state.
Instead it places an ephemeral root cassette spec into the ephemeral projection provider.
Ephemeral topology may derive additional ephemeral child specs beneath it.
The visible sidebar becomes:

* stable Settings projection
* followed by the ephemeral Send Logs chain

If the user leaves Settings and later returns, the ephemeral projection is gone because it was never durable meaning.

Example 3 — Durable settings context plus ephemeral action

Suppose a future persistent settings context such as Text settings is active.

Stable projection may include the stable text-settings cassette chain.

If the user then triggers a one-off ephemeral action, the sidebar becomes:

* stable text-settings projection
* followed by the temporary ephemeral action chain

If the user leaves the mode and returns:

* stable text-settings projection returns
* ephemeral action chain does not

⸻

Anti-Patterns

The following are architectural bugs.

Anti-pattern 1 — Writing ephemeral actions into flow state

Do not store Send logs, Reset message data, or similar one-off actions as durable context.

Anti-pattern 2 — Mixing stable and ephemeral specs in one retained rack

This makes temporary UI appear durable when the provider survives.

Anti-pattern 3 — Reconstructing durable meaning by scanning a rack

If a value is durable, read flow state.

Do not walk a spec list backwards asking whether a cassette “happens to contain” the durable meaning.

Anti-pattern 4 — Using mixed top-menu intents

Do not emit TopMenuChanged(choice) when choice may represent either durable or ephemeral behavior.

Durability must be intrinsic to the emitted intent type.

Anti-pattern 5 — Letting ephemeral projection spawn durable projection

Ephemeral cassettes are terminal.
No stable spec may descend from them.

Anti-pattern 6 — Allowing multiple unrelated ephemeral branches to accumulate

A new ephemeral action replaces the old ephemeral projection.

Anti-pattern 7 — Treating Settings as a special case

Do not solve transient behavior by inventing settings-only lifecycle hacks.

Ephemeral projection is the general concept.
It must work the same way for Messages, Settings, and future modes.

Anti-pattern 8 — Returning widgets directly for ephemeral flows

Ephemeral handling does not relax the sidebar payload/chrome boundary.

All normal sidebar architecture rules continue to apply.  

⸻

Relationship To Existing Cassette System

This document extends the sidebar cassette architecture; it does not replace it.

The stable cassette system still provides the core pipeline:

* cassette specs
* rack state
* topology
* app-level coordinator
* feature coordinators
* payloads
* shared render router
* essentials-owned chrome and layout

Ephemeral handling adds one architectural distinction:

* not every rendered sidebar cassette belongs to the durable branch of meaning

Therefore:

* durable branch content belongs in stable projection
* temporary action content belongs in ephemeral projection

⸻

Implementation Goals

Any implementation plan derived from this document must preserve these goals:

1. keep durable sidebar meaning in flow state
2. keep stable and ephemeral projection separate
3. let the coordinator render both layers through the same sidebar pipeline
4. route intent durability through typed intent taxonomy
5. prevent ephemeral action flows from surviving mode change or durable-state reconstruction
6. avoid feature-level special cases
7. preserve the existing essentials-owned layout/chrome boundary

⸻

Minimal Acceptance Criteria

The architecture is not considered implemented unless all of the following are true:

* stable and ephemeral cassette projections are stored separately
* durable flow state contains no ephemeral action meaning
* typed intents distinguish persistent from ephemeral action classes
* the coordinator renders stable projection followed by ephemeral projection
* ephemeral projection is cleared on sidebar mode change
* ephemeral projection is replaced, not accumulated, when a new ephemeral action is dispatched
* no stable cassette is ever derived beneath an ephemeral cassette
* leaving and re-entering a mode restores only stable projection from durable state
* ephemeral cassettes still obey the shared sidebar payload/render/layout rules

⸻

Summary

Durable sidebar meaning and temporary sidebar action flow are different things.

Durable meaning belongs in flow state and projects into the stable rack.
Temporary action flow belongs only in a separate ephemeral rack projection.

The visible sidebar is always:

stable projection + ephemeral projection

Stable projection is reconstructible.
Ephemeral projection is not.

That separation is the architectural foundation that allows mode retention, deterministic rebuilds, and one-off sidebar-local action flows to coexist without either masquerading as the other.