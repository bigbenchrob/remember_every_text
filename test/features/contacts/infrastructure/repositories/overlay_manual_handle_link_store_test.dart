import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/overlay_manual_handle_link_store.dart';

void main() {
  late OverlayDatabase overlayDb;
  late OverlayManualHandleLinkStore store;

  setUp(() {
    overlayDb = OverlayDatabase(NativeDatabase.memory());
    store = OverlayManualHandleLinkStore(overlayDatabase: overlayDb);
  });

  tearDown(() async {
    await overlayDb.close();
  });

  test(
    'real contact links are stored with graph handle and contact keys',
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

      await store.linkHandleToParticipant(
        handleId: rowidKeyedHandleId,
        participantId: rowidKeyedContactId,
      );

      expect(await overlayDb.getHandleOverride(rowidKeyedHandleId), isNull);
      final row = await overlayDb.getHandleOverride(graphHandleId);
      expect(row, isNotNull);
      expect(row!.participantId, graphContactId);
    },
  );

  test(
    'real contact links clear rowid-keyed and graph handle variants first',
    () async {
      const rowidKeyedHandleId = 42;
      const rowidKeyedContactId = 17;
      const oldContactId = 19;
      final graphHandleId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: rowidKeyedHandleId,
      );
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: rowidKeyedContactId,
      );

      await overlayDb.setHandleOverride(rowidKeyedHandleId, oldContactId);
      await overlayDb.setHandleOverride(graphHandleId, oldContactId);

      await store.linkHandleToParticipant(
        handleId: rowidKeyedHandleId,
        participantId: rowidKeyedContactId,
      );

      final rows = await overlayDb.getAllHandleOverrides();
      expect(rows, hasLength(1));
      expect(rows.single.handleId, graphHandleId);
      expect(rows.single.participantId, graphContactId);
    },
  );

  test(
    'readHandleOverride resolves rowid-keyed variants as graph keys',
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

      final override = await store.readHandleOverride(graphHandleId);

      expect(override, isNotNull);
      expect(override!.handleId, graphHandleId);
      expect(override.participantId, graphContactId);
    },
  );

  test('virtual links normalize handle key only', () async {
    const rowidKeyedHandleId = 42;
    final graphHandleId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: rowidKeyedHandleId,
    );
    final virtualParticipant = await store.createVirtualParticipant(
      displayName: 'New Source',
    );

    await store.linkHandleToVirtualParticipant(
      handleId: rowidKeyedHandleId,
      virtualParticipantId: virtualParticipant.id,
    );

    expect(await overlayDb.getHandleOverride(rowidKeyedHandleId), isNull);
    final row = await overlayDb.getHandleOverride(graphHandleId);
    expect(row, isNotNull);
    expect(row!.participantId, isNull);
    expect(row.virtualParticipantId, virtualParticipant.id);
  });

  test('deleteHandleOverride removes rowid-keyed and graph variants', () async {
    const rowidKeyedHandleId = 42;
    final graphHandleId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: rowidKeyedHandleId,
    );
    await overlayDb.setHandleOverride(rowidKeyedHandleId, 17);
    await overlayDb.setHandleOverride(graphHandleId, 17);

    await store.deleteHandleOverride(rowidKeyedHandleId);

    expect(await overlayDb.getAllHandleOverrides(), isEmpty);
  });
}
