import '../domain/pipeline_incident_report.dart';

abstract interface class PipelineIncidentLogWriter {
  Future<void> appendReport({required PipelineIncidentReport report});
}
