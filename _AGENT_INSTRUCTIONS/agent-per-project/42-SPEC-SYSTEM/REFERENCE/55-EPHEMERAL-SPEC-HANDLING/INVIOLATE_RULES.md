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

---

INVIOLATE RULE — Topology Decisions Are Local and Single-Step

Topology must operate strictly as a sequence of local, single-step decisions.

For any given cassette spec:

The topology rule for that spec may determine only its immediate next child.

⸻

Allowed Pattern

The only valid topology pattern is:

* given the current spec
* consult the minimal durable fact from flow state required for this decision
* return exactly one next child spec, or null

Expressed informally:

“What is my next child?”

Nothing more.

⸻

Flow State Access

Topology rules may consult durable flow state.

However:

Flow state may be read only as input to the immediate next-child decision for the current spec.

Topology must not:

* derive meaning from other specs
* depend on downstream structure
* cache or propagate derived branch state

⸻

Forbidden Patterns

The following are strictly prohibited:

1. Branch Planning

* deciding multiple future successors
* reasoning about “the branch as a whole”
* encoding entire chains in a single decision

2. Chain Assembly

* constructing lists of specs
* calling setRack([...])
* assembling partial or full branches procedurally

3. Conditional Omission

* “omit X”
* “stop before Y”
* “append Z only if condition”
* any logic that treats a branch as a modified version of another branch

4. Lookahead or Lookbehind

* inspecting future nodes
* scanning previous specs
* making decisions based on anything other than:
    * current spec
    * minimal required durable state

⸻

Correct Mental Model

Topology is not:

* a builder
* a planner
* a filter

Topology is:

a function that maps (current spec + durable state) → next spec

Repeated until termination.

⸻

Example

Correct:

* messageScopeToggle asks:
    * if scope is regular → next = handleFilter
    * if scope is recoveredDeleted → next = recoveredDeletedInfo

Incorrect:

* “build contact branch, but don’t include heatmap”
* “truncate the chain before heatmap”
* “omit heatmap in recoveredDeleted scope”

⸻

Summary

If a topology rule does more than answer:

“What is the next child of this spec?”

then it is violating the architecture.

No exceptions.

⸻

Summary Rule

If ephemeral UI can survive a rebuild, it is not ephemeral.

If ephemeral UI can be inferred as durable meaning, the architecture is broken.

Keep projection layers separate.