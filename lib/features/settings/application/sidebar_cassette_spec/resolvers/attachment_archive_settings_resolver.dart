import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../payloads/attachment_archive_settings_cassette_payload.dart';

part 'attachment_archive_settings_resolver.g.dart';

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
