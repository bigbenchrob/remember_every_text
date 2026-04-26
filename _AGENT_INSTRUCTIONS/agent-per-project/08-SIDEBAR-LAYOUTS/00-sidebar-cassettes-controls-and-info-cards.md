---
tier: project
scope: sidebar-layout
owner: @rob
last_reviewed: 2026-04-26
source_of_truth: doc
links:
  - ./README.md
  - ../05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md
  - ../07-CENTER-PANEL-LAYOUTS/00-center-panel-control-panels-and-infographics.md
  - ../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md
tests: []
---

# Sidebar Cassettes, Controls, And Info Cards

This document captures the current design principles for MessageLens sidebar layout.

The sidebar is a narrow, sequential surface. It should help the user understand where they are, what they can do next, and what supporting context matters right now.

It should not feel like a compressed dashboard.

## Core idea

The sidebar is a reading rail, not a collage.

That means the user should be able to scan it top to bottom and understand:

- current branch or context
- active controls
- any necessary supporting explanation
- what is primary versus secondary

The sidebar should feel guided, ordered, and narrow in purpose.

## Primary goals

1. Keep the branch legible in a narrow column.
2. Preserve strong visual hierarchy without adding clutter.
3. Make control density feel intentional rather than cramped.
4. Let explanatory cards support the branch without overwhelming it.

## Structural principles

### 1. The sidebar expresses one active branch at a time

Even when several cassettes are visible, they should read as one active branch.

Avoid compositions that make the sidebar feel like several unrelated modules stacked together.

Each cassette should clearly contribute one of these roles:

- branch context
- navigation or selection
- control surface
- supporting explanation

### 2. Context should usually come before controls

When the user needs orientation, establish context before presenting controls.

Typical good order:

- branch or identity card
- explanation or status card if needed
- controls and filters
- deeper drill-in or linked child content

This keeps controls from feeling detached from the thing they act on.

### 3. Density belongs to the cassette family, not ad hoc spacing hacks

Dense list cassettes, standard content cassettes, and control-aligned cassettes should feel like intentional layout families.

Do not create sidebar density by sprinkling custom paddings and one-off gaps around individual widgets.

The sidebar should have a small set of recognizable rhythms rather than feature-by-feature improvisation.

### 4. Section boundaries must mean something

Extra vertical spacing should primarily signal a section boundary or a meaningful conceptual break.

Within a section, rhythm should come from card chrome and cassette-level spacing, not from arbitrary stack gaps.

The practical rule is:

- section-boundary spacing belongs to the sectioning layer
- same-section rhythm belongs to payload spacing or the card itself

This prevents layout drift and preserves a consistent sidebar cadence.

### 5. Info cards should stay lightweight

Sidebar info cards work best when they explain one thing cleanly.

Good sidebar info cards usually have:

- a short title
- one to three short paragraphs
- brief bullets when needed

Avoid:

- dense wall-of-text blocks
- several equally important subtopics in one card
- footnote-like tiny text that becomes visually fuzzy in a narrow column

If explanation becomes too heavy, split it into multiple lightweight cards.

### 6. Controls should share an alignment rail

When several controls belong to one branch, they should feel aligned to the same optical lane.

That applies to:

- toggles
- menus
- drill-in rows
- reset or change actions

Users should not have to visually re-learn spacing and alignment for each cassette.

### 7. Navigation cards and info cards should not compete for emphasis

Navigation cards and action rows should feel actionable.

Info cards should feel explanatory.

If both kinds of cards use the same weight, density, and emphasis, the sidebar becomes noisy and the user loses a clear sense of what is interactive versus interpretive.

### 8. The sidebar is not the place for infographic complexity

If a surface needs broad visual comparison, large charts, or multi-part evidence, that belongs in the center panel.

The sidebar can summarize, frame, or support that content, but it should not become a shrunken analytics dashboard.

## Visual hierarchy guidance

### Top of branch

The top of the visible branch should answer either:

- where the user is
- what this branch is about
- who or what is currently selected

This is where branch identity or top-level context belongs.

### Middle of branch

The middle is for active controls, filters, navigators, and supporting cards that help the user act within the current branch.

This is usually the densest part of the sidebar and should be the most orderly.

### Lower in branch

Supporting explanation, special cases, caveats, and secondary help generally belong lower unless they are required before the user can safely act.

That keeps the sidebar from opening with a wall of explanation before the user even understands the branch.

## Composition patterns

### Navigation stack

Use when the sidebar is mainly helping the user choose a branch or drill deeper.

Typical order:

1. branch identity or context
2. selection rows or navigation cassettes
3. child detail or filters

### Control stack

Use when the sidebar is mainly adjusting the current branch.

Typical order:

1. context card
2. primary control cassette
3. secondary controls
4. brief explanatory card if needed

### Explanation stack

Use when the sidebar is supporting a center-panel report or system surface.

Typical order:

1. overview card
2. interpretation card
3. caveat or boundary-condition card

The Message History Coverage sidebar is the current reference case for this pattern.

## Density rules

### Technical controls may be slightly denser

Filter rows, toggle groups, and metric-like control lists can be tighter than prose-heavy info cards.

But density should never make tap targets or reading order ambiguous.

### Explanation needs breathing room

If the user is expected to read prose in the sidebar, the card needs enough spacing to stay scannable in a narrow column.

Shorter cards with slightly clearer separation are usually better than one large dense explanation block.

## Relationship to architecture docs

This folder does not define sidebar flow state or topology. Those belong in the sidebar cassette system docs:

- `../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md`
- `../42-SPEC-SYSTEM/REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md`

This folder answers a narrower question:

How should sidebar cassettes look and compose once the app has already decided which branch to show?

## Baseline pattern for sidebar explanation surfaces

When the sidebar is explaining a center-panel report or a stable settings surface, start from this pattern:

1. brief overview card
2. interpretation or “how to read” card
3. caveat or boundary-condition card

If a single card becomes long or conceptually mixed, split it into multiple lightweight cards rather than increasing density indefinitely.

## Current reference examples

Useful current reference cases:

- Message History Coverage three-card explanatory sidebar
- chosen-contact context plus controls stacks in the messages branch
- dense settings/action menus that rely on shared rails instead of feature-local spacing

## Future expansion

Likely follow-on docs for this section:

- navigation row emphasis rules in `20-navigation-row-emphasis-rules.md`
- pinned controls versus scrollable content in `10-pinned-controls-and-scrollable-content.md`
- sidebar action density and destructive-action spacing in `30-sidebar-action-density-and-destructive-action-spacing.md`
- info-card typography and supplemental content rules in `40-info-card-typography-and-supplemental-content.md`
