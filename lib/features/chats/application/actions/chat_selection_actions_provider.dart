import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../essentials/sidebar/domain/sidebar_action_intent.dart';

part 'chat_selection_actions_provider.g.dart';

@riverpod
class ChatSelectionActions extends _$ChatSelectionActions {
  @override
  FutureOr<void> build() {}

  Future<void> selectChat(
    int chatId, {
    int? anchorMessageId,
    String? searchQuery,
  }) async {
    try {
      await ref
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
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Chat selection failed',
            source: 'ChatSelectionActions',
            context: <String, Object?>{
              'chatId': chatId,
              'anchorMessageId': anchorMessageId,
              'searchQuery': searchQuery,
              'error': error.toString(),
              'stackTrace': stackTrace.toString(),
            },
          );
    }
  }
}
