import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/feature_level_providers.dart';
import 'application/app_logger.dart';
import 'application/diagnostic_report_exporter.dart';
import 'application/pipeline_incident_log_writer.dart';
import 'application/pipeline_incident_store.dart';
import 'infrastructure/log_export_service.dart';
import 'infrastructure/pipeline_audit_incident_log_writer.dart';
import 'infrastructure/pipeline_incident_storage.dart';
import 'infrastructure/support_bundle_diagnostic_report_exporter.dart';
import 'infrastructure/support_bundle_export_service.dart';

export 'application/app_logger.dart';

part 'feature_level_providers.g.dart';

@riverpod
Future<DiagnosticReportExporter> diagnosticReportExporter(Ref ref) async {
  final writer = ref.read(appLoggerProvider.notifier).writer;
  final databaseHealthAuditService = await ref.watch(
    databaseHealthAuditServiceProvider.future,
  );

  return SupportBundleDiagnosticReportExporter(
    LogExportService(
      SupportBundleExportService(writer, databaseHealthAuditService),
    ),
  );
}

@riverpod
String diagnosticLogDirectoryPath(Ref ref) {
  return ref.read(appLoggerProvider.notifier).writer.logDir.path;
}

@riverpod
PipelineIncidentStore pipelineIncidentStore(Ref ref) {
  return PipelineIncidentStorage(
    overlayDb: ref.watch(overlayDatabaseProvider.future),
  );
}

@riverpod
PipelineIncidentLogWriter pipelineIncidentLogWriter(Ref ref) {
  return const PipelineAuditIncidentLogWriter();
}
