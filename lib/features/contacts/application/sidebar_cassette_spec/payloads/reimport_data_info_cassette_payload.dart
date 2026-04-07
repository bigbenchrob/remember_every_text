import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

/// Inert transport payload for the reimport-data settings info cassette.
final class ReimportDataInfoCassettePayload
    extends FeatureInfoSidebarCassettePayload {
  const ReimportDataInfoCassettePayload({
    super.title = 'Reimport Data',
    super.bodyText =
        'This will reimport all the chat message and address book '
        'contact data from the databases on your Mac. Any records '
        'you have added (like new contact names for unfamiliar '
        'phone numbers) will not be affected.',
    super.role = SidebarCassetteRole.action,
    super.topSpacing = 0,
    super.footnote,
  });
}
