---
tier: feature
scope: work-log
owner: agent-per-project
last_reviewed: 2026-06-14
links:
	- ./CHARTER.md
	- ./TESTING_AND_MONITORING.md
tests: []
feature: messages
doc_type: work-log
status: active
last_updated: 2026-06-14
---

# Work Log — Messages

| Date | Change Summary | Author | Notes |
| --- | --- | --- | --- |
| 2025-11-06 | Added baseline documentation scaffold for messages feature. | GitHub Copilot | Established charter, data map, provider inventory, interactions, testing, and log template. |
| 2025-12-23 | Canonicalized contact-messages pipeline; hard-deleted chat UI. | GitHub Copilot | “Messages for Contact” is now the canonical timeline; chat-specific view/providers removed; docs updated to match. |
| 2026-06-14 | Recorded Message Evidence Spine as the current message surface. | Codex | Contact, conversation, handle, search, recovered, and global message views converge through typed evidence scopes, full-scope skeletons, visible-row hydration, shared headers, and shared row rendering. |

## Open Stewardship Items
- Keep timeline-like scopes on the full-skeleton/local-hydration model.
- Keep new message evidence surfaces on shared evidence widgets; source-specific
  scopes are allowed, source-specific renderers are not.
