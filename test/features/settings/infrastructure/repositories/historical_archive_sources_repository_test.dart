import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_sources.dart';
import 'package:remember_this_text/features/settings/infrastructure/repositories/historical_archive_sources_repository.dart';

void main() {
  group('HistoricalArchiveSourcesRepository', () {
    late OverlayDatabase overlayDatabase;
    late HistoricalArchiveSourcesRepository repository;

    setUp(() {
      overlayDatabase = OverlayDatabase(NativeDatabase.memory());
      repository = HistoricalArchiveSourcesRepository(
        overlayDatabase: overlayDatabase,
      );
    });

    tearDown(() async {
      await overlayDatabase.close();
    });

    test('writes and reads metadata through overlay storage', () async {
      await repository.upsertSourceMetadata(
        const HistoricalArchiveSourceMetadataUpdate(
          sourceChatDb: '/Archives/2018/chat.db',
          folderPath: '/Archives/2018',
          sourceLabel: 'Archive-2018',
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: 'Found',
          preflightStatusLabel: 'Preflight complete',
          preflightDetail: 'Source checks succeeded.',
          updatedAtUtc: '2026-06-10T00:00:00.000Z',
          totalMessages: 12,
          dryRunNewMessages: 3,
          dryRunDuplicateMessages: 9,
          lastImportFinishedAtUtc: '2026-06-10T00:01:00.000Z',
          lastImportSuccess: false,
          lastImportError: 'Import interrupted',
          lastImportedMessageCount: 2,
        ),
      );

      final metadata = await repository.readKnownSources();

      expect(metadata, hasLength(1));
      expect(metadata.single.sourceLabel, 'Archive-2018');
      expect(metadata.single.totalMessages, 12);
      expect(metadata.single.dryRunNewMessages, 3);
      expect(metadata.single.dryRunDuplicateMessages, 9);
      expect(
        metadata.single.lastImportFinishedAtUtc,
        '2026-06-10T00:01:00.000Z',
      );
      expect(metadata.single.lastImportSuccess, isFalse);
      expect(metadata.single.lastImportError, 'Import interrupted');
      expect(metadata.single.lastImportedMessageCount, 2);
    });

    test('does not expose source paths from read metadata', () async {
      await repository.upsertSourceMetadata(
        const HistoricalArchiveSourceMetadataUpdate(
          sourceChatDb: '/Private/Archive/chat.db',
          folderPath: '/Private/Archive',
          sourceLabel: 'Archive',
          chatDbStatusLabel: 'Found',
          attachmentsStatusLabel: 'Found',
          preflightStatusLabel: 'Preflight complete',
          preflightDetail: 'Source checks succeeded.',
          updatedAtUtc: '2026-06-10T00:00:00.000Z',
          totalMessages: 12,
        ),
      );

      final rawSetting = await overlayDatabase.readOverlaySetting(
        'historical_archive_sources/v1',
      );
      final metadata = await repository.readKnownSources();

      expect(rawSetting, contains('/Private/Archive/chat.db'));
      expect(metadata.single.sourceLabel, 'Archive');
      expect(metadata.single.totalMessages, 12);
      expect(metadata.single.preflightStatusLabel, 'Preflight complete');
    });

    test('replaces metadata by source chat database path', () async {
      await repository.upsertSourceMetadata(
        const HistoricalArchiveSourceMetadataUpdate(
          sourceChatDb: '/Archives/2018/chat.db',
          folderPath: '/Archives/2018',
          sourceLabel: 'Archive-2018',
          chatDbStatusLabel: 'Found',
          attachmentsStatusLabel: 'Found',
          preflightStatusLabel: 'Preflight complete',
          preflightDetail: 'Initial source checks succeeded.',
          updatedAtUtc: '2026-06-10T00:00:00.000Z',
          totalMessages: 12,
        ),
      );

      await repository.upsertSourceMetadata(
        const HistoricalArchiveSourceMetadataUpdate(
          sourceChatDb: '/Archives/2018/chat.db',
          folderPath: '/Archives/2018',
          sourceLabel: 'Archive-2018 updated',
          chatDbStatusLabel: 'Found',
          attachmentsStatusLabel: 'Found',
          preflightStatusLabel: 'Preflight complete',
          preflightDetail: 'Updated source checks succeeded.',
          updatedAtUtc: '2026-06-10T00:02:00.000Z',
          totalMessages: 15,
        ),
      );

      final metadata = await repository.readKnownSources();

      expect(metadata, hasLength(1));
      expect(metadata.single.sourceLabel, 'Archive-2018 updated');
      expect(metadata.single.totalMessages, 15);
    });

    test('returns known sources in latest-update order', () async {
      await repository.upsertSourceMetadata(
        const HistoricalArchiveSourceMetadataUpdate(
          sourceChatDb: '/Archives/2017/chat.db',
          folderPath: '/Archives/2017',
          sourceLabel: 'Archive-2017',
          chatDbStatusLabel: 'Found',
          attachmentsStatusLabel: 'Found',
          preflightStatusLabel: 'Preflight complete',
          preflightDetail: 'Older source.',
          updatedAtUtc: '2026-06-10T00:00:00.000Z',
        ),
      );
      await repository.upsertSourceMetadata(
        const HistoricalArchiveSourceMetadataUpdate(
          sourceChatDb: '/Archives/2018/chat.db',
          folderPath: '/Archives/2018',
          sourceLabel: 'Archive-2018',
          chatDbStatusLabel: 'Found',
          attachmentsStatusLabel: 'Found',
          preflightStatusLabel: 'Preflight complete',
          preflightDetail: 'Newer source.',
          updatedAtUtc: '2026-06-10T00:01:00.000Z',
        ),
      );

      final metadata = await repository.readKnownSources();

      expect(
        metadata.map((source) => source.sourceLabel),
        orderedEquals(['Archive-2018', 'Archive-2017']),
      );
    });

    test('ignores malformed overlay metadata', () async {
      await overlayDatabase.writeOverlaySetting(
        settingKey: 'historical_archive_sources/v1',
        settingValue: '{"unexpected":"shape"}',
      );

      final metadata = await repository.readKnownSources();

      expect(metadata, isEmpty);
    });
  });
}
