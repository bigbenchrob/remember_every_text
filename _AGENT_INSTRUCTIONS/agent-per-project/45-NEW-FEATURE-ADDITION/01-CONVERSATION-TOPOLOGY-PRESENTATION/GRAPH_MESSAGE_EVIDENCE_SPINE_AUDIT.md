---
tier: feature
scope: graph-message-evidence-spine
owner: agent-per-project
last_reviewed: 2026-05-27
source_of_truth: audit
links:
  - ./GRAPH-MESSAGE-PRESENTATION-MIGRATION-AUDIT.md
  - ./UNIFIED-MESSAGE-EVIDENCE-PRESENTATION.md
  - ../../40-FEATURES/messages/MESSAGE-TIMELINE-PIPELINE.md
  - ../../00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md
tests: []
---

# Graph Message Evidence Spine Audit

## Purpose

This audit pauses further message presentation work to verify whether the new graph-backed contact timeline is becoming a reusable message evidence spine or another source-specific path.

The desired architecture is:

1. A source resolves intent into a typed `MessageEvidenceScope` / `MessageEvidenceSpec`.
2. Timeline-like scopes build a lightweight full-scope skeleton.
3. Heatmaps, timeline controls, and jumps coordinate with that skeleton.
4. Visible rows hydrate by stable message identity near the viewport.
5. Shared message presentation renders hydrated evidence rows.
6. Attachment/media display uses the graph attachment evidence hydration boundary.

Hard rule:

> Pagination is not timeline navigation.

A source-specific query is allowed. A source-specific renderer is not.

## Current Spine Candidates

### Legacy ordinal spine

Current path:

`MessagesSpec` -> `MessageTimelineScope` -> ordinal strategy -> per-row hydration -> `MessageListItem` -> `MessageCard`

Strengths:

- Full lightweight ordinal skeleton exists for global/contact/chat/recovered-style timeline surfaces.
- Heatmap and month jumps operate against full selected scope.
- Visible rows hydrate independently.
- Mature attachment/image/video/link-preview rendering exists.

Limitations:

- It is legacy `working.db` backed.
- It uses legacy identity and presentation models.
- It cannot be the long-term graph source of truth.

### Graph contact skeleton path

Current path:

`MessagesSpec.forContact(filterHandleId: null)` -> `ContactGraphMessagesView` -> `contactPageGraphMessageTimelineProvider` -> `contactPageGraphMessageByIdProvider` -> `GraphMessageEvidenceRow`

Strengths:

- Uses graph data.
- Preserves the core timeline invariant: full lightweight skeleton first, local hydration second.
- Coordinates month jumping and visible-month feedback through the full skeleton.
- Renders text and attachments through graph evidence rows.

Limitations:

- This was originally contact-specific, but the skeleton/hydration contract has since been lifted into `MessageEvidenceScope`.
- Contact all-messages now consumes the shared spine and should remain a regression guard for full-scope timeline behavior.

### Graph conversation evidence path

Current path:

`MessagesSpec.forConversation` -> `ConversationMessagesPreviewView` -> `MessageEvidenceTimelineView` -> `GraphMessageEvidenceRow`

Strengths:

- Uses graph data.
- Uses a full conversation skeleton through `MessageEvidenceScope`.
- Hydrates visible rows by stable message `ss_id`.
- Uses shared graph row and graph attachment evidence rendering.
- Supports conversation-specific header/search review controls.

Current status:

- Conversation messages now use a full lightweight graph skeleton via the message evidence spine.
- Visible rows hydrate by `ss_id` through the shared graph evidence row path.
- Conversation search-match ids are exposed as full-scope read-model facts, not batch-local UI facts.
- Bounded latest-row preview should remain only as explicit diagnostic/dev behavior if it is retained.

## Surface Audit

| Surface | Current data source | Skeleton strategy | Hydration strategy | Presentation path | Attachment rendering | Conformance |
| --- | --- | --- | --- | --- | --- | --- |
| Contact All Messages | Graph `working_ss.db` via `conversation_graph` | Full lightweight graph skeleton through `MessageEvidenceScope` | Per-row graph hydration by `ss_id` | `MessageEvidenceTimelineView` -> `GraphMessageEvidenceRow` | Graph attachment evidence -> shared image/video/link/fallback tiles | Conforms for graph contact timeline |
| Conversation messages | Graph `working_ss.db` via `conversation_graph` | Full lightweight conversation skeleton through `MessageEvidenceScope` | Per-row graph hydration by `ss_id` | `MessageEvidenceTimelineView` -> `GraphMessageEvidenceRow` | Graph attachment evidence -> shared image/video/link/fallback tiles | Conforms for graph conversation timeline |
| Contact By Conversation selected messages | Graph conversation route after selecting a conversation | Same as conversation messages | Same as conversation messages | Same as conversation messages | Same as conversation messages | Conforms through conversation evidence scope |
| Handle-filtered contact messages | Graph `working_ss.db` via `conversation_graph` | Full lightweight handle-filtered contact skeleton through `MessageEvidenceScope` | Per-row graph hydration by `ss_id` | `MessageEvidenceTimelineView` -> `GraphMessageEvidenceRow` | Graph attachment evidence -> shared image/video/link/fallback tiles | Conforms for graph handle-filtered contact timeline |
| Search result context | Legacy `working.db` | Bounded context window, no full skeleton | Direct selected row plus before/after window | `SearchResultContextSidebarView` -> `MessageCard` | Legacy `MessageListItem` attachments | Acceptable as a context window, but not unified and currently has query logic outside infrastructure |
| Global timeline | Graph `working_ss.db` via `conversation_graph` | Full lightweight global skeleton through `MessageEvidenceScope` | Per-row graph hydration by `ss_id` | `MessageEvidenceTimelineView` -> `GraphMessageEvidenceRow` | Graph attachment evidence -> shared image/video/link/fallback tiles | Conforms for graph global timeline |
| Recovered messages | Legacy/recovery provider list | Full list-backed ordinal strategy over recovered candidates | Recovered item hydration into `MessageListItem` | `MessagesTimelineView` -> `MessageCard` | Recovered attachments mapped into legacy attachment info | Skeleton-like behavior conforms for recovered list; not graph spine |
| `MessagesSpec.forHandle` | Legacy `working.db` provider | None / whole stream list | Stream emits full `MessageListItem` list | `MessagesForHandleView` custom card | No shared evidence row; attachment display not equivalent | Does not conform |
| `MessagesSpec.handleLens` | Legacy `working.db` provider | None / whole stream list | Stream emits full `MessageListItem` list | `HandleLensView` custom row | Not the shared evidence surface | Does not conform |

## Current Architectural Risks

### Risk: contact graph timeline becomes a one-off

The contact graph path corrected the major performance regression, but it introduced a contact-local skeleton/hydration structure instead of a shared evidence resolver.

Entropy risk:

- future conversation, search, global, recovered, and tag/theme timelines copy the pattern separately
- heatmap coordination rules drift by surface
- skeleton definitions diverge

Correct direction:

- lift the contact graph skeleton contract into a typed message evidence spine
- let contact/conversation/search/global define scopes, not renderers

### Risk: conversation messages remain a batch preview

The conversation route is graph-backed and visually functional, but it still treats the latest N rows as the message universe.

Entropy risk:

- long conversations cannot support full-range heatmap/jump semantics
- search review controls undercount by design
- users may believe a conversation has only the loaded rows

Correct direction:

- conversation messages must move to full conversation skeleton + visible-row hydration
- “latest 100 / latest 500” may remain a preview/debug mode, not canonical timeline behavior

### Risk: legacy presentation survives as hidden authority

Legacy `MessagesTimelineView` and `MessageCard` remain the mature path for global, handle-filtered, recovered, and legacy context surfaces.

Entropy risk:

- graph evidence and legacy evidence evolve separately
- attachment behavior differs by route
- the app keeps two message languages

Correct direction:

- preserve useful legacy skeleton and rendering lessons
- migrate the authority into graph-backed evidence scopes and a shared evidence surface

### Risk: context windows are mistaken for timelines

Search result context is correctly a bounded evidence window today, but it must not become the model for timeline navigation.

Entropy risk:

- search/theme surfaces use page windows where full-scope timeline semantics are required
- jumps and heatmaps become batch-dependent again

Correct direction:

- explicitly classify scopes as `timeline` or `contextWindow`
- timeline scopes require skeletons; context windows may be bounded

### Risk: query authority leaks from infrastructure

`search_result_context_provider.dart` contains Drift query composition in an application/resolver-tools path.

Entropy risk:

- SQL/query policy spreads into application code
- message context semantics become hard to share or test through repository boundaries

Correct direction:

- keep raw SQL/Drift query mechanics quarantined in infrastructure repositories
- expose named methods such as `readSearchResultContext(...)`

## Proposed Canonical Evidence Spine

### Domain/application types

Introduce a typed message evidence contract before moving more UI:

- `MessageEvidenceScope`
- `MessageEvidenceSpec`
- `MessageEvidenceScopeKind.timeline`
- `MessageEvidenceScopeKind.contextWindow`
- `MessageEvidenceSkeletonEntry`
- `HydratedMessageEvidenceRow`
- `MessageEvidenceHeaderModel`

These types should not know about widgets. They represent evidence intent, skeleton identity, hydration output, and header facts.

### Repository boundaries

Infrastructure repositories should expose named methods for:

- full graph contact skeleton
- graph contact message hydration by `ss_id`
- full graph conversation skeleton
- graph conversation message hydration by `ss_id`
- graph global skeleton
- graph handle/contact-filter skeleton
- graph search result context window
- graph recovered/recovery-adapter scope, when migrated

Raw SQL/Drift queries are acceptable inside these repositories. They are not acceptable inside presentation widgets or application coordinators.

### Resolver/orchestrator boundary

Add one message evidence resolver that maps:

`MessageEvidenceSpec` -> skeleton/context model + hydration providers + header model

The resolver should be responsible for deciding whether the scope is timeline-like or context-window-like. Widgets should not infer that from source type.

### Presentation surface

Create one shared evidence surface:

- timeline mode: renders a full skeleton with viewport-local hydration
- context-window mode: renders a bounded evidence window
- both modes render rows through the same hydrated evidence row widget family
- attachments/media route through graph attachment evidence hydration

Source-specific differences should arrive as typed display/header/configuration data, not as separate renderers.

## Migration Plan

### Phase 1: name the spine without replacing behavior

- Add `MessageEvidenceSpec` / `MessageEvidenceScope` concepts.
- Map existing `MessagesSpec` variants into evidence specs.
- Document which variants are timeline scopes and which are context windows.
- Do not change visible behavior yet.

### Phase 2: generalize the graph contact skeleton

- Extract the contact graph skeleton/hydration shape into a reusable evidence skeleton contract.
- Keep `ContactGraphMessagesView` behavior equivalent.
- Prove the extracted contract still supports full range, month keys, latest jump, and visible-month feedback.

### Phase 3: migrate conversation messages to skeleton/hydration

- Add full conversation skeleton repository method.
- Add conversation message hydration by `ss_id`.
- Replace `conversationMessagesProvider(limit: ...)` as canonical timeline source.
- Keep bounded latest-row preview only as explicit diagnostic/dev behavior if still useful.

Status: completed for the default graph conversation route.

### Phase 4: unify graph row presentation

- Ensure contact and conversation graph rows consume the same `HydratedMessageEvidenceRow`.
- Keep graph attachment evidence hydration outside widgets.
- Remove route-specific attachment/text fallback decisions from presentation widgets.

### Phase 5: migrate handle-filtered and global timelines

- Implement graph-backed skeletons for handle-filtered contact scopes and global timeline.
- Keep legacy ordinal path until graph parity is proven.
- Do not implement these as pages or latest-N lists.

Status: handle-filtered contact scopes and the global timeline are completed for the default routes.

### Phase 6: migrate search/recovered/context surfaces deliberately

- Search result context may remain bounded, but must use shared evidence row presentation.
- Recovered scopes may use list-backed skeletons until they are graph-integrated.
- Handle lens / for-handle surfaces should stop using custom message renderers.

### Phase 7: quarantine/delete legacy paths

Once graph evidence covers the core routes:

- quarantine `MessagesTimelineView` behind diagnostic routes only
- retire legacy custom handle message renderers
- remove duplicate presentation decisions
- keep legacy import/migration only where still needed for data continuity

## Tests Required

### Spine contract tests

- timeline scopes return a full skeleton whose count equals the logical selected scope
- timeline skeleton entries include stable ids, timestamps, and month keys
- context-window scopes explicitly report bounded window semantics
- hydration limits never reduce selected logical scope size

### Contact graph tests

- contact all-messages skeleton includes more than 500 rows when the selected scope has more than 500 rows
- heatmap/month jump targets skeleton indices
- row hydration by `ss_id` loads text and attachment evidence for visible rows

### Conversation graph tests

- long conversation skeleton includes the full conversation, not latest N
- conversation search/review counts distinguish full-scope matches from visible hydrated rows
- anchor-message navigation targets skeleton index space

### Attachment evidence tests

- archived image evidence renders through shared media tile path
- archived video evidence renders through shared media tile path
- URL preview evidence is collapsed to one preview display when multiple resource records exist
- missing/unavailable attachment remains visibly rendered

### Regression tests

- no new source-specific message renderer is introduced for graph contact/conversation/search/handle routes
- no message evidence query mechanics appear in presentation widgets
- no timeline-like surface uses pagination as its primary navigation model

## Files Likely Involved

Current routing and specs:

- `lib/features/messages/domain/spec_classes/messages_view_spec.dart`
- `lib/features/messages/application/view_spec/coordinators/view_spec_coordinator.dart`

Current graph contact path:

- `lib/features/messages/presentation/view/contact_graph_messages_view.dart`
- `lib/essentials/conversation_graph/application/contacts/contact_graph_provider.dart`
- `lib/essentials/conversation_graph/application/contacts/contact_graph_reader.dart`
- `lib/essentials/conversation_graph/infrastructure/repositories/contact_graph_repository.dart`

Current graph conversation path:

- `lib/features/messages/presentation/view/conversation_messages_preview_view.dart`
- `lib/essentials/conversation_graph/application/conversations/conversation_reader_provider.dart`
- `lib/essentials/conversation_graph/application/conversations/conversation_reader.dart`
- `lib/essentials/conversation_graph/infrastructure/repositories/conversation_repository.dart`

Shared graph evidence row and attachments:

- `lib/features/messages/presentation/widgets/message_evidence/graph_message_evidence_row.dart`
- `lib/features/messages/application/message_evidence/graph_attachment_evidence.dart`
- `lib/features/messages/presentation/widgets/message_evidence/graph_attachment_evidence_tiles.dart`
- `lib/features/messages/presentation/widgets/message_evidence/message_evidence_header.dart`

Legacy timeline and custom renderers:

- `lib/features/messages/presentation/view/messages_timeline_view.dart`
- `lib/features/messages/presentation/widgets/message_card.dart`
- `lib/features/messages/presentation/view/messages_for_handle_view.dart`
- `lib/features/messages/presentation/view/handle_lens_view.dart`
- `lib/features/messages/presentation/view_model/timeline/hydration/message_by_ordinal_provider.dart`
- `lib/features/messages/presentation/view_model/shared/hydration/messages_for_handle_provider.dart`
- `lib/features/messages/application/view_spec/resolver_tools/search_result_context_provider.dart`

## Deletion / Quarantine Candidates

Do not delete these until graph parity is proven, but they should not remain permanent default presentation paths:

- `MessagesForHandleView` custom message cards
- `HandleLensView` custom message rows
- legacy `MessagesTimelineView` as default center-panel evidence renderer
- legacy `MessageRowMapper` as the primary hydration authority
- `conversationMessagesProvider(limit: ...)` should remain quarantined as a latest-row preview/helper, not a canonical conversation timeline source

## Recommended Next Slice

Do not add another source-specific message view.

The lowest-risk next implementation slice should be:

1. Define a typed `MessageEvidenceScope` / `MessageEvidenceSpec` model.
2. Classify existing routes as timeline or context-window scopes.
3. Extract the graph contact skeleton/hydration contract into a reusable evidence-spine boundary while preserving current contact behavior.
4. Add tests proving contact all-messages still uses full skeleton + local hydration after the extraction.

After these steps, conversation messages were migrated from bounded batch loading to full conversation skeleton + local hydration. The next migration pressure should be handle-filtered and global timelines, not another conversation-specific renderer.
