---
tier: feature
scope: work-log
owner: agent-per-project
last_reviewed: 2026-06-14
links:
	- ./CHARTER.md
	- ./TESTING_AND_MONITORING.md
tests: []
feature: chats
doc_type: work-log
status: active
last_updated: 2026-06-14
---

# Work Log — Chats

| Date | Change Summary | Author | Notes |
| --- | --- | --- | --- |
| 2025-11-06 | Created baseline documentation scaffold for chats feature. | GitHub Copilot | Added charter, data map, provider inventory, interactions, testing, and log template. |
| 2026-06-14 | Reframed chats as graph-backed conversation navigation. | Codex | Current user-facing conversation lists use source-scoped topology, conversation signatures, overlay favourites, and the shared Message Evidence Spine. |

## Open Stewardship Items
- Preserve historical architectural decisions in graph migration docs instead of
  resurrecting legacy chat-list architecture.
- Keep conversation overlays global/user-intent-owned and out of source-derived
  graph projection.
