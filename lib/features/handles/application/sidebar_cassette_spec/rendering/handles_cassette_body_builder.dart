import 'package:flutter/widgets.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../presentation/settings/manual_linking_view.dart';
import '../../../presentation/settings/spam_management_view.dart';
import '../../settings_cassette_spec/payloads/manual_linking_cassette_payload.dart';
import '../../settings_cassette_spec/payloads/spam_management_cassette_payload.dart';
import '../payloads/stray_emails_cassette_payload.dart';
import '../payloads/stray_handles_mode_switcher_cassette_payload.dart';
import '../payloads/stray_handles_review_cassette_payload.dart';
import '../payloads/stray_handles_type_switcher_cassette_payload.dart';
import '../payloads/stray_phone_numbers_cassette_payload.dart';
import '../payloads/unmatched_handles_cassette_payload.dart';
import '../widget_builders/stray_emails_cassette.dart';
import '../widget_builders/stray_handles_mode_switcher_cassette.dart';
import '../widget_builders/stray_handles_review_cassette.dart';
import '../widget_builders/stray_handles_type_switcher_cassette.dart';
import '../widget_builders/stray_phone_numbers_cassette.dart';
import '../widget_builders/unmatched_handles_cassette.dart';

/// Builds feature-owned sidebar cassette bodies from inert handles payloads.
Widget buildPlacementGovernedCassetteBody({
  required PlacementGovernedSidebarCassettePayload payload,
}) {
  return switch (payload) {
    ManualLinkingCassettePayload() => const ManualLinkingView(),
    SpamManagementCassettePayload() => const SpamManagementView(),
    StrayEmailsCassettePayload() => const StrayEmailsCassette(),
    StrayPhoneNumbersCassettePayload() => const StrayPhoneNumbersCassette(),
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
    UnmatchedHandlesCassettePayload() => const UnmatchedHandlesCassette(),
    PlacementGovernedSidebarCassettePayload() => throw UnsupportedError(
      'Unhandled handles cassette payload type: ${payload.runtimeType}',
    ),
  };
}
