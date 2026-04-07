import 'package:flutter/widgets.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../payloads/messages_heatmap_cassette_payload.dart';
import '../payloads/recovered_no_handle_from_me_navigator_cassette_payload.dart';
import '../payloads/recovered_unlinked_navigator_cassette_payload.dart';
import '../widget_builders/messages_heatmap_widget.dart';
import '../widget_builders/recovered_no_handle_from_me_navigator_widget.dart';
import '../widget_builders/recovered_unlinked_navigator_widget.dart';

/// Builds feature-owned sidebar cassette bodies from inert messages payloads.
Widget buildPlacementGovernedCassetteBody({
  required PlacementGovernedSidebarCassettePayload payload,
}) {
  return switch (payload) {
    MessagesHeatmapCassettePayload() => MessagesHeatmapWidget(
      contactId: payload.contactId,
    ),
    RecoveredUnlinkedNavigatorCassettePayload() =>
      RecoveredUnlinkedNavigatorWidget(cassetteIndex: payload.cassetteIndex),
    RecoveredNoHandleFromMeNavigatorCassettePayload() =>
      RecoveredNoHandleFromMeNavigatorWidget(
        cassetteIndex: payload.cassetteIndex,
      ),
    PlacementGovernedSidebarCassettePayload() => throw UnsupportedError(
      'Unhandled messages cassette payload type: ${payload.runtimeType}',
    ),
  };
}
