INVIOLATE_RULES.md

INVIOLATE RULES — Ephemeral Spec Handling

These rules govern ephemeral cassette handling. Violations are bugs.

⸻

1. Ephemeral Actions Must Not Write to Flow State

No ephemeral action may be stored in:

* SidebarFlowState
* persistent storage
* bookmarkable state
* any reconstructible durable representation

If an action is ephemeral, it must remain ephemeral.

⸻

2. Stable and Ephemeral Specs Must Not Share a Rack

Stable and ephemeral cassette specs must not be stored in the same retained rack state.

They must be stored in separate providers.

Mixing them causes ephemeral UI to masquerade as durable state.

⸻

3. Ephemeral Projection Must Be Terminal

No stable cassette may be derived beneath an ephemeral cassette.

Ephemeral topology may only produce additional ephemeral specs.

⸻

4. Ephemeral Projection Must Be Replace-Only

Dispatching a new ephemeral action must:

* clear the existing ephemeral projection
* create a new projection from the new root

Ephemeral projections must not accumulate.

⸻

5. Mode Changes Must Clear Ephemeral Projection

Switching SidebarMode must clear the ephemeral projection for the mode being left.

Durable state survives.
Ephemeral state does not.

⸻

6. Durable Context Changes Must Clear Incompatible Ephemeral Projection

If durable flow state changes such that the current ephemeral projection is no longer valid, the ephemeral projection must be cleared.

Do not allow temporary UI to outlive its context.

⸻

7. Intent Durability Must Be Intrinsic

The durability of an action must be known from its intent type.

Allowed:

* SidebarPersistentIntent
* SidebarEphemeralIntent

Forbidden:

* inspecting payload fields to determine durability
* generic intents like TopMenuChanged(choice) when choice mixes durable and ephemeral meanings

⸻

8. Dispatcher Must Not Guess Durability

The dispatcher must not infer whether an action is ephemeral or persistent.

The intent type must already encode this.

⸻

9. Ephemeral Specs Must Use the Same Cassette System

Ephemeral specs must:

* be valid CassetteSpec objects
* resolve through feature coordinators
* produce SidebarCassettePayload
* render through the shared sidebar render router
* obey all layout and chrome rules

No shortcuts. No direct widget injection.

⸻

10. Features Must Not Bypass the Projection Layers

Features must not:

* directly mutate the sidebar widget tree
* bypass the cassette system for ephemeral flows
* construct UI outside the coordinator/payload/render pipeline

All sidebar content — stable or ephemeral — must flow through the same system.

⸻

11. Ephemeral State Must Never Be Treated as Source of Truth

Ephemeral provider state is:

* live UI projection only
* not authoritative
* not queryable for durable meaning

Never scan ephemeral specs to determine application state.

⸻

12. Stable Projection Must Remain Reconstructible

If the stable projection cannot be rebuilt solely from flow state, the architecture is broken.

Do not allow ephemeral behavior to leak into stable projection logic.

⸻

13. No Mode-Specific Hacks

Do not introduce:

* Settings-only reset behavior
* Messages-only persistence rules
* mode-specific lifecycle hacks

All rules must apply uniformly across all SidebarModes.

⸻

14. Ephemeral Handling Must Not Alter Layout Ownership

Ephemeral specs must not:

* introduce new chrome types
* redefine layout rules
* bypass essentials-owned composition

All layout and rendering rules from the core cassette system remain in force.

⸻

15. Coordinator Must Render Both Layers

The coordinator must:

* read stable projection
* read ephemeral projection
* render stable specs first
* render ephemeral specs second

No implicit merging. No loss of ordering.

⸻

Summary Rule

If ephemeral UI can survive a rebuild, it is not ephemeral.

If ephemeral UI can be inferred as durable meaning, the architecture is broken.

Keep projection layers separate.