# Checklist: Message Sidebar Focus

- Confirm this feature remains separate from regular search behavior.
- Define `MessagesSpec.searchResultContext` in `messages_view_spec.dart`.
- Route the new variant in `application/view_spec/coordinators/view_spec_coordinator.dart`.
- Add `application/view_spec/resolvers/search_result_context_sidebar_resolver.dart`.
- Add `application/view_spec/widget_builders/search_result_context_sidebar_builder.dart`.
- Add `presentation/view/search_result_context_sidebar_view.dart`.
- Add `application/view_spec/resolver_tools/search_result_context_provider.dart`.
- Ensure provider inputs include both `messageId` and `chatId`.
- Keep initial window at 10 records before and 10 after.
- Center the selected record when possible.
- Add the magnifying-glass action in `_SearchResultRow` in `messages_timeline_view.dart`.
- Do not make row click open context in v1.
- Keep sidebar content read-only.
- Highlight the selected record clearly in the sidebar.
- Open the context surface in `WindowPanel.right`.
- Handle missing-message and short-window boundary cases explicitly.
- Verify no search ranking or result retrieval behavior changes.
- Verify no cross-chat context mixing.
