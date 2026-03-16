# Design Notes: Message Sidebar Focus

## 1. Core Concept
This feature is a context-expansion surface for one selected message record.

It does not change how search works. Search continues to return individual matching records. The sidebar focus feature receives one selected result and resolves a bounded same-chat window around it.

## 2. Architectural Direction

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

This keeps the feature inside the existing ViewSpec routing model.

### 2.2. Surface Ownership
- Search results stay in the center panel.
- The new context viewer belongs in the end sidebar.
- The user opens it only via the search-row magnifying-glass action.

### 2.3. Resolver Pattern
Use the existing coordinator -> resolver -> widget builder pattern.

Suggested pieces:
- `MessagesSpec.searchResultContext(...)`
- end-sidebar resolver for that spec
- context widget builder
- focused context provider/tooling for bounded same-chat loading

## 3. Data Requirements

### 3.1. Required Inputs
The sidebar context feature needs:
- selected `messageId`
- owning `chatId`
- bounded window size before/after

### 3.2. Query Semantics
Load records from the same chat only.

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
2. Add spec variant and navigation plumbing.
3. Add bounded same-chat context provider.
4. Add sidebar widget builder with selected-message highlight.
5. Add search-row magnifying-glass action.
6. Polish header and loading/empty/error states.

## 8. Manual Validation Targets
- result opens context only from the magnifying-glass action
- context window is chat-local only
- selected message is centered when possible
- top/bottom boundary behavior is graceful
- search result list remains unchanged after context opens