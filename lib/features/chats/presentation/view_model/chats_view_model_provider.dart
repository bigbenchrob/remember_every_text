import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
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
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: ConversationSelected(
            conversationId: chatId,
            anchorMessageId: anchorMessageId,
            searchQuery: searchQuery,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
          ),
        );
  }
}
