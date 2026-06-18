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
      const retainedHandleId = 42;
      const retainedContactId = 17;
      final graphHandleId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: retainedHandleId,
      );
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: retainedContactId,
      );

      await store.linkHandleToParticipant(
        handleId: retainedHandleId,
        participantId: retainedContactId,
      );

      expect(await overlayDb.getHandleOverride(retainedHandleId), isNull);
      final row = await overlayDb.getHandleOverride(graphHandleId);
      expect(row, isNotNull);
      expect(row!.participantId, graphContactId);
    },
  );

  test(
    'real contact links clear retained and graph handle variants first',
    () async {
      const retainedHandleId = 42;
      const retainedContactId = 17;
      const oldContactId = 19;
      final graphHandleId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: retainedHandleId,
      );
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: retainedContactId,
      );

      await overlayDb.setHandleOverride(retainedHandleId, oldContactId);
      await overlayDb.setHandleOverride(graphHandleId, oldContactId);

      await store.linkHandleToParticipant(
        handleId: retainedHandleId,
        participantId: retainedContactId,
      );

      final rows = await overlayDb.getAllHandleOverrides();
      expect(rows, hasLength(1));
      expect(rows.single.handleId, graphHandleId);
      expect(rows.single.participantId, graphContactId);
    },
  );

  test('readHandleOverride resolves retained variants as graph keys', () async {
    const retainedHandleId = 42;
    const retainedContactId = 17;
    final graphHandleId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: retainedHandleId,
    );
    final graphContactId = SourceScopedRowKey.pack(
      sourceId: liveAddressBookSourceId,
      sourceRowId: retainedContactId,
    );

    await overlayDb.setHandleOverride(retainedHandleId, retainedContactId);

    final override = await store.readHandleOverride(graphHandleId);

    expect(override, isNotNull);
    expect(override!.handleId, graphHandleId);
    expect(override.participantId, graphContactId);
  });

  test('virtual links normalize handle key only', () async {
    const retainedHandleId = 42;
    final graphHandleId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: retainedHandleId,
    );
    final virtualParticipant = await store.createVirtualParticipant(
      displayName: 'New Source',
    );

    await store.linkHandleToVirtualParticipant(
      handleId: retainedHandleId,
      virtualParticipantId: virtualParticipant.id,
    );

    expect(await overlayDb.getHandleOverride(retainedHandleId), isNull);
    final row = await overlayDb.getHandleOverride(graphHandleId);
    expect(row, isNotNull);
    expect(row!.participantId, isNull);
    expect(row.virtualParticipantId, virtualParticipant.id);
  });

  test('deleteHandleOverride removes retained and graph variants', () async {
    const retainedHandleId = 42;
    final graphHandleId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: retainedHandleId,
    );
    await overlayDb.setHandleOverride(retainedHandleId, 17);
    await overlayDb.setHandleOverride(graphHandleId, 17);

    await store.deleteHandleOverride(retainedHandleId);

    expect(await overlayDb.getAllHandleOverrides(), isEmpty);
  });
}
