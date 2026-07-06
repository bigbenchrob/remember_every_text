# X-Column Layout

This folder documents the cross-column layout grammar emerging from the
MessageLens UI walk.

The immediate trigger is the Search page, but the intent is broader: major
MessageLens lenses should share a stable page skeleton so new surfaces snap
into a common visual rhythm instead of inventing their own vertical hierarchy.

## Core Principle

The page owns the layout.

Components own their presentation.

Components must adapt to the space assigned by the page skeleton. They should
not determine the vertical positioning of peer content across panels.

## Problem

The three Search page panels currently drift because each column lays itself
out according to its own content height.

This is fragile. For example, Conversation Cards may contain timeline glyphs
with different heights or metadata density. If a Conversation Card grows, it
should not push the excerpt description or message content out of alignment
with the Messages panel.

The solution is not more widget nudging. The solution is a stable page
skeleton.

## Page Skeleton

Each primary MessageLens page should be organized into vertical bands:

### Band 1: Panel Title / Lens Identity

Examples:

- `Search all messages`
- `All messages`
- `Conversation`

The title names the lens or panel. It should not narrate how the user arrived
there.

### Band 2: Primary Object / Primary Mode Information

Examples:

- Left: compact heatmap orientation or search mode context.
- Center: result date range and hit count.
- Right: Conversation Card.

This band answers: what object, mode, or evidence universe is currently being
inspected?

### Band 3: Secondary Scope / Controls

Examples:

- Left: secondary guidance, if needed.
- Center: search input and AND/OR controls.
- Right: `21-message excerpt centered on the chosen message`.

This band explains scope, controls, or the relationship between the primary
object and the content below.

### Band 4: Content

Examples:

- Left: heatmap/navigation.
- Center: message results.
- Right: conversation excerpt messages.

The beginning of Band 4 should align across peer panels.

## Band Ownership

Band heights are owned by the page skeleton, not by arbitrary widget content.

If a component is too tall for its assigned band, the component should adapt:

- reduce internal spacing
- use compact mode
- constrain glyph height
- truncate or scale appropriately
- defer secondary details to another area

It should not push lower bands out of alignment.

## Left Sidebar Guidance

The left sidebar serves a different function from the center and right panels,
but it should still fit into the same skeleton.

For the Search page:

- Keep a short orientation statement visible in Band 2.
- Place extended usage guidance in a secondary/post-content guidance area.
- Do not hide guidance behind a disclosure unless necessary.
- Ensure the heatmap begins in the shared Band 4 content region.

The orientation statement tells the user what the heatmap represents. The
post-content guidance tells the user how the heatmap connects to the Messages
column and search controls.

## Conversation Card Constraint

Conversation Cards may vary in glyph size or metadata density.

Inside the page skeleton, a Conversation Card must fit inside Band 2 without
causing Band 3 or Band 4 to move.

If necessary, provide a compact/read-only Conversation Card manifestation for
cross-column context panels.

## Proposed Search Page Structure

The Search page should resolve into:

| Band | Search Panel | Messages Panel | Conversation Panel |
| --- | --- | --- | --- |
| 1 | Search all messages | All messages | Conversation |
| 2 | Heatmap scope/orientation | Date range + hit count | Conversation Card |
| 3 | Secondary guidance or mode context | Search field + AND/OR | Excerpt description |
| 4 | Heatmap/navigation | Search results | Conversation excerpt |

The page skeleton should own the vertical positions of these bands. The panel
contents should render inside the assigned band.

## Implementation Plan

Before broad code changes, inspect the Search page and identify the current
owners of each panel:

- left Search sidebar cassettes
- center Message Evidence header and timeline
- right Search-result Conversation excerpt sidebar

Then implement in small steps:

1. Define reusable band constants or a lightweight page skeleton primitive.
2. Apply it first to the Search page only.
3. Constrain the right Conversation Card to Band 2.
4. Move the left heatmap into the shared Band 4 content start.
5. Keep extended guidance available but below or outside the primary band flow.
6. Verify that changing Conversation Card glyph density does not move Band 4.
7. Document any component compact modes introduced for this skeleton.

Avoid a broad app-shell redesign. This is a reusable layout grammar, not a new
navigation system.

## Acceptance Criteria

- The three panel titles align on a shared visual baseline.
- The primary object/mode band aligns across the three panels.
- The secondary control/scope band aligns across the three panels.
- The content band begins at approximately the same vertical position in all
  three panels.
- Components adapt to assigned bands rather than pushing lower bands downward.
- The Search page feels like three coordinated lenses onto one graph, not a
  sidebar plus a main view plus another sidebar.

## Design Philosophy

This is not a Search-only tweak.

This should become the layout grammar of MessageLens:

Panel title
-> primary object/mode
-> secondary scope/controls
-> evidence/content

The goal is a stable architectural grid, not a visually patched screenshot.
