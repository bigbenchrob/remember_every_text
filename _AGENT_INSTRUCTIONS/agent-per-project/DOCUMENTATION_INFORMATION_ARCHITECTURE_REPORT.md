---
tier: project
scope: documentation-information-architecture
owner: agent-per-project
last_reviewed: 2026-07-09
source_of_truth: doc
links:
  - ./00-START-HERE.md
  - ./README.md
  - ./DOCUMENTATION_PASS_LOG.md
tests: []
---

# Documentation Information Architecture Report

Date: 2026-07-09

Scope: `_AGENT_INSTRUCTIONS/agent-per-project/`

This pass evaluated documentation organization and navigation. It did not
rewrite technical content or modify application source code.

## Summary

The documentation has strong technical depth and preserves important project
history, but the information architecture had become chronological rather than
reader-oriented. The biggest discoverability problem was not missing content; it
was knowing which documents are current, canonical, historical, or proposal
evidence.

The pass therefore added orientation and topic-index layers instead of moving
large historical folder trees.

## Strengths Found

- Most major subsystems already have durable folder-level owners.
- The top-level `README.md` has a useful canonical map.
- The architectural constitution is clearly separated and authoritative.
- The UI/UX walk has a well-defined process and standards/register structure.
- The graph migration record is unusually complete and useful as audit
  evidence.
- Feature folders generally preserve proposals, checklists, design notes, and
  tests, which makes historical decisions recoverable.

## Weaknesses Found

- New readers had no single "cold start" document that distinguishes current
  project mode from historical migration work.
- `55-READERS-INTEGRATORS-ORCHESTRATORS/` combines durable invariants with a
  long numbered migration history. File numbers alone do not indicate whether a
  document is current guidance, historical audit evidence, or a retired plan.
- `45-NEW-FEATURE-ADDITION/` contains active planning, implemented-feature
  history, stale proposals, images, zips, and seed files in one large flat
  collection. Without an index, readers may treat old proposal folders as
  active instructions.
- Some concepts have intentionally moved: Conversation ownership, message
  evidence, archive/recovery, and UI layout now have current owners outside the
  folders where their original planning occurred.
- Physically reorganizing the largest historical folders would risk breaking
  links and obscuring chronology.

## Structural Changes Made

### Added `00-START-HERE.md`

Rationale:

- Gives brand-new developers and fresh agents a short entry point.
- Separates current mode, canonical owners, and historical reference areas.
- Reduces the need to infer currency from folder names or document numbers.

### Added `55-READERS-INTEGRATORS-ORCHESTRATORS/TOPIC_INDEX.md`

Rationale:

- Keeps the valuable graph migration chronology intact.
- Provides topic-based access to durable RIO guidance, message evidence,
  retained storage, archive/recovery, and migration-history documents.
- Prevents numbered migration documents from being mistaken for a current
  sequential checklist.

### Added `45-NEW-FEATURE-ADDITION/INDEX.md`

Rationale:

- Clarifies that the folder is both staging and history.
- Identifies the active/potentially active planning folders separately from
  migrated or canonicalized work.
- Points readers to current owners before they implement from older proposals.

### Updated top-level `README.md`

Rationale:

- Points cold readers to `00-START-HERE.md`.
- Makes the top-level canonical map consistent with the new orientation layer.

### Updated `45-NEW-FEATURE-ADDITION/README.md`

Rationale:

- Makes the folder's mixed active/history role explicit.
- Directs readers to the new index before using feature folders as
  implementation guidance.

### Updated `55-READERS-INTEGRATORS-ORCHESTRATORS/README.md`

Rationale:

- Points readers to the new topic index.
- Preserves the existing reading flow while improving navigation.

## Folders Intentionally Left Unchanged

### `55-READERS-INTEGRATORS-ORCHESTRATORS/`

No physical reorganization was performed.

Reason:

- Its chronology is meaningful audit evidence.
- Many links likely refer to numbered documents.
- A topic index solves discoverability without link churn.

### `45-NEW-FEATURE-ADDITION/`

No folders were moved or archived.

Reason:

- It contains a large amount of proposal and spike history.
- Some entries may still be referenced by prompts, user instructions, or
  historical reports.
- The new `INDEX.md` is a safer first step than a broad restructure.

### `42-SPEC-SYSTEM/`

No restructuring was performed.

Reason:

- It already separates canonical architecture from reference material.
- The top-level README already points readers toward canonical architecture
  first.

### `95-WALK-UI-TREE/`

No restructuring was performed.

Reason:

- Its process, standards, registers, and surface-specific review folders are
  already arranged around the current UI-walk workflow.
- Current X-column and sidebar-seam work is still active; structural churn would
  be premature.

### `40-FEATURES/`

No restructuring was performed.

Reason:

- It is already the correct home for shipped feature ownership.
- The recent Conversations feature boundary has a dedicated README.

## Recommendations For Future Evolution

1. Keep `00-START-HERE.md` short and current.
   It should remain the first orientation page, not become another long index.

2. Use topic indexes before moving historical trees.
   For large planning/history folders, add navigation first and move files only
   when link-preserving redirects or replacement indexes are available.

3. Promote shipped feature guidance out of `45-NEW-FEATURE-ADDITION/`.
   When a planning folder becomes durable product guidance, summarize the
   stable result in `40-FEATURES/` and leave the planning folder as history.

4. Treat `55` documents after `70` as graph-migration audit history unless the
   topic index or release plan says otherwise.

5. Keep historical areas explicitly labelled.
   Avoid deleting useful material, but do not allow old proposals to masquerade
   as current marching orders.

6. Add README/index files before a folder grows deep.
   New major folders should explain ownership, currency, and where to start.

## Human Review Items

- Confirm whether the three active/planning folders listed in
  `45-NEW-FEATURE-ADDITION/INDEX.md` are still the intended active set.
- Consider a later, link-preserving archive pass for `45-NEW-FEATURE-ADDITION/`
  after the current release/UI-walk phase.
- If future agents continue to struggle with `55`, consider adding lightweight
  `CURRENT.md` and `HISTORY.md` entry points rather than moving numbered files.
