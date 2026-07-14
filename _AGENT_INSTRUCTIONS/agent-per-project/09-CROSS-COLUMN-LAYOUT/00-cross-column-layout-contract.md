---
tier: project
scope: cross-column-layout-contract
owner: agent-per-project
last_reviewed: 2026-07-14
source_of_truth: doc
links:
  - ./README.md
  - ./01-column-band-wrappers.md
  - ./02-sidebar-cassette-content-start-seam.md
tests: []
---

# Cross-Column Layout Contract

MessageLens pages often present several peer workspaces at once:

```text
left sidebar / navigation lens
center evidence or record lens
right contextual lens
```

The user should perceive these as coordinated views onto the same underlying
graph, not as independently stacked columns.

## Contract

Participating columns share two fixed vertical envelopes:

1. **Title band**
2. **Context band**

Primary content begins immediately after the context band.

The important invariant is not that every element inside the context band lines
up. The important invariant is that the page establishes common top and content
content-start positions across peer columns.

## Title Band

The title band identifies the panel or lens.

Examples:

- Left: `Search all messages` selector
- Center: `All messages`
- Right: `Conversation`

The title names the lens or panel. It should not narrate how the user arrived
there.

## Context Band

The context band contains pre-content context, scope, controls, or the primary
object summary for that panel.

Examples:

- Left: short orientation text or one pre-content sidebar cassette
- Center: result metadata and search controls
- Right: Conversation Card and excerpt description

This band is fixed in outer height for participating columns, but elastic in
meaning. Children may arrange themselves internally. They must not push the
primary content start downward.

## Content Start

Primary content begins directly below the context band.

Examples:

- Left: heatmap/navigation or the cassette selected as sidebar content start
- Center: message results
- Right: conversation excerpt messages

The content-start alignment is the main perceptual win. It lets the user scan
across the page and understand that the panels are peers.

## Ownership

The page owns:

- the fixed outer height of the title band
- the fixed outer height of the context band
- the content-start y-position
- optional developer diagnostics showing band boundaries

Components own:

- wording
- typography
- internal vertical placement inside their assigned band
- compact/truncated/adaptive presentation when content approaches overflow

Components do not own:

- panel-level top padding outside the band wrappers
- ad hoc spacer stacks that move primary content down
- repair logic that tries to align with peer panels after layout

## What To Do When Alignment Looks Wrong

Fix one of:

- band wrapper defaults
- internal child placement inside a band
- sidebar content-start seam semantics
- component compact-mode behavior

Do not add one-off top padding outside the bands.

Do not make a feature widget know about sibling columns.

Do not solve alignment with post-frame measurement or imperative repair unless
there is a separate design decision approving that risk.

## Current Heights

As of this review, the shared wrapper defaults are:

- `TitleColumnBand.height`: `72`
- `ContextColumnBand.height`: `166`

These are layout rhythm values, not business meaning. If they change, update
this document and the wrapper documentation together.
