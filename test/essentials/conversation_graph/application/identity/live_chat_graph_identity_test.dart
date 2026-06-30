import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/identity/live_chat_graph_identity.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  group('canonicalLiveChatGraphId', () {
    test('packs live chat.db source rowids into graph identity', () {
      expect(
        canonicalLiveChatGraphId(42),
        SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 42),
      );
    });

    test('preserves values that are already graph-sized ids', () {
      final graphId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      );

      expect(canonicalLiveChatGraphId(graphId), graphId);
    });

    test('preserves invalid placeholder ids', () {
      expect(canonicalLiveChatGraphId(0), 0);
      expect(canonicalLiveChatGraphId(-1), -1);
    });

    test('unpacks live chat graph ids to source rowids', () {
      final graphId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      );

      expect(liveChatSourceRowIdForGraphId(graphId), 42);
      expect(liveChatSourceRowIdForGraphId(42), isNull);
    });
  });
}
