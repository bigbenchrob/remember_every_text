import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/logging/feature_level_providers.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../messages/feature_level_providers.dart' as messages_feature;
import '../../../feature_level_providers.dart';

part 'contact_picker_actions_provider.g.dart';

@riverpod
class ContactPickerActions extends _$ContactPickerActions {
  @override
  FutureOr<void> build() {}

  Future<void> chooseContact({
    required int contactId,
    required int cassetteIndex,
  }) async {
    prewarmContact(contactId: contactId);
    await ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: ContactChosen(contactId: contactId),
          context: SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
            cassetteIndex: cassetteIndex,
          ),
        );
  }

  Future<void> chooseAnotherContact({
    required int contactId,
    required int cassetteIndex,
  }) async {
    ref
        .read(appLoggerProvider.notifier)
        .debug(
          'Change contact tapped',
          source: 'ContactSelectionControl',
          context: {'contactId': contactId, 'cassetteIndex': cassetteIndex},
        );

    await ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: const ChooseAnotherContact(),
          context: SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
            cassetteIndex: cassetteIndex,
          ),
        );
  }

  void prewarmContact({required int contactId}) {
    unawaited(ref.read(contactProfileProvider(contactId: contactId).future));
    unawaited(
      ref.read(
        messages_feature
            .prewarmContactMessagesProvider(contactId: contactId)
            .future,
      ),
    );
  }
}
