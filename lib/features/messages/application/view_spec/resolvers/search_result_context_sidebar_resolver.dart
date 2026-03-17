import 'package:flutter/widgets.dart';

import '../widget_builders/search_result_context_sidebar_builder.dart';

class SearchResultContextSidebarResolver {
  SearchResultContextSidebarResolver();

  static const _builder = SearchResultContextSidebarBuilder();

  Widget resolve({
    required int messageId,
    required int chatId,
    required int beforeCount,
    required int afterCount,
  }) {
    return _builder.build(
      messageId: messageId,
      chatId: chatId,
      beforeCount: beforeCount,
      afterCount: afterCount,
    );
  }
}
