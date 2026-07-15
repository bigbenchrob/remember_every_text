---
tier: project
scope: implementation-investigation
owner: agent-per-project
last_reviewed: 2026-07-14
source_of_truth: proposal
status: exploratory
links:
  - ./README.md
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ../../09-CROSS-COLUMN-LAYOUT/README.md
  - ../../../lib/config/theme/widgets/layout/vertical_column_bands.dart
tests: []
---

# Flutter Implementation Investigation: Cross-Column Layout Tracks

## Question

Assume the layout-track architecture is correct.

The implementation question is:

> How can Flutter express this architecture most naturally?

The target architecture is:

```text
columns declare requirements
page resolves a shared track plan
columns render inside the resolved plan
```

The first implementation target remains the Search page only. The sidebar
participates only through its top menu in the first track. The rest of the
sidebar continues to use the existing cassette flow.

## Current State

The current implemented model is ordinary widget composition:

- `TitleColumnBand`
- `ContextColumnBand`
- primary content below

These wrappers live in:

```text
lib/config/theme/widgets/layout/vertical_column_bands.dart
```

The Search page currently maps:

```text
TitleColumnBand:
  left: Search all messages selector
  center: All messages title
  right: Conversation title

ContextColumnBand:
  left: short orientation / sidebar context-zone content
  center: result metadata and search controls
  right: Conversation Card and excerpt description

Content:
  left: cassette flow / heatmap
  center: message results
  right: conversation excerpt messages
```

The current implementation proves the visual grammar, but fixed heights create
pressure when right-panel Conversation Cards or center-panel controls need
different amounts of space.

## Recommendation

Use ordinary widget composition plus explicit, model-published
`TrackRequirement` values and a page-resolved `ResolvedTrackPlan` for the first
implementation slice.

Do not start with `CustomMultiChildLayout`, `MultiChildRenderObjectWidget`, or a
custom `RenderBox`.

Recommended shape:

1. Columns publish explicit `TrackRequirement` values before rendering.
2. The Search page resolves a `ResolvedTrackPlan`.
3. Existing title/context wrappers become compatibility renderers that accept
   resolved heights instead of using only fixed defaults.
4. Center and right columns render inside the same resolved plan.
5. The sidebar top menu participates in Track A; the rest of the cassette flow
   remains unchanged.

This is the best fit for the first slice because it preserves MessageLens'
existing ownership rules:

- the page owns track resolution;
- columns own which tracks they participate in;
- widgets own presentation inside the resolved allocation;
- sidebar cassettes remain cassette-owned.

## Answer 1: Can Flutter Do Declaration -> Resolution -> Render Without Post-Frame Measurement?

Yes, if the declarations are app-level `TrackRequirement` values rather than
measurements of already-built widgets.

Flutter's normal build/layout flow is parent-to-child:

```text
parent provides constraints
child lays out within constraints
parent positions child
```

The track architecture can fit this naturally if the parent page already has
the requirements before it builds the final column layout.

That means the first implementation should avoid asking actual rendered widgets:

```text
How tall are you?
```

Instead, the participating column models or layout adapters should declare:

```text
What does this Track require?
```

For the first slice, those requirements may contain only height:

```text
Track A: height requirement 72
Track B: height requirement 166
```

The parent can then resolve:

```text
resolved Track A height = max(all Track A height requirements)
resolved Track B height = max(all Track B height requirements)
```

and pass those resolved heights into the wrapper widgets during the same build.

This avoids post-frame measurement, avoids imperative repair, and fits Flutter's
constraint-driven layout philosophy.

## Answer 2: Can Actual Widgets Be Measured During Normal Layout?

Yes, but that is not the best first tool for this architecture.

Flutter can measure children during layout in lower-level mechanisms such as
`CustomMultiChildLayout` or custom render objects. A parent can lay out a child
with constraints, read the child's size, and use that result to lay out or
position other children.

However, this has tradeoffs:

- it moves layout policy into a layout delegate or render object;
- it couples track planning to actual widget layout;
- it can make sidebar participation harder because the sidebar is already a
  complex cassette system;
- it increases the risk of layout jitter if measurement becomes reactive rather
  than declarative;
- it makes testing architecture harder than testing simple requirement
  resolution.

For MessageLens, model-published requirements are preferable for the first
slice because many first-slice height requirements are semantic and
predictable:

- title track height;
- compact Conversation Card context height;
- search metadata/control context height;
- empty or non-participating sidebar tracks.

Actual measurement should be reserved for a later slice only if explicit
requirements prove insufficient.

## Answer 3: Would A Custom RenderObject Simplify The Implementation?

Not for the first implementation.

A custom render object would provide maximum control. It could collect children,
measure them, resolve track heights, and position everything in one layout pass.

But that control is not currently worth the cost.

Risks:

- higher implementation complexity;
- harder accessibility and semantics review;
- more specialized tests;
- more fragile integration with existing scroll views and cassette layout;
- greater chance of violating feature ownership by moving too much page policy
  into a rendering primitive;
- harder future maintenance for agents and application developers.

A custom render object may become appropriate only if:

- track requirements must be based on real child measurements;
- ordinary widget composition cannot avoid layout loops;
- the same pattern is needed across several high-value pages;
- the behavior stabilizes enough to justify a lower-level primitive.

That is not true yet.

## Answer 4: Would CustomMultiChildLayout Naturally Support This Architecture?

`CustomMultiChildLayout` partially matches the problem, but it is not the best
first abstraction.

### Strengths

`CustomMultiChildLayout` can:

- identify children by slot;
- lay out children in a chosen order;
- use one child's measured size to constrain or position another;
- express coordination among a fixed set of children;
- perform layout in Flutter's normal layout phase rather than post-frame.

Those strengths map well to:

```text
measure participating track widgets
resolve shared heights
position columns
```

### Weaknesses

It also has important limitations for MessageLens:

- it is best suited to a fixed set of known children, while the sidebar cassette
  system is intentionally dynamic;
- its overall size cannot depend on child layout properties through
  `getSize`; if parent size needs child-dependent sizing, Flutter's own
  documentation points toward a custom render object;
- it would concentrate page layout details into a delegate, which may be
  overkill when the first slice can use explicit requirements;
- every child must be managed through layout IDs, which adds ceremony for a
  page that already has working column composition;
- it does not itself solve how requirements are known before layout.

### Recommendation

Do not use `CustomMultiChildLayout` for the first slice.

Keep it as a possible second-stage implementation if explicit requirement
resolution becomes too limited.

## Answer 5: Height Requirement Or Richer Requirements?

Use a richer requirement object from the beginning, even if the first slice only
uses height.

The object should represent a layout requirement, not merely a number.

Conceptually:

```text
TrackRequirement
  height
  minimumHeight
  maximumHeight
  compactPreferredHeight
  alignmentPreference
  overflowPolicy
```

The first implementation does not need every field, but the type should leave
room for them.

Reasons:

- a Conversation Card may prefer standard height but allow compact height;
- a search-control context region may have a minimum that should not be clipped;
- a sidebar top menu may require fixed height but no Track B participation;
- debug tooling may need to show whether a track was resolved from standard or
  compact requirements;
- future pages may need alignment preferences inside a resolved track.

The first slice can use:

```text
track id
height requirement
```

but the naming should not imply that height is the only future requirement.

## Answer 6: Ownership In Flutter Terms

The proposed ownership aligns with Flutter's layout philosophy if implemented
declaratively.

### Page Owns

The page owns:

- track IDs;
- collecting column requirements;
- resolving shared heights;
- passing resolved heights to columns;
- developer diagnostics for the resolved plan.

The page should not own:

- Conversation Card internals;
- message evidence header internals;
- sidebar cassette identity;
- heatmap-specific rules.

### Columns Own

Columns own:

- mapping their content into tracks;
- publishing requirements for those tracks;
- choosing compact presentation when needed;
- rendering inside the resolved track plan.

### Participating Widgets Own

Widgets own:

- local presentation;
- typography;
- internal spacing;
- truncation;
- compact variants;
- whether a particular mode can fit a given resolved height.

Widgets should not:

- inspect sibling columns;
- add external top padding to repair page alignment;
- decide page-level track heights by themselves.

## Sidebar First Slice

The proposed first slice is sensible:

```text
Track A: sidebar top menu participates
below Track A: sidebar cassette flow continues normally
```

This proves the track-plan concept without requiring the sidebar cassette
coordinator to become track-aware beyond the top menu.

It also avoids the hardest unsolved problem: autonomous cassette placement into
context/content tracks.

Future sidebar work can decide whether cassettes publish track requirements,
content-start candidacy, or both. That should remain outside the first slice.

## Alternatives Considered

### Ordinary Widget Composition With Fixed Heights

This is the current implementation.

Strengths:

- simple;
- testable;
- low risk;
- easy to inspect;
- already working.

Weaknesses:

- fixed values drift from actual content needs;
- variable Conversation Cards can feel cramped;
- later tuning tempts local padding repairs;
- the model does not naturally express "each column declares requirements."

Verdict:

Keep as compatibility implementation, but evolve toward resolved track heights.

### LayoutBuilder

`LayoutBuilder` is useful when layout depends on incoming constraints.

It does not solve the main track problem by itself because it tells a widget
what space the parent gave it; it does not let sibling columns declare
requirements and negotiate a shared plan.

Verdict:

Useful inside column widgets for compact variants based on width/height, but
not sufficient as the track coordinator.

### Inherited Layout Plan

An inherited layout plan can distribute the resolved track heights to descendant
widgets.

Strengths:

- keeps rendering declarative;
- avoids passing plan arguments through many constructors;
- can let nested column participants read the same resolved values.

Weaknesses:

- can obscure ownership if used too broadly;
- does not itself compute requirements;
- should be scoped tightly to a page, not app-global.

Verdict:

Good candidate for distributing a resolved track plan after the page computes
it. Do not use it as the source of truth for requirements.

### Provider-Driven Layout Models

Provider-driven requirements could work if the layout model is derived from
page state and read models rather than widget measurement.

Strengths:

- fits existing Riverpod architecture;
- testable as pure model logic;
- requirements can be computed before render;
- avoids post-frame repair.

Weaknesses:

- must avoid turning layout into global state;
- can overcomplicate simple page composition;
- must not let feature providers own page-level layout.

Verdict:

Reasonable if scoped as a page-level provider/model for Search. Prefer a simple
local computation first unless sharing or invalidation makes a provider useful.

### CustomMultiChildLayout

Verdict:

Technically capable for fixed child sets, but premature for the first slice.
Consider later only if explicit requirements fail.

### MultiChildRenderObjectWidget / Custom RenderBox

Verdict:

Too heavy for the first slice. Keep as a last resort for a mature, repeated
layout primitive.

## Suggested Flutter Implementation Strategy

Do not implement yet. If approved later, implement in this order:

1. Define a small page-local track model:

   ```text
   TrackId
   TrackRequirement
   ResolvedTrackPlan
   ```

2. Map current wrapper heights to fallback requirements:

   ```text
   Track A ~= current TitleColumnBand height
   Track B ~= current ContextColumnBand height
   ```

3. Add compatibility constructors or wrappers that accept resolved heights:

   ```text
   TitleColumnBand(height: plan.heightFor(trackA), ...)
   ContextColumnBand(height: plan.heightFor(trackB), ...)
   ```

4. Let Search center and right columns publish requirements.

5. Let the sidebar top menu publish Track A only.

6. Resolve the plan at the Search page composition level.

7. Render center/right/left using the same plan.

8. Keep the sidebar cassette flow below Track A unchanged for the first slice.

9. Preserve debug margins by drawing track boundaries from the resolved plan.

## Suggested Migration Strategy

Phase 1:

- Search page only.
- Explicit requirements only.
- No sidebar cassette auto-placement.
- Existing wrapper widgets remain.

Phase 2:

- Add compact variants for Conversation context content if needed.
- Allow right panel to publish larger Track B requirements.
- Verify that center content starts align with right content starts.

Phase 3:

- Consider whether sidebar context cassettes should publish optional Track B
  requirements.
- Keep the cassette system as the owner of cassette sequencing.

Phase 4:

- If the model is successful, update `09-CROSS-COLUMN-LAYOUT/` and mark this
  package as implemented.
- Only then consider retiring fixed wrapper defaults or older support
  primitives.

## Final Recommendation

Use declarative, model-published layout requirements and ordinary widget
composition for the first implementation slice.

Do not use post-frame measurement.

Do not start with a custom render object.

Do not start with `CustomMultiChildLayout`.

Flutter can express the architecture naturally if the app treats track
requirements as part of page composition rather than as measurements recovered
after rendering.

This approach best preserves the MessageLens architecture:

- page owns layout rhythm;
- features own meaning;
- widgets own presentation;
- sidebar cassettes remain sidebar-owned;
- the first slice can prove the concept without destabilizing the app.
