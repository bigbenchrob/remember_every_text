import 'graph_health_report.dart';

abstract interface class GraphHealthRepository {
  Future<GraphHealthReport> readHealthReport({
    bool includeFileAudits = false,
    bool includeRecoveryAudit = false,
  });
}
