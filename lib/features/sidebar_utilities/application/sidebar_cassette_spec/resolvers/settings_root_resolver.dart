import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/settings_top_menu_row.dart';
import '../../../domain/sidebar_utilities_constants.dart';
import '../payloads/settings_top_menu_cassette_payload.dart';

part 'settings_root_resolver.g.dart';

@riverpod
class SettingsRootResolver extends _$SettingsRootResolver {
  @override
  void build() {
    // Stateless resolver; invoked imperatively.
  }

  Future<SettingsTopMenuCassettePayload> resolve({
    required int cassetteIndex,
    required SettingsMenuActionId? persistentContextActionId,
  }) async {
    return SettingsTopMenuCassettePayload(
      cassetteIndex: cassetteIndex,
      promptLabel: 'Choose setting or action',
      persistentContextActionId: persistentContextActionId,
      rows: const [
        SettingsTopMenuGroupHeaderRow(label: 'Troubleshooting'),
        SettingsTopMenuActionRow.transientAction(
          label: 'Send logs…',
          actionId: SettingsMenuActionId.sendLogs,
        ),
        SettingsTopMenuActionRow.transientAction(
          label: 'Reset message data…',
          actionId: SettingsMenuActionId.resetMessageData,
        ),
        SettingsTopMenuGroupHeaderRow(label: 'Appearance'),
        SettingsTopMenuActionRow.persistentContext(
          label: 'Text size…',
          actionId: SettingsMenuActionId.textSize,
        ),
        SettingsTopMenuActionRow.persistentContext(
          label: 'Image size…',
          actionId: SettingsMenuActionId.imageSize,
        ),
      ],
    );
  }
}
