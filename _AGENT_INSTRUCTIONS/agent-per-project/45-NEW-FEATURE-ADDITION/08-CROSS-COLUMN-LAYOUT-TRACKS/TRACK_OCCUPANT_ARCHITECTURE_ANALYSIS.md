---
tier: project
scope: architecture-analysis
owner: agent-per-project
last_reviewed: 2026-07-15
source_of_truth: proposal
status: exploratory
links:
  - ./README.md
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./FLUTTER_IMPLEMENTATION_INVESTIGATION.md
tests: []
---

# TrackOccupant Architecture Analysis

## Summary Recommendation

Introduce `TrackOccupant` as the next abstraction only after the current Track
A/Track B proof remains stable.

The useful idea is not that widgets can be asked how tall they are. They cannot
be queried that way without entering Flutter's layout phase or doing
post-frame repair. The useful idea is that the same presentation contract that
builds a track cell can also declare what that cell requires.

Recommended direction:

```text
source data + presentation contract
        ↓
TrackOccupant
        ↓
TrackRequirement
        ↓
ResolvedTrackPlan
        ↓
render inside resolved allocation
```

A `TrackOccupant` should therefore be a presentation-layer adapter. It should
not be a domain object, a widget measurement hook, or a persistence model.

All visible content placed into a track should be represented by a
`TrackOccupant`.

Examples:

- sidebar top menu;
- center and right panel titles;
- metadata text;
- future Conversation Cards;
- future Conversation glyphs;
- explicit spacing shims.

An empty track cell has no occupant and contributes no requirement.

The first implementation candidate should be narrow:

- Track A sidebar top menu;
- Track A center/right titles;
- Track B center metadata;
- empty Track B cells represented by the absence of occupants.

Do not start with Conversation Cards. Cards and glyphs are the reason the
abstraction is valuable, but they need a shared presentation-metrics contract
before they can safely participate.

## Implementation-Plan Constraints

The forthcoming first-slice implementation plan should treat these as settled
constraints:

1. Every visible item placed into a track is represented by a `TrackOccupant`.
2. Constant and calculated natural requirements share the same abstraction.
3. Constant requirements come from shared presentation contracts, not page
   magic numbers.
4. Calculated requirements use the same inputs used to build the widget.
5. The track coordinator only collects requirements, resolves maximums, and
   builds the resolved plan.
6. Empty track cells have no occupant and contribute no requirement.
7. Shim tracks are ordinary tracks containing a `FixedHeightTrackOccupant`.
8. A `TrackOccupant` owns both requirement calculation and construction of the
   presentation widget.

These constraints refine the analysis; they do not authorize implementation.

## 1. What Is A TrackOccupant?

A `TrackOccupant` is the thing a column places into a shared layout track.

It represents both:

- the content that will render in one track cell; and
- the natural requirement that content contributes to the track plan.

Every visible item inside a track should be represented by a `TrackOccupant`.
The page coordinator should not contain branches such as:

```text
if this is the Top Menu
if this is a title
if this is a Conversation Card
```

The page should understand only:

```text
TrackOccupant -> TrackRequirement
```

It is not merely a widget. It is a small adapter around source data,
presentation style, and layout-relevant options.

Likely conceptual shape:

```dart
abstract interface class TrackOccupant {
  TrackId get trackId;

  TrackRequirement requirement(TrackRequirementContext context);

  Widget build(
    BuildContext context,
    ResolvedTrackAllocation allocation,
  );
}
```

The exact API can evolve, but the ownership should remain stable:

- columns decide which `TrackOccupant`s participate;
- occupants declare requirements;
- the page resolves the shared plan;
- occupants build inside the resolved allocation.

Empty cells are not represented by `EmptyTrackOccupant`. They simply omit an
occupant and therefore contribute no requirement.

## 2. Why Not Query A Widget?

Flutter widgets are immutable configuration. They do not have a size until an
element/render object is laid out under constraints.

Asking a widget for its height before layout usually requires one of:

- post-frame measurement;
- `GlobalKey` plus `RenderBox.size`;
- a custom render object;
- a `CustomMultiChildLayout` delegate that measures children during layout;
- intrinsic measurement.

Those tools have valid uses, but they are the wrong default for this
architecture.

The track model is declarative:

```text
participants declare requirements
page resolves plan
columns render inside plan
```

Widget measurement reverses the model:

```text
render something
measure it
repair layout
render again
```

That risks jitter, hidden dependencies, and imperative layout repair. It also
makes the page learn too much about individual widgets.

The page should not ask:

> How tall did this widget become?

It should receive:

> This track occupant requires this much space under this presentation contract.

## 3. Requirement Context

Requirements are not globally constant. The same occupant can require different
space depending on the environment.

A `TrackRequirementContext` should be immutable and built by the page or column
adapter during build. It should contain only information needed to compute
layout requirements, such as:

- available width for the track cell;
- text scaler;
- text direction;
- locale, when text measurement needs it;
- typography tokens;
- compact/dense presentation mode;
- max-line and overflow policy;
- relevant track identity;
- possibly device class or column role, if those become real inputs.

For text, width and text scaler matter.

For controls, padding, typography, icon size, and control chrome matter.

For glyphs, width, dot size, spacing, month count, anchoring policy, and
highlight-ring policy matter.

For cards, visible fields, glyph mode, tag visibility, hook visibility, and
style all matter.

The context should not include repositories, providers, database handles, graph
query objects, or user-intent mutation APIs.

## 4. Requirement Object

The current `TrackRequirement` contains only:

```dart
TrackId trackId;
double height;
```

That is sufficient for the implemented Track A/Track B proof. It is also a good
minimum for a first `TrackOccupant` slice.

However, the term `TrackRequirement` should remain broader than "preferred
height." Height is the first requirement, not the whole architecture.

Likely future fields:

- natural height;
- minimum height;
- maximum height;
- compact height;
- alignment preference;
- overflow policy;
- whether the track may expand;
- whether the occupant can provide a compact variant.

Do not add these until a real track requires them. The important point is to
avoid naming the model as though a single fixed height is its permanent purpose.

## 4A. Constant And Calculated Requirements

`TrackOccupant` should cover both constant and calculated natural
requirements.

The page must not distinguish between:

```text
TopMenuTrackOccupant        -> constant requirement
TextTrackOccupant           -> TextPainter calculation
ConversationGlyphOccupant   -> glyph metrics calculation
ConversationCardOccupant    -> composed metrics calculation
FixedHeightTrackOccupant    -> constant requirement
```

To the page, all of these are just occupants that produce `TrackRequirement`
values.

When an occupant has a genuinely fixed natural outer height, that requirement
should come from the same shared presentation contract that renders the widget.
The page should not contain magic numbers.

When an occupant depends on current presentation context, it should calculate
its natural requirement from the same inputs used to build the widget. Text
should use `TextPainter`; glyphs should use shared glyph metrics; cards should
use composed card metrics.

Do not estimate from character counts. Do not query already-built widgets. Do
not use post-frame measurement.

## 5. Header/Text Occupants

Text is the safest first category of occupant.

Examples:

- `All messages`;
- `Conversation`;
- result date range and message count;
- short sidebar orientation text.

A text occupant can compute its natural requirement with `TextPainter` using
the same text, style, max-lines, width, text scaler, text direction, locale, and
overflow policy that the rendered widget will use.

For one-line titles, this replaces hard-coded line-height constants such as:

```text
20 * 1.15
```

with a declarative calculation from the actual typography token.

Important rule:

The text occupant's requirement is the text's natural outer requirement. It
must not include page-level breathing room. Any intentional separation belongs
in a separate empty track or a reviewed wrapper rule.

## 6. Fixed-Control Occupants

Fixed controls are also reasonable early occupants, but their requirements
should come from the control's presentation contract.

The Search sidebar top menu is the current example.

Its visual height is not arbitrary. It comes from:

- selected-value typography;
- trigger vertical padding;
- chevron icon size;
- chevron capsule padding;
- border/chrome effects, if they affect outer size.

The current Search top menu effectively resolves to the dropdown trigger's
natural height:

```text
vertical trigger padding
+ max(selected text line, chevron capsule)
```

This is a legitimate natural control requirement. The problem is not that it is
fixed. The problem would be scattering the number in page code without a named
control contract.

Recommended direction:

- centralize reusable dropdown trigger metrics with the dropdown control;
- let a top-menu occupant use those metrics;
- avoid duplicating the same arithmetic in the Search page.

Fixed controls are still ordinary occupants. The page should not know that the
top menu is a fixed-control occupant. It should see only the resulting
`TrackRequirement`.

## 7. Conversation Glyph Occupants

Conversation glyphs are the first place where `TrackOccupant` becomes more
interesting.

The glyph's height depends on:

- available width;
- number of anchored months;
- column count derived from dot size and spacing;
- row count;
- dot size;
- empty-dot size;
- row spacing;
- highlighted-month ring/padding.

The current glyph widget already knows these rules internally. For example, it
derives columns from width, chunks months into rows, and uses fixed dot and
spacing constants.

That logic should not be duplicated in a track occupant.

If glyphs need to participate in tracks, first extract or expose a shared
glyph-presentation metrics helper. The widget and the occupant should both use
that helper.

Recommended direction:

```text
ConversationSignatureGlyphMetrics
  - columnsForWidth(width)
  - rowsForMonths(months, width)
  - heightFor(months, width, highlightedMonth)
```

The exact name is not important. The single-source requirement is.

## 8. Conversation Card Occupants

Conversation Cards are the most important future occupant category and the
worst first implementation target.

A Conversation Card's height may depend on:

- title;
- optional participant suffix;
- optional formatted chat hook;
- trailing favourite control;
- glyph row count;
- summary metadata;
- optional tags;
- card style;
- card padding;
- compact/read-only mode;
- available width.

Because cards are canonical Conversation presentation, any height requirement
must be derived from the same presentation contract that renders the card.

Do not create a second "card height estimator" in page code.

Recommended future direction:

- keep `ConversationSignatureCard` pure;
- introduce a `ConversationSignatureCardMetrics` or similar presentation helper
  inside `features/conversations`;
- let a Conversation-owned track occupant consume `ConversationSignatureCardData`
  and `ConversationSignatureCardStyle`;
- keep graph facts, overlay intent, and tag state outside the occupant.

The occupant should not decide what a Conversation is. It should receive
already-prepared presentation data and answer what that presentation requires
inside a track.

## 9. Composition

Composition is useful, but only if it shares metrics rather than recreating the
widget tree.

Text, glyph, tag-row, and control occupants can be composed into a larger card
occupant. But the composition should be based on shared presentation primitives,
not copied widget layout.

Example:

```text
ConversationCardOccupant
  title text requirement
  optional hook text requirement
  glyph requirement
  summary text requirement
  optional tag row requirement
  card padding/gaps
```

This is appropriate once those lower-level presentation contracts are explicit.

For the next slice, composition is not necessary. Text and control occupants are
enough.

## 10. Build API

The build API should separate requirement calculation from presentation
construction.

`TrackOccupant` owns both:

- requirement calculation; and
- construction of the presentation widget.

The page owns only track resolution and `ResolvedTrackPlan` creation.

Recommended shape:

```dart
abstract interface class TrackOccupant {
  TrackId get trackId;
  TrackRequirement requirement(TrackRequirementContext context);
  Widget build(BuildContext context, ResolvedTrackAllocation allocation);
}
```

`TrackRequirementContext` should be build-time environment converted into a
plain value object.

`ResolvedTrackAllocation` can initially be small:

```dart
class ResolvedTrackAllocation {
  final TrackId trackId;
  final double height;
  final double width;
}
```

If the first implementation does not need width in the build allocation, it can
be omitted. The conceptual distinction still matters:

- requirement phase receives environment and declares need;
- presentation phase receives resolved allocation and constructs the visible
  presentation.

Avoid APIs where `requirement()` takes a `BuildContext`. Context makes it easy
to smuggle providers and feature state into what should remain deterministic
layout calculation.

## 11. Ownership

Ownership should remain consistent with the rest of MessageLens.

Page/layout infrastructure owns:

- `TrackId`;
- `TrackRequirement`;
- `ResolvedTrackPlan`;
- requirement resolution;
- generic track occupant interfaces.

The track coordinator should remain deliberately small:

```text
collect TrackRequirements
resolve maximum requirement per Track
build ResolvedTrackPlan
```

It should know nothing about Search, Conversations, glyphs, cards, sidebar
controls, or text measurement.

Columns own:

- selecting which occupants participate;
- providing width/environment context;
- rendering occupants in the resolved plan.

Feature presentation owns:

- feature-specific occupants;
- feature-specific metrics helpers;
- conversion from presentation data to track requirements.

Domain/graph/import/overlay layers do not own track occupants.

For Conversation surfaces specifically:

- graph provides Conversation facts;
- overlay provides user intent;
- Conversations feature merges those into presentation data;
- Conversation presentation supplies card/glyph occupants if needed;
- the page resolves tracks.

## 12. Sidebar Implications

The sidebar cassette system should not be rewritten for `TrackOccupant`.

For the first occupant slice, the sidebar should participate only through the
top menu occupant.

Later, a cassette may expose a track occupant if it explicitly participates in
the cross-column page rhythm. That should be a cassette-chain seam, not a page
hard-code.

The page should not know:

- which cassette is a heatmap;
- which cassette is explanatory text;
- which cassette is a picker;
- how cassette overflow works.

The sidebar may eventually translate selected cassette roles into occupants,
but that is a future sidebar-layout problem. It is not required to validate the
TrackOccupant model.

## 12A. Empty Cells And Fixed-Height Spacing Occupants

An empty track cell simply has no `TrackOccupant`.

It contributes no requirement:

```text
Sidebar Track B: no occupant
Right Track B: no occupant
```

Do not introduce `EmptyTrackOccupant`.

Spacing does not require a special architectural concept. A page composition
may place one fixed-height occupant in one track cell:

```text
D1: no occupant
D2: FixedHeightTrackOccupant(height: 8)
D3: no occupant
```

The resolved track height naturally becomes 8 because the normal track
negotiation algorithm already handles it. D1 and D3 honor the resolved
allocation without contributing duplicate occupants.

Do not introduce a special `ShimTrack` type or assign spacing semantics to the
track itself. Spacing and content should use the same track negotiation
mechanism through occupants.

## 13. Performance And Recalculation

The recommended calculations are cheap:

- one-line text measurement;
- dropdown trigger arithmetic;
- glyph row count from width and month count;
- card height composition from a small set of primitives.

Recalculate requirements when any layout-relevant input changes:

- available width;
- text scaler;
- typography;
- locale or text direction;
- selected surface;
- selected Conversation;
- visible tags/hooks;
- glyph month data;
- compact mode.

Do not introduce caching until profiling shows a need. If caching becomes
necessary, cache by stable presentation inputs rather than widget identity.

Avoid post-frame loops entirely. Requirement recalculation should happen during
normal build from current model/environment values.

## 14. Testing

Testing should focus on deterministic requirement calculation and plan
resolution.

Recommended test categories:

- text occupant calculates expected one-line and wrapped heights;
- top-menu occupant matches the shared dropdown trigger contract;
- empty cells contribute no requirement because they have no occupant;
- fixed-height spacing occupant contributes its fixed natural height;
- multiple occupants in the same track resolve to the maximum requirement;
- Track A remains governed by the sidebar selector when it is tallest;
- Track B remains content-tight around metadata;
- glyph metrics produce expected row counts at known widths;
- card metrics include optional hook/tags only when visible;
- no requirement includes discretionary spacing.

Widget tests should then verify that the Search page still renders:

- with no right panel;
- with the Conversation excerpt panel;
- after window-width changes;
- in light and dark mode;
- with developer track diagnostics enabled.

## 15. First Implementation Candidate

Recommended first slice:

> Convert the existing Search-page Track A/Track B proof from page-level numeric
> constants to TrackOccupants for the same occupants already participating.

Scope:

- `TextTrackOccupant` for center/right titles;
- `TextTrackOccupant` for center metadata;
- `TopMenuTrackOccupant` or `FixedControlTrackOccupant` for the sidebar top
  menu;
- no occupant for intentionally empty peer cells;
- Search page only;
- Track A and Track B only.

This slice should not introduce a fixed-height spacing occupant unless the
visual design review explicitly calls for one. If spacing is later needed, it
should be represented as an ordinary occupant in a chosen track cell.

Do not include:

- Conversation Card occupant;
- Conversation glyph occupant;
- sidebar cassette content-start participation;
- Track C;
- Contacts migration;
- wrapper removal.

Success criterion:

The page still looks the same, but `SearchPageTrackRequirements` no longer has
to hand-maintain text/control heights as free-floating page constants.

## Alternatives Considered

### Manually Publishing Numeric Requirements From Page Code

This is what the current proof mostly does.

Strengths:

- simple;
- explicit;
- easy to test;
- good for proving the track-resolution model.

Weaknesses:

- numbers drift from widgets;
- typography/control changes require manual updates;
- larger components such as Conversation Cards become unsafe to estimate.

Recommendation:

Acceptable for the proof slice that already exists. Not acceptable as the
forthcoming `TrackOccupant` implementation pattern. The first occupant slice
should remove feature/page-specific numeric branches from the coordinator path.

### Widget-Specific Static Constants

Strengths:

- better than page-local magic numbers;
- keeps known control contracts near widgets;
- easy to consume.

Weaknesses:

- static constants fail for width-sensitive content;
- typography/text-scaling can make constants wrong;
- cards and glyphs are too variable for simple constants.

Recommendation:

Useful for genuinely fixed control chrome. Insufficient for text, glyphs, and
cards unless paired with metrics functions.

### Direct Widget Measurement

Strengths:

- measures actual rendered result;
- avoids duplicated calculations in theory.

Weaknesses:

- requires layout-phase or post-frame mechanisms;
- can create repair loops;
- makes ownership harder to reason about;
- complicates tests;
- risks coupling the page to concrete widgets.

Recommendation:

Avoid for this architecture unless explicit requirement contracts prove
impossible.

### IntrinsicHeight / Intrinsic Measurement

Strengths:

- can ask children for intrinsic dimensions inside Flutter's layout protocol;
- sometimes useful for small static layouts.

Weaknesses:

- expensive;
- not reliable for all widgets;
- interacts poorly with complex scrollables and dynamic sidebar cassettes;
- still treats measurement as discovery rather than declaration.

Recommendation:

Do not use for cross-column page rhythm.

### CustomMultiChildLayout

Strengths:

- can measure and position known children in one layout phase;
- avoids post-frame measurement;
- maps reasonably well to fixed slot layouts.

Weaknesses:

- less natural for the dynamic cassette sidebar;
- adds ceremony and delegate complexity;
- concentrates page layout policy in a lower-level layout primitive;
- does not eliminate the need to define track participation semantics.

Recommendation:

Keep as a possible future implementation tool, not the next step.

### Custom RenderObjects

Strengths:

- maximum control;
- can implement true parent-driven layout.

Weaknesses:

- high complexity;
- harder accessibility/semantics maintenance;
- harder for future agents to modify safely;
- unnecessary for the current Search-page proof.

Recommendation:

Do not use unless several pages require behavior that ordinary composition
cannot express.

### Post-Frame Measurement

Strengths:

- easy to prototype;
- can observe actual sizes.

Weaknesses:

- imperative repair;
- visible jitter risk;
- asynchronous layout state;
- harder invalidation;
- violates the project's derivation-over-repair principle.

Recommendation:

Do not use.

## Boundaries

`TrackOccupant` should not:

- query databases;
- watch providers directly;
- mutate overlay/user intent;
- interpret graph identity;
- decide which feature owns a surface;
- encode page-level spacing;
- know about sibling columns;
- make sidebar cassette placement decisions.

It should:

- receive already-prepared presentation data;
- declare track requirements from that data and presentation contract;
- build the corresponding widget inside a resolved allocation.

## Risks

- **Metric drift**: if requirement calculation duplicates widget layout, it will
  become wrong. Shared metrics helpers are required for complex widgets.
- **Over-generalization**: a generic occupant framework could outgrow the
  immediate need. Start with Search Track A/B.
- **Hidden spacing returning**: occupants might smuggle breathing room into
  requirements. Keep the occupied-track rule strict.
- **Sidebar overreach**: using occupants to force cassette placement too early
  would violate sidebar ownership.
- **Context leakage**: allowing requirement calculation to use `BuildContext`
  directly may pull providers and side effects into layout logic.

## Unresolved Questions Before Implementation Planning

1. Where should the generic `TrackOccupant` interface live?
   `lib/config/theme/widgets/layout/` is plausible, but the final location
   should reflect whether it is considered theme/layout infrastructure or
   broader page-layout infrastructure.

2. Should `TrackRequirementContext` contain typography objects directly, or
   resolved primitive text metrics?

3. Should dropdown trigger metrics be centralized in `AppDropdownMenu` or in a
   separate presentation-metrics helper?

4. Should `TrackRequirement` grow now to include natural/min/max/compact
   fields, or remain height-only for the first occupant slice?

5. How should baseline alignment be represented if height alignment is not
   sufficient for text-heavy tracks?

6. When Conversation Cards eventually participate, should the card expose a
   metrics helper first, or should a card occupant be built as an adapter around
   smaller text/glyph/tag metrics?

## Conclusion

`TrackOccupant` is the right next architectural seam if it is treated as a
declarative presentation adapter, not as a widget measurement system.

It preserves the approved direction:

```text
page owns tracks
columns own participation
widgets own presentation
```

The next implementation should prove the abstraction with the simplest
participants already in production. Conversation Cards and glyphs should wait
until their presentation metrics can be shared rather than duplicated.
