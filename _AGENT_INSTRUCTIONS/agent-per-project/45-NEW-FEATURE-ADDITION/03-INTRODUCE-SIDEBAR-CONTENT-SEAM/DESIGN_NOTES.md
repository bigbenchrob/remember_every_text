---
tier: project
scope: design-notes
owner: agent-per-project
last_reviewed: 2026-07-07
source_of_truth: draft
status: proposed
---

# Sidebar Content Seam Design Notes

## Core Model

The sidebar cassette system should not obey the center panel. It should expose a
semantic seam that the X-column page skeleton can align.

The page says:

> Content starts here.

The sidebar says:

> This cassette is my primary content start.

The seam is the meeting point between those two responsibilities.

## Existing Concepts That Map Cleanly

| Proposed concept | Existing code concept |
| --- | --- |
| Top selector/menu | App-control cassettes, such as `TopChatMenuCassettePayload` |
| Cassette chain | `RenderableSidebarCassetteSpec` to `ResolvedSidebarCassette` |
| Cassette body | `SidebarCassetteCard` and placement-governed payload body |
| Primary cassette | `SidebarCassetteRole.contextPrimary` |
| Secondary guidance | `FeatureInfoSidebarCassettePayload`, `contextSecondary`, `supportingContext`, `footerText` |
| Layout coordinator | `_LeftSidebarSurface` plus cassette sectioning/render routing |
| Primary visual/navigation surface | `SidebarCassetteSemanticStyle.visualization` in some cases |

The best implementation seam is therefore above individual cassette widgets and
below feature-owned cassette resolution: the resolved cassette chain.

## Naming Recommendation

Preferred name:

```dart
enum SidebarCassetteLayoutAnchor {
  none,
  preferredContentStart,
}
```

Rationale:

- "layout anchor" is neutral and sidebar-local.
- "preferred" leaves room for future coordinator decisions.
- "content start" matches the X-column grammar without naming a widget.

Avoid names like:

- `heatmapStart`
- `xColumnStart`
- `searchContentStart`

Those names would leak page-specific or feature-specific assumptions into the
cassette model.

## Where The Hint Should Live

The hint should live on the inert cassette payload contract, most likely
`SidebarCassettePayload` or `InertSidebarCassettePayload`.

It should not live in:

- widget builders
- `SidebarCassetteCard`
- feature views
- X-column page code

Payloads already carry semantic role, top spacing, and semantic style. A layout
anchor hint belongs beside those fields.

## Search Prototype Mapping

For Search All Messages:

1. Top menu cassette remains the panel identity cassette.
2. Search orientation/info cassette remains non-content-start middle content.
3. Heatmap cassette marks itself as `preferredContentStart`.
4. Sidebar stack inserts spacer before the heatmap.
5. The heatmap begins at the shared content-start anchor.

This tests the seam against a real chain:

```text
top selector
short info text
heatmap
guidance/footer
```

## Dynamic Height Risk

The tempting future behavior is to ask whether middle-zone cassettes fit before
the content-start seam. That is useful, but risky.

Risks:

- Flutter child height is not generally known before layout.
- Post-frame measurement can create visible jumps.
- Rebuild-triggered measurement can become imperative repair logic.
- Async cassette loading can change heights after the seam decision.
- Dynamic type and localization can change text height.
- Scrollable/expanding cassettes have contextual height behavior.

Therefore the first implementation should be semantic, not measurement-driven.

## Future Measurement Strategy

If autonomous fitting becomes necessary, prefer constrained layout over
post-frame repair:

- cassettes that opt into the middle zone may expose compact variants
- middle-zone text may use explicit max lines
- overflow may move to lower guidance areas
- the layout coordinator may use known/declared preferred heights rather than
  measuring arbitrary widgets

Any measurement-based implementation should be treated as a separate design
phase.

## Architectural Guardrail

When the layout looks wrong, fix the seam contract, cassette semantics, or page
anchor derivation. Do not add imperative repair calls or one-off padding inside
feature widgets.

