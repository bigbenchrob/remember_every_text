import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/handles/infrastructure/repositories/overlay_handle_review_store.dart';

void main() {
  late OverlayDatabase overlayDb;
  late OverlayHandleReviewStore store;

  setUp(() {
    overlayDb = OverlayDatabase(NativeDatabase.memory());
    store = OverlayHandleReviewStore(overlayDatabase: overlayDb);
  });

  tearDown(() async {
    await overlayDb.close();
  });

  test('markReviewed stores reviewed-only row with graph handle key', () async {
    const rowidKeyedHandleId = 42;
    final graphHandleId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: rowidKeyedHandleId,
    );

    await store.markReviewed(handleId: rowidKeyedHandleId);

    expect(await overlayDb.getHandleOverride(rowidKeyedHandleId), isNull);
    final row = await overlayDb.getHandleOverride(graphHandleId);
    expect(row, isNotNull);
    expect(row!.participantId, isNull);
    expect(row.virtualParticipantId, isNull);
    expect(row.reviewedAt, isNotNull);
  });

  test(
    'markReviewed preserves real contact link while normalizing keys',
    () async {
      const rowidKeyedHandleId = 42;
      const rowidKeyedContactId = 17;
      final graphHandleId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: rowidKeyedHandleId,
      );
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: rowidKeyedContactId,
      );
      await overlayDb.setHandleOverride(
        rowidKeyedHandleId,
        rowidKeyedContactId,
      );

      await store.markReviewed(handleId: graphHandleId);

      expect(await overlayDb.getHandleOverride(rowidKeyedHandleId), isNull);
      final row = await overlayDb.getHandleOverride(graphHandleId);
      expect(row, isNotNull);
      expect(row!.participantId, graphContactId);
      expect(row.reviewedAt, isNotNull);
    },
  );

  test(
    'markReviewed preserves virtual contact link while normalizing handle',
    () async {
      const rowidKeyedHandleId = 42;
      final graphHandleId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: rowidKeyedHandleId,
      );
      final virtualParticipant = await overlayDb.createVirtualParticipant(
        displayName: 'New Source',
      );
      await overlayDb.setHandleVirtualParticipantOverride(
        rowidKeyedHandleId,
        virtualParticipant.id,
      );

      await store.markReviewed(handleId: rowidKeyedHandleId);

      expect(await overlayDb.getHandleOverride(rowidKeyedHandleId), isNull);
      final row = await overlayDb.getHandleOverride(graphHandleId);
      expect(row, isNotNull);
      expect(row!.participantId, isNull);
      expect(row.virtualParticipantId, virtualParticipant.id);
      expect(row.reviewedAt, isNotNull);
    },
  );
}
