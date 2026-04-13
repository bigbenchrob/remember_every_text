import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/navigation/application/panel_widget_providers.dart';
import '../../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../domain/spec_classes/messages_view_spec.dart';

part 'message_context_anchor_provider.g.dart';

final class MessageContextAnchor {
  const MessageContextAnchor({
    required this.messageId,
    required this.chatId,
    required this.beforeCount,
    required this.afterCount,
  });

  final int messageId;
  final int chatId;
  final int beforeCount;
  final int afterCount;

  String get activationKey => '$chatId::$messageId::$beforeCount::$afterCount';

  bool matches({required int messageId, required int chatId}) {
    return this.messageId == messageId && this.chatId == chatId;
  }
}

@riverpod
MessageContextAnchor? messageContextAnchor(Ref ref) {
  final activeRightSpec = ref.watch(
    effectiveRightPanelSpecProvider(SidebarMode.messages),
  );

  return activeRightSpec?.whenOrNull(
    messages: (spec) {
      return spec.whenOrNull(
        searchResultContext: (messageId, chatId, beforeCount, afterCount) {
          return MessageContextAnchor(
            messageId: messageId,
            chatId: chatId,
            beforeCount: beforeCount,
            afterCount: afterCount,
          );
        },
      );
    },
  );
}
