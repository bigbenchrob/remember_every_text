import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../payloads/settings_info_actions_cassette_payload.dart';

part 'reset_message_data_settings_resolver.g.dart';

@riverpod
class ResetMessageDataSettingsResolver
    extends _$ResetMessageDataSettingsResolver {
  @override
  void build() {}

  SettingsInfoActionsCassettePayload resolve({required int cassetteIndex}) {
    return SettingsInfoActionsCassettePayload(
      cassetteIndex: cassetteIndex,
      title: 'Reset Message Data',
      bodyText:
          'Use this advanced action if the messages or contacts shown in '
          'MessageLens do not match what you see in Messages or Contacts on '
          'your Mac. After confirmation, Start Fresh removes only rebuildable '
          'imported-message and conversation-index data. It preserves your '
          'preferences, MessageLens customizations, setup history, and '
          'archived attachments, verifies a clean state, then restarts '
          'Onboarding. It does not change Apple Messages, Contacts, archive '
          'source folders, or recovery donors.',
      actions: const [
        SidebarActionDescriptor(
          label: 'Reset message data…',
          intent: ResetMessageDataRequested(),
          tone: SidebarActionTone.destructive,
        ),
      ],
    );
  }
}
