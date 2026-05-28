The Unified Message Evidence Header proposal is directionally strong and approved to proceed with refinements.

Please incorporate the following architectural refinements before implementation begins.

======================================================================

1. # PRESERVE THE CORE INVARIANT

The proposal correctly captures the key rule:

```text
source-specific composers write meaning
shared header renderer writes form



Preserve this strictly.

Do NOT:

* create a magical semantic inference renderer
* infer wording from raw scopes
* move semantic composition into the renderer

The renderer owns:

* typography
* spacing
* hierarchy
* blur/fade
* layout rhythm
* chrome minimization

The source-specific composer owns:

* meaning
* wording
* contextual semantics
* caveat semantics
* active scope semantics
* actions/controls configuration

======================================================================
2. REFINE THE HEADER MODEL SEMANTIC REGIONS

The current proposal still compresses meaning slightly too early.

Specifically:
contextLine is currently carrying multiple semantically different responsibilities:

* participant identity context
* handle context
* recovered-message explanation
* unfamiliar-source explanation

Please refine the conceptual model so these meanings are not prematurely merged.

Preferred direction:
split conceptually into something closer to:

* participant/identity context
* scope/caveat context

The exact names may differ, but:
“Claire Merriman Campbell”
and:
“Recovered records without normal conversational linkage”

should not conceptually occupy the same semantic field even if they later render similarly.

Do not overbuild.
Simple named optional regions are enough.

======================================================================
3. METRICS SHOULD EVENTUALLY BECOME A STRUCTURED REGION

Current proposal:

dateRangeLabel
countLabel

graph skeleton • hydrate visible rows

is not long-term user-facing semantic meaning.

The proposal already recognizes this risk in Open Question #4.
Please preserve that concern explicitly.

======================================================================
5. VISUAL INVARIANT

Promote this visual direction into explicit design guidance:

Message evidence headers should feel:

* calm
* editorial
* lightly integrated into the evidence stream
* minimally chromed
* spatially coherent

Avoid:

* dashboard headers
* boxed panels
* heavy cards
* nested chrome
* visually detached control slabs

The Contact All Messages header remains the visual reference baseline.

Especially preserve:

* subtle blur/fade separator
* calm hierarchy
* evidence-reading feel
* low-friction typography
* absence of obtrusive framing

MessageLens is increasingly a reading environment, not a dashboard.

======================================================================
6. KEEP THE FIRST SLICE SMALL

The proposal correctly avoids overbuilding.

Preserve that discipline.

Do NOT introduce:

* header DSLs
* giant region managers
* abstract layout engines
* polymorphic semantic builders
* over-generalized configuration trees

First slice should remain:

* typed
* incremental
* semantically grounded
* visually coherent

======================================================================
7. IMPLEMENTATION APPROVAL

Once the above refinements are incorporated:

Proceed with:

* MessageEvidenceHeaderModel introduction
* shared renderer refinement
* Contact All Messages migration
* Conversation header migration

while preserving:

* Message Evidence Spine invariants
* shared evidence rendering
* graph skeleton/hydration architecture
* existing message evidence behavior
```
