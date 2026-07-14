---
tier: project
scope: navigation
owner: agent-per-project
last_reviewed: 2026-07-12
source_of_truth: doc
links:
  - ./README.md
  - ../40-FEATURES/README.md
  - ../95-WALK-UI-TREE/README.md
tests: []
---

# Feature Planning Index

This folder is a mixed staging and history area. It contains active feature
plans, implemented-feature retrospectives, abandoned or superseded proposals,
and design/audit material that was intentionally preserved.

Do not assume that a folder here is current implementation guidance merely
because it exists.

## How To Use This Folder

1. Start with the current owner:
   - shipped feature guidance: [`../40-FEATURES/`](../40-FEATURES/)
   - active UI/UX walk: [`../95-WALK-UI-TREE/`](../95-WALK-UI-TREE/)
   - source-scoped graph and evidence invariants:
     [`../55-READERS-INTEGRATORS-ORCHESTRATORS/TOPIC_INDEX.md`](../55-READERS-INTEGRATORS-ORCHESTRATORS/TOPIC_INDEX.md)
2. Use this folder for proposal history, rationale, audits, or explicitly
   active feature-planning folders.
3. Before implementing from a folder here, verify that it is listed as active
   below, linked by a current roadmap, or explicitly named by the user.

## Active Or Potentially Active Planning Folders

These folders were still listed as active/planning in the workflow README at
the time of this IA pass. Verify status before implementation.

| Folder | Current reading |
| --- | --- |
| [`03-INTRODUCE-SIDEBAR-CONTENT-SEAM/`](03-INTRODUCE-SIDEBAR-CONTENT-SEAM/) | Active design-planning area for aligning sidebar cassette chains with the X-column layout work. |
| [`04-CONVERSATION-TAGS/`](04-CONVERSATION-TAGS/) | Implemented first slice for durable user-created semantic labels attached to canonical Conversation identity. Also contains deferred evaluations such as Contact-backed Conversation Tags as identity-backed retrieval coordinates. |
| [`05-CONVERSATION-INTENT-ARCHITECTURE/`](05-CONVERSATION-INTENT-ARCHITECTURE/) | Exploratory architecture package defining Conversation Intent as the broader overlay/user-intent seam under Favourites, Tags, Working Sets, Hidden state, Notes, saved investigations, and future user-confirmed classifications. |
| [`06-STRUCTURED-CONVERSATION-RETRIEVAL/`](06-STRUCTURED-CONVERSATION-RETRIEVAL/) | Structured retrieval planning for describing remembered Conversation context with tokens. First implemented slice consumes Tag tokens. |
| [`07-TAG-VISIBILITY-POLICY/`](07-TAG-VISIBILITY-POLICY/) | Planning package for visibility policy attached to Tag definitions, including suppressing low-value Conversation classes from ordinary browsing while keeping them explicitly retrievable. |
| [`archive-canonical-attachments/`](archive-canonical-attachments/) | Attachment/archive planning material. Verify against `25-ONBOARDING-AND-ARCHIVE/`, `55/84`, and current archive/recovery work before implementation. |
| [`ephemeral-sidebar-projection/`](ephemeral-sidebar-projection/) | Sidebar projection planning material. Verify against the canonical spec/cassette system and current UI-walk direction before implementation. |

## Migrated Or Canonicalized Elsewhere

These folders contain useful rationale, but the canonical home for day-to-day
guidance now lives elsewhere.

| Folder | Canonical owner now |
| --- | --- |
| [`01-CONVERSATION-TOPOLOGY-PRESENTATION/`](01-CONVERSATION-TOPOLOGY-PRESENTATION/) | Conversation presentation and UI work now lives under `40-FEATURES/conversations/`, `95-WALK-UI-TREE/`, and the message evidence spine docs in `55/69`. |
| [`02-UNIFIED-MESSAGE-EVIDENCE-HEADER/`](02-UNIFIED-MESSAGE-EVIDENCE-HEADER/) | Shared message evidence UI work now belongs to the UI walk and message evidence spine documentation. |
| [`database-health-audit/`](database-health-audit/) | Implemented database health architecture lives under `12-DATABASE-HEALTH-AUDIT/`. |
| [`enhanced-onboarding-flow/`](enhanced-onboarding-flow/) and [`enhanced-onboarding-readiness-panel/`](enhanced-onboarding-readiness-panel/) | Onboarding/archive guidance lives under `25-ONBOARDING-AND-ARCHIVE/`. |
| [`living-attachments-archive/`](living-attachments-archive/) and [`living-attachments-deterministic/`](living-attachments-deterministic/) | Current archive/recovery guidance lives under `25-ONBOARDING-AND-ARCHIVE/` and `55/84`. |
| [`settings-cassette-system/`](settings-cassette-system/), [`sidebar-cassette-role-system/`](sidebar-cassette-role-system/), [`sidebar-flow-state-introduction/`](sidebar-flow-state-introduction/) | Canonical sidebar/spec guidance lives under `42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/` and the active UI walk. |

## Historical Proposal Archive

Most other folders are retained as historical proposal, spike, retrospective,
or refinement material. They are useful for:

- understanding why a decision was made;
- recovering a discarded idea;
- tracing the evolution of a shipped feature;
- auditing an older implementation path.

They are not current marching orders unless a current document links to them.

## Information Architecture Notes

This folder is intentionally not deeply reorganized yet.

Reason:

- It preserves chronological and conversational development history.
- Many links in current and historical docs refer to these paths.
- A navigation index improves discoverability without breaking those links.

If the folder continues to grow, prefer adding a small `archive/` taxonomy only
after the current release/UI-walk phase, and only with link-preserving redirect
notes.
