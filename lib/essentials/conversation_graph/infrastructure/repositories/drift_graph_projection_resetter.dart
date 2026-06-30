import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../application/archives/graph_projection_resetter.dart';

final class DriftGraphProjectionResetter implements GraphProjectionResetter {
  const DriftGraphProjectionResetter({required this.graphDatabase});

  final ConversationGraphDatabase graphDatabase;

  @override
  Future<void> clearProjectionRows() {
    return graphDatabase.clearProjectionRows();
  }
}
