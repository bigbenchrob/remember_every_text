Before proceeding with implementation, please review the following clarifications and constraints. These are not changes to the plan, but guardrails to ensure the architecture is implemented correctly and without drift.

1. Stable Projection Is Logically Derived, Even If Not Fully Reactive

Stable projection is described in the 55-series docs as being derived from durable flow state. In the current implementation, this derivation is still partially expressed through explicit rack mutations (e.g. replaceAtIndexAndCascade).

This is acceptable.

However, the invariant must be preserved:

* stable projection must remain logically derivable from flow state
* no durable meaning may be stored only in the rack

Do not attempt to convert the system to a fully reactive recomputation model as part of this work. That is out of scope.

2. Ephemeral Topology Must Be Explicitly Isolated

Ephemeral projection introduces its own cascade behavior (deriving a chain from an ephemeral root spec).

This must be implemented as a separate topology path, not mixed into existing stable topology.

Requirements:

* ephemeral topology must not share resolution paths with stable topology
* stable topology must never consult ephemeral projection
* ephemeral topology may depend on stable context, but must not convert itself into durable meaning

Avoid duplicating the entire cascade system; reuse patterns where appropriate, but keep the layers strictly separated.

3. Cassette Index Is Legacy, Not Architectural

Any use of cassetteIndex or “previous cassette index” should be treated as migration debt, not a core concept to preserve.

The new architecture is intentionally moving away from:

* inferring meaning from rack position
* mutating structure based on index-relative operations

Instructions:

* do not design new logic around index-based behavior unless absolutely required
* audit existing uses and preserve only those that are still functionally necessary
* prefer flow-state-driven logic over position-based logic

Do not introduce new index-coupled behavior into the stable/ephemeral split.

4. Ephemeral Lifecycle Must Be Rule-Based, Not Mode-Specific

The previous Settings implementation used a mode-specific cleanup hack.

That approach is being removed.

The correct rules are:

* ephemeral projection is cleared on SidebarMode change
* ephemeral projection is cleared when durable context changes incompatibly
* ephemeral projection is replace-only

These rules apply uniformly across all modes. Do not introduce any Settings-specific lifecycle handling.

5. Intent Durability Must Be Intrinsic

The dispatcher must not infer whether an action is persistent or ephemeral.

Instead:

* UI layers must emit typed intents (SidebarPersistentIntent or SidebarEphemeralIntent)
* dispatcher routing must be based on intent type, not payload inspection

Do not retain or reintroduce mixed intent patterns such as TopMenuChanged(choice) where durability must be inferred downstream.

6. Stable vs Ephemeral Is a Projection Concern, Not a Spec Concern

Do not modify feature cassette specs to carry durability flags.

Durability belongs to:

* the intent layer (semantic meaning)
* the projection layer (which provider stores the spec)

Specs remain unchanged.

7. Stable Provider Is the Existing Rack Provider

The existing cassetteRackStateProvider(mode) represents the stable projection.

Do not duplicate or replace it unnecessarily.

The new work introduces:

* an additional ephemeral projection provider
* not a replacement for the stable provider

8. Coordinator Remains the Single Composition Point

The sidebar coordinator must:

1. read stable projection
2. read ephemeral projection
3. concatenate (stable first, ephemeral second)
4. resolve all specs through the existing pipeline

Do not introduce a second rendering path.

9. Ephemeral Must Never Feed Back Into Stable Logic

Ephemeral projection must not:

* influence stable topology
* influence flow-state transitions
* be scanned to determine application state

If any logic depends on ephemeral state to determine durable behavior, that is a bug.

10. Scope Control

This work introduces projection-layer separation only.

It must not:

* redesign the cassette system
* change payload contracts
* alter layout/chrome ownership
* convert the system to a new reactive model

Keep changes tightly scoped to:

* projection separation
* intent taxonomy
* dispatcher routing
* coordinator composition

⸻

If any part of the implementation requires violating one of these constraints, stop and flag it rather than working around it.