import 'package:flutter/widgets.dart';

import '../payloads/settings_action_card_cassette_payload.dart';
import 'settings_action_list.dart';

class SettingsActionCardWidget extends StatelessWidget {
  const SettingsActionCardWidget({super.key, required this.payload});

  final SettingsActionCardCassettePayload payload;

  @override
  Widget build(BuildContext context) {
    return SettingsActionList(
      actions: payload.actions,
      cassetteIndex: payload.cassetteIndex,
    );
  }
}
