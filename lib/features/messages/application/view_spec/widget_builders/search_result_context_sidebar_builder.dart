import 'package:flutter/widgets.dart';

import '../../../presentation/view/search_result_context_sidebar_view.dart';

class SearchResultContextSidebarBuilder {
  const SearchResultContextSidebarBuilder();

  Widget build({
    required int messageId,
    required int chatId,
    required int beforeCount,
    required int afterCount,
  }) {
    return SearchResultContextSidebarView(
      messageId: messageId,
      chatId: chatId,
      beforeCount: beforeCount,
      afterCount: afterCount,
    );
  }
}
