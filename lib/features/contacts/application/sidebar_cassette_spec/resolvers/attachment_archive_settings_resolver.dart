import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../presentation/cassettes/settings/attachment_archive_settings_content.dart';

part 'attachment_archive_settings_resolver.g.dart';

/// Resolver for ContactsSettingsSpec.attachmentArchive().
///
/// Returns an info cassette with the archive toggle, stats, and clear action.
@riverpod
class AttachmentArchiveSettingsResolver
    extends _$AttachmentArchiveSettingsResolver {
  @override
  void build() {}

  SidebarInfoCassetteViewModel resolve({required int cassetteIndex}) {
    return const SidebarInfoCassetteViewModel(
      role: SidebarCassetteRole.action,
      title: 'Attachment Archive',
      bodyText:
          'Images from your Messages are automatically archived to protect '
          'against iCloud eviction. Archived images remain available even '
          'when the originals are no longer on this Mac.',
      content: AttachmentArchiveSettingsContent(),
    );
  }
}
