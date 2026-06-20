import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_settings_store.dart';

void main() {
  late OverlayDatabase overlayDatabase;
  late OverlayAttachmentArchiveSettingsStore store;

  setUp(() {
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    store = OverlayAttachmentArchiveSettingsStore(overlayDb: overlayDatabase);
  });

  tearDown(() async {
    await overlayDatabase.close();
  });

  test('reads and writes overlay settings by key', () async {
    expect(await store.readSetting('attachment_archive_enabled'), isNull);

    await store.writeSetting(key: 'attachment_archive_enabled', value: 'true');

    expect(await store.readSetting('attachment_archive_enabled'), 'true');
  });

  test('clears archive records without clearing overlay settings', () async {
    await store.writeSetting(key: 'attachment_archive_enabled', value: 'true');
    await overlayDatabase.customStatement(
      '''
      INSERT INTO archived_attachments (
        message_guid,
        import_attachment_id,
        archive_relative_path,
        archived_at_utc,
        file_size_bytes,
        content_hash,
        provenance
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
      <Object?>[
        'message-guid',
        200,
        'ab/archive.jpg',
        '2026-06-19T10:00:00.000Z',
        5,
        'hash',
        'archived',
      ],
    );

    await store.clearArchivedAttachmentRecords();

    expect(
      await overlayDatabase.select(overlayDatabase.archivedAttachments).get(),
      isEmpty,
    );
    expect(await store.readSetting('attachment_archive_enabled'), 'true');
  });
}
