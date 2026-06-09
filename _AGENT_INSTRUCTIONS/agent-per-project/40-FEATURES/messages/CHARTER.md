---
tier: feature
scope: charter
owner: agent-per-project
last_reviewed: 2026-06-05
links:
  - ./DOMAIN_AND_DATA_MAP.md
  - ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: messages
doc_type: charter
status: current
last_updated: 2026-06-05
---

# Feature Charter - Messages

## Mission

- Provide fast, stable message evidence surfaces across global, contact,
  filtered-contact, conversation, handle/unfamiliar source, recovered, and
  search-result scopes.
- Keep the presentation pipeline deterministic and resilient to database
  maintenance/reset.
- Enable search and timeline jumps without coupling UI widgets to data-fetching
  details.

## Primary Outcomes

- Unified evidence spine: all message surfaces converge on shared
  `MessageEvidenceScope` resolution, skeleton construction, visible-row
  hydration, and message evidence rendering.
- Full-scope skeleton plus per-row hydration: fast first paint, stable scroll,
  minimal churn.
- Jump behavior: jump to latest and jump to month without requiring the view to
  know index math.
- Search: provider-driven search across the selected logical scope, including
  global, contact, conversation, handle, and recovered contexts where supported.

## Hard Timeline Invariant

- Full lightweight skeleton first; local hydration second.
- Heatmaps coordinate with the full selected-scope skeleton, not a latest page.
- Jumps target skeleton indices.
- Row bodies, attachment evidence, media, previews, and other heavy evidence
  hydrate near the viewport.
- Limits apply to hydration windows, not to the selected message scope.
- Pagination is not timeline navigation.
- Source-specific scopes are allowed; source-specific message renderers are not.

## Success Metrics

- Evidence scopes open quickly even with large histories.
- No UI lockups during destructive DB maintenance.
- No unexpected scroll-to-bottom behavior when new messages arrive while the
  user is reading older evidence.
- Shared evidence rendering remains visually consistent across every source.

## Non-Goals

- App-level navigation orchestration, sidebar topology, and panel-stack
  ownership. Those belong to essentials and the canonical spec system.
- Direct widget-driven database access.
- Recreating legacy `working.db` message index tables as the app-facing model.

## Stakeholders & Dependencies

- Depends on `working_ss.db` graph tables, source-scoped message identity, graph
  attachment evidence, display identity resolution, overlay user intent, and
  maintenance lock (`dbMaintenanceLockProvider`).
- Consumed by: messages center panel surfaces, sidebar heatmaps/navigators,
  recovered-message sidebars, search result context surfaces, and conversation
  evidence views.

## Open Questions

- When to delete remaining historical ordinal-timeline documentation and tests.
- Whether additional semantic overlays should be rendered as evidence badges,
  header metadata, or search facets.
