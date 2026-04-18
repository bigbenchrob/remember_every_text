import 'package:flutter/widgets.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../payloads/attachment_archive_settings_cassette_payload.dart';
import '../payloads/settings_action_card_cassette_payload.dart';
import '../payloads/settings_info_actions_cassette_payload.dart';
import '../widget_builders/settings_action_card_widget.dart';
import '../widget_builders/settings_action_list.dart';

Widget buildPlacementGovernedCassetteBody({
  required PlacementGovernedSidebarCassettePayload payload,
}) {
  return switch (payload) {
    SettingsActionCardCassettePayload() => SettingsActionCardWidget(
      payload: payload,
    ),
    PlacementGovernedSidebarCassettePayload() => throw UnsupportedError(
      'Unhandled settings cassette payload type: ${payload.runtimeType}',
    ),
  };
}

Widget? buildFeatureInfoSupplementalContent({
  required FeatureInfoSidebarCassettePayload payload,
}) {
  return switch (payload) {
    SettingsInfoActionsCassettePayload() => SettingsActionList(
      actions: payload.actions,
      cassetteIndex: payload.cassetteIndex,
    ),
    AttachmentArchiveSettingsCassettePayload() => null,
    FeatureInfoSidebarCassettePayload() => throw UnsupportedError(
      'Unhandled settings info payload type: ${payload.runtimeType}',
    ),
  };
}
