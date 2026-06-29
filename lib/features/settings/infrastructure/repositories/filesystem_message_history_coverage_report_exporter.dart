import 'dart:io';

import 'package:path/path.dart' as path;

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
      if (_isSymlink(exportDirectory.path)) {
        throw StateError(
          'Coverage report export directory must not be a symlink.',
        );
      }
      await exportDirectory.create(recursive: true);

      final effectiveNow = now ?? DateTime.now();
      final exportFile = File(
        path.join(
          exportDirectory.path,
          messageHistoryCoverageReportExportFileName(effectiveNow),
        ),
      );
      if (_isSymlink(exportFile.path) || _isDirectory(exportFile.path)) {
        throw StateError(
          'Coverage report export target must be a regular file.',
        );
      }
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

bool _isDirectory(String filePath) {
  return FileSystemEntity.typeSync(filePath, followLinks: false) ==
      FileSystemEntityType.directory;
}

bool _isSymlink(String filePath) {
  return FileSystemEntity.typeSync(filePath, followLinks: false) ==
      FileSystemEntityType.link;
}
