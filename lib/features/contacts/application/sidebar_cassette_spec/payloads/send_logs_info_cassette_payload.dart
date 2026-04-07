import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

/// Inert transport payload for the send-logs settings info cassette.
final class SendLogsInfoCassettePayload
    extends FeatureInfoSidebarCassettePayload {
  const SendLogsInfoCassettePayload({
    super.title = 'Send Logs',
    super.bodyText =
        'If you encounter a problem, you can send diagnostic logs '
        'to help with troubleshooting.',
    super.role = SidebarCassetteRole.action,
    super.topSpacing = 0,
    super.footnote,
  });
}
