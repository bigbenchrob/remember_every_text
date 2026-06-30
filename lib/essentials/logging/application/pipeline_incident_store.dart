import '../domain/pipeline_incident_report.dart';

abstract interface class PipelineIncidentStore {
  Future<PipelineIncidentReport?> loadLatestReport();

  Future<void> saveLatestReport(PipelineIncidentReport report);

  Future<void> dismissLatestReport();

  Future<void> clearLatestReport();
}
