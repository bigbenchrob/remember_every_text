# Sidebar Layout and Optical Composition

This document defines the ownership boundary between:

- essentials-owned sidebar layout and chrome
- feature-owned cassette body composition

It exists to prevent two opposite failures:

- feature code inventing alternate sidebar rails, padding, or spacing
- essentials trying to take over complex body rendering that depends deeply on
  feature infrastructure and domain-specific UI logic

---

## 1. Core Rule

Essentials always owns sidebar layout.

Features may own complex cassette body rendering, but they do so inside an
essentials-defined frame.

Use this mental model:

- essentials defines the frame
- feature defines the composition inside the frame

Features may not resize, reposition, or redefine the frame.

---

## 2. What Essentials Owns

Essentials is solely responsible for outer sidebar geometry and stack rhythm.

Essentials owns:

- sidebar rails and content envelope width
- cassette wrapper width and horizontal alignment
- vertical rhythm between cassettes
- section grouping and section-transition spacing
- whether a cassette is rendered as governed chrome, info, navigation, or a
  constrained feature-owned complex body
- the existence of an outer constrained host for cassette bodies

Section-transition spacing is semantic, not decorative. In particular, filter
groups may need different transition strength above and below because dense
controls followed immediately by dense results content often feel more crowded
below than above. When that happens, solve it in essentials-owned sectioning
rules, not with feature-local wrapper padding.

Whenever a control can be rendered as a standard sidebar primitive without
feature-specific rendering complexity, essentials should own the cassette body.
Examples include:

- simple buttons
- menus and dropdown-like controls
- compact navigation affordances
- other governed primitives that do not depend on feature-specific view logic

This keeps common controls visually consistent and prevents each feature from
recreating sidebar chrome independently.

---

## 3. When Features May Own the Body

It does not make sense for essentials to take over rendering of complex widgets
whose content depends heavily on feature infrastructure, repositories, or
domain-specific interaction patterns.

Feature-owned complex bodies are allowed when the widget:

- has significant feature-specific rendering logic
- depends on feature infrastructure or reactive state
- would become unnatural or brittle if re-expressed as an essentials primitive

Examples include:

- heatmaps
- dense review lists
- other interactive visualizations or feature-specific compound widgets

In this case, the feature builds the widget body, but the widget still lives
inside an essentials-owned constrained host.

Feature-owned sidebar bodies must route actions through the sidebar/essentials
action layer rather than mutating global sidebar structure directly. Use sidebar
action intents, coordinator routing, and ViewSpec-based navigation rather than
feature-local layout control.

---

## 4. Frame Contract for Feature-Owned Bodies

For feature-owned list or complex cassettes, essentials supplies the full outer
cassette width and any bounded vertical space.

The feature body must treat that supplied space as authoritative.

Required behavior:

- the root feature body fills the provided cassette body width
- when bounded height is supplied, scrollable or expandable bodies fill that
  height unless they have a genuine intrinsic-height reason not to
- the feature may subdivide the body internally into composition lanes such as
  main content, metadata, divider lane, and trailing action gutter

Forbidden behavior:

- adding extra outer horizontal padding that narrows the cassette body
- inventing a second outer rail system inside the cassette
- shrinking the whole body to make it "look right" relative to neighboring
  cassettes
- using root-level padding to simulate a gutter or alternate cassette width

The cassette body fills the frame. Optical tuning happens inside that body.

---

## 5. Optical Composition Is Allowed Inside the Frame

Once the geometry contract is satisfied, features may tune how content sits
inside the constrained body.

This is optical composition, not structural layout.

Approved optical adjustments include:

- spacing between text and metadata columns
- divider alignment and divider length within the body
- tuning the width of an internal trailing action gutter
- right-aligning marginal controls to the gutter edge
- adjusting row density, vertical spacing, and internal grouping
- introducing a coherent internal text lane when that lane is part of the
  widget's composition rather than a disguised outer inset

The important distinction is:

- optical composition may change how content sits inside the frame
- it may not change the width or rails of the frame itself

If internal optical tuning causes visible content not to touch the full width,
that is acceptable only when the full-width body still exists structurally and
the internal composition is coherent across the cassette.

This distinction also applies to spacing around filter groups:

- keep internal spacing within the filter section tight so the controls read as
  one cluster
- if the transition into results content needs more separation than the
  transition from the control above, express that as an asymmetric section
  spacing rule in essentials
- do not add one-off top or bottom padding inside individual filter widgets to
  fake that separation

This also applies to contextual headers inside result cassettes:

- if the active controls already define the dataset being shown, do not repeat
  that same scope in a section header above the results
- remove redundant headers that merely restate the current filter or mode
- let the results read as the direct outcome of the selected controls unless a
  header adds genuinely new structure or meaning

---

## 6. Coherent Lane Rule

If a feature introduces an internal composition lane, it must be coherent.

That means related elements in the same cassette should compose against the same
internal logic, rather than each inventing its own inset.

For list-style cassettes, this usually means the following should agree with one
another:

- section header lane
- row text lane
- divider lane
- metadata lane
- trailing gutter edge

Do not let each of these elements drift independently.

---

## 7. Lists With Trailing Actions

Lists with trailing buttons often look optically wider than bordered cassettes
even when their structural width is correct.

Required rules:

- the list still fills the full cassette body width supplied by essentials
- the trailing control aligns to the outer edge of the feature-owned trailing
  gutter
- the gutter is carved out internally, not by shrinking the whole cassette body

Recommended adjustments:

- reduce gutter width to match actual control footprint
- align metadata and dividers coherently with the internal content lane
- tune spacing between main content and metadata before changing any geometry

When content feels too wide, inspect composition first.
Do not change cassette geometry unless the frame contract itself is wrong.

---

## 8. Diagnostic Order

Before applying optical tuning, verify that the body is structurally correct.

Check for accidental width loss at these levels, in this order:

- wrapper layout style
- host padding or placement mode
- list-level outer padding
- row-level outer padding
- divider-level inset
- internal lane spacing

Only after structural correctness is confirmed should optical tuning be used.

---

## 9. Summary Rule

Do not change the width of the box.
Change how the contents sit inside it.
