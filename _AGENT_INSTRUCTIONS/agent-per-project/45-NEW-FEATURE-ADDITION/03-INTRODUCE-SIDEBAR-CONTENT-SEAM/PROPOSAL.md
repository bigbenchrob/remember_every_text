---
tier: project
scope: feature-proposal
owner: agent-per-project
last_reviewed: 2026-07-07
source_of_truth: draft
status: proposed
---

# Introduce Sidebar Content Seam

## Purpose

Introduce a small layout seam that lets the sidebar cassette system align its
primary content with peer X-column content regions without giving up cassette
ownership, cassette chaining, or flexible sidebar behavior.

The goal is not to make the X-column page skeleton understand specific sidebar
widgets such as heatmaps. The goal is to let the sidebar expose a semantic
content-start point that the page skeleton can align with the center and right
panel content starts.

## Problem

The X-column layout work needs a stable content-start anchor across peer panels:

- left sidebar primary content
- center message evidence content
- right conversation excerpt content

The existing sidebar cassette system already solves a different problem:
assembling flexible, chained sidebar content from feature-owned cassette specs.

If the page skeleton directly imposes widget-specific rules such as "the
heatmap starts here", it violates the cassette system's ownership. If the
sidebar ignores the X-column anchors, the three panels drift visually and no
shared layout grammar emerges.

## Proposed Direction

Keep the cassette system in charge of sidebar composition, but add an explicit
content-start seam.

The page skeleton owns two vertical anchors:

1. **Panel identity anchor**
   - Left: top selector / menu cassette
   - Center: panel title
   - Right: panel title

2. **Content-start anchor**
   - Left: first semantic sidebar content-start cassette
   - Center: message evidence list
   - Right: conversation excerpt list

Sidebar cassettes may declare themselves as preferred content-start candidates.
The sidebar layout coordinator then inserts a spacer before the first such
cassette so that it begins at the shared content-start anchor. Normal cassette
layout continues below it.

## Conservative First Slice

The first slice intentionally avoids pre-measuring cassette heights.

For the Search All Messages sidebar:

- top menu remains the identity-row cassette
- short explanatory info remains before the primary content
- heatmap cassette declares itself as the content-start candidate
- sidebar inserts a spacer before the heatmap so the heatmap begins at the
  shared content-start anchor

This will make overflow or excessive middle-zone content obvious. It will not
attempt to solve autonomous snapping yet.

## Deferred Autonomous Behavior

The richer future behavior would let the cassette layout coordinator decide
whether earlier cassettes fit in the middle zone:

- if a non-content-start cassette fits, render it before the seam
- if it does not fit, promote it to content start or otherwise adapt the chain
- if no explicit candidate exists, the first cassette that cannot fit becomes
  the practical content start

That requires a careful height strategy. Flutter widget measurement can easily
lead to jitter, post-frame repair loops, and imperative layout patches, so this
behavior is explicitly deferred.

## Ownership Rules

- The X-column skeleton owns cross-column anchors.
- The sidebar cassette system owns cassette chain semantics and sidebar layout.
- Feature cassettes may declare semantic layout hints.
- Individual cassette widgets must not know about peer panels.
- The page skeleton must not hard-code sidebar widget identities.

## Non-Goals

- Do not rewrite the cassette system.
- Do not introduce measurement-driven layout repair in the first slice.
- Do not create Search-specific sidebar layout logic.
- Do not require every sidebar mode to adopt the seam immediately.
- Do not redesign the Search page visual treatment as part of the seam work.

## Open Questions

- Should the content-start hint be named `preferredContentStart`,
  `contentStartCandidate`, or another term?
- Should the first implementation treat only explicit candidates as seams, or
  also infer from existing semantic styles such as `visualization`?
- What should happen if pre-seam content is visibly too tall before autonomous
  measurement exists?

