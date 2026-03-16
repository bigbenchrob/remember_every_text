# Feature Proposal: Message Sidebar Focus

## 1. Summary
Add a dedicated read-only end-sidebar context view that can be opened from an individual search result via a magnifying-glass action. The context view keeps regular search result retrieval record-based, but lets the user inspect the selected message in conversational context by loading nearby records from the same chat.

This is a separate feature from regular search. Search remains responsible for finding individual message records. The new sidebar focus feature is responsible for expanding one selected result into local same-chat context.

## 2. Goals
1. Keep search results flat and record-based.
2. Add an explicit action to inspect a result in context without leaving the search surface.
3. Show the selected message centered within an initial same-chat window of 10 records before and 10 records after.
4. Keep the initial version read-only at the message-text level.
5. Fit the existing ViewSpec and sidebar architecture rather than introducing ad hoc view state.

## 3. Scope
### In Scope
- Add a magnifying-glass affordance on search result rows.
- Open a dedicated end-sidebar context surface for the selected result.
- Load 10 earlier and 10 later records from the same chat as the selected message.
- Center the selected message in the context view when possible.
- Highlight the selected message clearly within the context window.
- Keep the feature read-only in v1.

### Out of Scope
- Changing search retrieval to grouped or conversation-level results.
- Editing, annotation, pinning, or retrieval workflows from the context sidebar.
- Loading cross-chat context.
- Replacing the center panel search results surface.
- Changing ordinal hydration or main timeline virtualization semantics.

## 4. Product Shape
- The user searches as normal.
- Each search result row exposes a magnifying-glass action.
- Clicking only that action opens the end sidebar context view.
- The sidebar shows a bounded same-chat message window centered on the selected result.
- The selected message is the visual anchor inside the sidebar.

## 5. Why This Is Separate From Search
Regular search answers: "Which individual records match this query?"

Sidebar focus answers: "What was happening around this record in its original conversation?"

Treating these as separate features preserves clean responsibilities:
- Search stays index/ranking/result oriented.
- Sidebar focus stays context/navigation/original-conversation oriented.

## 6. Risks & Constraints
- Context loading must never mix messages from different chats.
- The sidebar feature should not implicitly change the selected result list or ranking behavior.
- The new context view should use existing spec/resolver patterns instead of custom local navigation state.
- The initial bounded window must be small and predictable for performance.

## 7. Success Criteria
- Search results remain individual messages.
- Clicking the magnifying glass opens a same-chat context sidebar.
- The selected message is visible and centered within a 10-before / 10-after window when enough records exist.
- The feature is read-only in v1.
- No existing timeline hydration or record identity behavior changes.