import '../application/pipeline_incident_log_writer.dart';
import '../domain/pipeline_incident_report.dart';
import 'pipeline_audit_logger.dart';

class PipelineAuditIncidentLogWriter implements PipelineIncidentLogWriter {
  const PipelineAuditIncidentLogWriter();

  static const _logFile = 'pipeline_incident_log';

  @override
  Future<void> appendReport({required PipelineIncidentReport report}) async {
    final log = await PipelineAuditLogger.open(_logFile);

    try {
      log.header(
        'PIPELINE INCIDENT - ${report.stage.displayLabel} - ${report.recordedAtUtc.toIso8601String()}',
      );
      log.stat('Report id', report.reportId);
      log.stat('Stage', report.stage.displayLabel);
      log.stat('Batch id', report.batchId);
      log.stat('Dismissed', report.dismissed);
      log.stat('Blocking incident', report.hasBlockingIncident);
      log.info(report.headline);
      log.info(report.summary);

      if (report.entries.isEmpty) {
        log.ok('No incident entries were recorded.');
      } else {
        log.subHeader('ENTRIES');
        for (final entry in report.entries) {
          log.info(
            '[${entry.severity.name}] ${entry.stage.displayLabel}: ${entry.summary}',
          );
          if (entry.code != null && entry.code!.isNotEmpty) {
            log.stat('  code', entry.code!);
          }
          if (entry.detail != null && entry.detail!.isNotEmpty) {
            log.info('  ${entry.detail!}');
          }
        }
      }

      log.blank();
      log.info('--- end of pipeline incident report ---');
      log.blank();
    } finally {
      await log.close();
    }
  }
}
