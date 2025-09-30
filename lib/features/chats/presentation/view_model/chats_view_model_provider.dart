import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/navigation/application/panels_view_state_provider.dart';
import '../../../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';

part 'chats_view_model_provider.g.dart';

/// View model that handles chat-centric user actions like selection.
@riverpod
class ChatsViewModel extends _$ChatsViewModel {
  @override
  void build() {
    // Stateless controller.
  }

  Future<void> selectChat(int chatId) async {
    final notifier = ref.read(panelsViewStateProvider.notifier);
    notifier.show(
      panel: WindowPanel.center,
      spec: ViewSpec.messages(MessagesSpec.forChat(chatId: chatId)),
    );
  }
}
