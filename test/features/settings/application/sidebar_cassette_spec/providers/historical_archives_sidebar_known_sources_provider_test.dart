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
    totalMessages: 8882,
    earliestMessageUtc: '2012-07-25T08:00:00.000Z',
    latestMessageUtc: '2017-06-11T08:00:00.000Z',
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
    importedMessageCount: 8882,
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
        'Date range: Jul 2012 – Jun 2017',
      );
      expect(summaries.single.messageCountLabel, 'Messages: 8,882');
      expect(summaries.single.importedOnLabel, 'Imported on: Apr 29, 2026');
    });

    test('omits imported-on without a trustworthy successful completion', () {
      final failedSummaries = buildHistoricalArchiveSidebarKnownSources(
        sources: [
          _sourceWithImportCompletion(
            finishedAtUtc: '2026-05-01T18:30:00.000Z',
            wasSuccessful: false,
          ),
        ],
        importedSourcesByKey: const {sourceKey: importedMatch},
      );
      final missingTimestampSummaries =
          buildHistoricalArchiveSidebarKnownSources(
            sources: [
              _sourceWithImportCompletion(
                finishedAtUtc: null,
                wasSuccessful: true,
              ),
            ],
            importedSourcesByKey: const {sourceKey: importedMatch},
          );
      final unverifiedTimestampSummaries =
          buildHistoricalArchiveSidebarKnownSources(
            sources: [
              _sourceWithImportCompletion(
                finishedAtUtc: '2026-05-02T18:30:00.000Z',
                wasSuccessful: null,
              ),
            ],
            importedSourcesByKey: const {sourceKey: importedMatch},
          );

      expect(failedSummaries.single.importedOnLabel, isNull);
      expect(missingTimestampSummaries.single.importedOnLabel, isNull);
      expect(unverifiedTimestampSummaries.single.importedOnLabel, isNull);
    });

    test('omits an unsupported date range instead of showing a fallback', () {
      final summaries = buildHistoricalArchiveSidebarKnownSources(
        sources: [
          _sourceWithImportCompletion(
            finishedAtUtc: '2026-04-29T18:30:00.000Z',
            wasSuccessful: true,
            earliestMessageUtc: null,
          ),
        ],
        importedSourcesByKey: const {sourceKey: importedMatch},
      );

      expect(summaries.single.dateRangeLabel, isNull);
      expect(summaries.single.messageCountLabel, 'Messages: 8,882');
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
        presentationContext: HistoricalArchivesPresentationContext.hub,
        reference: const HistoricalArchivesKnownSourceReference(
          sourceKey: sourceKey,
          referenceOccurrence: 3,
        ),
      );

      expect(selected.single.isSelected, isTrue);
      expect(selected.single.isReferenced, isFalse);
      expect(referenced.single.isSelected, isFalse);
      expect(referenced.single.isReferenced, isTrue);
      expect(referenced.single.referenceOccurrence, 3);
    });

    test('reference targets only the matching canonical source key', () {
      const otherSourceKey =
          'historical-messages-archive:/Archives/2016/chat.db';
      const otherSource = HistoricalArchiveSourceMetadata(
        sourceKey: otherSourceKey,
        sourceChatDb: '/Archives/2016/chat.db',
        folderPath: '/Archives/2016',
        sourceLabel: 'Archive-2016',
        chatDbStatusLabel: 'Found and readable',
        attachmentsStatusLabel: 'Not found',
        preflightStatusLabel: 'Imported successfully',
        totalMessages: 10,
        earliestMessageUtc: '2016-01-01T00:00:00.000Z',
        latestMessageUtc: '2016-12-31T00:00:00.000Z',
        dryRunNewMessages: 10,
        dryRunDuplicateMessages: 0,
        lastImportFinishedAtUtc: '2026-04-30T18:30:00.000Z',
        lastImportSuccess: true,
        lastImportError: null,
        lastImportedMessageCount: 10,
      );
      const otherMatch = HistoricalArchiveImportedSourceMatch(
        sourceKey: otherSourceKey,
        sourceId: 4,
        importedMessageCount: 10,
      );

      final summaries = buildHistoricalArchiveSidebarKnownSources(
        sources: const [source, otherSource],
        importedSourcesByKey: const {
          sourceKey: importedMatch,
          otherSourceKey: otherMatch,
        },
        reference: const HistoricalArchivesKnownSourceReference(
          sourceKey: sourceKey,
          referenceOccurrence: 7,
        ),
      );

      expect(summaries.where((summary) => summary.isReferenced), hasLength(1));
      expect(
        summaries.singleWhere((summary) => summary.isReferenced).sourceKey,
        sourceKey,
      );
      expect(
        summaries
            .singleWhere((summary) => summary.sourceKey == otherSourceKey)
            .referenceOccurrence,
        0,
      );
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

HistoricalArchiveSourceMetadata _sourceWithImportCompletion({
  required String? finishedAtUtc,
  required bool? wasSuccessful,
  String? earliestMessageUtc = '2012-07-25T08:00:00.000Z',
  String? latestMessageUtc = '2017-06-11T08:00:00.000Z',
}) {
  return HistoricalArchiveSourceMetadata(
    sourceKey: 'historical-messages-archive:/Archives/2017/chat.db',
    sourceChatDb: '/Archives/2017/chat.db',
    folderPath: '/Archives/2017',
    sourceLabel: 'Archive-2017',
    chatDbStatusLabel: 'Found and readable',
    attachmentsStatusLabel: 'Found',
    preflightStatusLabel: 'Preflight complete',
    totalMessages: 8882,
    earliestMessageUtc: earliestMessageUtc,
    latestMessageUtc: latestMessageUtc,
    dryRunNewMessages: 0,
    dryRunDuplicateMessages: 8882,
    lastImportFinishedAtUtc: finishedAtUtc,
    lastImportSuccess: wasSuccessful,
    lastImportError: wasSuccessful == false ? 'Import failed' : null,
    lastImportedMessageCount: wasSuccessful == true ? 8882 : null,
  );
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
