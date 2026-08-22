import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/conversation_graph/feature_level_providers.dart'
    show currentSourceMessageGraphCoverageReaderProvider;
import '../../../essentials/source_scoped_import/feature_level_providers.dart'
    show currentMessagesSourceCoverageReaderProvider;
import '../infrastructure/repositories/filesystem_message_history_coverage_report_exporter.dart';
import '../infrastructure/repositories/message_history_coverage_repository.dart';
import 'message_history_coverage_repository.dart';
import 'sidebar_cassette_spec/actions/message_history_coverage_report_actions.dart';

part 'message_history_coverage_repository_provider.g.dart';

@riverpod
Future<MessageHistoryCoverageRepository> messageHistoryCoverageRepository(
  Ref ref,
) async {
  return CanonicalMessageHistoryCoverageRepository(
    currentSourceReader: ref.watch(currentMessagesSourceCoverageReaderProvider),
    currentSourceGraphReader: await ref.watch(
      currentSourceMessageGraphCoverageReaderProvider.future,
    ),
  );
}

@riverpod
MessageHistoryCoverageReportExporter messageHistoryCoverageReportExporter(
  Ref ref,
) {
  return const FilesystemMessageHistoryCoverageReportExporter();
}
