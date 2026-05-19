import '../../../domain/models/topology_projection_preview.dart';
import '../../../domain/responsibiliity_role_interfaces.dart';
import '../../../infrastructure/topology_projection_preview_repository.dart';

class TopologyProjectionPreviewFactsReader
    implements Reader<List<TopologyProjectionPreviewFact>> {
  const TopologyProjectionPreviewFactsReader({
    required TopologyProjectionPreviewRepository repository,
  }) : _repository = repository;

  final TopologyProjectionPreviewRepository _repository;

  @override
  Future<List<TopologyProjectionPreviewFact>> read() async {
    return _repository.readPreviewFacts();
  }
}
