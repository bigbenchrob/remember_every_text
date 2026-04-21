INVIOLATE RULE — Topology Is the Only Source of Cassette Chains

This system has exactly one correct way to derive a stable sidebar cassette-spec chain.

Topology is the only source of truth.

⸻

The Rule

For any given durable flow state:

There must exist exactly one valid, deterministic cassette-spec chain, derived solely through topology.

This chain is defined by:

* a starting spec (root or branch entry)
* a sequence of childSpec relations
* termination when no child exists

No other mechanism is allowed to construct or modify that chain.

⸻

What Is Forbidden

The following patterns are strictly prohibited:

1. Procedural Branch Assembly

Do not construct cassette chains by:

* building a list of specs (setRack([...]))
* appending specs conditionally
* truncating a “default” branch
* stopping “before” a spec

This is not topology. This is imperative assembly.

⸻

2. Conditional Omission / Suppression

Do not model behavior as:

* “omit the heatmap”
* “stop before heatmap”
* “append X only if condition Y”

There is no concept of omission in this architecture.

If a spec is not part of the correct chain, it must not exist in that chain at all.

⸻

3. Multiple Topology Authors

There must not be more than one place that defines the cassette chain.

Forbidden:

* topology defined in *_cassette_topology.dart
* alternate chain defined in sidebar_flow_state_provider.dart
* any other layer constructing or mutating the chain

This creates competing sources of truth and breaks determinism.

⸻

4. Flow Layer Authoring Topology

The flow layer (sidebar_flow_state_provider.dart) must not:

* construct cassette-spec chains
* decide which specs come next
* encode branch structure procedurally

The flow layer owns durable meaning only.

It must not become a topology author.

⸻

The Correct Model

The system must operate as follows:

* durable flow state defines meaning
* that meaning selects a topology
* topology defines the chain:
    * spec → childSpec → childSpec → … → terminal

There is no:

* appending
* truncating
* omitting
* hiding

There is only:

“What is the correct next child spec for this state?”

⸻

Example: Contact Branch

Correct thinking:

* regular contact scope → topology leads to heatmap
* recoveredDeleted scope → topology leads to a different terminal

Incorrect thinking:

* “build contact branch, but don’t append heatmap”
* “stop before heatmap”
* “omit heatmap in recoveredDeleted”

RecoveredDeleted is not a modified branch.

It is a different valid topology.

⸻

Enforcement

Any code that:

* constructs cassette lists manually
* conditionally appends or removes specs
* duplicates topology outside the spec graph

must be treated as a violation and removed.

⸻

Summary

If the cassette chain is not derived exclusively through childSpec relations, the architecture is broken.

There must be:

one flow meaning → one topology → one deterministic cassette-spec chain

No exceptions.