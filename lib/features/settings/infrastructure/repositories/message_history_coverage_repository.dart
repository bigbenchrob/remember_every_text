import '../../../../essentials/conversation_graph/feature_level_providers.dart'
    show CurrentSourceMessageGraphCoverageReader;
import '../../../../essentials/source_scoped_import/feature_level_providers.dart'
    show CurrentMessagesSourceCoverageReader;
import '../../application/message_history_coverage_repository.dart';

final class CanonicalMessageHistoryCoverageRepository
    implements MessageHistoryCoverageRepository {
  const CanonicalMessageHistoryCoverageRepository({
    required CurrentMessagesSourceCoverageReader currentSourceReader,
    required CurrentSourceMessageGraphCoverageReader currentSourceGraphReader,
  }) : _currentSourceReader = currentSourceReader,
       _currentSourceGraphReader = currentSourceGraphReader;

  final CurrentMessagesSourceCoverageReader _currentSourceReader;
  final CurrentSourceMessageGraphCoverageReader _currentSourceGraphReader;

  @override
  Future<MessageHistoryCoverageEvidence> readEvidence({
    required String chatDatabasePath,
  }) async {
    final currentSource = await _currentSourceReader.read(
      databasePath: chatDatabasePath,
    );
    final currentSourceGraph = await _currentSourceGraphReader.read();
    return MessageHistoryCoverageEvidence(
      currentSource: currentSource,
      currentSourceGraph: currentSourceGraph,
    );
  }
}
