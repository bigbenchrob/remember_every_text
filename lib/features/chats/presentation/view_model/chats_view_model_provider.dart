import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../application/chat_read_model_source_provider.dart';

part 'chats_view_model_provider.g.dart';

/// View model that handles chat-centric user actions like selection.
@riverpod
class ChatsViewModel extends _$ChatsViewModel {
  @override
  void build() {
    // Stateless controller.
  }

  Future<void> selectChat(int chatId) async {
    final notifier = ref.read(
      panelsViewStateProvider(SidebarMode.messages).notifier,
    );
    final readModelSource = ref.read(chatReadModelSourceProvider);
    final messagesSpec = switch (readModelSource) {
      ChatReadModelSourceMode.conversationGraph => MessagesSpec.forConversation(
        conversationId: chatId,
      ),
      ChatReadModelSourceMode.legacy => MessagesSpec.forChat(chatId: chatId),
    };
    notifier.show(
      panel: WindowPanel.center,
      spec: ViewSpec.messages(messagesSpec),
    );
  }
}
