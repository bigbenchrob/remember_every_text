import 'database_health_audit_models.dart';

abstract interface class DatabaseHealthAuditReportWriter {
  Future<String> writeReport({
    required String outputDirectoryPath,
    required DatabaseHealthReport report,
  });
}
