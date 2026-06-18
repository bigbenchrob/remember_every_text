import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/identity/retained_overlay_identity_bridge.dart';
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

  group('overlayValueForContactId', () {
    test('finds retained contact overlay value for graph contact id', () {
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: 17,
      );

      final value = overlayValueForContactId({17: 'Claire'}, graphContactId);

      expect(value, 'Claire');
    });

    test('prefers exact graph contact value over retained variant', () {
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: 17,
      );

      final value = overlayValueForContactId({
        17: 'Retained Claire',
        graphContactId: 'Graph Claire',
      }, graphContactId);

      expect(value, 'Graph Claire');
    });

    test(
      'does not read retained value for non-AddressBook graph contact id',
      () {
        final nonAddressBookId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: 17,
        );

        final value = overlayValueForContactId({
          17: 'Wrong source Claire',
        }, nonAddressBookId);

        expect(value, isNull);
      },
    );
  });

  group('canonicalContactOverlayKey', () {
    test('rewrites retained live AddressBook id to graph contact id', () {
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: 17,
      );

      expect(canonicalContactOverlayKey(17), graphContactId);
    });

    test('preserves graph contact id', () {
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: 17,
      );

      expect(canonicalContactOverlayKey(graphContactId), graphContactId);
    });

    test('preserves non-live graph id', () {
      final archiveContactId = SourceScopedRowKey.pack(
        sourceId: 99,
        sourceRowId: 17,
      );

      expect(canonicalContactOverlayKey(archiveContactId), archiveContactId);
    });
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

  group('overlayValueForHandleId', () {
    test('finds retained handle overlay value for graph handle id', () {
      final graphHandleId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      );

      final value = overlayValueForHandleId({42: 'visible'}, graphHandleId);

      expect(value, 'visible');
    });

    test('prefers exact graph handle value over retained variant', () {
      final graphHandleId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      );

      final value = overlayValueForHandleId({
        42: 'retained',
        graphHandleId: 'graph',
      }, graphHandleId);

      expect(value, 'graph');
    });

    test('does not read retained value for non-live graph handle id', () {
      final archiveHandleId = SourceScopedRowKey.pack(
        sourceId: 99,
        sourceRowId: 42,
      );

      final value = overlayValueForHandleId({
        42: 'wrong source',
      }, archiveHandleId);

      expect(value, isNull);
    });
  });

  group('canonicalHandleOverlayKey', () {
    test('collapses retained live handle id to graph handle id', () {
      final graphHandleId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      );

      expect(canonicalHandleOverlayKey(42), graphHandleId);
      expect(canonicalHandleOverlayKey(graphHandleId), graphHandleId);
    });

    test('preserves non-live graph handle ids', () {
      final archiveHandleId = SourceScopedRowKey.pack(
        sourceId: 99,
        sourceRowId: 42,
      );

      expect(canonicalHandleOverlayKey(archiveHandleId), archiveHandleId);
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
