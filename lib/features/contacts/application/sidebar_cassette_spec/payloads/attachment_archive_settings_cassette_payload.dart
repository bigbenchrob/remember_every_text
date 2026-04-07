import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

/// Inert transport payload for the attachment-archive settings info cassette.
final class AttachmentArchiveSettingsCassettePayload
    extends FeatureInfoSidebarCassettePayload {
  const AttachmentArchiveSettingsCassettePayload({
    super.title = 'Attachment Archive',
    super.bodyText =
        'Images from your Messages are automatically archived to protect '
        'against iCloud eviction. Archived images remain available even '
        'when the originals are no longer on this Mac.',
    super.role = SidebarCassetteRole.action,
    super.topSpacing = 0,
    super.footnote,
  });
}
