import 'package:flutter/widgets.dart';

import '../widget_builders/conversation_excerpt_panel_builder.dart';

class ConversationExcerptPanelResolver {
  ConversationExcerptPanelResolver();

  static const _builder = ConversationExcerptPanelBuilder();

  Widget resolve({
    required int conversationId,
    required int anchorMessageId,
    required int beforeCount,
    required int afterCount,
  }) {
    return _builder.build(
      conversationId: conversationId,
      anchorMessageId: anchorMessageId,
      beforeCount: beforeCount,
      afterCount: afterCount,
    );
  }
}
