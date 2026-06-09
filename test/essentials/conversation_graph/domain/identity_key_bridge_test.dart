import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/domain/identity_key_bridge.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  group('legacyMessageRowIdForGraphMessageId', () {
    test('returns source rowid for live chat-db message ids', () {
      final messageSsId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      );

      expect(legacyMessageRowIdForGraphMessageId(messageSsId), 42);
    });

    test('returns null for non-live message ids', () {
      final messageSsId = SourceScopedRowKey.pack(
        sourceId: 99,
        sourceRowId: 42,
      );

      expect(legacyMessageRowIdForGraphMessageId(messageSsId), isNull);
    });
  });

  group('graphMessageIdForLegacyMessageRowId', () {
    test('packs valid legacy live message rowids', () {
      final messageSsId = graphMessageIdForLegacyMessageRowId(42);

      expect(
        messageSsId,
        SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 42),
      );
    });

    test('returns null for invalid legacy live message rowids', () {
      expect(graphMessageIdForLegacyMessageRowId(0), isNull);
      expect(
        graphMessageIdForLegacyMessageRowId(
          SourceScopedRowKey.maxSourceRowId + 1,
        ),
        isNull,
      );
    });
  });
}
