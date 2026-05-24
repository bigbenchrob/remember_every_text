import 'graph_health_report.dart';
import 'graph_health_repository.dart';

class GraphHealthReader {
  const GraphHealthReader({required this.repository});

  final GraphHealthRepository repository;

  Future<GraphHealthReport> readHealthReport() {
    return repository.readHealthReport();
  }
}
