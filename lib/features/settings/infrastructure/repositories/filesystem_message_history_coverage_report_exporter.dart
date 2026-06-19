import 'dart:io';

import '../../application/sidebar_cassette_spec/actions/message_history_coverage_report_actions.dart';
import '../../application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';

typedef CoverageReportProcessRunner =
    Future<ProcessResult> Function(String executable, List<String> arguments);

class FilesystemMessageHistoryCoverageReportExporter
    implements MessageHistoryCoverageReportExporter {
  const FilesystemMessageHistoryCoverageReportExporter({
    this.processRunner = Process.run,
  });

  final CoverageReportProcessRunner processRunner;

  @override
  Future<MessageHistoryCoverageReportExportResult> export({
    required MessageHistoryCoverageReport report,
    required String exportDirectoryPath,
    DateTime? now,
  }) async {
    try {
      final exportDirectory = Directory(exportDirectoryPath);
      await exportDirectory.create(recursive: true);

      final effectiveNow = now ?? DateTime.now();
      final exportFile = File(
        '${exportDirectory.path}/'
        '${messageHistoryCoverageReportExportFileName(effectiveNow)}',
      );
      await exportFile.writeAsString(
        messageHistoryCoverageReportExportJson(
          report: report,
          now: effectiveNow,
        ),
      );

      var revealedInFinder = false;
      if (Platform.isMacOS) {
        final result = await processRunner('open', ['-R', exportFile.path]);
        revealedInFinder = result.exitCode == 0;
      }

      return MessageHistoryCoverageReportExportResult(
        exportPath: exportFile.path,
        revealedInFinder: revealedInFinder,
      );
    } catch (error) {
      return MessageHistoryCoverageReportExportResult(
        exportPath: null,
        revealedInFinder: false,
        errorMessage: error.toString(),
      );
    }
  }
}
