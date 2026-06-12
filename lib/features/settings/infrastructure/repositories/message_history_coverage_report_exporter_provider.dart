import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/sidebar_cassette_spec/actions/message_history_coverage_report_actions.dart';
import 'filesystem_message_history_coverage_report_exporter.dart';

part 'message_history_coverage_report_exporter_provider.g.dart';

@riverpod
MessageHistoryCoverageReportExporter messageHistoryCoverageReportExporter(
  MessageHistoryCoverageReportExporterRef ref,
) {
  return const FilesystemMessageHistoryCoverageReportExporter();
}
