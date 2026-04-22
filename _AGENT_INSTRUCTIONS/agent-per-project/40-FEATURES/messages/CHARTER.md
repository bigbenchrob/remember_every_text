---
tier: feature
scope: charter
owner: agent-per-project
last_reviewed: 2026-04-21
links:
	- ./DOMAIN_AND_DATA_MAP.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: messages
doc_type: charter
status: draft
last_updated: 2026-04-21
---

# Feature Charter — Messages

## Mission
- Provide fast, stable message timeline surfaces across global, contact, filtered-contact, chat, handle, and recovered scopes.
- Keep the presentation pipeline deterministic and resilient to database maintenance/reset.
- Enable search and timeline jumps without coupling UI widgets to data-fetching details.

## Primary Outcomes
- Unified timeline: one `MessagesTimelineView` and `MessageTimelineScope` model across supported scopes.
- Ordinal skeleton + per-row hydration: fast first paint, stable scroll, minimal churn.
- “Jump” behavior: jump to latest and jump to month (heatmap-driven) without requiring the view to know index math.
- Search: debounced, provider-driven search results for global, contact, chat, and recovered/handle contexts where supported.

## Success Metrics
- Timeline opens quickly even with large histories (ordinal skeleton computation is bounded and cache-friendly).
- No UI lockups during destructive DB maintenance (providers short-circuit rather than hanging).
- No scroll jitter during hydration (placeholders are fixed-height).

## Non-Goals
- App-level navigation orchestration, sidebar topology, and panel-stack ownership. Those belong to essentials and the canonical spec system.
- Direct widget-driven database access.

## Stakeholders & Dependencies
- Depends on `working.db` projection tables plus `global_message_index`, `contact_message_index`, and scope-specific ordinal strategies.
- Depends on centralized DB providers (`driftWorkingDatabaseProvider`) and maintenance lock (`dbMaintenanceLockProvider`).
- Consumed by: messages center panel surfaces, sidebar heatmaps/navigators, recovered-message sidebars, search result context surfaces.

## Open Questions
- Further unification of recovered timelines with normal ordinal strategy storage.
- Whether month jump should be animated vs. instantaneous for large jumps.
