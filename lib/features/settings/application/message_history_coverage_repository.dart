import '../../../essentials/conversation_graph/feature_level_providers.dart'
    show CurrentSourceMessageGraphCoverageEvidence;
import '../../../essentials/source_scoped_import/feature_level_providers.dart'
    show CurrentMessagesSourceCoverageEvidence;

final class MessageHistoryCoverageEvidence {
  const MessageHistoryCoverageEvidence({
    required this.currentSource,
    required this.currentSourceGraph,
  });

  final CurrentMessagesSourceCoverageEvidence currentSource;
  final CurrentSourceMessageGraphCoverageEvidence currentSourceGraph;
}

abstract interface class MessageHistoryCoverageRepository {
  Future<MessageHistoryCoverageEvidence> readEvidence({
    required String chatDatabasePath,
  });
}
