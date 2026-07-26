---
tier: feature
scope: work-log
owner: agent-per-project
last_reviewed: 2026-07-18
links:
	- ./CHARTER.md
	- ./TESTING_AND_MONITORING.md
tests: []
feature: search
doc_type: work-log
status: active
last_updated: 2026-07-18
---

# Work Log — Search

| Date | Change Summary | Author | Notes |
| --- | --- | --- | --- |
| 2025-11-06 | Seeded documentation scaffold for search feature. | GitHub Copilot | Added charter, data map, provider inventory, interactions, testing, and log template. |
| 2026-06-14 | Recorded graph-backed search state. | Codex | Search resolves graph `message_ss_id` evidence scopes through `lib/essentials/search` and the shared Message Evidence Spine; legacy `working.db` FTS is not an ordinary app path. |
| 2026-07-18 | Shipped declarative Search investigation compatibility. | Codex | Added an opaque generation owned by Search; Conversation excerpts carry originating provenance; effective right-panel state derives from identity compatibility while stored state remains restorable. |

## Open Stewardship Items
- Measure graph search latency before introducing any acceleration layer.
- If acceleration is needed, keep it behind `GraphSearchRepository` rather
  than creating a parallel search spine.
