# INVIOLATE RULES — Sidebar Cassette System

These rules govern the sidebar cassette stack. Violations are bugs.

---

## 1. Feature Coordinators Return `Future<SidebarCassetteCardViewModel>`

Every feature cassette coordinator **must** have this signature:

```dart
Future<SidebarCassetteCardViewModel> buildViewModel(
  FeatureCassetteSpec spec, {
  required int cassetteIndex,
})
```

No other return type. No widgets. No wrapper objects. No sync returns.

## 2. `SidebarCassetteCardViewModel` Is the Only Boundary Payload

This is the **only** object that crosses from a feature into `essentials/sidebar`.
If additional data is needed, add a field to the view model.
Do not introduce parallel types, tuples, records, or wrappers.

## 3. The Resolver Decides, the View Model Declares, the Card Obeys

- The **resolver** determines all view model field values (title, cardType, child, etc.)
- The **view model** carries those decisions as data
- The **card widget** (SidebarCassetteCard, SidebarInfoCard, etc.) renders what it's told

No component may override decisions made upstream.

## 4. Features Never Construct Card Chrome

Features return `SidebarCassetteCardViewModel`. The `CassetteWidgetCoordinator`
wraps it in `SidebarCassetteCard`, `SidebarInfoCard`, or `SidebarNavigationCard`
based on `cardType`.

Features must not import, instantiate, or return card widgets.

## 5. Cascade Topology Is the Only Place for Cross-Feature Links

When cassette A (owned by feature X) needs to spawn cassette B (owned by feature Y),
the connection lives **only** in `cascade/links/`. Features do not import each
other's specs directly in coordinators or resolvers.

## 6. Rack Mutations Use Provided Methods Only

Cassettes must be added, removed, or replaced through `CassetteRackState` methods
(`replaceAtIndexAndCascade`, `truncateAfter`, `pushCassette`, etc.).
Direct modification of the cassette list is not permitted.

## 7. Loading = Pending Future

While the `CassetteWidgetCoordinator` awaits a feature's `Future<SidebarCassetteCardViewModel>`:
- The pending Future represents "loading"
- The view model must not contain `isLoading` flags, skeleton states, or placeholders
- The sidebar system uses stale-while-revalidate at the render level

## 8. Error/Empty States Are View Model Content

Resolvers encode errors and empty states in the view model fields.
Resolvers must not throw exceptions across the feature → essentials boundary.
Resolvers must not return null.

## 9. One Spec Variant = One Resolver

Each variant of a feature's cassette spec maps to exactly one resolver call
in the coordinator. No multi-resolver composition, no conditional resolver
selection beyond the initial pattern match.

## 10. `cassetteIndex` Must Be Passed Through

The `cassetteIndex` parameter (the cassette's position in the rack) is passed
from the app-level coordinator to the feature coordinator. Features that need
to know their position in the stack use this value. It must not be inferred
or hard-coded.

## 11. Expansion Is Opt-In

`SidebarCassetteCardViewModel.shouldExpand` defaults to **`false`**. Cards render
at intrinsic height unless the resolver explicitly sets `shouldExpand: true`.

- **Set `shouldExpand: true`** only for cards with scrollable lists or content
  that should fill available vertical space.
- **Leave the default** for info cards, summaries, heatmaps, controls, and any
  card with fixed-height content.
- **Never** rely on implicit expansion. If a card needs to expand, say so explicitly
  in the resolver.

## 12. Essentials Owns Sidebar Layout

Essentials always owns outer sidebar layout.

Features must not redefine:

- cassette width
- outer horizontal rails
- wrapper alignment relative to sibling cassettes
- vertical rhythm between cassettes
- section-transition spacing

If a cassette needs different chrome or composition, express that through the
approved sidebar payload and essentials-owned wrapper rules. Do not invent a
second layout system inside the feature.

## 13. Feature-Owned Complex Bodies Fill the Frame

For feature-owned complex bodies, essentials supplies the full cassette body
frame. The feature body must fill that frame and may only subdivide it
internally.

Allowed:

- internal text or metadata lanes
- internal trailing action gutters
- optical tuning inside the full-width body

Forbidden:

- outer horizontal padding that shrinks the whole body
- simulated gutters created by shrinking the root body
- alternate outer rails inside the cassette

## 14. Optical Tuning Does Not Override Geometry

Optical tuning is allowed only after the geometry contract is satisfied.

Use optical tuning to adjust how content sits inside the cassette body.
Do not use it to compensate for broken wrapper geometry.

When content feels too wide or too narrow, verify first that width is not being
lost at the wrapper, list, or row boundary before introducing visual tuning.

## 15. Do Not Repeat Control-Defined Dataset Context

Avoid redundant section headers when the current UI controls already fully
define the dataset being displayed.

Lists should read as the direct result of the selected controls unless
additional context is required for clarity.

Do not add a results header that merely restates the active filter, mode, or
scope already communicated by the controls above.
