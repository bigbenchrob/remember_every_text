import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../payloads/settings_info_actions_cassette_payload.dart';

part 'send_logs_settings_resolver.g.dart';

@riverpod
class SendLogsSettingsResolver extends _$SendLogsSettingsResolver {
  @override
  void build() {}

  SettingsInfoActionsCassettePayload resolve({required int cassetteIndex}) {
    return SettingsInfoActionsCassettePayload(
      cassetteIndex: cassetteIndex,
      bodyText:
          'Send log data to help diagnose problems with MessageLens. The exported report includes application logs and database health diagnostics. It does not modify your imported data.',
      actions: const [
        SidebarActionDescriptor(
          label: 'Send log data…',
          intent: SendLogsRequested(),
          tone: SidebarActionTone.primary,
        ),
      ],
    );
  }
}
