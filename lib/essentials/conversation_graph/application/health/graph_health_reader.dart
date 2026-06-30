import 'graph_health_report.dart';
import 'graph_health_repository.dart';

class GraphHealthReader {
  const GraphHealthReader({required this.repository});

  final GraphHealthRepository repository;

  Future<GraphHealthReport> readHealthReport({
    bool includeFileAudits = false,
    bool includeRecoveryAudit = false,
  }) {
    return repository.readHealthReport(
      includeFileAudits: includeFileAudits,
      includeRecoveryAudit: includeRecoveryAudit,
    );
  }
}
