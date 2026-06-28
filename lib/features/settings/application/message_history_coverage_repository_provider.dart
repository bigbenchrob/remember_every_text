import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider;
import '../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import '../infrastructure/repositories/filesystem_message_history_coverage_report_exporter.dart';
import '../infrastructure/repositories/message_history_coverage_repository.dart';
import 'sidebar_cassette_spec/actions/message_history_coverage_report_actions.dart';

part 'message_history_coverage_repository_provider.g.dart';

@riverpod
Future<MessageHistoryCoverageRepository> messageHistoryCoverageRepository(
  Ref ref,
) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return MessageHistoryCoverageRepository(
    graphDb: graphDb,
    onSourceReadFailure: (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'MessageHistoryCoverage: failed to read source chat.db summary',
            source: 'SettingsFeatureProviders',
            context: <String, Object?>{
              'error': error.toString(),
              'stackTrace': stackTrace.toString(),
            },
          );
    },
  );
}

@riverpod
MessageHistoryCoverageReportExporter messageHistoryCoverageReportExporter(
  Ref ref,
) {
  return const FilesystemMessageHistoryCoverageReportExporter();
}
