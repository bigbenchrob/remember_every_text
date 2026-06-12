import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/application/retained_archive_metadata_store.dart';
import 'package:remember_this_text/features/settings/infrastructure/repositories/historical_archive_sources_repository.dart';

void main() {
  group('HistoricalArchiveSourcesRepository', () {
    test(
      'reads metadata through the retained metadata store contract',
      () async {
        final store = _FakeRetainedArchiveMetadataStore(
          records: const [
            HistoricalArchiveSourceRecord(
              sourceChatDb: '/Archives/2017/chat.db',
              folderPath: '/Archives/2017',
              sourceLabel: 'Archive-2017',
              chatDbStatusLabel: 'Found and readable',
              attachmentsStatusLabel: 'Found',
              preflightStatusLabel: 'Preflight complete',
              preflightDetail: 'Source checks succeeded.',
              updatedAtUtc: '2026-06-10T00:00:00.000Z',
              totalMessages: 42,
              dryRunNewMessages: 10,
              dryRunDuplicateMessages: 32,
              lastImportSuccess: true,
              lastImportedMessageCount: 10,
            ),
          ],
        );
        final repository = HistoricalArchiveSourcesRepository(
          metadataStore: store,
        );

        final metadata = await repository.readKnownSources();

        expect(metadata, hasLength(1));
        expect(metadata.single.sourceLabel, 'Archive-2017');
        expect(metadata.single.totalMessages, 42);
        expect(metadata.single.dryRunNewMessages, 10);
        expect(metadata.single.dryRunDuplicateMessages, 32);
        expect(metadata.single.lastImportSuccess, isTrue);
        expect(metadata.single.lastImportedMessageCount, 10);
      },
    );

    test(
      'writes metadata through the retained metadata store contract',
      () async {
        final store = _FakeRetainedArchiveMetadataStore();
        final repository = HistoricalArchiveSourcesRepository(
          metadataStore: store,
        );

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
            lastImportSuccess: false,
            lastImportError: 'Import interrupted',
          ),
        );

        expect(store.upserts, hasLength(1));
        final upsert = store.upserts.single;
        expect(upsert.sourceChatDb, '/Archives/2018/chat.db');
        expect(upsert.folderPath, '/Archives/2018');
        expect(upsert.sourceLabel, 'Archive-2018');
        expect(upsert.totalMessages, 12);
        expect(upsert.dryRunNewMessages, 3);
        expect(upsert.lastImportSuccess, isFalse);
        expect(upsert.lastImportError, 'Import interrupted');
      },
    );
  });
}

final class _FakeRetainedArchiveMetadataStore
    implements RetainedArchiveMetadataStore {
  _FakeRetainedArchiveMetadataStore({
    List<HistoricalArchiveSourceRecord> records = const [],
  }) : _records = records;

  final List<HistoricalArchiveSourceRecord> _records;
  final List<_StoreUpsert> upserts = [];

  @override
  Future<void> close() async {}

  @override
  Future<List<HistoricalArchiveSourceRecord>>
  listHistoricalArchiveSources() async {
    return _records;
  }

  @override
  Future<void> upsertHistoricalArchiveSource({
    required String sourceChatDb,
    required String folderPath,
    required String sourceLabel,
    required String chatDbStatusLabel,
    required String attachmentsStatusLabel,
    required String preflightStatusLabel,
    required String preflightDetail,
    required String updatedAtUtc,
    int? totalMessages,
    int? totalChats,
    int? totalHandles,
    int? missingGuids,
    String? earliestMessageUtc,
    String? latestMessageUtc,
    int? dryRunNewMessages,
    int? dryRunDuplicateMessages,
    String? lastImportFinishedAtUtc,
    bool? lastImportSuccess,
    String? lastImportError,
    int? lastImportedMessageCount,
  }) async {
    upserts.add(
      _StoreUpsert(
        sourceChatDb: sourceChatDb,
        folderPath: folderPath,
        sourceLabel: sourceLabel,
        totalMessages: totalMessages,
        dryRunNewMessages: dryRunNewMessages,
        lastImportSuccess: lastImportSuccess,
        lastImportError: lastImportError,
      ),
    );
  }
}

final class _StoreUpsert {
  const _StoreUpsert({
    required this.sourceChatDb,
    required this.folderPath,
    required this.sourceLabel,
    required this.totalMessages,
    required this.dryRunNewMessages,
    required this.lastImportSuccess,
    required this.lastImportError,
  });

  final String sourceChatDb;
  final String folderPath;
  final String sourceLabel;
  final int? totalMessages;
  final int? dryRunNewMessages;
  final bool? lastImportSuccess;
  final String? lastImportError;
}
