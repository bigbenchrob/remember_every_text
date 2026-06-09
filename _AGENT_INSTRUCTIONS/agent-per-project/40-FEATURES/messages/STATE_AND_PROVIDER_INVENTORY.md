---
tier: feature
scope: state-provider-inventory
owner: agent-per-project
last_reviewed: 2026-06-05
links:
  - ./CHARTER.md
  - ./DOMAIN_AND_DATA_MAP.md
tests: []
feature: messages
doc_type: state-provider-inventory
status: current
last_updated: 2026-06-05
---

# State & Provider Inventory - Messages

This inventory is authoritative for the graph-backed Message Evidence Spine.
Older `contact_messages/`, `global_messages/`, and ordinal `working.db`
timeline provider folders were retired by the graph migration.

## Active Providers And Boundaries

| Provider / Boundary | Kind | Location | Responsibility |
| --- | --- | --- | --- |
| Message evidence spine providers | `@riverpod` evidence boundary | `lib/features/messages/application/message_evidence/message_evidence_spine_provider.dart` | Build full-scope skeletons, resolve search matches, hydrate visible graph evidence rows, and expose timeline navigation facts. |
| Message evidence views | widgets/composers | `lib/features/messages/presentation/view/` | Compose source-specific headers/specs, then delegate evidence rows to the shared evidence presentation widgets. |
| Shared evidence widgets | widgets | `lib/features/messages/presentation/widgets/message_evidence/` | Render the shared center-panel evidence surface. Widgets do not query databases or decide graph semantics. |
| Graph search providers | graph repository/provider | `lib/essentials/search/` | Search graph messages and return graph `message_ss_id` evidence scopes. |
| Graph message repositories | infrastructure repositories | `lib/essentials/conversation_graph/infrastructure/repositories/` | Own graph SQL/read queries behind named repository methods. |
| `dbMaintenanceLockProvider` | provider | `lib/essentials/db/feature_level_providers.dart` | Guards destructive DB maintenance and rebuild/reset flows. |

## State Objects

- `MessageEvidenceScope`: selected logical message universe.
- Evidence skeleton rows: full selected-scope ids/timestamps/navigation facts.
- Hydrated evidence rows: visible message text, sender identity, semantics,
  badges, attachments, URL previews, and overlay metadata.
- Header models: title, metrics, scope details, search config, and action row.

## Lifecycle Rules

- Timeline-like scopes preserve the full logical selected message universe even
  when visible rows and media hydrate incrementally.
- Search operates against the selected logical scope, not just currently
  hydrated rows.
- ViewSpec/sidebar flow produces typed message evidence scopes.
- Graph build completion invalidates graph/evidence readers.
- Search/header controls update evidence-scope search state; matching remains
  in the evidence spine, not the header widget.

## TODO

- Continue retiring dead ordinal/timeline docs and tests only after reference
  scans prove no active graph evidence dependency.
- Keep visual changes centralized in shared evidence widgets rather than
  source-specific message views.
