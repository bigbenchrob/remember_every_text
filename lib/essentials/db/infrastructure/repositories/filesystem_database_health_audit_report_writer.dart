import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../../application/database_health_audit/database_health_audit_models.dart';
import '../../application/database_health_audit/database_health_audit_report_writer.dart';

class FilesystemDatabaseHealthAuditReportWriter
    implements DatabaseHealthAuditReportWriter {
  const FilesystemDatabaseHealthAuditReportWriter();

  @override
  Future<String> writeReport({
    required String outputDirectoryPath,
    required DatabaseHealthReport report,
  }) async {
    final directory = Directory(outputDirectoryPath);
    final directoryType = FileSystemEntity.typeSync(
      outputDirectoryPath,
      followLinks: false,
    );
    if (directoryType == FileSystemEntityType.link) {
      throw StateError(
        'Database health report directory must not be a symlink.',
      );
    }
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    final reportPath = path.join(outputDirectoryPath, 'database_health.json');
    final reportTargetType = FileSystemEntity.typeSync(
      reportPath,
      followLinks: false,
    );
    if (reportTargetType == FileSystemEntityType.link ||
        reportTargetType == FileSystemEntityType.directory) {
      throw StateError(
        'Database health report target must be a regular file path.',
      );
    }

    const encoder = JsonEncoder.withIndent('  ');
    await File(
      reportPath,
    ).writeAsString('${encoder.convert(report.toJson())}\n');

    return reportPath;
  }
}
