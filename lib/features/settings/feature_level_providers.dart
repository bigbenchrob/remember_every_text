// =============================================================================
// SETTINGS FEATURE — PUBLIC API
// =============================================================================

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/db/feature_level_providers.dart';
import './application/archive_source_inspection.dart';
import './application/historical_archive_folder_chooser.dart';
import './application/historical_archive_sources.dart';
import './application/sidebar_cassette_spec/actions/message_history_coverage_report_actions.dart';
import './infrastructure/repositories/archive_source_inspection_repository.dart';
import './infrastructure/repositories/file_selector_historical_archive_folder_chooser.dart';
import './infrastructure/repositories/filesystem_message_history_coverage_report_exporter.dart';
import './infrastructure/repositories/historical_archive_sources_repository.dart';
import './infrastructure/repositories/message_history_coverage_repository.dart';

export './application/historical_archive_folder_chooser.dart';
export './application/historical_archive_sources.dart';
export './application/sidebar_cassette_spec/coordinators/settings_coordinator.dart';
export './application/sidebar_cassette_spec/payloads/attachment_archive_settings_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/historical_archives_settings_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/settings_action_card_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/settings_info_actions_cassette_payload.dart';
export './application/sidebar_cassette_spec/providers/historical_archives_sidebar_known_sources_provider.dart';
export './application/sidebar_cassette_spec/rendering/settings_cassette_body_builder.dart';
export './application/view_spec/coordinators/view_spec_coordinator.dart';
export './domain/spec_classes/settings_cassette_spec.dart';
export './domain/spec_classes/settings_view_spec.dart';

part 'feature_level_providers.g.dart';

@riverpod
Future<ArchiveSourceInspector> archiveSourceInspector(Ref ref) {
  return ref.watch(archiveSourceInspectionRepositoryProvider.future);
}

@riverpod
HistoricalArchiveFolderChooser historicalArchiveFolderChooser(Ref ref) {
  return const FileSelectorHistoricalArchiveFolderChooser();
}

@riverpod
Future<HistoricalArchiveSources> historicalArchiveSources(Ref ref) {
  return ref.watch(historicalArchiveSourcesRepositoryProvider.future);
}

@riverpod
Future<List<HistoricalArchiveSourceMetadata>> historicalArchiveSourceMetadata(
  Ref ref,
) async {
  final sources = await ref.watch(historicalArchiveSourcesProvider.future);
  return sources.readKnownSources();
}

@riverpod
Future<MessageHistoryCoverageRepository> messageHistoryCoverageRepository(
  Ref ref,
) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return MessageHistoryCoverageRepository(graphDb: graphDb);
}

@riverpod
MessageHistoryCoverageReportExporter messageHistoryCoverageReportExporter(
  Ref ref,
) {
  return const FilesystemMessageHistoryCoverageReportExporter();
}
