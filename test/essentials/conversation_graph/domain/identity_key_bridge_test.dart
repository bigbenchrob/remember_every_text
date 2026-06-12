import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/domain/identity_key_bridge.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  group('retainedOverlayMessageRowIdForGraphMessageId', () {
    test('returns source rowid for live chat-db message ids', () {
      final messageSsId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      );

      expect(retainedOverlayMessageRowIdForGraphMessageId(messageSsId), 42);
    });

    test('returns null for non-live message ids', () {
      final messageSsId = SourceScopedRowKey.pack(
        sourceId: 99,
        sourceRowId: 42,
      );

      expect(retainedOverlayMessageRowIdForGraphMessageId(messageSsId), isNull);
    });
  });

  group('graphMessageIdForRetainedOverlayMessageRowId', () {
    test('packs valid retained-overlay live message rowids', () {
      final messageSsId = graphMessageIdForRetainedOverlayMessageRowId(42);

      expect(
        messageSsId,
        SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 42),
      );
    });

    test('returns null for invalid retained-overlay live message rowids', () {
      expect(graphMessageIdForRetainedOverlayMessageRowId(0), isNull);
      expect(
        graphMessageIdForRetainedOverlayMessageRowId(
          SourceScopedRowKey.maxSourceRowId + 1,
        ),
        isNull,
      );
    });
  });
}
