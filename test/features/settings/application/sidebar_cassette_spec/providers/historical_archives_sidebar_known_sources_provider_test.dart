import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_sources.dart';
import 'package:remember_this_text/features/settings/application/historical_archives_workflow_panel_model_provider.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/providers/historical_archives_sidebar_known_sources_provider.dart';

void main() {
  group('buildHistoricalArchiveSidebarKnownSources', () {
    test('returns empty when no persisted archive source exists', () {
      final summaries = buildHistoricalArchiveSidebarKnownSources(
        sources: const [],
      );

      expect(summaries, isEmpty);
    });

    test('builds a sidebar summary from persisted archive source metadata', () {
      const sources = [
        HistoricalArchiveSourceMetadata(
          sourceKey: 'historical-messages-archive:/Archives/2017/chat.db',
          sourceChatDb: '/Archives/2017/chat.db',
          folderPath: '/Archives/2017',
          sourceLabel: 'Archive-2017',
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: 'Found',
          preflightStatusLabel: 'Preflight complete',
          totalMessages: 42,
          earliestMessageUtc: '2017-01-03T00:00:00.000Z',
          latestMessageUtc: '2017-01-05T00:00:00.000Z',
          dryRunNewMessages: 10,
          dryRunDuplicateMessages: 32,
          lastImportFinishedAtUtc: '2026-04-29T18:30:00.000Z',
          lastImportSuccess: true,
          lastImportError: null,
          lastImportedMessageCount: 10,
        ),
      ];

      final summaries = buildHistoricalArchiveSidebarKnownSources(
        sources: sources,
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
      expect(summaries.single.isReferenced, isFalse);
      expect(summaries.single.isSelected, isFalse);
      expect(summaries.single.referencePulseOccurrence, 0);
    });

    test('targets only the canonically matching source reference', () {
      const sources = [
        HistoricalArchiveSourceMetadata(
          sourceKey: 'historical-messages-archive:/Archives/2017/chat.db',
          sourceChatDb: '/Archives/2017/chat.db',
          folderPath: '/Archives/2017',
          sourceLabel: 'Archive-2017',
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: 'Found',
          preflightStatusLabel: 'Imported successfully',
          totalMessages: 42,
          earliestMessageUtc: null,
          latestMessageUtc: null,
          dryRunNewMessages: 0,
          dryRunDuplicateMessages: 42,
          lastImportFinishedAtUtc: null,
          lastImportSuccess: true,
          lastImportError: null,
          lastImportedMessageCount: 42,
        ),
        HistoricalArchiveSourceMetadata(
          sourceKey: 'historical-messages-archive:/Archives/other/chat.db',
          sourceChatDb: '/Archives/other/chat.db',
          folderPath: '/Archives/other',
          sourceLabel: 'Other',
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: 'Found',
          preflightStatusLabel: 'Imported successfully',
          totalMessages: 9,
          earliestMessageUtc: null,
          latestMessageUtc: null,
          dryRunNewMessages: 0,
          dryRunDuplicateMessages: 9,
          lastImportFinishedAtUtc: null,
          lastImportSuccess: true,
          lastImportError: null,
          lastImportedMessageCount: 9,
        ),
      ];

      final summaries = buildHistoricalArchiveSidebarKnownSources(
        sources: sources,
        reference: const HistoricalArchivesKnownSourceReference(
          sourceKey: 'historical-messages-archive:/Archives/2017/chat.db',
          pulseOccurrence: 3,
        ),
      );

      expect(summaries.first.isReferenced, isTrue);
      expect(summaries.first.referencePulseOccurrence, 3);
      expect(summaries.last.isReferenced, isFalse);
      expect(summaries.last.referencePulseOccurrence, 0);
    });

    test('selects only an explicitly selected exact-key source', () {
      const sourceKey = 'historical-messages-archive:/Archives/2017/chat.db';
      const sources = [
        HistoricalArchiveSourceMetadata(
          sourceKey: sourceKey,
          sourceChatDb: '/Archives/2017/chat.db',
          folderPath: '/Archives/2017',
          sourceLabel: 'Archive-2017',
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: 'Found',
          preflightStatusLabel: 'Imported successfully',
          totalMessages: 42,
          earliestMessageUtc: null,
          latestMessageUtc: null,
          dryRunNewMessages: 0,
          dryRunDuplicateMessages: 42,
          lastImportFinishedAtUtc: null,
          lastImportSuccess: true,
          lastImportError: null,
          lastImportedMessageCount: 42,
        ),
      ];

      final hub = buildHistoricalArchiveSidebarKnownSources(sources: sources);
      final selected = buildHistoricalArchiveSidebarKnownSources(
        sources: sources,
        presentationContext:
            HistoricalArchivesPresentationContext.existingSource,
        selectedSourceKey: sourceKey,
      );
      final addRecognition = buildHistoricalArchiveSidebarKnownSources(
        sources: sources,
        presentationContext: HistoricalArchivesPresentationContext.addArchive,
        selectedSourceKey: sourceKey,
        reference: const HistoricalArchivesKnownSourceReference(
          sourceKey: sourceKey,
          pulseOccurrence: 1,
        ),
      );

      expect(hub.single.isSelected, isFalse);
      expect(selected.single.isSelected, isTrue);
      expect(selected.single.isReferenced, isFalse);
      expect(addRecognition.single.isSelected, isFalse);
      expect(addRecognition.single.isReferenced, isTrue);
    });
  });
}
