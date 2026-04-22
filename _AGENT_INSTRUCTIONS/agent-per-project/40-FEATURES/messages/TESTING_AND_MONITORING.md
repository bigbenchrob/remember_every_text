---
tier: feature
scope: testing-monitoring
owner: agent-per-project
last_reviewed: 2026-04-21
links:
	- ./STATE_AND_PROVIDER_INVENTORY.md
	- ./WORK_LOG.md
tests: []
feature: messages
doc_type: testing-monitoring
status: draft
last_updated: 2026-04-21
---

# Testing & Monitoring — Messages

This document focuses on the unified message timeline implementation.

## Automated Coverage Targets
- Unit
	- `ContactMessageIndexDataSource.getTotalCount`, `getMessageIdByOrdinal`, `getFirstOrdinalForMonth` semantics.
	- `MessageTimelineViewModel` debounce behavior (controller updates → debounced query → loading/data).
	- Scope-specific ordinal strategies for global, contact, filtered contact, chat, and recovered scopes.
- Integration
	- Query joins for row hydration: ensure hydration returns `MessageListItem` for valid ordinals.
	- Maintenance lock behavior: when `dbMaintenanceLockProvider` is true, ordinal provider returns empty state without opening DB.
- Widget
	- Timeline skeleton + hydration: fixed-height placeholders, no upward scroll jitter.
	- Default behavior: jump to latest after initial frame.
	- Date-scoped behavior: `scrollToDate` results in month jump.

## Test Data Requirements
- Fixture scopes with large history spread across global, contact, chat, handle, and recovered scenarios where possible.
- Ensure month boundaries exist for jump testing (at least 3 distinct `YYYY-MM` buckets).
- Include rows that return null on hydration (e.g., missing message ids) to confirm UI resilience.

## Monitoring & Telemetry
- Track time-to-first-render for contact messages timeline (skeleton should appear quickly).
- Track the rate of “ordinal hydration returned null” as an integrity signal.
- Log maintenance lock transitions + any provider attempting DB open during maintenance.

## Manual Verification Checklist
- Open global/contact/chat/recovered scopes: list appears and jumps correctly where supported.
- Toggle maintenance/reset flow: contact messages should not spin indefinitely (should show empty).
- Type in search field: results update after debounce; clearing search returns to list.
- Use heatmap month tap: timeline jumps to that month.

## TODO
- Add or update widget harnesses around `MessagesTimelineView` with fake providers.
