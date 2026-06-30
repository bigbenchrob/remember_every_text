import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/actions/chat_selection_actions_provider.dart';

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
    await ref
        .read(chatSelectionActionsProvider.notifier)
        .selectChat(
          chatId,
          anchorMessageId: anchorMessageId,
          searchQuery: searchQuery,
        );
  }
}
