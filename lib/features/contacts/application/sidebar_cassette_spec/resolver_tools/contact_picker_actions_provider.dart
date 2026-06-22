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
    unawaited(_prewarmContactProfile(contactId: contactId));
    unawaited(_prewarmContactMessages(contactId: contactId));
  }

  Future<void> _prewarmContactProfile({required int contactId}) async {
    try {
      await ref.read(contactProfileProvider(contactId: contactId).future);
    } catch (error, stackTrace) {
      _logPrewarmFailure(
        contactId: contactId,
        stage: 'contactProfile',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _prewarmContactMessages({required int contactId}) async {
    try {
      await ref.read(
        messages_feature
            .prewarmContactMessagesProvider(contactId: contactId)
            .future,
      );
    } catch (error, stackTrace) {
      _logPrewarmFailure(
        contactId: contactId,
        stage: 'contactMessages',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _logPrewarmFailure({
    required int contactId,
    required String stage,
    required Object error,
    required StackTrace stackTrace,
  }) {
    ref
        .read(appLoggerProvider.notifier)
        .warn(
          'Contact prewarm failed',
          source: 'ContactPickerActions',
          context: <String, Object?>{
            'contactId': contactId,
            'stage': stage,
            'error': error.toString(),
            'stackTrace': stackTrace.toString(),
          },
        );
  }
}
