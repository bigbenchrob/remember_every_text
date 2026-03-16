# Test Notes: Message Sidebar Focus

## Manual Test Scenarios

### 1. Normal Mid-Chat Result
- Search for a term with a result from the middle of a long chat.
- Click the magnifying glass.
- Verify the sidebar opens with 10 earlier and 10 later records when available.
- Verify the selected message appears visually centered.

### 2. Near Chat Start
- Open context for a result near the start of a chat.
- Verify fewer than 10 earlier records are handled cleanly.
- Verify the selected record remains clearly anchored.

### 3. Near Chat End
- Open context for a result near the end of a chat.
- Verify fewer than 10 later records are handled cleanly.

### 4. Different Chats With Same Sender Name
- Open context for search results from different chats but with the same sender name.
- Verify each context sidebar contains only records from the selected result's chat.

### 5. Attachment / Variant Records
- Open context for a selected result that is adjacent to media or non-standard records.
- Verify surrounding records render visibly and are not suppressed.

### 6. Search Stability
- Open context from multiple results.
- Verify the search result list itself does not regroup, rerank, or otherwise change behavior.

## Regression Focus
- No changes to global search ranking.
- No changes to ordinary search result retrieval shape.
- No cross-chat contamination in context loading.
- No unintended center-panel navigation when opening sidebar context.