import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/attachment_archive_settings_store.dart';

class OverlayAttachmentArchiveSettingsStore
    implements AttachmentArchiveSettingsStore {
  const OverlayAttachmentArchiveSettingsStore({
    required OverlayDatabase overlayDb,
  }) : _overlayDb = overlayDb;

  final OverlayDatabase _overlayDb;

  @override
  Future<String?> readSetting(String key) {
    return _overlayDb.readOverlaySetting(key);
  }

  @override
  Future<void> writeSetting({required String key, required String value}) {
    return _overlayDb.writeOverlaySetting(settingKey: key, settingValue: value);
  }

  @override
  Future<void> clearArchivedAttachmentRecords() {
    return _overlayDb.delete(_overlayDb.archivedAttachments).go();
  }
}
