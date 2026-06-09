---
tier: project
scope: center-panel-layout
owner: @rob
last_reviewed: 2026-04-26
source_of_truth: doc
links:
  - ./README.md
  - ../05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md
  - ../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md
tests: []
---

# Center Panel Control Panels And Infographics

This document captures the current design principles for report-like center panels in MessageLens.

The immediate reference case is Message History Coverage, but these rules are intended to generalize to future audit panels, attachment coverage reports, migration summaries, and other evidence-driven center-panel surfaces.

## Core idea

The center panel is not a pile of unrelated cards.

It should read as a single explained surface:

- first establish status
- then show accounting or evidence
- then show supporting comparisons
- then show exceptions or special cases
- then end with notes or caveats

The user should feel guided through one argument, not asked to inspect a dashboard of disconnected widgets.

## Primary goals

1. Make state legible at a glance.
2. Preserve trust by showing how MessageLens arrived at the conclusion.
3. Avoid dead space, orphan cards, and ambiguous hierarchy.
4. Keep dense technical content readable without flattening everything into one text block.

## Structural rules

### 1. Width is owned by the row, not the panel

A panel should render its content.

A row should decide whether that content is:

- full width
- compact full width
- paired in two columns
- paired in two columns with equal height

Do not let individual panels declare themselves half-width or full-width independently.

This prevents accidental orphan cards, ragged empty space, and layout drift between reports.

### 2. Rows should be explicit, not implied by styling

Center-panel report surfaces should declare a row model up front.

Good:

- hero row
- accounting row
- paired evidence row
- exception row
- notes row

Bad:

- a long `Column` where each panel quietly picks its own width
- ad hoc `Row` decisions inside feature widgets without a shared layout contract

### 3. A two-column row must be complete

If a row is defined as two-column, it must contain exactly two children.

Do not allow:

- a single half-width card sitting alone
- reserved empty space beside a lone card
- hidden or absent second children that collapse meaningfully different sections into a broken row

### 4. Equal-height pairing is a first-class layout mode

Some paired evidence looks visually broken if one card is much taller than the other.

When two cards are being compared or jointly read, use an equal-height row mode.

Typical examples:

- reconciliation + timeline coverage
- before + after
- count summary + visual evidence

### 5. Compact rows are for secondary material only

Compact full-width rows are appropriate for:

- notes
- caveats
- generated-at metadata
- secondary explanations

Do not use compact styling for the primary status or main evidence rows.

## Visual hierarchy guidance

### Hero row

Use the first row to answer the main user question immediately.

Typical contents:

- report title
- status badge
- primary headline
- one-sentence conclusion
- generated-at label if useful

The hero should feel conclusive, not busy.

### Evidence and accounting rows

The next rows should explain why the headline is true.

Use full-width sections for:

- accounting bars
- segmented totals
- summary visuals
- anything that benefits from uninterrupted horizontal space

### Paired supporting rows

Two-column rows work best when the user benefits from reading two related pieces of evidence together.

Examples:

- numerical reconciliation beside timeline coverage
- summary counts beside a date span
- before/after comparisons

The two panels should feel like peers in one thought, not two unrelated topics forced into the same row.

### Exception and caveat rows

Recovered messages, anomalies, edge cases, and notes usually belong later in the report.

That ordering keeps the report feeling stable:

- conclusion first
- evidence second
- caveats after the user understands the main outcome

## Density rules

### Keep technical rows denser than explanatory rows

Dense rows are acceptable when the content is ledger-like.

Examples:

- count comparisons
- metric tables
- reconciliation lists

But density should be deliberate. Use slightly tighter vertical spacing for technical metrics while keeping prose rows more open.

### Avoid uniform card rhythm when meaning differs

If every row has the same spacing, the same weight, and the same internal rhythm, the report becomes visually flat.

Use subtle variation:

- hero rows can breathe more
- metric rows can tighten slightly
- notes can be compact

The goal is hierarchy, not novelty.

## Infographic principles

An infographic-like center panel should still behave like a document.

That means:

- one dominant takeaway
- one or two strong supporting visuals
- supporting metrics grouped by concept
- short prose that interprets the data

It should not become a BI dashboard with many equally loud boxes competing for attention.

### Good infographic behavior

- the user can explain the main result after a quick glance
- the visuals reinforce the text rather than duplicating it awkwardly
- counts, status, and caveats agree semantically

### Bad infographic behavior

- multiple cards compete for “most important” status
- cards vary in width without compositional reason
- the user must infer reading order from trial and error
- empty horizontal gutters suggest a missing panel

## Relationship to theming and navigation

This folder does not define color tokens or typography tokens. Those belong in `../05-COLOR-AND-TYPOGRAPHY-THEMING/`.

This folder also does not define how center panels are routed. ViewSpec ownership and coordinator routing belong in `../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md`.

This folder answers a narrower question:

How should a center-panel report be composed once the app has decided to show it?

## Baseline pattern for report surfaces

When a center-panel feature is report-like, start from this pattern:

1. Full-width hero/status row
2. Full-width accounting or summary-visual row
3. Two-column or two-column-equal-height evidence row
4. Full-width exception or special-case row
5. Compact full-width notes row

Do not treat this as a strict template for every feature, but it is the default shape the feature should justify deviating from.

## Message History Coverage as the current reference

Message History Coverage currently illustrates this pattern well:

1. Full-width hero/status row
2. Full-width message accounting row
3. Equal-height two-column reconciliation + timeline row
4. Full-width recovered messages row
5. Compact full-width notes row

This report should be treated as the first reference implementation for future center-panel report surfaces.

## Future expansion

Likely follow-on docs for this section:

- compact metadata rows
- embedded charts and legends
- empty-state report behavior
- alert and warning panels
- cross-references to sidebar layout rules in `../08-SIDEBAR-LAYOUTS/`
