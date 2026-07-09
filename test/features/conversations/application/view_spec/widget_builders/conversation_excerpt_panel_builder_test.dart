import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/conversations/application/view_spec/widget_builders/conversation_excerpt_panel_builder.dart';
import 'package:remember_this_text/features/conversations/presentation/view/conversation_excerpt_panel_view.dart';

void main() {
  test(
    'conversation excerpt builder returns conversation excerpt panel view',
    () {
      expect(
        const ConversationExcerptPanelBuilder().build(
          conversationId: 200,
          anchorMessageId: 100,
          beforeCount: 5,
          afterCount: 10,
        ),
        isA<ConversationExcerptPanelView>(),
      );
    },
  );
}
