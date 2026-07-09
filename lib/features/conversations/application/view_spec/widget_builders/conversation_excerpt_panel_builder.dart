import 'package:flutter/widgets.dart';

import '../../../presentation/view/conversation_excerpt_panel_view.dart';

class ConversationExcerptPanelBuilder {
  const ConversationExcerptPanelBuilder();

  Widget build({
    required int conversationId,
    required int anchorMessageId,
    required int beforeCount,
    required int afterCount,
  }) {
    return ConversationExcerptPanelView(
      conversationId: conversationId,
      anchorMessageId: anchorMessageId,
      beforeCount: beforeCount,
      afterCount: afterCount,
    );
  }
}
