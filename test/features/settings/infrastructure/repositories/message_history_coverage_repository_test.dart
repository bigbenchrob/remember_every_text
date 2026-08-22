import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/feature_level_providers.dart';
import 'package:remember_this_text/essentials/source_scoped_import/feature_level_providers.dart';
import 'package:remember_this_text/features/settings/infrastructure/repositories/message_history_coverage_repository.dart';

void main() {
  test(
    'composes evidence without reinterpreting either owning domain',
    () async {
      final sourceEvidence = CurrentMessagesSourceCoverageEvidence(
        sourceRowIds: const <int>{1, 2},
        earliestMessageDate: null,
        latestMessageDate: null,
      );
      final graphEvidence = CurrentSourceMessageGraphCoverageEvidence(
        placementBySourceRowId: const <int, CurrentSourceMessageGraphPlacement>{
          1: CurrentSourceMessageGraphPlacement.conversationLinked,
        },
      );
      final sourceReader = _SourceReader(sourceEvidence);
      final graphReader = _GraphReader(graphEvidence);
      final repository = CanonicalMessageHistoryCoverageRepository(
        currentSourceReader: sourceReader,
        currentSourceGraphReader: graphReader,
      );

      final result = await repository.readEvidence(
        chatDatabasePath: '/source/chat.db',
      );

      expect(result.currentSource, same(sourceEvidence));
      expect(result.currentSourceGraph, same(graphEvidence));
      expect(sourceReader.paths, <String>['/source/chat.db']);
      expect(graphReader.readCount, 1);
    },
  );
}

final class _SourceReader implements CurrentMessagesSourceCoverageReader {
  _SourceReader(this.evidence);

  final CurrentMessagesSourceCoverageEvidence evidence;
  final paths = <String>[];

  @override
  Future<CurrentMessagesSourceCoverageEvidence> read({
    required String databasePath,
  }) async {
    paths.add(databasePath);
    return evidence;
  }
}

final class _GraphReader implements CurrentSourceMessageGraphCoverageReader {
  _GraphReader(this.evidence);

  final CurrentSourceMessageGraphCoverageEvidence evidence;
  var readCount = 0;

  @override
  Future<CurrentSourceMessageGraphCoverageEvidence> read() async {
    readCount++;
    return evidence;
  }
}
