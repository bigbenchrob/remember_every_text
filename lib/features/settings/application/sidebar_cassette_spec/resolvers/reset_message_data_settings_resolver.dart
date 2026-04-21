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
          'Use this if the messages or contacts shown in MessageLens do not match what you see in Messages or Contacts on your Mac. Selecting Reset message data opens a confirmation dialog before anything is deleted. Resetting clears only MessageLens databases, keeps your preferences, and re-imports from your Mac the next time you open the app.',
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
