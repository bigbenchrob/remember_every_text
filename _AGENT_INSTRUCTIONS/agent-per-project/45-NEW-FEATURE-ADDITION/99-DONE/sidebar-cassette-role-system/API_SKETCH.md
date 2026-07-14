---
tier: feature
scope: api-sketch
owner: agent-per-project
last_reviewed: 2026-03-20
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./SIDEBAR_GEOMETRY_CONTRACT.md
  - ./CHECKLIST.md
  - ./TESTS.md
tests: []
---

# API Sketch - Sidebar Cassette Role System

## Purpose

Sketch the phase 1 Dart-side API shape for the sidebar role and geometry work before implementation begins.

This is not intended as final code.

It is the concrete contract proposal that should guide the first essentials-side edits.

## Design Goals

The phase 1 API should:

- add semantic role to the essentials-owned sidebar presentation payload
- replace free-form width negotiation with centrally owned placement modes
- allow centrally owned width tokens to propagate through shells and feature-facing constraints
- minimize disruption to the current cassette rack and feature-owned spec system
- preserve the coordinator -> resolver -> widget_builder pattern

## Existing Weak Point

Today the essentials-owned presentation payload is effectively:

```dart
class SidebarCassetteCardViewModel {
  final Widget child;
  final SidebarCardLayoutStyle layoutStyle;
  final bool isControl;
  final bool isNaked;
  final double topSpacing;
  // ... other chrome fields
}
```

This leaves too much structural meaning distributed across:

- `layoutStyle`
- `isControl`
- `isNaked`
- `topSpacing`
- arbitrary feature-owned `child` layout behavior

The phase 1 API should shift that meaning into explicit role and geometry contracts.

## Proposed Phase 1 Types

### `SidebarCassetteRole`

```dart
enum SidebarCassetteRole {
  appControl,
  contextPrimary,
  contextSecondary,
  filter,
  action,
}
```

Purpose:

- semantic grouping
- section derivation
- default hierarchy behavior

Not responsible for:

- exact chrome widget choice
- exact body width behavior by itself

### `SidebarBodyPlacementMode`

```dart
enum SidebarBodyPlacementMode {
  fullWidth,
  inset,
  insetWithTrailingGutter,
}
```

Purpose:

- describe how content is placed within the centrally owned content envelope
- replace cassette-local width negotiation

### `SidebarGeometryConstraints`

```dart
class SidebarGeometryConstraints {
  const SidebarGeometryConstraints({
    required this.placementMode,
    required this.contentEnvelopeWidth,
    required this.maxContentWidth,
    required this.hasTrailingGutter,
    required this.trailingGutterWidth,
    required this.trailingAffordanceMaxWidth,
  });

  final SidebarBodyPlacementMode placementMode;
  final double contentEnvelopeWidth;
  final double maxContentWidth;
  final bool hasTrailingGutter;
  final double trailingGutterWidth;
  final double trailingAffordanceMaxWidth;
}
```

Purpose:

- pass centrally computed geometry limits from essentials into role-specific shells and any approved feature-owned builders
- ensure tuning a small set of geometry tokens updates both shells and feature-facing constraints

### `SidebarGeometryTokens`

```dart
class SidebarGeometryTokens {
  const SidebarGeometryTokens({
    required this.contentEnvelopeWidth,
    required this.bodyInset,
    required this.trailingGutterWidth,
    required this.interiorGap,
  });

  final double contentEnvelopeWidth;
  final double bodyInset;
  final double trailingGutterWidth;
  final double interiorGap;
}
```

Purpose:

- centralize the tunable width constants for the sidebar system
- allow layout experimentation by editing one essentials-owned token source

## Presentation Payload Direction

### Phase 1 Minimal Evolution

The least disruptive first step is to extend the current payload rather than replacing it outright.

Conceptually:

```dart
class SidebarCassetteCardViewModel {
  const SidebarCassetteCardViewModel({
    required this.role,
    required this.placementMode,
    required this.title,
    required this.child,
    this.subtitle,
    this.sectionTitle,
    this.footerText,
    this.cardType = CassetteCardType.standard,
    this.infoBodyText,
    this.infoAction,
    this.isNaked = false,
    this.topSpacing = 0,
    bool? shouldExpand,
  }) : shouldExpand = shouldExpand ?? false;

  final SidebarCassetteRole role;
  final SidebarBodyPlacementMode placementMode;
  final String title;
  final String? subtitle;
  final String? sectionTitle;
  final String? footerText;
  final Widget child;
  final CassetteCardType cardType;
  final String? infoBodyText;
  final Widget? infoAction;
  final bool isNaked;
  final double topSpacing;
  final bool shouldExpand;
}
```

Key point:

- `layoutStyle` and `isControl` drop out of the long-term contract
- `role` and `placementMode` become explicit

### Why Not Replace `child` Immediately?

Phase 1 should not force every cassette into a new fully structured content model immediately.

Instead:

- keep `child` for compatibility
- constrain it with `placementMode` and `SidebarGeometryConstraints`
- later narrow specific roles such as `contextSecondary` into structured payloads where appropriate

## Phase 1 Shell Computation

The essentials-owned shell layer should translate `placementMode` + tokens into `SidebarGeometryConstraints`.

Conceptually:

```dart
SidebarGeometryConstraints computeConstraints({
  required SidebarGeometryTokens tokens,
  required SidebarBodyPlacementMode placementMode,
}) {
  switch (placementMode) {
    case SidebarBodyPlacementMode.fullWidth:
      return SidebarGeometryConstraints(
        placementMode: placementMode,
        contentEnvelopeWidth: tokens.contentEnvelopeWidth,
        maxContentWidth: tokens.contentEnvelopeWidth,
        hasTrailingGutter: false,
        trailingGutterWidth: 0,
        trailingAffordanceMaxWidth: 0,
      );

    case SidebarBodyPlacementMode.inset:
      final insetWidth = tokens.contentEnvelopeWidth - (tokens.bodyInset * 2);

      return SidebarGeometryConstraints(
        placementMode: placementMode,
        contentEnvelopeWidth: tokens.contentEnvelopeWidth,
        maxContentWidth: insetWidth,
        hasTrailingGutter: false,
        trailingGutterWidth: 0,
        trailingAffordanceMaxWidth: 0,
      );

    case SidebarBodyPlacementMode.insetWithTrailingGutter:
      final mainWidth =
          tokens.contentEnvelopeWidth -
          tokens.bodyInset -
          tokens.trailingGutterWidth -
          tokens.interiorGap;

      return SidebarGeometryConstraints(
        placementMode: placementMode,
        contentEnvelopeWidth: tokens.contentEnvelopeWidth,
        maxContentWidth: mainWidth,
        hasTrailingGutter: true,
        trailingGutterWidth: tokens.trailingGutterWidth,
        trailingAffordanceMaxWidth: tokens.trailingGutterWidth,
      );
  }
}
```

The exact math may change, but the ownership model should not.

## Where These Types Should Live

### Recommended Essentials Locations

- `SidebarCassetteRole`
  In the sidebar presentation/view-model layer or a closely related essentials-owned sidebar presentation contract file.

- `SidebarBodyPlacementMode`
  Same place as the role or in a dedicated sidebar geometry contract file inside essentials.

- `SidebarGeometryConstraints`
  Essentials-owned sidebar presentation contract layer.

- `SidebarGeometryTokens`
  Essentials-owned theme or sidebar configuration layer.

The key rule is that these types must remain `essentials/sidebar` owned.

## Coordinator Impact

The app-level cassette coordinator will need to do more than simply wrap a `child` with a chrome widget.

It will need to:

1. resolve the cassette view model
2. derive section grouping from `role`
3. compute geometry constraints from `placementMode`
4. pass those constraints into the correct shell and content path
5. render the final sidebar in section order while preserving rack order inside each section

## Role-Specific Shell Direction

Phase 1 does not require a unique shell widget per role, but it likely benefits from a small number of role-aware wrappers.

Possible direction:

```dart
Widget buildSidebarCassetteShell({
  required SidebarCassetteCardViewModel viewModel,
  required SidebarGeometryConstraints geometry,
}) {
  switch (viewModel.cardType) {
    case CassetteCardType.standard:
      return SidebarCassetteCard(
        viewModel: viewModel,
        geometry: geometry,
      );
    case CassetteCardType.info:
      return SidebarInfoCard(
        viewModel: viewModel,
        geometry: geometry,
      );
    case CassetteCardType.sidebarNavigation:
      return SidebarNavigationCard(
        viewModel: viewModel,
        geometry: geometry,
      );
  }
}
```

This keeps `cardType` as the chrome primitive choice while letting geometry be a separate contract.

## Future Phase Direction

Once phase 1 stabilizes, the next likely API refinement is to reduce the use of arbitrary `child` widgets for constrained roles.

Most likely order:

1. narrow `contextSecondary` into structured content payloads
2. narrow some `filter` surfaces into structured control payloads
3. keep `action` more flexible for longer because it contains richer interactive content

That evolution should happen after role and geometry are already explicit.

## Migration Notes

The minimum safe sequence is:

1. add `SidebarCassetteRole`
2. add `SidebarBodyPlacementMode`
3. add centrally owned geometry tokens and constraint computation
4. thread geometry constraints through shells
5. map current cassettes to role + placement
6. remove or demote `layoutStyle` / `isControl` usage

## Open Questions

1. Should `SidebarCassetteCardViewModel` remain the main payload name once it carries role and geometry, or should a new presentation contract type replace it?
2. Should `isNaked` survive phase 1 unchanged, or should naked rendering become a chrome subtype instead?
3. Should geometry tokens live under general theme spacing, or under a sidebar-specific geometry configuration source?
4. Which current cassettes need `insetWithTrailingGutter` immediately, and which can remain `inset` or `fullWidth`?
