---
tier: feature
scope: interactions
owner: agent-per-project
last_reviewed: 2026-04-21
links:
	- ./CHARTER.md
	- ../../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md
tests: []
feature: messages
doc_type: interactions
status: draft
last_updated: 2026-04-21
---

# Interactions & Navigation — Messages

This document describes the current messages panel flows. Panel entry points are selected by `ViewSpec.messages(MessagesSpec...)`; app-level panel stack ownership and cross-surface reconciliation remain in essentials.

## Primary Entry Points
- Global messages in the center panel via `MessagesSpec.globalTimeline(...)`.
- Contact messages in the center panel via `MessagesSpec.forContact(...)`, with optional `filterHandleId`.
- Chat/handle messages via `MessagesSpec.forChat(...)` and `MessagesSpec.forHandle(...)` where routed.
- Recovered-message surfaces via `MessagesSpec.recoveredUnlinkedMessages(...)`, `recoveredNoHandleFromMeMessages(...)`, `recoveredAttachmentViewer(...)`, and `searchResultContext(...)`.
- Handle Lens via `MessagesSpec.handleLens(...)`.
- The view is intentionally “dumb”: it renders state and delegates behaviors (search debounce, jump) to the view model.

## User Flows
1. **Select Timeline Scope** → center panel shows `MessagesTimelineView(scope: ...)`.
	- “Skeleton”: ordinal provider loads `totalCount` and builds a fixed-height list.
	- “Hydration”: each row loads `messageByOrdinalProvider(scope, ordinal)`.
2. **Initial positioning**
	- Default: jump to latest message.
	- If `scrollToDate` is provided, VM jumps to the month bucket for that date.
3. **Search messages**
	- Typing updates VM controller → debounce → scope-specific search in `messageTimelineViewModelProvider`.
	- UI switches from ordinal timeline to a search results list.
4. **Jump by month (heatmap)**
	- Heatmap chooses a month.
	- VM invokes `messageTimelineOrdinalProvider(...).notifier.jumpToMonth(monthKey)`.
5. **View rich content**
	- URL previews use `MessageLinkPreviewCard` when appropriate.
	- Image/video tiles render for first matching attachment.

## Cross-Feature Touchpoints
- Contacts feature selects a `contactId` and drives `MessagesSpec.forContact` navigation.
- Essentials search provides `SearchService`, used by message timeline search.
- DB maintenance/reset feature toggles `dbMaintenanceLockProvider`.

## Navigation Guardrails
- Always rely on ViewSpec variants for navigation; avoid manual route pushes.
- Prefer `MessagesSpec.forContact(contactId: ..., scrollToDate: ...)` for contact-scoped browsing.
- Features do not own app-level panel orchestration. They interpret their approved spec variants and return current surface output through the existing panel migration boundary.
- Ensure timeline gracefully handles missing message records (row hydration may return null).

## Outstanding Decisions
- Whether to add “jump to specific day” (today: month-level jump is supported).
- How far recovered timelines should be unified with normal working-DB ordinal strategy storage.
