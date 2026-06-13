import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/feature_level_providers.dart';
import 'application/app_logger.dart';
import 'application/diagnostic_report_exporter.dart';
import 'infrastructure/log_export_service.dart';
import 'infrastructure/support_bundle_diagnostic_report_exporter.dart';
import 'infrastructure/support_bundle_export_service.dart';

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
