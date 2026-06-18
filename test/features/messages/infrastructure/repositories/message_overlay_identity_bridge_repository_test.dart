import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/messages/infrastructure/repositories/message_overlay_identity_bridge_repository.dart';

import '../../../../essentials/conversation_graph/conversation_graph_test_database.dart';

void main() {
  late ConversationGraphDatabase graphDatabase;
  late OverlayDatabase overlayDatabase;
  late MessageOverlayIdentityBridgeRepository repository;

  setUp(() async {
    graphDatabase = await openConversationGraphTestDatabase();
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    await overlayDatabase.customSelect('SELECT 1').get();
    repository = MessageOverlayIdentityBridgeRepository(
      graphDatabase: graphDatabase,
      overlayDatabase: overlayDatabase,
    );
  });

  tearDown(() async {
    await graphDatabase.close();
    await overlayDatabase.close();
  });

  test('creates graph-native message intent overlay tables', () async {
    final rows = await overlayDatabase.customSelect('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name IN ('message_intent_overlays', 'message_intent_tags')
      ORDER BY name ASC
      ''').get();

    expect(rows.map((row) => row.data['name']), [
      'message_intent_overlays',
      'message_intent_tags',
    ]);
  });

  test(
    'reads retained rowid annotations for live-source graph messages',
    () async {
      final messageId = _messageId(42);
      await _insertGraphMessage(
        graphDatabase: graphDatabase,
        messageSsId: messageId,
        guid: 'guid-42',
      );
      await overlayDatabase.toggleMessageStar(42);
      await overlayDatabase.setMessageArchived(messageId: 42, archived: true);
      await overlayDatabase.addMessageTags(42, <String>['receipt']);
      await overlayDatabase.setMessageNotes(42, 'retained note');
      await overlayDatabase.setMessagePriority(42, 4);

      final state = await repository.readForMessage(messageId);

      expect(state.isStarred, isTrue);
      expect(state.isArchived, isTrue);
      expect(state.tags, contains('receipt'));
      expect(state.userNotes, 'retained note');
      expect(state.priority, 4);
      expect(state.usedRetainedAnnotationFallback, isTrue);
    },
  );

  test(
    'does not read retained rowid annotations for non-live graph messages',
    () async {
      final messageId = SourceScopedRowKey.pack(sourceId: 2, sourceRowId: 42);
      await _insertGraphMessage(
        graphDatabase: graphDatabase,
        messageSsId: messageId,
        guid: 'archive-guid-42',
      );
      await overlayDatabase.toggleMessageStar(42);
      await overlayDatabase.setMessageArchived(messageId: 42, archived: true);
      await overlayDatabase.addMessageTags(42, <String>['receipt']);
      await overlayDatabase.setMessageNotes(42, 'retained note');
      await overlayDatabase.setMessagePriority(42, 4);

      final state = await repository.readForMessage(messageId);

      expect(state.isStarred, isFalse);
      expect(state.isArchived, isFalse);
      expect(state.tags, isEmpty);
      expect(state.userNotes, isNull);
      expect(state.priority, isNull);
      expect(state.usedRetainedAnnotationFallback, isFalse);
    },
  );

  test(
    'reads unique GUID saved and tag overlays as compatibility fallback',
    () async {
      final messageId = _messageId(43);
      await _insertGraphMessage(
        graphDatabase: graphDatabase,
        messageSsId: messageId,
        guid: 'guid-43',
      );
      await overlayDatabase.setMessageSaved(
        messageGuid: 'guid-43',
        isSaved: true,
      );
      await overlayDatabase.addMessageUserTags(
        messageGuid: 'guid-43',
        tags: <String>['Important'],
      );

      final state = await repository.readForMessage(messageId);

      expect(state.isSaved, isTrue);
      expect(state.tags, contains('Important'));
      expect(state.usedGuidFallback, isTrue);
      expect(state.skippedGuidFallbackBecauseAmbiguous, isFalse);
    },
  );

  test(
    'does not apply GUID overlays when the GUID is graph-ambiguous',
    () async {
      final firstMessageId = _messageId(44);
      final secondMessageId = SourceScopedRowKey.pack(
        sourceId: 2,
        sourceRowId: 44,
      );
      await _insertGraphMessage(
        graphDatabase: graphDatabase,
        messageSsId: firstMessageId,
        guid: 'shared-guid',
      );
      await _insertGraphMessage(
        graphDatabase: graphDatabase,
        messageSsId: secondMessageId,
        guid: 'shared-guid',
      );
      await overlayDatabase.setMessageSaved(
        messageGuid: 'shared-guid',
        isSaved: true,
      );
      await overlayDatabase.addMessageUserTags(
        messageGuid: 'shared-guid',
        tags: <String>['Ambiguous'],
      );

      final state = await repository.readForMessage(firstMessageId);

      expect(state.isSaved, isFalse);
      expect(state.tags, isEmpty);
      expect(state.usedGuidFallback, isFalse);
      expect(state.skippedGuidFallbackBecauseAmbiguous, isTrue);
    },
  );

  test(
    'graph-native writes use message_ss_id and override retained fallback',
    () async {
      final messageId = _messageId(45);
      await _insertGraphMessage(
        graphDatabase: graphDatabase,
        messageSsId: messageId,
        guid: 'guid-45',
      );
      await overlayDatabase.toggleMessageStar(45);

      await repository.setStarred(messageSsId: messageId, isStarred: false);
      await repository.setSaved(messageSsId: messageId, isSaved: true);
      await repository.addTags(messageSsId: messageId, tags: <String>['Graph']);

      final state = await repository.readForMessage(messageId);
      final retainedGuidFlag = await overlayDatabase.getMessageUserFlag(
        'guid-45',
      );

      expect(state.hasGraphNativeOverlay, isTrue);
      expect(state.isStarred, isFalse);
      expect(state.isSaved, isTrue);
      expect(state.tags, contains('Graph'));
      expect(state.usedRetainedAnnotationFallback, isFalse);
      expect(retainedGuidFlag, isNull);
    },
  );
}

int _messageId(int sourceRowId) {
  return SourceScopedRowKey.pack(sourceId: 1, sourceRowId: sourceRowId);
}

Future<void> _insertGraphMessage({
  required ConversationGraphDatabase graphDatabase,
  required int messageSsId,
  required String guid,
}) {
  return graphDatabase.database.insert('messages', <String, Object?>{
    'ss_id': messageSsId,
    'guid': guid,
    'is_from_me': 0,
  });
}
