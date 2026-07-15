---
tier: project
scope: design-notes
owner: agent-per-project
last_reviewed: 2026-07-15
source_of_truth: proposal
status: c2-fixed-height-occupant-implemented
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
- proposed model: page compositions place `TrackOccupant`s into cells;
  occupants publish `TrackRequirement` values; and the page resolves a shared
  `ResolvedTrackPlan`.

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

Pages own:

- which content belongs to which track cell;
- cell alignment decisions for those occupants;
- the page-specific arrangement of occupied and empty cells.

TrackOccupants own:

- the requirement declaration for their presentation;
- construction of the presentation widget;
- compact/adaptive presentation when content approaches constraints;
- rendering inside the resolved track allocation.

Widgets own:

- visual presentation;
- internal spacing;
- typography;
- truncation or compact mode.

Widgets do not own cross-column alignment.

## Track Cell Alignment

Track cell alignment answers a different question than track height or
occupant requirement.

```text
Track height:
  How tall is this shared horizontal coordinate?

TrackRequirement:
  How much space does this occupant naturally require?

Track cell alignment:
  Where should this occupant be placed inside its resolved cell allocation?
```

Alignment belongs to the page composition because it is a decision about how
one page arranges its occupants. It is not a property of the track, the
`TrackOccupant`, or the underlying widget.

This preserves the ownership model:

- tracks own shared geometry;
- `TrackOccupant`s own natural requirements and construction of the
  presentation widget;
- pages own track occupancy and cell alignment;
- widgets own presentation inside their natural bounds.

Initial vertical alignment options should be limited to:

- top;
- center;
- bottom.

Do not broaden this into a general layout framework until real page work
requires it. Do not add horizontal alignment until a concrete need appears.

Alignment must not become hidden spacing. Padding inserts space and can change
the apparent rhythm of a page. Cell alignment places an occupant inside an
allocation that has already been resolved. It must not alter the
`TrackRequirement`, the resolved track height, or the negotiation algorithm.

Example:

```text
Resolved Track C height: 120

C2:
  occupant requirement: 18
  alignment: bottom

C3:
  occupant requirement: 120
  alignment: top
```

The track remains 120px. C2 is simply placed at the bottom of its resolved
cell. The track system still knows nothing about metadata, cards, Search,
context, or controls.

## Track Requirements

The proposal does not settle the exact implementation mechanism.

An occupied track's requirement should describe the natural outer height of the
occupant itself. It is not a spacing allowance. Compatibility wrappers may
preserve horizontal inset and default child placement during the migration, but
when they consume a resolved track plan they should not add top or bottom
padding to that track. Future cell placement should be a page-composition
alignment decision rather than wrapper-owned layout behavior.

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

## Fixed-Height Occupants Used For Spacing

Spacing uses the same mechanism as content.

A spacing decision is not a special track type and does not receive a direct
fixed height from the page coordinator. It is represented by placing a
`FixedHeightTrackOccupant` in one track cell of the current page composition.

For the current Search page:

```text
C1: no occupant
C2: MessageEvidencePostMetadataControlsTrackOccupant
C3: optional ConversationSignatureCardTrackOccupant when a Conversation excerpt
    is visible
```

The page coordinator collects the C2 requirement and, when the right
Conversation excerpt is visible, the C3 requirement. The resolved track height
is simply the maximum requirement contributed by the current occupants. C1
renders the resolved cell allocation without contributing a duplicate occupant.

Track C does not therefore gain spacing semantics. Tracks know only their
ordinal identity and resolved geometry. Meaning belongs to the occupants and to
the page composition that places those occupants.

In this composition, the C2 occupant declares the natural outer height for the
Message Evidence support/search-control group. The C2 cell then bottom-aligns
that group inside the resolved allocation when another cell contributes a taller
requirement.

`ConversationSignatureCardTrackOccupant` is the first Search-page occupant in
this package whose natural requirement varies materially with content. It uses
`ConversationSignatureCardPresentationMetrics`, shared with the rendered
Conversation Card, so glyph row count and canonical card width influence the C3
requirement without adding a page-owned Conversation Card height constant.

The canonical card width is itself part of the Conversation Card presentation
contract. The authoritative value is
`ConversationSignatureCardPresentationMetrics.canonicalWidth`. Surfaces that
use canonical `ConversationSignatureCard` presentation must provide enough
space for that width. If a container is wider, it places the fixed-width card
inside the available space; it does not stretch the card and therefore does not
change glyph wrapping or natural-height calculation.

This preserves the universal rule:

```text
occupants declare requirements
tracks resolve maximums
columns honor resolved allocations
```

There should be no separate code path for fixed track height, spacing metadata,
or semantic track-role overrides.

## Track Cell Vocabulary

Track cells are named with the track letter followed by the column number:

```text
A1  A2  A3
B1  B2  B3
C1  C2  C3
```

The letter identifies the shared horizontal track. The number identifies the
column:

- `1` = left sidebar;
- `2` = center panel;
- `3` = right/end panel.

Use this vocabulary in design discussion, implementation plans, diagnostics,
and tests when it clarifies which column owns an occupant.

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
7. Add the first explicit spacing shim as Track C using a single C2
   `FixedHeightTrackOccupant`. **Done.**
8. Add the right-panel Conversation Card as an optional C3
   `ConversationSignatureCardTrackOccupant`. **Done.**
9. Verify that the current visual alignment is preserved or improved.
10. Map future controls or excerpt metadata onto later tracks only if
   approved.
11. Only after that, consider replacing wrappers or extending sidebar track
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
- What maximum height should prevent a single rich widget from making the whole
  page feel top-heavy?
- How should debug overlays show resolved track plans?
