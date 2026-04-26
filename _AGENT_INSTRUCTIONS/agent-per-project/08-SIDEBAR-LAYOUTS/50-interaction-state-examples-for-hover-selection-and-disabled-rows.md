---
tier: project
scope: sidebar-interaction-states
owner: @rob
last_reviewed: 2026-04-26
source_of_truth: doc
links:
  - ./README.md
  - ./20-navigation-row-emphasis-rules.md
  - ./40-info-card-typography-and-supplemental-content.md
  - ../05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md
tests: []
---

# Interaction-State Examples For Hover, Selection, And Disabled Rows

This document captures how sidebar rows should behave visually when hovered, selected, inactive, or disabled.

The goal is to make state changes legible without destabilizing the overall branch composition.

## Core idea

The sidebar should feel calm at rest and clear in motion.

Hover, selection, and disabled states should help the user understand what they can do, what is currently active, and what is temporarily unavailable.

These states should be obvious enough to read quickly, but not so loud that the whole sidebar flickers into noise.

## Primary goals

1. Make state changes visible at a glance.
2. Keep selection unmistakable in dense branches.
3. Let hover feel responsive without overpowering selection.
4. Make disabled rows understandable rather than broken-looking.

## State hierarchy

The basic interaction hierarchy should usually be:

1. selected
2. hovered actionable row
3. idle actionable row
4. passive context or explanatory row
5. disabled row

That order can vary slightly by feature, but selection should generally remain stronger than hover, and disabled should never look more active than idle.

## Hover guidance

### Hover on actionable rows

Hover should confirm interactivity.

It should usually feel like:

- a mild surface lift
- a modest increase in contrast
- clearer affordance around disclosure or selection

Hover should not feel like a second selected state.

### Hover on already selected rows

If a row is already selected, hover should reinforce that selection lightly rather than replacing it.

The user should still read the row first as selected, second as hovered.

### Hover on passive rows

Passive context cards and explanatory cards should usually have little or no hover treatment.

If a passive card reacts as strongly as an actionable row, the sidebar starts to miscommunicate interactivity.

## Selection guidance

### Selected state must be unmistakable

Selection should remain obvious in a grayscale reading and in a dense stack.

Users should not have to infer selection from subtle color drift alone.

### Selection should express ownership of the branch

When a selected row determines what the rest of the branch means, that selected state should feel stable and central.

The row should read as the current answer, not as a transient hover effect.

### Only rows that represent persistent or meaningful current state should look selected

Do not visually persist selection on rows that are really one-shot actions.

If a row behaves like a button, it should usually return to an unselected resting state after the action completes.

## Disabled guidance

### Disabled should read as unavailable, not invisible

Users should still be able to perceive the row and understand its intended role.

The disabled treatment should communicate:

- this exists
- it is not available right now
- the sidebar is not broken

### Disabled should be quieter than idle

Disabled rows should lose interaction energy, but not enough readability to become cryptic.

Avoid treatments that make labels too faint to parse in a narrow sidebar.

### Disabled explanation may need nearby support

If a disabled row matters to the user, consider pairing it with short contextual explanation rather than relying on opacity alone.

Opacity can say “not now,” but it rarely explains why.

## Example role patterns

### Actionable navigation row

Idle:

- clear label
- visible disclosure or row affordance
- moderate contrast

Hover:

- stronger surface response
- slightly clearer action affordance

Selected:

- strongest state in the branch
- stable and unmistakable

Disabled:

- reduced energy
- still readable

### Context cassette

Idle:

- calm and stable
- title and body lead

Hover:

- minimal or none unless it contains a supporting action

Selected:

- usually not applicable

Disabled:

- rare; if used, explain why the context is temporarily unavailable

### Explanatory info card

Idle:

- readable, lightweight, subordinate to navigation

Hover:

- none or very minimal

Selected:

- usually not applicable

Disabled:

- generally avoid; explanation should usually remain readable even when nearby actions are disabled

## Interaction transitions

### Hover should feel quick and light

Hover is a momentary cue, not a mode switch.

Its transition should feel responsive and low drama.

### Selection should feel more stable than hover

Selection can transition in, but once present it should visually settle and hold the branch together.

### Disabled changes should feel intentional

When a row becomes disabled because context changes, the resulting state should look deliberate rather than like a rendering glitch.

## Anti-patterns

Avoid these:

- hover treatment stronger than selected state
- passive cards reacting like actionable rows
- selected state so subtle it disappears beside hover
- disabled rows faded so far they become unreadable
- multiple row families using inconsistent state logic without semantic reason

## Relationship to other docs

This document builds on:

- `20-navigation-row-emphasis-rules.md` for role-level action emphasis
- `40-info-card-typography-and-supplemental-content.md` for passive explanatory cards
- `../05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md` for token-level luminance and contrast guidance

This doc answers a narrower question:

Once the row roles are defined, how should hover, selection, and disabled states behave visually so the sidebar remains legible and calm?

## Current reference candidates

Useful current reference cases:

- top-menu and settings-menu rows with durable selection
- action rows that fire without persisting selected state
- explanatory cards that should remain visually quiet under pointer movement

## Future expansion

Likely follow-on docs for this section:

- examples of state behavior for mixed action-plus-context rows
- compact control clusters with selected sub-items
- disabled-state explanation patterns for gated settings or unavailable actions
