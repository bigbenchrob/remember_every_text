import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/domain/identity_key_bridge.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';

void main() {
  group('contactOverlayKeyVariants', () {
    test('includes graph contact id for retained live AddressBook ids', () {
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: 17,
      );

      expect(contactOverlayKeyVariants(17), {17, graphContactId});
    });

    test('includes retained contact id for graph live AddressBook ids', () {
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: 17,
      );

      expect(contactOverlayKeyVariants(graphContactId), {graphContactId, 17});
    });

    test(
      'does not invent retained contact id for non-AddressBook graph ids',
      () {
        final chatDbId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: 17,
        );

        expect(contactOverlayKeyVariants(chatDbId), {chatDbId});
      },
    );
  });

  group('handleOverlayKeyVariants', () {
    test('includes graph handle id for retained live handle ids', () {
      final graphHandleId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      );

      expect(handleOverlayKeyVariants(42), {42, graphHandleId});
    });

    test('includes retained handle id for graph live handle ids', () {
      final graphHandleId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      );

      expect(handleOverlayKeyVariants(graphHandleId), {graphHandleId, 42});
    });

    test('does not invent retained handle id for non-live graph ids', () {
      final archiveHandleId = SourceScopedRowKey.pack(
        sourceId: 99,
        sourceRowId: 42,
      );

      expect(handleOverlayKeyVariants(archiveHandleId), {archiveHandleId});
    });
  });

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
