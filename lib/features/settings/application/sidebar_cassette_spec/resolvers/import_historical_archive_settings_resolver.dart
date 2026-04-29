import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../historical_archive_merge/historical_archive_import_result.dart';
import '../../historical_archive_merge/historical_archive_preflight_summary.dart';
import '../payloads/settings_info_actions_cassette_payload.dart';

part 'import_historical_archive_settings_resolver.g.dart';

@riverpod
class ImportHistoricalArchiveSettingsResolver
    extends _$ImportHistoricalArchiveSettingsResolver {
  @override
  void build() {}

  SettingsInfoActionsCassettePayload resolveInitial({
    required int cassetteIndex,
  }) {
    return SettingsInfoActionsCassettePayload(
      cassetteIndex: cassetteIndex,
      title: 'Import Historical Archive',
      bodyText:
          'Add messages from an older Messages folder into your timeline without replacing your current data.',
      actions: const [
        SidebarActionDescriptor(
          label: 'Choose Archive Folder',
          intent: ChooseHistoricalArchiveFolderRequested(),
          tone: SidebarActionTone.primary,
        ),
      ],
    );
  }

  SettingsInfoActionsCassettePayload resolvePreflight({
    required int cassetteIndex,
    required HistoricalArchivePreflightSummary summary,
  }) {
    final lines = <String>[
      'Archive label: ${summary.archiveLabel}',
      'Messages found: ${summary.totalMessages}',
      'Already present: ${summary.duplicateMessages}',
      'New messages to import: ${summary.newMessages}',
      'Messages without usable identifier: ${summary.rowsWithoutGuidCount}',
      'Date range: ${_formatRange(summary.earliestDate, summary.latestDate)}',
      '',
      'This import is additive. MessageLens will add messages from this archive that are not already present in your timeline.',
      '',
      'Your current MessageLens data will not be deleted or replaced.',
      '',
      'Messages that already exist will be skipped.',
    ];

    if (summary.warnings.isNotEmpty) {
      lines
        ..add('')
        ..add('Warnings:')
        ..addAll(summary.warnings.map((warning) => '• $warning'));
    }

    return SettingsInfoActionsCassettePayload(
      cassetteIndex: cassetteIndex,
      title: 'Archive Ready to Import',
      bodyText: lines.join('\n'),
      actions: [
        SidebarActionDescriptor(
          label: 'Clear Archive Cache',
          intent: ClearHistoricalArchiveCacheRequested(
            archivePath: summary.archivePath,
          ),
          tone: SidebarActionTone.destructive,
        ),
        SidebarActionDescriptor(
          label: 'Merge Into Timeline',
          intent: ImportHistoricalArchiveRequested(
            archivePath: summary.archivePath,
            archiveLabel: summary.archiveLabel,
          ),
          tone: SidebarActionTone.primary,
          isEnabled: summary.canImport,
        ),
        const SidebarActionDescriptor(
          label: 'Cancel',
          intent: SettingsTransientActionCancelled(),
        ),
      ],
    );
  }

  SettingsInfoActionsCassettePayload resolveInProgress({
    required int cassetteIndex,
    required String archiveLabel,
  }) {
    final lines = <String>[
      'Archive label: $archiveLabel',
      '',
      'MessageLens is currently staging and projecting this archive into the live timeline.',
      '',
      'This can take a while on a populated working database because timeline indexes must be refreshed before archive rows become visible.',
      '',
      'Contact-based views are temporarily unavailable until this archive projection completes.',
    ];

    return SettingsInfoActionsCassettePayload(
      cassetteIndex: cassetteIndex,
      title: 'Merging Archive Into Timeline',
      bodyText: lines.join('\n'),
      actions: const [],
    );
  }

  SettingsInfoActionsCassettePayload resolveImportResult({
    required int cassetteIndex,
    required HistoricalArchiveImportResult result,
  }) {
    final title = result.importedMessages > 0
        ? 'Archive Import Complete'
        : result.stagedMessages > 0
        ? 'Archive Projection Incomplete'
        : 'No New Archive Messages Imported';

    final lines = <String>[
      'Archive label: ${result.archiveLabel}',
      'Messages staged in archive cache: ${result.stagedMessages}',
      'Messages added to timeline: ${result.importedMessages}',
      'Already present in MessageLens: ${result.skippedDuplicates}',
      'Failed rows: ${result.failedRows}',
      'Messages without usable identifier: ${result.rowsWithoutGuidCount}',
      if (result.batchId != null) 'Archive batch id: ${result.batchId}',
      '',
      if (result.stagedMessages > 0)
        'Archive rows were stored in the dedicated archive import database.',
      if (result.importedMessages > 0)
        'Only the rows projected into working.db are now available in MessageLens timelines and search.',
      if (result.stagedMessages > 0 && result.importedMessages == 0)
        'Staged archive rows are not yet available in MessageLens because projection into working.db did not complete.',
      if (result.importedMessages > 0)
        'Rows with archive chat linkage replay into their matching conversations. Rows without chat linkage still fall back to a synthetic archive chat.',
    ];

    if (result.warnings.isNotEmpty) {
      lines
        ..add('')
        ..add('Warnings:')
        ..addAll(result.warnings.map((warning) => '• $warning'));
    }

    return SettingsInfoActionsCassettePayload(
      cassetteIndex: cassetteIndex,
      title: title,
      bodyText: lines.join('\n'),
      actions: const [
        SidebarActionDescriptor(
          label: 'Import Another Archive',
          intent: ShowImportHistoricalArchiveFlow(),
          tone: SidebarActionTone.primary,
        ),
        SidebarActionDescriptor(
          label: 'Close',
          intent: SettingsTransientActionCancelled(),
        ),
      ],
    );
  }

  String _formatRange(DateTime? earliestDate, DateTime? latestDate) {
    if (earliestDate == null && latestDate == null) {
      return 'Unavailable';
    }

    final formatter = DateFormat('MMM d, yyyy');
    final earliestLabel = earliestDate == null
        ? 'Unknown'
        : formatter.format(earliestDate);
    final latestLabel = latestDate == null
        ? 'Unknown'
        : formatter.format(latestDate);
    return '$earliestLabel -> $latestLabel';
  }
}
