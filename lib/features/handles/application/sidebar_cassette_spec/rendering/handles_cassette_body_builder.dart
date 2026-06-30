import 'package:flutter/widgets.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../payloads/stray_handles_mode_switcher_cassette_payload.dart';
import '../payloads/stray_handles_review_cassette_payload.dart';
import '../payloads/stray_handles_type_switcher_cassette_payload.dart';
import '../widget_builders/stray_handles_mode_switcher_cassette.dart';
import '../widget_builders/stray_handles_review_cassette.dart';
import '../widget_builders/stray_handles_type_switcher_cassette.dart';

/// Builds feature-owned sidebar cassette bodies from inert handles payloads.
Widget buildPlacementGovernedCassetteBody({
  required PlacementGovernedSidebarCassettePayload payload,
}) {
  return switch (payload) {
    StrayHandlesReviewCassettePayload() => StrayHandlesReviewCassette(
      filter: payload.filter,
      mode: payload.mode,
    ),
    StrayHandlesModeSwitcherCassettePayload() =>
      StrayHandlesModeSwitcherCassette(mode: payload.mode),
    StrayHandlesTypeSwitcherCassettePayload() =>
      StrayHandlesTypeSwitcherCassette(
        selectedFilter: payload.selectedFilter,
        cassetteIndex: payload.cassetteIndex,
      ),
    PlacementGovernedSidebarCassettePayload() => throw UnsupportedError(
      'Unhandled handles cassette payload type: ${payload.runtimeType}',
    ),
  };
}
