# X-Column Layout

This folder documents the cross-column layout grammar emerging from the
MessageLens UI walk.

> Current canonical mechanics live in
> `../../09-CROSS-COLUMN-LAYOUT/`. This folder preserves the UI-walk history,
> rationale, and ownership repairs that led to the durable cross-column layout
> contract.

The immediate trigger is the Search page, but the intent is broader: major
MessageLens lenses should share a stable page skeleton so new surfaces snap
into a common visual rhythm instead of inventing their own vertical hierarchy.

## Core Principle

The page owns the layout.

Components own their presentation.

Components must adapt to the space assigned by the page skeleton. They should
not determine the vertical positioning of peer content across panels.

The page skeleton establishes the application's visual grammar. Individual
panels do not invent their own vertical hierarchy; they express the shared
grammar using content appropriate to their lens.

## Problem

The three Search page panels currently drift because each column lays itself
out according to its own content height.

This is fragile. For example, Conversation Cards may contain timeline glyphs
with different heights or metadata density. If a Conversation Card grows, it
should not push the excerpt description or message content out of alignment
with the Messages panel.

The solution is not more widget nudging. The solution is a stable page
skeleton.

This layout work also exposed a Conversation ownership issue. The right panel
is a Conversation workspace, not a Search-owned context widget. See:

- `CONVERSATION_OWNERSHIP_AUDIT.md`
- `CONVERSATION_OWNERSHIP_REPAIR.md`

## Current Page Skeleton

The current implementation direction is deliberately simpler than the original
four-band model.

The page owns two shared vertical envelopes:

1. title band
2. context band

Content starts immediately after the context band.

This preserves the important cross-column rhythm without forcing every panel
to subdivide its internal header content identically.

### Title Band

Examples:

- Left: `Search all messages` selector.
- Center: `All messages`.
- Right: `Conversation`.

The title names the lens or panel. It should not narrate how the user arrived
there.

### Context Band

Examples:

- Left: compact orientation or cassette material above primary sidebar
  content.
- Center: result metadata and search controls.
- Right: Conversation Card and excerpt description.

The context band is elastic in meaning but fixed in outer height for
participating columns. Children may arrange themselves inside the band. They
must not push content start downward.

### Content Start

Examples:

- Left: heatmap/navigation or the cassette selected as the sidebar content
  start.
- Center: message results.
- Right: conversation excerpt messages.

The beginning of content should align across peer panels.

## Band Ownership

Band heights are owned by the page skeleton, not by arbitrary widget content.

If a component is too tall for its assigned band, the component should adapt:

- reduce internal spacing
- use compact mode
- constrain glyph height
- truncate or scale appropriately
- defer secondary details to another area

It should not push lower bands out of alignment.

## Sidebar Cassette Seam

The sidebar cassette system remains responsible for cassette chaining and
flexible sidebar layout. X-column layout must not rewrite the cassette system
or hard-code widget-specific rules such as "the heatmap starts here."

Instead, participating sidebar surfaces use a content-start seam:

- The top menu/selector is wrapped in the title band.
- The next pre-content cassette or orientation material may occupy the middle
  context band.
- The primary navigation/evidence cassette begins after the context band.
- Future cassette specs may declare preferred content-start candidacy when the
  autonomous seam needs to handle more configurations.

For the Search page, the heatmap/navigation cassette is the current content
start. The orientation text sits above it in the context band, and task guidance
may sit below the heatmap as post-content guidance.

The important invariant is not "the heatmap aligns." The invariant is that the
sidebar exposes a content-start seam that can align with peer panel content
without surrendering cassette ownership.

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
| Title band | Search all messages | All messages | Conversation |
| Context band | Heatmap scope/orientation | Date range, hit count, search controls | Conversation Card, excerpt description |
| Content start | Heatmap/navigation | Search results | Conversation excerpt |

The page skeleton should own the vertical positions of these bands. The panel
contents should render inside the assigned band.

## Implementation Plan

Before broad code changes, inspect the Search page and identify the current
owners of each panel:

- left Search sidebar cassettes
- center Message Evidence header and timeline
- right Search-result Conversation excerpt sidebar

Then implement in small steps:

1. Define reusable band constants or lightweight band wrapper primitives.
2. Apply it first to the Search page only.
3. Constrain the right Conversation Card to Band 2.
4. Move the left heatmap into the shared Band 4 content start.
5. Keep extended guidance available but below or outside the primary band flow.
6. Verify that changing Conversation Card glyph density does not move Band 4.
7. Document any component compact modes introduced for this skeleton.

Avoid a broad app-shell redesign. This is a reusable layout grammar, not a new
navigation system.

## Current Implementation Primitives

The current shared primitives are:

- `lib/config/theme/widgets/layout/vertical_column_bands.dart`
- `lib/config/theme/widgets/layout/app_panel_bands.dart`

`TitleColumnBand` and `ContextColumnBand` are the current diagnostic wrappers for
the simplified two-envelope model. They own the fixed outer dimensions and
optional developer-mode margin visualization. Children own their internal
presentation and may use explicit child placement only when the default is not
enough.

`AppPanelBandHeader` and related `app_panel_bands.dart` types are retained as
older support primitives during the transition. Prefer the top/context band
wrappers for new X-column layout work unless the existing code path already
requires the older primitive.

The center Message Evidence header and the right Conversation excerpt panel
both participate in this skeleton. The left Search sidebar remains
cassette-driven, but its content should expose the same conceptual seam:
selector, middle orientation/context, and content-start cassette.

## Acceptance Criteria

- The three panel identities align on a shared visual baseline.
- The title band is fixed and shared for participating columns.
- The context band is fixed and shared for participating columns.
- Content begins immediately after the context band in all participating
  columns.
- Components adapt to assigned bands rather than pushing lower bands downward.
- The Search page feels like three coordinated lenses onto one graph, not a
  sidebar plus a main view plus another sidebar.
- Users perceive the three panels as coordinated peer workspaces presenting
  different lenses onto the same underlying graph.

## Design Philosophy

This is not a Search-only tweak.

This should become the layout grammar of MessageLens:

Panel title
-> primary object/mode
-> secondary scope/controls
-> evidence/content

The goal is a stable architectural grid, not a visually patched screenshot.
