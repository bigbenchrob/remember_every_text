We need to tighten the boundary and simplify the renderable-spec layer.

1. Rename Provider

Rename:

visibleSidebarCassetteSpecs

to:

renderableSidebarCassetteSpecs

This name better reflects its role:

* it operates on cassette specs, not widgets
* it produces the final ordered spec list ready for rendering

Update all references accordingly.

⸻

2. Remove Flow-Based Filtering

Remove _shouldHideSpecForFlow(...) and any equivalent logic from the renderable-spec layer.

The renderable-spec layer must not:

* hide stable specs based on flow state
* reinterpret stable topology decisions
* act as a second derivation layer

⸻

3. Enforce Deterministic Composition

The renderable-spec provider must have a single responsibility:

* read stable cassette specs
* read ephemeral cassette specs
* concatenate them in order:
    * stable first
    * ephemeral second

That is all.

No additional filtering, branching, or flow-based decisions should occur in this layer.

⸻

4. Architectural Rule

The stable projection must already represent the correct sidebar structure for the current durable flow state.

If a spec should not appear, it must not exist in the stable cassette stack.

Do not fix upstream topology issues by hiding specs downstream.

⸻

5. Coordinator Contract (Reaffirmation)

The coordinator must consume:

renderableSidebarCassetteSpecs

and:

* resolve each spec
* produce payloads/widgets

It must not:

* merge projection layers
* filter specs
* infer flow state
* distinguish stable vs ephemeral

⸻

6. Future Guidance

If a future case genuinely requires conditional visibility at the renderable layer:

* do not reintroduce ad hoc filtering
* introduce it explicitly with a clearly documented rationale

Until then, keep the pipeline strictly:

stable specs + ephemeral specs → renderable specs → resolved widgets