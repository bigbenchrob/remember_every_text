---
tier: project
scope: sidebar-navigation-emphasis
owner: @rob
last_reviewed: 2026-04-26
source_of_truth: doc
links:
  - ./README.md
  - ./00-sidebar-cassettes-controls-and-info-cards.md
  - ./10-pinned-controls-and-scrollable-content.md
  - ../05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md
  - ../42-SPEC-SYSTEM/REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md
tests: []
---

# Navigation Row Emphasis Rules

This document captures how actionable navigation rows should differ visually from passive context cassettes and explanatory info cards in the sidebar.

The goal is simple: the user should be able to tell what can be acted on, what is framing, and what is explanatory without reading the whole sidebar carefully.

## Core idea

Actionable rows should feel selectable.

Context cards should feel orienting.

Info cards should feel interpretive.

These three roles can coexist in one sidebar branch, but they should not share the same visual emphasis.

## Primary goals

1. Make interactivity legible at a glance.
2. Prevent passive cards from visually competing with primary actions.
3. Keep navigation rows scannable in long vertical stacks.
4. Preserve a coherent branch while still distinguishing role.

## Role distinctions

### Navigation rows

Navigation rows are for:

- choosing a branch
- drilling deeper
- selecting a filter or mode
- changing scope

They should look actionable and ready for focus, hover, and selection.

### Context cassettes

Context cassettes are for:

- showing current identity
- explaining where the user is
- summarizing the currently active branch or selection

They should feel stable and informative, not clickable by default.

### Explanatory info cards

Explanatory info cards are for:

- telling the user how to interpret something
- clarifying a caveat
- giving brief supporting prose

They should feel readable and lightweight, not like hidden actions.

## Emphasis rules

### 1. Navigation rows should carry the clearest interaction signal

If the user can click, select, expand, or drill in, the row should visually advertise that.

Signals may include:

- stronger hover response
- clearer selected state
- visible disclosure affordance
- firmer contrast between idle and active states

The exact token choices belong to theming, but the compositional rule is fixed:

actionable rows should look more interactive than passive cards.

### 2. Context cassettes should lead through clarity, not action weight

Context cassettes often sit near the top of a branch and therefore already have positional importance.

They do not need the same action emphasis as navigation rows.

Good context emphasis usually comes from:

- stable card chrome
- strong title or identity treatment
- calm, readable spacing

Not from making the card feel like a button.

### 3. Info cards should be visually quieter than navigation rows

Info cards can be prominent enough to be readable, but they should not challenge the action hierarchy.

If an info card and a navigation row feel equally loud, the user has to stop and infer which one is interactive.

That creates avoidable friction.

### 4. Selected navigation state should be unmistakable

When a row expresses the currently selected branch, scope, or item, that state should remain obvious even in a dense sidebar.

If selection is subtle enough to be confused with passive context styling, the branch becomes harder to parse.

### 5. Do not overload one row with multiple visual messages

Avoid rows that try to be all of the following at once:

- identity summary
- primary action
- explanatory prose
- destructive warning

If the row is doing too many jobs, split the meaning across separate cassettes or rows.

## Practical hierarchy guidance

### Most emphasized

Use the strongest emphasis for:

- the currently selected navigation row
- the primary actionable row in a navigation stack
- rows that change branch or scope meaning

### Medium emphasis

Use medium emphasis for:

- inactive but selectable navigation rows
- secondary actions within the same branch
- controls that matter but do not define the whole branch

### Lower emphasis

Use lower emphasis for:

- passive context cards
- short explanatory cards
- caveats and supporting notes

Lower emphasis should not mean hard to read. It means not competing with navigation.

## Composition guidance

### Navigation stack with context

When a context cassette sits above navigation rows:

- the context cassette should establish the branch calmly
- the rows below should carry the action energy

This makes the branch feel understandable first, actionable second.

### Mixed controls and explanation

If navigation rows and explanation cards appear in the same branch, keep the explanatory card either above as framing or below as support.

Avoid placing a prose-heavy info card between several equally weighted navigation rows unless the interruption is semantically necessary.

### Destructive or high-risk actions

Destructive actions should stand out from ordinary navigation, but they should still read as actions rather than as passive warnings.

That means they need distinct emphasis without becoming the loudest element in branches where they are not the primary task.

## Anti-patterns

Avoid these:

- passive info cards that look like tappable navigation rows
- navigation rows with such weak emphasis that they resemble static labels
- several row families using identical emphasis despite different roles
- burying the selected row among equally loud explanatory chrome
- mixing long prose directly inside a primary navigation row

## Relationship to theming and architecture

This document is about layout emphasis and role clarity.

It does not define the final colors, typography tokens, or state machines.

Those belong in:

- `../05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md`
- `../42-SPEC-SYSTEM/REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md`

This doc answers a narrower question:

How should the sidebar communicate which rows are actionable, which are contextual, and which are explanatory?

## Current reference candidates

Useful current reference cases:

- top-menu and settings-menu navigation rows
- chosen-contact context cards above actionable controls
- Message History Coverage explanatory cards, which should stay readable without looking interactive

## Future expansion

Likely follow-on docs for this section:

- sidebar action density and destructive-action spacing in `30-sidebar-action-density-and-destructive-action-spacing.md`
- info-card typography and supplemental content rules in `40-info-card-typography-and-supplemental-content.md`
- interaction-state examples for hover, selection, and disabled rows in `50-interaction-state-examples-for-hover-selection-and-disabled-rows.md`
