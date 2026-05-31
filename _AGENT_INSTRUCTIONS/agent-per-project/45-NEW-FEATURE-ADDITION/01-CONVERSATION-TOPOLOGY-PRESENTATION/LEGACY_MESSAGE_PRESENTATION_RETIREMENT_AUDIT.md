---
tier: feature
scope: message-evidence-spine
owner: agent-per-project
last_reviewed: 2026-05-29
source_of_truth: audit
links:
  - ./GRAPH_MESSAGE_EVIDENCE_SPINE_AUDIT.md
  - ./UNIFIED-MESSAGE-EVIDENCE-PRESENTATION.md
  - ../../55-READERS-INTEGRATORS-ORCHESTRATORS/69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md
  - ../../00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md
tests:
  - test/features/messages/presentation/view/recovered_messages_evidence_view_test.dart
---

# Legacy Message Presentation Retirement Audit

## Purpose

This audit records where MessageLens currently stands in retiring legacy
message presentation paths after the graph-backed Message Evidence Spine became
the default center-panel evidence surface.

The invariant is:

> Source-specific message scopes are allowed. Source-specific message evidence
> renderers are not.

## Active Center-Panel Message Routes

| Route / surface | Current target | Evidence spine status |
| --- | --- | --- |
| Contact all messages | `ContactMessagesEvidenceView` | Uses `MessageEvidenceScope`, full evidence skeleton, visible-row hydration, `MessageEvidenceTimelineView`, and `MessageEvidenceRow`. |
| Contact handle-filtered messages | `ContactMessagesEvidenceView` | Uses the same spine with a handle-filtered scope. Limits apply to hydration, not logical scope. |
| Contact by-conversation selection | `ConversationMessagesPreviewView` | Resolves to a conversation scope and uses the shared timeline/evidence row path. |
| Conversations sidebar selection | `ConversationMessagesPreviewView` | Same conversation evidence path as contact by-conversation. |
| Global timeline | `GlobalMessagesEvidenceView` | Uses the shared message evidence spine. |
| Handle messages | `HandleMessagesEvidenceView` | Uses a handle scope through the shared evidence spine. |
| Unfamiliar source / handle lens | `HandleLensView` | Uses graph-backed handle evidence and the shared evidence row path. |
| Recovered deleted / no-handle messages | `RecoveredMessagesEvidenceView` | Uses the shared header/timeline/evidence row shape over recovered evidence facts. The old placeholder wrapper has been removed. |
| Search result context | `SearchResultContextSidebarView` | Uses the evidence-spine presentation vocabulary for bounded context review. This remains a context-window scope, not timeline navigation. |

## Non-Message or Diagnostic Routes

`ConversationBrowserView` remains a conversation navigation/signature browser,
not a message evidence renderer.

`MessagesSpec.forChat` and `MessagesSpec.forChatInDateRange` currently route to
placeholder panels. They must not grow new renderers. If implemented, they
should produce a `MessageEvidenceScope` and use the shared evidence spine.

## Legacy Presentation Code Still Present

The legacy message renderers have been retired. The remaining compatibility
artifact is a narrow media tile DTO used by message attachment evidence to reuse
the existing shared image/video tile widgets:

- `lib/features/messages/presentation/widgets/message_evidence/media_tile_attachment.dart`

This DTO is not graph source truth. It is an adapter at the media tile boundary
only.

## Legacy Provider Classification

| File / group | Classification | Why it remains | Retirement direction |
| --- | --- | --- | --- |
| `presentation/view/messages_timeline_view.dart` | Retired | Old `working.db` timeline renderer had no active code references after message evidence spine migration. | Deleted. Do not recreate a timeline renderer outside `MessageEvidenceTimelineView`. |
| `presentation/widgets/message_card.dart` | Retired | Old `MessageListItem` renderer was no longer referenced outside its tests. | Deleted. New work must use `MessageEvidenceRow`. |
| `presentation/widgets/message_link_preview_card.dart` | Retired | Only supported `MessageCard`; message URL previews now render through `MessageAttachmentEvidenceTiles` and `UrlPreviewWidget`. | Deleted. |
| `presentation/widgets/message_user_metadata_widgets.dart` | Retired from presentation | Only supported old `MessageListItem` presentation. | Deleted. Message-level user metadata should return through the evidence spine if revived. |
| `presentation/widgets/ordinal_message_row.dart` | Retired | Only served old chat-ordinal hydration. Graph timelines now use full-scope skeletons and stable message IDs. | Deleted. Do not recreate chat-local ordinal row rendering. |
| `presentation/view/messages_for_handle_view.dart` | Retired | Old handle-specific message view was superseded by `HandleMessagesEvidenceView`. | Deleted. |
| `infrastructure/repositories/messages_for_handle_provider.dart` | Retired | Old handle-specific legacy `working.db` query supported only `MessagesForHandleView`. | Deleted. |
| `domain/entities/message_list_item.dart` | Retired | Old presentation row DTO had no remaining imports. | Deleted. |
| `presentation/view_model/timeline/hydration/message_by_id_provider.dart` | Retired | Hydrated old `MessagesTimelineView` rows by legacy working message id. | Deleted with `MessagesTimelineView`. |
| `presentation/view_model/timeline/hydration/message_by_ordinal_provider.dart` | Retired | Hydrated old ordinal timeline rows and recovered timeline compatibility paths. | Deleted with `MessagesTimelineView`. |
| `presentation/view_model/timeline/hydration/message_grouping_metadata_by_ordinal_provider.dart` | Retired | Supplied old adjacent-row grouping metadata for `MessagesTimelineView`. | Deleted with `MessagesTimelineView`. |
| `presentation/view_model/shared/hydration/message_by_id_provider.dart` | Retired | Old `MessageListItem` single-row hydrator had no remaining imports. | Deleted. |
| `presentation/view_model/shared/hydration/message_by_ordinal_provider.dart` | Retired | Old chat-local ordinal hydrator was only used by `OrdinalMessageRow`. | Deleted with `OrdinalMessageRow`. |
| `presentation/view_model/shared/hydration/messages_for_handle_provider.dart` | Retired | Old `MessageListItem` provider had no remaining active consumers. | Deleted. |
| `presentation/widgets/message_evidence/media_tile_attachment.dart` | Active presentation adapter | Existing shared image/video tiles consume this DTO. Message attachment evidence converts into it at the tile boundary. | Keep as presentation-only adapter. Do not treat it as graph or source truth. |
| `presentation/view_model/shared/hydration/attachment_info_loader.dart` | Retired | Loaded legacy `working.db` attachments for old `MessageListItem` surfaces. | Deleted. |
| `application/view_spec/resolver_tools/search_result_context_provider.dart` | Retired | Search result context now uses `SearchResultContextEvidenceScope` through the message evidence spine. | Deleted. Do not recreate a `MessageListItem`-based search context provider. |
| `presentation/view_model/timeline/message_timeline_view_model_provider.dart` | Retired | Old timeline search/controller state no longer drives graph-backed evidence views. Header search state now lives with each evidence view and search semantics flow through `messageEvidenceTextMatchIdsProvider` / evidence scopes. | Deleted. Do not reintroduce a parallel timeline search view model. |
| `presentation/view_model/timeline/timeline_metadata_provider.dart` | Retired | Old header metadata provider was no longer consumed after unified `MessageEvidenceHeaderModel` composition moved into evidence-spine views. | Deleted. Header facts should be composed from the active evidence scope/read model. |
| `presentation/view_model/timeline/ordinal/message_timeline_ordinal_provider.dart` | Retired alias | Presentation-layer export of the application ordinal provider obscured ownership. | Deleted with the old ordinal provider. Evidence surfaces use `messageEvidenceTimelineSkeletonProvider`. |
| `presentation/view_model/timeline/contact_timeline_display_version_provider.dart` | Retired alias | Presentation-layer export of application display-version state obscured ownership. | Deleted with the old display-version provider. Heatmaps watch message data version and evidence visible-month state. |
| `application/strategies/*_ordinal_strategy.dart` | Retired | Legacy `working.db` ordinal strategies were superseded by graph-backed `MessageEvidenceTimelineSkeleton` scopes. | Deleted. Do not recreate strategy-specific timeline renderers or working-db ordinal bridges for active evidence. |
| `application/timeline/ordinal/message_timeline_ordinal_provider.dart` | Retired | Owned scroll controllers and list jumps for the old ordinal timeline. The shared evidence timeline now owns viewport movement against its full skeleton. | Deleted. Timeline-like surfaces must use evidence skeleton indices. |
| `application/timeline/contact_timeline_display_version_provider.dart` | Retired | Only supported old displayed-vs-live ordinal timeline delta handling. Graph heatmaps now rebuild from message data version and evidence skeleton state. | Deleted. |
| `presentation/view_model/timeline/ordinal/message_timeline_index_coordinator_provider.dart` | Retired | Anchored old ordinal timelines during count changes. `MessageEvidenceTimelineView` now handles anchor/month jumps from the typed skeleton. | Deleted. |
| `domain/value_objects/message_timeline_scope.dart` | Retired | Old timeline-scope identity duplicated the active `MessageEvidenceScope` model after ordinal strategies were removed. | Deleted. Heatmap visible-month state is now keyed by `MessageEvidenceScope`. |
| `infrastructure/repositories/messages_repository_provider.dart` and `sqlite_messages_repository.dart` | Retired | Unimplemented scaffold provider had no callers and exported a dead persistence path outside the evidence spine. | Deleted. New message reads must use named evidence/graph readers rather than resurrecting this repository. |
| `domain/i_repositories/repository_interface.dart` and `domain/entities/message.dart` | Retired scaffold | Only served the unimplemented repository scaffold. Active evidence rows now use graph `ConversationMessage` and `MessageEvidenceRowData`. | Deleted. Keep `MessageId` because attachment domain value objects still depend on it. |
| `application/view_spec/resolver_tools/global_message_timeline_provider.dart` | Retired | Old global timeline paging provider duplicated the graph-backed `GlobalMessagesEvidenceScope` path and risked reintroducing pagination as timeline navigation. | Deleted with its generated provider and focused legacy test. |
| `infrastructure/data_sources/*message_index_data_source.dart` | Retired wrappers | Index data-source wrappers were either unused or only served the retired global paging provider. Active timeline coordination now flows through graph evidence skeletons. | Deleted. Do not reintroduce source-specific index wrappers for presentation navigation. |

### Classification Invariant

Legacy hydration providers have been retired from active message evidence.
New message evidence work must start from a typed `MessageEvidenceScope`,
produce a full logical skeleton when timeline-like, and hydrate visible rows
through the graph evidence boundary.

The remaining `currentVisibleMonthForScopeProvider` is a thin state bridge
between the shared evidence timeline and sidebar heatmaps, keyed by
`MessageEvidenceScope`. It does not own message lookup, scroll controllers, row
hydration, or source-specific presentation behavior.

The old public `messagesRepositoryProvider` has been removed. It was an
unimplemented scaffold, not an architectural dependency. Keeping it exported
would invite future features to bypass the evidence spine.

## Retired In This Slice

`RecoveredUnlinkedMessagesPlaceholderView` was removed because recovered
messages now have a real evidence-spine view:

- `RecoveredMessagesEvidenceView`

The route builder already targeted `RecoveredMessagesEvidenceView` directly, so
the wrapper only preserved obsolete placeholder language.

The old `MessageTimelineViewModel` search/controller layer and unused timeline
metadata provider were also removed. Search-result context panel compatibility
now follows sidebar/spec compatibility rather than stale legacy timeline search
state.

The old global timeline paging provider and index data-source wrappers were
also removed. Global messages now use the same graph-backed evidence scope and
full-skeleton/hydrated-row invariant as the other timeline-like surfaces.

## Deletion Roadmap

1. Keep active route builders pointed at graph/evidence-spine views.
2. Add regression tests that assert message surfaces instantiate shared evidence
   views rather than legacy timeline widgets where practical.
3. For every remaining legacy widget/provider, classify it as:
   - active compatibility requirement,
   - diagnostic/reference artifact, or
   - deletion candidate.
4. Delete legacy message presentation files only after their tests are either
   migrated to evidence-spine equivalents or intentionally removed.

## Guardrails

- Do not create another message row renderer.
- Do not add a conversation-only, contact-only, handle-only, recovered-only, or
  search-only message evidence presentation path.
- Do not use pagination as timeline navigation.
- Timeline-like surfaces must preserve the full selected logical message scope
  through a lightweight skeleton.
- Context-window surfaces may be bounded, but must still use the shared evidence
  presentation vocabulary.
- Raw SQL remains acceptable only inside named infrastructure repositories.
