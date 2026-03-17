# Design Notes: Message Sidebar Focus

## 1. Core Concept
This feature is a context-expansion surface for one selected message record.

It does not change how search works. Search continues to return individual matching records. The sidebar focus feature receives one selected result and resolves a bounded same-chat window around it.

## 2. Architectural Direction

This feature should use the existing **right/end panel** pattern already used by `MessagesSpec.recoveredAttachmentViewer(...)`.

It should **not** be implemented as the left contextual sidebar overlay used for recovered message surfaces. The target interaction is an explicit search-result action that opens a dedicated end-panel context viewer while leaving the center search surface intact.

### 2.1. Spec-Driven Navigation
The feature should be introduced as a new message-oriented spec variant rather than as local widget state.

Likely shape:

```dart
const factory MessagesSpec.searchResultContext({
  required int messageId,
  required int chatId,
  int beforeCount,
  int afterCount,
}) = _MessagesSearchResultContext;
```

Initial defaults:
- `beforeCount = 10`
- `afterCount = 10`

This keeps the feature inside the existing ViewSpec routing model and allows it to be opened directly into `WindowPanel.right` while the main search result surface stays in `WindowPanel.center`.

### 2.2. Surface Ownership
- Search results stay in the center panel.
- The new context viewer belongs in the end sidebar.
- The user opens it only via the search-row magnifying-glass action.

### 2.3. Resolver Pattern
Use the existing coordinator -> resolver -> widget builder pattern.

Concrete v1 recommendation:
- `lib/features/messages/domain/spec_classes/messages_view_spec.dart`
  - add `MessagesSpec.searchResultContext(...)`
- `lib/features/messages/application/view_spec/coordinators/view_spec_coordinator.dart`
  - route the new variant to a dedicated resolver
- `lib/features/messages/application/view_spec/resolvers/search_result_context_sidebar_resolver.dart`
  - end-panel resolver for the new variant
- `lib/features/messages/application/view_spec/widget_builders/search_result_context_sidebar_builder.dart`
  - widget builder for the end-panel view
- `lib/features/messages/presentation/view/search_result_context_sidebar_view.dart`
  - concrete read-only sidebar UI
- `lib/features/messages/application/view_spec/resolver_tools/search_result_context_provider.dart`
  - bounded same-chat context loader/provider

This mirrors the existing recovered-attachment sidebar path:
- spec variant in `messages_view_spec.dart`
- resolver in `application/view_spec/resolvers/`
- widget builder in `application/view_spec/widget_builders/`
- view in `presentation/view/`

## 3. Data Requirements

### 3.1. Required Inputs
The sidebar context feature needs:
- selected `messageId`
- owning `chatId`
- bounded window size before/after

### 3.2. Query Semantics
Load records from the same chat only.

Recommended provider contract:

```dart
class SearchResultContextState {
  final MessageListItem? selectedMessage;
  final List<MessageListItem> beforeMessages;
  final List<MessageListItem> afterMessages;
  final bool hasMoreBefore;
  final bool hasMoreAfter;
}
```

The provider should return:
- `selectedMessage`
- `beforeMessages`
- `afterMessages`
- booleans indicating whether more context exists above or below

Ordering should remain chronological in the final rendered list.

### 3.3. Centering Rule
The selected message should appear centered when enough earlier and later records exist.

Boundary behavior:
- near the beginning of the chat, the window naturally shifts downward
- near the end of the chat, the window naturally shifts upward

## 4. UI Behavior

### 4.1. Search Result Action
Only the magnifying-glass action opens context.

The base result row remains a search result row, not a mini conversation preview.

Concrete hook point for v1:
- `lib/features/messages/presentation/view/messages_timeline_view.dart`
  - update `_SearchResultRow` to add a magnifying-glass action
  - action should open `WindowPanel.right` with `ViewSpec.messages(MessagesSpec.searchResultContext(...))`

### 4.2. Sidebar Content
The sidebar should:
- show a compact chat/context header
- render the selected message with a clear highlight treatment
- render neighboring messages in the same visual language as the message surfaces already used elsewhere
- remain read-only in v1

### 4.3. Read-Only Scope
Initial version:
- read-only message text context
- no edit/pin/retrieve action yet

Future extension:
- user pinning of important messages for later retrieval

That future work should be treated as a separate follow-on feature.

## 5. Provider Direction
Introduce a dedicated context provider instead of reusing the existing search list providers.

Suggested behavior:
- fetch the selected record
- fetch bounded earlier/later messages from the same chat
- compose a context entity/view model for rendering

Concrete implementation direction:
- `search_result_context_provider.dart` should accept:
  - `messageId`
  - `chatId`
  - `beforeCount`
  - `afterCount`
- it should query only the selected chat
- it should return the selected record plus bounded neighboring records in chronological order

This keeps responsibilities clear:
- search provider: ranking and result ids
- context provider: chat-local neighborhood around one result

## 6. Edge Cases
- selected record missing: render explicit error state
- fewer than 10 records above/below: render available records only
- message has attachments or variant content: still show the record; do not suppress anomalous or attachment-only entries
- selected result from a chat that no longer hydrates normally: render diagnostic fallback, do not silently hide

## 7. Recommended Incremental Build Order
1. Add planning docs and freeze feature scope.
2. Add `MessagesSpec.searchResultContext(...)` to `messages_view_spec.dart`.
3. Route the new variant in `view_spec_coordinator.dart`.
4. Add `search_result_context_sidebar_resolver.dart`.
5. Add `search_result_context_provider.dart`.
6. Add `search_result_context_sidebar_builder.dart` and `search_result_context_sidebar_view.dart`.
7. Add the magnifying-glass action in `_SearchResultRow` inside `messages_timeline_view.dart`.
8. Polish header, selected-message highlight, and loading/empty/error states.

## 8. Concrete First Slice
The safest first implementation slice is:
1. Add the new `MessagesSpec.searchResultContext(...)` variant.
2. Add resolver + builder + placeholder sidebar view.
3. Wire the magnifying-glass action to open that placeholder in `WindowPanel.right`.

This gives end-to-end navigation before the bounded same-chat data loader is added.

## 9. Manual Validation Targets
- result opens context only from the magnifying-glass action
- context window is chat-local only
- selected message is centered when possible
- top/bottom boundary behavior is graceful
- search result list remains unchanged after context opens