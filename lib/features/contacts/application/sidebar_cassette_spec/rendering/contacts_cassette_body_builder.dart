import 'package:flutter/widgets.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../presentation/cassettes/settings/attachment_archive_settings_content.dart';
import '../../../presentation/cassettes/settings/reimport_data_action_button.dart';
import '../../../presentation/cassettes/settings/send_logs_action_button.dart';
import '../payloads/attachment_archive_settings_cassette_payload.dart';
import '../payloads/contact_chooser_cassette_payload.dart';
import '../payloads/contact_hero_summary_cassette_payload.dart';
import '../payloads/contact_message_scope_toggle_cassette_payload.dart';
import '../payloads/contact_selection_control_cassette_payload.dart';
import '../payloads/handle_filter_cassette_payload.dart';
import '../payloads/reimport_data_info_cassette_payload.dart';
import '../payloads/send_logs_info_cassette_payload.dart';
import '../widget_builders/contact_chooser_widget.dart';
import '../widget_builders/contact_hero_summary_widget.dart';
import '../widget_builders/contact_message_scope_toggle_widget.dart';
import '../widget_builders/contact_selection_control_widget.dart';
import '../widget_builders/handle_filter_widget.dart';

/// Builds feature-owned sidebar cassette bodies from inert contacts payloads.
Widget buildPlacementGovernedCassetteBody({
  required PlacementGovernedSidebarCassettePayload payload,
}) {
  return switch (payload) {
    ContactChooserCassettePayload() => ContactChooserWidget(payload: payload),
    ContactHeroSummaryCassettePayload() => ContactHeroSummaryWidget(
      contactId: payload.contactId,
    ),
    ContactMessageScopeToggleCassettePayload() =>
      ContactMessageScopeToggleWidget(contactId: payload.contactId),
    ContactSelectionControlCassettePayload() => ContactSelectionControlWidget(
      contactId: payload.contactId,
      cassetteIndex: payload.cassetteIndex,
    ),
    HandleFilterCassettePayload() => HandleFilterWidget(
      contactId: payload.contactId,
      selectedHandleId: payload.selectedHandleId,
      cassetteIndex: payload.cassetteIndex,
    ),
    PlacementGovernedSidebarCassettePayload() => throw UnsupportedError(
      'Unhandled contacts cassette payload type: ${payload.runtimeType}',
    ),
  };
}

/// Builds feature-owned supplemental content for inert contacts info payloads.
Widget? buildFeatureInfoSupplementalContent({
  required FeatureInfoSidebarCassettePayload payload,
}) {
  return switch (payload) {
    SendLogsInfoCassettePayload() => const SendLogsActionButton(),
    ReimportDataInfoCassettePayload() => const ReimportDataActionButton(),
    AttachmentArchiveSettingsCassettePayload() =>
      const AttachmentArchiveSettingsContent(),
    FeatureInfoSidebarCassettePayload() => throw UnsupportedError(
      'Unhandled contacts info payload type: ${payload.runtimeType}',
    ),
  };
}
