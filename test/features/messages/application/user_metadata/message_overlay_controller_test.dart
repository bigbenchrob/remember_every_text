import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/messages/application/user_metadata/message_overlay_provider.dart';

import '../../../../essentials/conversation_graph/conversation_graph_test_database.dart';

void main() {
  late ConversationGraphDatabase graphDatabase;
  late OverlayDatabase overlayDatabase;
  late ProviderContainer container;

  setUp(() async {
    graphDatabase = await openConversationGraphTestDatabase();
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    await overlayDatabase.customSelect('SELECT 1').get();
    container = ProviderContainer(
      overrides: <Override>[
        driftConversationGraphDatabaseProvider.overrideWith((ref) async {
          return graphDatabase;
        }),
        overlayDatabaseProvider.overrideWith((ref) async {
          return overlayDatabase;
        }),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await graphDatabase.close();
    await overlayDatabase.close();
  });

  test('reads and writes message overlay state by graph message id', () async {
    final messageId = SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 77);
    await graphDatabase.database.insert('messages', <String, Object?>{
      'ss_id': messageId,
      'guid': 'message-77',
      'is_from_me': 0,
    });

    final initial = await container.read(
      messageOverlayProvider(messageId).future,
    );
    expect(initial.hasUserIntent, isFalse);

    final controller = container.read(
      messageOverlayProvider(messageId).notifier,
    );
    await controller.setSaved(isSaved: true);
    await controller.setStarred(isStarred: true);
    await controller.addTags(<String>['Review']);

    final updated = await container.read(
      messageOverlayProvider(messageId).future,
    );
    final guidKeyedFlag = await overlayDatabase.getMessageUserFlag(
      'message-77',
    );

    expect(updated.isSaved, isTrue);
    expect(updated.isStarred, isTrue);
    expect(updated.tags, contains('Review'));
    expect(updated.hasGraphNativeOverlay, isTrue);
    expect(guidKeyedFlag, isNull);
  });

  test('provider canonicalizes rowid-keyed id before overlay writes', () async {
    const rowidKeyedMessageId = 78;
    final messageSsId = SourceScopedRowKey.pack(
      sourceId: 1,
      sourceRowId: rowidKeyedMessageId,
    );
    await graphDatabase.database.insert('messages', <String, Object?>{
      'ss_id': messageSsId,
      'guid': 'message-78',
      'is_from_me': 0,
    });

    final controller = container.read(
      messageOverlayProvider(rowidKeyedMessageId).notifier,
    );
    await controller.setSaved(isSaved: true);

    final graphRows = await overlayDatabase.customSelect('''
      SELECT message_ss_id, is_saved
      FROM message_intent_overlays
      ''').get();
    final rowidKeyedRows = await overlayDatabase
        .customSelect(
          '''
      SELECT message_ss_id
      FROM message_intent_overlays
      WHERE message_ss_id = ?
      ''',
          variables: const [Variable<int>(rowidKeyedMessageId)],
        )
        .get();

    expect(graphRows, hasLength(1));
    expect(graphRows.single.data['message_ss_id'], messageSsId);
    expect(graphRows.single.data['is_saved'], 1);
    expect(rowidKeyedRows, isEmpty);
  });
}
