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
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    final reportPath = path.join(outputDirectoryPath, 'database_health.json');
    const encoder = JsonEncoder.withIndent('  ');
    await File(
      reportPath,
    ).writeAsString('${encoder.convert(report.toJson())}\n');

    return reportPath;
  }
}
