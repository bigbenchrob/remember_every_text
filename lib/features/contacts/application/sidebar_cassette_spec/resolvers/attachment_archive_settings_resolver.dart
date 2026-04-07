import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../payloads/attachment_archive_settings_cassette_payload.dart';

part 'attachment_archive_settings_resolver.g.dart';

/// Resolver for ContactsSettingsSpec.attachmentArchive().
///
/// Returns an info cassette with the archive toggle, stats, and clear action.
@riverpod
class AttachmentArchiveSettingsResolver
    extends _$AttachmentArchiveSettingsResolver {
  @override
  void build() {}

  AttachmentArchiveSettingsCassettePayload resolve({
    required int cassetteIndex,
  }) {
    return const AttachmentArchiveSettingsCassettePayload();
  }
}
