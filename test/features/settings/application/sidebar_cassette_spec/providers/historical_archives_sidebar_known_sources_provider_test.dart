import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/providers/historical_archives_sidebar_known_sources_provider.dart';

void main() {
  group('buildHistoricalArchiveSidebarKnownSources', () {
    test('returns empty when no persisted archive source exists', () {
      final summaries = buildHistoricalArchiveSidebarKnownSources(
        records: const [],
      );

      expect(summaries, isEmpty);
    });

    test('builds a sidebar summary from persisted archive source metadata', () {
      const records = [
        HistoricalArchiveSourceRecord(
          sourceChatDb: '/tmp/Archive-2017/chat.db',
          folderPath: '/tmp/Archive-2017',
          sourceLabel: 'Archive-2017',
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: 'Found',
          preflightStatusLabel: 'Preflight complete',
          preflightDetail: 'Source checks succeeded.',
          totalMessages: 42,
          totalChats: 2,
          totalHandles: 10,
          missingGuids: 1,
          earliestMessageUtc: '2017-01-03T00:00:00.000Z',
          latestMessageUtc: '2017-01-05T00:00:00.000Z',
          dryRunNewMessages: 10,
          dryRunDuplicateMessages: 32,
          lastImportBatchId: 8,
          lastImportFinishedAtUtc: '2026-04-29T18:30:00.000Z',
          lastImportSuccess: true,
          lastImportedMessageCount: 10,
          updatedAtUtc: '2026-04-29T18:30:00.000Z',
        ),
      ];

      final summaries = buildHistoricalArchiveSidebarKnownSources(
        records: records,
      );

      expect(summaries, hasLength(1));
      expect(summaries.single.label, 'Archive-2017');
      expect(
        summaries.single.dateRangeLabel,
        'Date range: 2017-01-03 to 2017-01-05',
      );
      expect(summaries.single.messageCountLabel, 'Total messages: 42');
      expect(
        summaries.single.statusLabel,
        'Current status: Imported successfully',
      );
      expect(
        summaries.single.lastRunSummaryLabel,
        'Last run: imported 10 messages',
      );
      expect(
        summaries.single.lastImportedLabel,
        'Last imported: 2026-04-29 18:30 UTC',
      );
    });
  });
}
