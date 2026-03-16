# Checklist: Message Sidebar Focus

- Confirm this feature remains separate from regular search behavior.
- Define `MessagesSpec.searchResultContext` (or equivalent) for sidebar routing.
- Choose the exact end-sidebar resolver/coordinator integration point.
- Add a bounded same-chat context provider.
- Ensure provider inputs include both `messageId` and `chatId`.
- Keep initial window at 10 records before and 10 after.
- Center the selected record when possible.
- Add the magnifying-glass action to search result rows.
- Do not make row click open context in v1.
- Keep sidebar content read-only.
- Highlight the selected record clearly in the sidebar.
- Handle missing-message and short-window boundary cases explicitly.
- Verify no search ranking or result retrieval behavior changes.
- Verify no cross-chat context mixing.
