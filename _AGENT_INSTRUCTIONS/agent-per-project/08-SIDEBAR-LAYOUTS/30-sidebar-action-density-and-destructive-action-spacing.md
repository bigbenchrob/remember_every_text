---
tier: project
scope: sidebar-action-density
owner: @rob
last_reviewed: 2026-04-26
source_of_truth: doc
links:
  - ./README.md
  - ./00-sidebar-cassettes-controls-and-info-cards.md
  - ./20-navigation-row-emphasis-rules.md
  - ../05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md
  - ../42-SPEC-SYSTEM/REFERENCE/55-EPHEMERAL-SPEC-HANDLING/00-ephemeral-spec-handling-architecture.md
tests: []
---

# Sidebar Action Density And Destructive-Action Spacing

This document captures how sidebar actions should be grouped, spaced, and emphasized, especially when ordinary actions and destructive actions appear in the same branch.

The goal is to make action-heavy sidebars feel orderly and safe rather than cramped or alarming.

## Core idea

Action density should feel authored.

Ordinary actions should remain easy to scan.

Destructive actions should be explicit and separated enough to prevent accidental visual blending with routine actions.

The user should be able to tell:

- what is a normal next step
- what is a high-risk or irreversible action
- what belongs together as one action cluster

## Primary goals

1. Keep action groups compact without becoming visually crowded.
2. Preserve a clear distinction between ordinary and destructive actions.
3. Prevent destructive actions from feeling hidden or casually adjacent to safe actions.
4. Make sidebar action clusters easy to scan and hard to misread.

## Density principles

### 1. Keep related actions close enough to read as a set

Actions that are peers within the same task should be close enough to scan together.

Examples:

- adjacent mode choices
- a small cluster of related troubleshooting actions
- primary and secondary actions that work on the same branch context

If related actions are spaced too far apart, the sidebar loses rhythm and the user stops reading them as one decision surface.

### 2. Do not compress unrelated actions into one visual block

Actions that differ in purpose or risk should not be packed so tightly that they look equivalent.

Examples of meaningful separation:

- non-destructive support actions versus reset actions
- branch navigation versus maintenance actions
- ordinary branch adjustments versus irreversible recovery steps

Density should help grouping, not erase it.

### 3. Destructive actions need spatial separation, not just color treatment

Color alone is not enough.

Destructive actions should usually have at least one additional separator from ordinary actions:

- extra vertical gap
- separate card or row group
- explanatory warning block before confirmation

If a destructive action sits immediately adjacent to routine actions with only a color change, the sidebar is too easy to misread.

### 4. Explanatory text should not be packed into dense action groups

If a branch needs explanation around an action, let the prose breathe rather than stuffing it into the same tight action cluster.

Dense action groups are good for choosing among actions. They are poor containers for warning prose.

### 5. High-frequency actions may be denser than low-frequency recovery actions

Actions the user may use repeatedly can sit in a tighter rhythm when they belong to one stable cluster.

Rare or risky actions should usually get more separation and more explicit framing.

## Grouping rules

### Ordinary action group

Use when actions are routine, reversible, or low-risk.

Typical examples:

- send logs
- open a report
- switch scope
- change display mode

These can live in a compact group if they belong to the same branch task.

### Mixed-risk group

If one action is destructive and the others are not, the destructive action should not read as just another peer in the same dense list.

Preferred patterns:

- ordinary actions first, destructive action later with visible separation
- ordinary actions in one card, destructive action in another
- warning or confirmation step before destructive execution

### Destructive action group

If the whole surface is about a dangerous maintenance flow, then the branch can be action-dense around that one task.

Even then, the sidebar should make the action sequence feel deliberate rather than casual.

## Spacing guidance

### Tight spacing is appropriate for:

- equivalent navigation choices
- sibling low-risk actions
- short control clusters that the user will compare directly

### Moderate separation is appropriate for:

- switching from informational content into actions
- moving from primary action to secondary support actions
- distinguishing action groups with different semantic purpose

### Stronger separation is appropriate for:

- destructive or irreversible actions
- reset, wipe, or maintenance actions
- actions that can materially change user data or app state

## Destructive-action principles

### 1. Destructive actions should be explicit, not ambient

The user should notice that the action is destructive before they interact with it, not only after they click.

### 2. Destructive actions should not be the first thing the user encounters unless the branch is specifically about recovery or reset

Ordinary troubleshooting or support actions should generally appear before destructive recovery actions.

This keeps the sidebar from implying that reset is the default next step.

### 3. Destructive actions should be visually distinct but still belong to the branch

They should not look hidden, but they also should not visually dominate unrelated branch content.

The ideal result is:

- obvious enough to find
- separate enough to respect risk
- contained enough to preserve the branch hierarchy

### 4. Confirmation flows deserve their own breathing room

If a destructive action opens an ephemeral confirmation flow, that flow should not inherit the same compact rhythm as ordinary menu rows.

Confirmation content should feel slower, clearer, and more deliberate.

## Current practical examples

The Settings sidebar is the most useful current reference:

- `Send logs…` is a non-destructive troubleshooting action
- `Reset message data…` is the destructive recovery action

The compositional lesson is:

- keep the support action easy to find
- keep the reset action explicit and secondary
- do not make the destructive path feel like the default troubleshooting answer

## Anti-patterns

Avoid these:

- placing a destructive action immediately under a routine action with no separation
- using a dense cluster where one row quietly does much more damage than its neighbors
- using only red text to communicate risk while keeping identical spacing and hierarchy
- surrounding a destructive action with so much warning prose that the sidebar becomes a wall of text
- making ordinary support actions feel less prominent than the destructive fallback

## Relationship to other docs

This document builds on:

- `00-sidebar-cassettes-controls-and-info-cards.md` for general sidebar composition
- `20-navigation-row-emphasis-rules.md` for interactive emphasis versus passive context

It does not define ephemeral action mechanics, confirmation state, or payload transport. Those belong in the ephemeral and sidebar architecture docs.

This doc answers a narrower question:

When a sidebar contains several actions, especially a mix of safe and destructive ones, how dense should the action cluster be and how much spacing should separate riskier actions?

## Future expansion

Likely follow-on docs for this section:

- info-card typography and supplemental content rules in `40-info-card-typography-and-supplemental-content.md`
- confirmation-flow pacing inside ephemeral sidebar branches
- examples of safe default ordering for mixed-risk settings actions
