# Graph Message Presentation Migration Audit

## Current State

MessageLens currently has two authoritative message data paths feeding center-panel evidence.

### Legacy-backed message evidence

These paths still read from legacy `working.db` through `driftWorkingDatabaseProvider`:

- `MessagesSpec.forContact` -> `MessagesForContactResolver` -> `MessagesTimelineView(scope: MessageTimelineScope.contact(...))`
- `MessagesSpec.globalTimeline` -> `GlobalTimelineResolver` -> `MessagesTimelineView(scope: MessageTimelineScope.global())`
- `MessagesSpec.forChat` / `MessageTimelineScope.chat` infrastructure is legacy-shaped, though the current `forChat` center route is still a placeholder.
- `MessagesSpec.recoveredUnlinkedMessages` and `MessagesSpec.recoveredNoHandleFromMeMessages` are legacy/recovery surfaces outside the normal graph topology.
- `MessagesSpec.searchResultContext`, `MessagesSpec.forHandle`, and `MessagesSpec.handleLens` still use legacy message providers or legacy working tables.

The main legacy timeline path resolves message ordinals through `MessageTimelineScope` strategies, hydrates rows through `messageByTimelineOrdinalProvider` / `messageByIdProvider`, maps them through `MessageRowMapper`, and renders through `MessageCard`.

Legacy-backed paths can render image/video/link-preview attachments today because `MessageRowMapper` loads legacy `workingAttachments`, resolves display availability through the attachment resolver, produces `MessageListItem.attachments`, and `MessageCard` delegates to `ImageMessageTile`, `VideoMessageTile`, or `MessageLinkPreviewCard`.

### Graph-backed message evidence

These paths read from `working_ss.db` through `driftConversationGraphDatabaseProvider`:

- `MessagesSpec.forConversation` -> `ConversationMessagesPreviewView`
- Conversations sidebar signature list and contact "By conversation" lists through `conversation_graph` readers.
- Conversation favourites and signature display overlays.

The graph conversation message path uses `conversationMessagesProvider` -> `ConversationReader` -> `SqliteConversationRepository` to produce `ConversationMessage`. Attachment details are loaded separately by `messageAttachmentsProvider` -> `ChatSummaryReader` -> `SqliteChatSummaryRepository`.

Graph-backed conversation messages now share the center evidence header/fade primitives and use the shared text tile language for primary text, but their attachment display is still a separate textual chip path.

## Current Presentation Paths

Shared or partially shared:

- `MessageEvidenceHeader` is the shared center-panel evidence header.
- `MessageEvidenceFadeOverlay` is the shared scroll-collision fade under the header.
- `MessageEvidenceBadge` / `MessageEvidenceBadgeStrip` are shared evidence badges.
- `TextMessageTile`, `ImageMessageTile`, `VideoMessageTile`, `MessageShell`, and `MetadataLine` are the existing shared message tile primitives.
- `MessageCard` is the mature shared renderer for legacy-hydrated `MessageListItem` rows.

Legacy/contact/global presentation:

- `MessagesTimelineView` renders contact/global/recovered/chat timeline surfaces.
- `_MessageRow` hydrates `MessageListItem` and renders `MessageCard`.
- `MessageCard` can render text, image, video, and link-preview evidence.

Graph conversation presentation:

- `ConversationMessagesPreviewView` resolves `ConversationMessage` rows.
- `_ConversationMessageRow` now uses shared `TextMessageTile` for the primary message body.
- `_ConversationMessageAttachments` and `_ConversationAttachmentChip` remain mode-specific and text-only.

Duplicated or mode-specific areas:

- Attachment rendering differs between graph conversation messages and legacy timeline messages.
- Graph conversation messages use `ConversationMessage`, while legacy timelines use `MessageListItem`.
- The graph message attachment model is `MessageAttachment`; the legacy renderable attachment model is hydrated `AttachmentInfo`.
- Conversation message semantic badges are graph-specific, but the badge presentation itself is now shared.

## Attachment Evidence Gap

Images show in contact/global views because that path produces `MessageListItem.attachments` as hydrated `AttachmentInfo` objects. Those objects are already resolved for display and are consumed by `MessageCard`, `ImageMessageTile`, and `VideoMessageTile`.

Images do not show in conversation views because the graph path does not currently produce the same render-ready attachment evidence. It only loads `MessageAttachment` records on demand and renders them as textual chips.

This is primarily a read-model / evidence-model gap, not a schema or projection gap.

The graph schema appears to preserve enough attachment facts to support display:

- `message_to_attachment` links graph messages to graph attachments.
- `attachments` carries filename, transfer name, UTI, MIME type, byte count, and timestamps.
- `messageAttachmentsProvider` can determine archive existence and archive path through overlay/archive lookup.

However, graph-backed messages do not yet carry a first-class renderable attachment evidence model equivalent to hydrated `AttachmentInfo`. The current `MessageAttachment` model has useful archive facts, but it is not the same contract expected by `ImageMessageTile` / `VideoMessageTile`.

An adapter could map `MessageAttachment.archiveAbsolutePath` into a displayable `AttachmentInfo`, but if that adapter lives in the presentation widget it would be a migration shortcut. The safer direction is to create a named graph attachment evidence read model or mapper outside the low-level renderer.

## Graph Migration Status

Graph is authoritative for:

- Conversation identity and topology in the Conversations sidebar.
- Contact-derived conversation lists.
- Conversation signatures and monthly glyphs.
- Conversation favourites overlays.
- `MessagesSpec.forConversation` center-panel conversation evidence.
- Source-scoped import/projection proof flow and graph health diagnostics.

Legacy is still authoritative for:

- Contact "All messages" center-panel timelines.
- Global all-message timelines.
- Existing ordinal timeline infrastructure.
- Existing `MessageCard` hydration through `working.db`.
- Attachment display hydration and resolver-backed media presentation.
- Handle lens / stray handle review message lists.
- Recovered deleted-message and recovered no-handle surfaces.
- Search result context surfaces.

Still necessary legacy code:

- Legacy `working.db` remains necessary until contact/global/recovered/search/handle evidence surfaces migrate to graph-backed query models.
- Existing attachment resolver and archive code remains necessary and should be reused, not bypassed.
- Legacy import/migration remains necessary while SS/graph import replaces it incrementally.

Diagnostic/reference legacy code:

- The old conversation browser/list presentation is now mostly reference/diagnostic.
- Any center-panel conversation list path should remain non-default while conversation signatures drive navigation.

## Risks

- A conversation-only attachment renderer would create a third message evidence path.
- A presentation-layer adapter from `MessageAttachment` to `AttachmentInfo` would hide semantic policy in widgets.
- Adding attachment display directly inside `_ConversationMessageAttachments` would preserve the split between graph and legacy message evidence.
- Continuing to improve legacy `MessagesTimelineView` without moving it graphward delays the deletion path.
- Moving contact/global views to graph too abruptly risks losing mature attachment resolution, search/month navigation, and heatmap behavior.

## Recommended Sequence

1. Define a graph-backed renderable message evidence row.

   Create an application/read-model object that can represent text, sender, date, semantic badges, and render-ready attachments for graph messages. This should be conceptually compatible with the shared tile primitives, but it does not need to reuse `MessageListItem` if that would import legacy assumptions.

2. Add graph attachment evidence hydration outside widgets.

   Add a mapper or repository method that converts graph `MessageAttachment` facts into a render-ready attachment evidence object, including display path / availability / provenance. This may reuse the existing attachment resolver/archive services, but the conversion must be named and tested outside presentation.

3. Make `ConversationMessagesPreviewView` consume render-ready graph evidence rows.

   Replace `_ConversationMessageAttachments` textual chip rendering with shared `ImageMessageTile` / `VideoMessageTile` / text fallback through the shared evidence row model. If a temporary adapter is needed, name it explicitly as temporary and keep it outside low-level widgets.

4. Migrate contact "All messages" to graph-backed evidence.

   Add a graph contact message path that answers the same center-panel spec currently served by `MessageTimelineScope.contact`. Preserve the timeline invariant: full lightweight skeleton first; local row hydration second.

   The graph contact route must not be implemented as a latest-page or month-page query. Pagination is not timeline navigation.

   Required graph contact timeline shape:

   - full selected-scope skeleton of stable message `ss_id`s, timestamps, and month keys
   - heatmap counts and selected-month feedback coordinated against that full skeleton
   - latest/month jumps into skeleton index space
   - visible row hydration by message `ss_id`
   - attachment/media/URL preview hydration outside the skeleton and near the viewport

   Current graph contact implementation points:

   - `contactPageGraphMessageTimelineProvider` supplies the full lightweight contact skeleton.
   - `contactPageGraphMessageByIdProvider` hydrates one graph message row by id.
   - `ContactGraphMessagesView` renders a `ScrollablePositionedList` over the skeleton and hydrates visible rows through shared graph evidence rows.

5. Migrate global timeline/search/handle surfaces.

   Move global/search/handle evidence onto graph-backed queries after contact evidence proves parity. Timeline-like surfaces must follow the same skeleton/hydration invariant; sample/search result lists may use bounded result sets only when they are not being presented as full timeline navigation.

6. Delete or quarantine legacy message presentation paths.

   Once graph-backed contact/global/search/recovered equivalents exist, remove duplicated legacy center-panel renderers or leave them only behind explicit diagnostic/dev routes.

## Files Involved

Current center routing:

- `lib/features/messages/domain/spec_classes/messages_view_spec.dart`
- `lib/features/messages/application/view_spec/coordinators/view_spec_coordinator.dart`

Legacy timeline evidence:

- `lib/features/messages/presentation/view/messages_timeline_view.dart`
- `lib/features/messages/presentation/widgets/message_card.dart`
- `lib/features/messages/presentation/view_model/shared/message_row_mapper.dart`
- `lib/features/messages/presentation/view_model/timeline/hydration/message_by_ordinal_provider.dart`
- `lib/features/messages/presentation/view_model/timeline/hydration/message_by_id_provider.dart`
- `lib/features/messages/application/timeline/ordinal/message_timeline_scope_ordinal_extensions.dart`

Graph conversation evidence:

- `lib/features/messages/presentation/view/conversation_messages_preview_view.dart`
- `lib/essentials/conversation_graph/application/conversations/conversation.dart`
- `lib/essentials/conversation_graph/application/conversations/conversation_reader_provider.dart`
- `lib/essentials/conversation_graph/infrastructure/repositories/conversation_repository.dart`
- `lib/essentials/conversation_graph/application/chat_summaries/chat_summary.dart`
- `lib/essentials/conversation_graph/application/chat_summaries/chat_summary_provider.dart`
- `lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart`

Shared presentation:

- `lib/features/messages/presentation/widgets/message_evidence/message_evidence_header.dart`
- `lib/features/messages/presentation/widgets/message_evidence/message_evidence_fade_overlay.dart`
- `lib/features/messages/presentation/widgets/message_evidence/message_evidence_badges.dart`
- `lib/features/messages/presentation/view_model/shared/display_widgets/new_display_widgets.dart`

## Tests Needed

- Graph attachment evidence hydration maps archived image/video files to display-ready evidence.
- Missing graph attachments remain visibly rendered as unavailable evidence.
- Conversation messages render image attachments through shared media tiles.
- Conversation messages render video attachments through shared media tiles or activation shell.
- Text-only graph messages continue to render with shared text tile language.
- Existing conversation message timeline tests continue to pass.
- Existing `MessageCard` tests continue to pass.
- Contact/global timeline tests continue to pass until those surfaces are migrated.
- Graph contact timeline tests prove full skeleton ordering/month keys independently from row hydration.
- Graph contact heatmap tests prove month selection updates projected contact timeline state and jumps into skeleton index space rather than issuing a page-style message query.
- Graph message view tests prove default latest positioning and selected-month visible-month feedback using the skeleton.

## Eventually Deletable

After graph-backed message evidence fully replaces legacy center-panel evidence, these should be candidates for deletion, replacement, or diagnostic-only quarantine:

- Legacy `MessageTimelineScope` ordinal strategies for contact/global/chat.
- Legacy `MessageRowMapper` tied to `working.db`.
- Legacy `MessagesTimelineView` paths that remain `working.db`-specific.
- `MessagesForHandleView` and `HandleLensView` private message renderers.
- Conversation-only attachment chip rendering in `ConversationMessagesPreviewView`.
- Any placeholder `MessagesSpec.forChat` route that does not use graph conversations.

## Lowest-Risk Next Step

Do not add a conversation-only attachment renderer.

The next implementation slice should introduce graph attachment evidence hydration as a named application/read-model boundary, then make conversation messages use the shared media tiles through that boundary.

If a temporary adapter is unavoidable, it should be:

- outside low-level widgets,
- named as temporary,
- covered by tests,
- limited to graph `MessageAttachment` -> renderable evidence conversion,
- explicitly scheduled for removal once contact/global message evidence migrates to graph.
