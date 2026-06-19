# Checklist: Enhanced Message Search

## Current Conformance Note (2026-06-06)

This checklist is historical. Future enhanced-search work should be planned
against `GraphSearchRepository`, typed graph search scopes, and evidence-spine
tests rather than retained `working.db` FTS/indexer tasks.
Unchecked items below are not approved implementation tasks unless rewritten
for graph search repository boundaries and source-scoped `message_ss_id`
evidence scopes.

## Phase 1: Foundation & Lexical Search

- [ ] **Infrastructure Setup**
    - [ ] Define `SearchIndexer` interface.
    - [ ] Define `SearchContext` class.
    - [ ] Create `SearchIndexOrchestrator` skeleton.
    - [ ] Register `SearchIndexOrchestrator` in Riverpod.

- [ ] **FTS Indexer**
    - [ ] Implement `FtsMessageIndexer`.
    - [ ] Implement `rebuildAll` (truncate/fill).
    - [ ] Implement `validate` (row count check).

- [ ] **Query Parsing & Execution**
    - [ ] Implement `SearchQueryParser` (basic term splitting).
    - [ ] Implement `SearchEngine` (FTS query execution).
    - [ ] Create `SearchPlan` value object.

- [ ] **UI Integration**
    - [ ] Update `GlobalMessagesViewModel` to use `SearchEngine`.
    - [ ] Update `ContactMessagesViewModel` to use `SearchEngine`.

## Phase 2: Indexing Infrastructure & Example

- [ ] **Emotional Indexer (Schema)**
    - [ ] Graph-era rewrite required: define any emotion/semantic features as graph-search acceleration data behind repository methods, not retained `working.db` schema.
    - [ ] Run `dart run build_runner build`.

- [ ] **Emotional Indexer (Logic)**
    - [ ] Implement `MessageEmotionIndexer`.
    - [ ] Implement heuristic logic (caps, emojis).
    - [ ] Register in `SearchIndexOrchestrator`.

- [ ] **Pipeline Integration**
    - [ ] Graph-era rewrite required: integrate any derived search acceleration with graph lifecycle orchestration without making it evidence-rendering authority.
    - [ ] Verify new messages get indexed automatically.

- [ ] **Search Enhancements**
    - [ ] Update `SearchQueryParser` to handle `emotion:intense`.
    - [ ] Update `SearchEngine` to filter by emotion features.

## Phase 3: Verification & Cleanup

- [ ] **Testing**
    - [ ] Unit test `SearchQueryParser`.
    - [ ] Integration test FTS search (multi-term).
    - [ ] Verify incremental updates work end-to-end.
- [ ] **Documentation**
    - [ ] Update `STATUS.md`.
    - [ ] Move feature docs to `40-FEATURES`.
