import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/feature_level_providers.dart';

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
    ref
        .read(sidebarFlowProvider.notifier)
        .selectConversation(
          conversationId: chatId,
          anchorMessageId: anchorMessageId,
          searchQuery: searchQuery,
        );
  }
}
