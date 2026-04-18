import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../payloads/settings_action_card_cassette_payload.dart';

part 'settings_action_card_resolver.g.dart';

@riverpod
class SettingsActionCardResolver extends _$SettingsActionCardResolver {
  @override
  void build() {}

  SettingsActionCardCassettePayload resolve({
    required int cassetteIndex,
    required List<SidebarActionDescriptor> actions,
  }) {
    return SettingsActionCardCassettePayload(
      cassetteIndex: cassetteIndex,
      actions: actions,
    );
  }
}
