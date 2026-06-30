import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/handles/infrastructure/repositories/overlay_handle_visibility_store.dart';

void main() {
  late OverlayDatabase overlayDb;
  late OverlayHandleVisibilityStore store;

  setUp(() {
    overlayDb = OverlayDatabase(NativeDatabase.memory());
    store = OverlayHandleVisibilityStore(overlayDatabase: overlayDb);
  });

  tearDown(() async {
    await overlayDb.close();
  });

  test('blockHandle stores graph handle key', () async {
    const rowidKeyedHandleId = 42;
    final graphHandleId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: rowidKeyedHandleId,
    );

    await store.blockHandle(rowidKeyedHandleId);

    expect(await overlayDb.getHandleVisibility(rowidKeyedHandleId), isNull);
    final row = await overlayDb.getHandleVisibility(graphHandleId);
    expect(row, isNotNull);
    expect(row!.isVisible, isFalse);
    expect(row.isBlacklisted, isTrue);
  });

  test(
    'blockHandle clears rowid-keyed and graph variants before writing',
    () async {
      const rowidKeyedHandleId = 42;
      final graphHandleId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: rowidKeyedHandleId,
      );
      await overlayDb.setHandleVisibility(
        rowidKeyedHandleId,
        isVisible: true,
        isBlacklisted: false,
      );
      await overlayDb.setHandleVisibility(
        graphHandleId,
        isVisible: true,
        isBlacklisted: false,
      );

      await store.blockHandle(rowidKeyedHandleId);

      final rows = await overlayDb.getAllHandleVisibilities();
      expect(rows, hasLength(1));
      expect(rows.single.handleId, graphHandleId);
      expect(rows.single.isBlacklisted, isTrue);
    },
  );

  test('unblockHandle removes rowid-keyed and graph variants', () async {
    const rowidKeyedHandleId = 42;
    final graphHandleId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: rowidKeyedHandleId,
    );
    await overlayDb.setHandleVisibility(
      rowidKeyedHandleId,
      isVisible: false,
      isBlacklisted: true,
    );
    await overlayDb.setHandleVisibility(
      graphHandleId,
      isVisible: false,
      isBlacklisted: true,
    );

    await store.unblockHandle(rowidKeyedHandleId);

    expect(await overlayDb.getAllHandleVisibilities(), isEmpty);
  });

  test('readAll deduplicates rowid-keyed and graph variants', () async {
    const rowidKeyedHandleId = 42;
    final graphHandleId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: rowidKeyedHandleId,
    );
    await overlayDb.setHandleVisibility(
      rowidKeyedHandleId,
      isVisible: false,
      isBlacklisted: true,
    );
    await overlayDb.setHandleVisibility(
      graphHandleId,
      isVisible: true,
      isBlacklisted: false,
    );

    final intents = await store.readAll();

    expect(intents, hasLength(1));
    expect(intents.single.handleId, graphHandleId);
    expect(intents.single.isVisible, isTrue);
    expect(intents.single.isBlacklisted, isFalse);
  });
}
