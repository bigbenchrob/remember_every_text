---
tier: project
scope: design-notes
owner: agent-per-project
last_reviewed: 2026-07-14
source_of_truth: proposal
status: second-slice-implemented
links:
  - ./PROPOSAL.md
  - ../../09-CROSS-COLUMN-LAYOUT/01-column-band-wrappers.md
  - ../../09-CROSS-COLUMN-LAYOUT/02-sidebar-cassette-content-start-seam.md
tests: []
---

# Design Notes: Cross-Column Layout Tracks

## Product Rationale

MessageLens should feel like a coordinated set of lenses onto the same memory
graph.

On pages such as Search, the user is not using three unrelated columns. They are
moving between:

```text
Search scope
Message evidence
Conversation context
```

Shared horizontal tracks help the eye understand that these are peer workspaces.
The geometry exists to create that perception.

## Architectural Rationale

The current wrapper model correctly established that page rhythm belongs to the
page, not to individual feature widgets.

The track model keeps that ownership but changes the way track geometry is
chosen:

- current model: the page gives fixed wrapper heights;
- proposed model: columns publish `TrackRequirement` values and the page
  resolves a shared `ResolvedTrackPlan`.

That is a better long-term fit because MessageLens has heterogeneous content:

- a title may be plain text or a selector;
- a context region may contain metadata, controls, a Conversation Card, or
  nothing;
- a Conversation Card can change height as glyphs, tags, hooks, or compact
  states change;
- sidebar cassette chains can vary by selected surface.

## Ownership

The page-level layout coordinator owns:

- track identity;
- collecting `TrackRequirement` values;
- resolving the shared `ResolvedTrackPlan`;
- distributing the resolved plan;
- enforcing that participating columns render within the plan.

Columns own:

- which content belongs to which track;
- the requirement declaration for that track;
- compact/adaptive presentation when content approaches constraints;
- rendering inside the resolved track allocation.

Widgets own:

- visual presentation;
- internal spacing;
- typography;
- truncation or compact mode.

Widgets do not own cross-column alignment.

## Track Requirements

The proposal does not settle the exact implementation mechanism.

An occupied track's requirement should describe the natural outer height of the
occupant itself. It is not a spacing allowance. Compatibility wrappers may
preserve horizontal inset and alignment, but when they consume a resolved track
plan they should not add top or bottom padding to that track.

Possible approaches:

1. **Model-published requirements**
   - A column or panel model declares `TrackRequirement` values from known
     content characteristics.
   - Example: a compact Conversation Card model can estimate the needed track
     height from glyph row count and visible metadata.

2. **Widget-published static contracts**
   - A widget exposes track requirements for named modes.
   - Example: compact card, standard card, dense card.

3. **Direct measurement**
   - The framework measures widgets and feeds requirements back into the
     coordinator.
   - This should be treated cautiously because it can introduce layout repair,
     jitter, and implementation complexity.

The first implementation should prefer explicit `TrackRequirement` values over
post-layout measurement.

Height is simply the first requirement the architecture needs. The model should
leave room for later requirements such as:

- minimum height;
- maximum height;
- compact variants;
- alignment preferences;
- overflow policy.

## Variable Content

Variable content is the central reason to explore tracks.

Examples:

- one-row vs five-row Conversation glyphs;
- optional formatted chat hooks;
- optional tags;
- Conversation Card compact vs standard modes;
- metadata wrapping in narrow panels.

The track model should let such content request enough room while preserving
the global rhythm.

If a component's standard requirement would make the page feel unwieldy, the
component should provide a compact requirement rather than forcing the page into
an unbounded track.

## Empty Tracks

Empty tracks are a feature, not a problem.

A column may participate in Track B with no visible content so that Track C
still starts at the shared y-position.

This avoids making every panel invent filler content merely to satisfy the
grid.

## Sidebar Participation

The sidebar cassette system should continue to own cassette sequencing,
selection, overflow, and cassette-specific layout.

For the implemented early slices:

- Track A contains the sidebar top menu;
- Track B is an empty sidebar allocation;
- the rest of the sidebar continues below it with the existing cassette flow;
- no attempt is made to auto-place cassettes inside Track B;
- the page does not know which cassette is a heatmap, picker, or control stack.

Future sidebar participation may add a cassette-chain seam that lets a cassette
declare track participation or content-start candidacy, but that remains
explicitly out of scope.

## Relationship To Current Wrapper Model

The current `TitleColumnBand` and `ContextColumnBand` model remains valid as
the implemented version of the cross-column layout contract.

What remains valid:

- page owns cross-column alignment;
- components render inside assigned space;
- content starts should align across peer panels;
- sidebar cassettes should participate through a seam rather than feature hacks;
- diagnostic margins are useful during layout tuning.

What would change:

- fixed heights become resolved track allocations;
- wrapper names may become track renderers or compatibility wrappers;
- Track A/Track B requirements can vary by page and by content;
- the Search page can prove the model before other surfaces migrate.

## Migration Strategy

Migration should be gradual.

1. Keep current wrapper implementation intact. **Done for Track A/Track B.**
2. Introduce a track-plan concept on the Search page only.
   **Done for Track A/Track B.**
3. Map existing title bands onto Track A. **Done.**
4. Let center and right title columns publish `TrackRequirement` values.
   **Done through the page-level Track A plan.**
5. Let the sidebar top menu participate in Track A only. **Done.**
6. Map center metadata onto Track B, with empty sidebar/right allocations.
   **Done.**
7. Verify that the current visual alignment is preserved or improved.
8. Map future controls, Conversation Card, or excerpt metadata onto later
   tracks only if approved.
9. Only after that, consider replacing wrappers or extending sidebar track
   participation.

This avoids destabilizing Contacts, Conversations, and other sidebar surfaces
while the new model is still being proven.

## Risks

- **Over-generalization**: a track system could become a layout framework before
  the product needs it.
- **Measurement complexity**: direct widget measurement can introduce rebuild
  loops or jitter.
- **Sidebar collision**: forcing cassette chains into tracks too early would
  violate sidebar ownership.
- **Naming drift**: tracks must be explained as page-level layout regions, not
  feature concepts.
- **Premature replacement**: removing the wrapper model before the track model
  is proven would create avoidable churn.

## Open Questions

- Should `TrackRequirement` values be declared by models, widgets, or layout
  adapters?
- What vocabulary should replace `TitleColumnBand` and `ContextColumnBand` if
  tracks become canonical?
- Should tracks be named semantically (`identity`, `context`) or ordinally
  (`trackA`, `trackB`) in code?
- What maximum height should prevent a single rich widget from making the whole
  page feel top-heavy?
- How should debug overlays show resolved track plans?
