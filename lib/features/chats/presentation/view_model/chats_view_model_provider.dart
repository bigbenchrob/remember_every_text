import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../../../essentials/sidebar/feature_level_providers.dart';
import '../../application/chat_read_model_source_provider.dart';

part 'chats_view_model_provider.g.dart';

/// View model that handles chat-centric user actions like selection.
@riverpod
class ChatsViewModel extends _$ChatsViewModel {
  @override
  void build() {
    // Stateless controller.
  }

  Future<void> selectChat(
    int chatId, {
    int? anchorMessageId,
    String? searchQuery,
  }) async {
    final notifier = ref.read(
      panelsViewStateProvider(SidebarMode.messages).notifier,
    );
    final readModelSource = ref.read(chatReadModelSourceProvider);
    final messagesSpec = switch (readModelSource) {
      ChatReadModelSourceMode.conversationGraph => MessagesSpec.forConversation(
        conversationId: chatId,
        anchorMessageId: anchorMessageId,
        searchQuery: searchQuery,
      ),
      ChatReadModelSourceMode.legacy => MessagesSpec.forChat(chatId: chatId),
    };
    if (readModelSource == ChatReadModelSourceMode.conversationGraph) {
      ref
          .read(sidebarFlowProvider.notifier)
          .selectConversation(
            conversationId: chatId,
            anchorMessageId: anchorMessageId,
            searchQuery: searchQuery,
          );
      return;
    }
    notifier.show(
      panel: WindowPanel.center,
      spec: ViewSpec.messages(messagesSpec),
    );
  }
}
