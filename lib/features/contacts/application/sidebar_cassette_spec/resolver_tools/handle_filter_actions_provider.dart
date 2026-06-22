import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/logging/feature_level_providers.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../services/manual_handle_link_service.dart';

part 'handle_filter_actions_provider.g.dart';

@riverpod
class HandleFilterActions extends _$HandleFilterActions {
  @override
  FutureOr<void> build() {}

  Future<void> selectHandle({
    required int contactId,
    required int? handleId,
    required int cassetteIndex,
  }) async {
    await _dispatch(
      ContactHandleSelected(contactId: contactId, handleId: handleId),
      cassetteIndex: cassetteIndex,
    );
  }

  Future<void> unlinkSelectedHandle({
    required int contactId,
    required int selectedHandleId,
    required int cassetteIndex,
  }) async {
    final result = await ref
        .read(manualHandleLinkServiceProvider.notifier)
        .unlinkHandle(handleId: selectedHandleId);

    bool? contactDeleted;
    result.fold(
      (failure) {
        ref
            .read(appLoggerProvider.notifier)
            .warn(
              'Selected contact handle unlink failed',
              source: 'HandleFilterActions',
              context: {
                'contactId': contactId,
                'selectedHandleId': selectedHandleId,
                'failure': failure.message,
              },
            );
      },
      (deleted) {
        contactDeleted = deleted;
      },
    );
    if (contactDeleted == null) {
      return;
    }

    if (contactDeleted!) {
      await _dispatch(
        const ChooseAnotherContact(),
        cassetteIndex: cassetteIndex,
      );
      return;
    }

    await selectHandle(
      contactId: contactId,
      handleId: null,
      cassetteIndex: cassetteIndex,
    );
  }

  Future<void> _dispatch(
    SidebarActionIntent intent, {
    required int cassetteIndex,
  }) async {
    await ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: intent,
          context: SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
            cassetteIndex: cassetteIndex,
          ),
        );
  }
}
