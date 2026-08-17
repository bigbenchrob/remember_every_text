import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/message_data_version_provider.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_sources.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_sources_provider.dart';
import 'package:remember_this_text/features/settings/application/historical_archives_workflow_panel_model_provider.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/providers/historical_archives_sidebar_known_sources_provider.dart';

void main() {
  const sourceKey = 'historical-messages-archive:/Archives/2017/chat.db';
  const source = HistoricalArchiveSourceMetadata(
    sourceKey: sourceKey,
    sourceChatDb: '/Archives/2017/chat.db',
    folderPath: '/Archives/2017',
    sourceLabel: 'Archive-2017',
    chatDbStatusLabel: 'Found and readable',
    attachmentsStatusLabel: 'Found',
    preflightStatusLabel: 'Imported successfully',
    totalMessages: 42,
    earliestMessageUtc: '2017-01-03T00:00:00.000Z',
    latestMessageUtc: '2017-01-05T00:00:00.000Z',
    dryRunNewMessages: 10,
    dryRunDuplicateMessages: 32,
    lastImportFinishedAtUtc: '2026-04-29T18:30:00.000Z',
    lastImportSuccess: true,
    lastImportError: null,
    lastImportedMessageCount: 40,
  );
  const importedMatch = HistoricalArchiveImportedSourceMatch(
    sourceKey: sourceKey,
    sourceId: 3,
    importedMessageCount: 40,
  );

  group('buildHistoricalArchiveSidebarKnownSources', () {
    test('returns empty when no persisted archive source exists', () {
      final summaries = buildHistoricalArchiveSidebarKnownSources(
        sources: const [],
        importedSourcesByKey: const {},
      );

      expect(summaries, isEmpty);
    });

    test('omits remembered source without positive imported truth', () {
      final summaries = buildHistoricalArchiveSidebarKnownSources(
        sources: const [source],
        importedSourcesByKey: const {},
      );

      expect(summaries, isEmpty);
      expect(source.sourceKey, sourceKey);
    });

    test('builds an imported-source summary from ledger truth', () {
      final summaries = buildHistoricalArchiveSidebarKnownSources(
        sources: const [source],
        importedSourcesByKey: const {sourceKey: importedMatch},
      );

      expect(summaries, hasLength(1));
      expect(summaries.single.label, 'Archive-2017');
      expect(
        summaries.single.dateRangeLabel,
        'Date range: 2017-01-03 to 2017-01-05',
      );
      expect(summaries.single.messageCountLabel, 'Messages: 40');
      expect(
        summaries.single.lastRunSummaryLabel,
        'Last run: imported 40 messages',
      );
      expect(
        summaries.single.lastImportedLabel,
        'Last imported: 2026-04-29 18:30 UTC',
      );
    });

    test('keeps selection and reference keyed to imported membership', () {
      final selected = buildHistoricalArchiveSidebarKnownSources(
        sources: const [source],
        importedSourcesByKey: const {sourceKey: importedMatch},
        presentationContext:
            HistoricalArchivesPresentationContext.existingSource,
        selectedSourceKey: sourceKey,
      );
      final referenced = buildHistoricalArchiveSidebarKnownSources(
        sources: const [source],
        importedSourcesByKey: const {sourceKey: importedMatch},
        presentationContext: HistoricalArchivesPresentationContext.addArchive,
        reference: const HistoricalArchivesKnownSourceReference(
          sourceKey: sourceKey,
          pulseOccurrence: 3,
        ),
      );

      expect(selected.single.isSelected, isTrue);
      expect(selected.single.isReferenced, isFalse);
      expect(referenced.single.isSelected, isFalse);
      expect(referenced.single.isReferenced, isTrue);
      expect(referenced.single.referencePulseOccurrence, 3);
    });
  });

  test('message-data refresh removes zero-count sidebar membership', () async {
    final lookup = _MutableImportedSourceLookup(importedMatch);
    final container = ProviderContainer(
      overrides: [
        historicalArchiveSourceMetadataProvider.overrideWith(
          (ref) async => const [source],
        ),
        historicalArchiveImportedSourceLookupProvider.overrideWith(
          (ref) async => lookup,
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      historicalArchivesSidebarKnownSourcesProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(
      await container.read(
        historicalArchivesSidebarKnownSourcesProvider.future,
      ),
      hasLength(1),
    );

    lookup.match = null;
    container.read(messageDataVersionProvider.notifier).bump();

    expect(
      await container.read(
        historicalArchivesSidebarKnownSourcesProvider.future,
      ),
      isEmpty,
    );
    expect(
      await container.read(historicalArchiveSourceMetadataProvider.future),
      const [source],
    );
  });
}

final class _MutableImportedSourceLookup
    implements HistoricalArchiveImportedSourceLookup {
  _MutableImportedSourceLookup(this.match);

  HistoricalArchiveImportedSourceMatch? match;

  @override
  Future<HistoricalArchiveImportedSourceMatch?> findImportedSource({
    required String folderPath,
  }) async {
    return match;
  }

  @override
  Future<HistoricalArchiveImportedSourceMatch?> findImportedSourceByKey({
    required String sourceKey,
  }) async {
    final current = match;
    return current?.sourceKey == sourceKey ? current : null;
  }
}
