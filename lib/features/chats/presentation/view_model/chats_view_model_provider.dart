import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/navigation/application/panels_view_state_provider.dart';
import '../../../../essentials/navigation/domain/entities/features/messages_spec.dart';

import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';

part 'chats_view_model_provider.g.dart';

/// ChatsViewModel using clean separation of concerns architecture.
/// Provides stateless actions; state type is void.
@riverpod
class ChatsViewModel extends _$ChatsViewModel {
  @override
  void build() {
    // Stateless: no initialization needed.
  }

  void selectChat(int chatId) {
    final notifier = ref.read(panelsViewStateProvider.notifier);
    notifier.show(
      panel: WindowPanel.center, // target panel
      spec: ViewSpec.messages(MessagesSpec.forChat(chatId: chatId)),
    );
  }
}
