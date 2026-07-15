import 'package:flutter/widgets.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../payloads/settings_top_menu_cassette_payload.dart';
import '../payloads/top_chat_menu_cassette_payload.dart';
import '../widget_builders/settings_top_menu_widget.dart';
import '../widget_builders/top_chat_menu_widget.dart';

/// Builds feature-owned sidebar utilities cassette bodies from inert payloads.
Widget buildPlacementGovernedCassetteBody({
  required PlacementGovernedSidebarCassettePayload payload,
}) {
  return switch (payload) {
    SettingsTopMenuCassettePayload() => SettingsTopMenuWidget(payload: payload),
    TopChatMenuCassettePayload() => TopMenuTrackOccupantView(
      currentChoice: payload.currentChoice,
      cassetteIndex: payload.cassetteIndex,
      sidebarMode: payload.sidebarMode,
    ),
    PlacementGovernedSidebarCassettePayload() => throw UnsupportedError(
      'Unhandled sidebar utilities payload type: ${payload.runtimeType}',
    ),
  };
}
