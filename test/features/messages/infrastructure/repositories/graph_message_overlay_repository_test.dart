import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/messages/infrastructure/repositories/graph_message_overlay_repository.dart';

import '../../../../essentials/conversation_graph/conversation_graph_test_database.dart';

void main() {
  late ConversationGraphDatabase graphDatabase;
  late OverlayDatabase overlayDatabase;
  late GraphMessageOverlayRepository repository;

  setUp(() async {
    graphDatabase = await openConversationGraphTestDatabase();
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    await overlayDatabase.customSelect('SELECT 1').get();
    repository = GraphMessageOverlayRepository(
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
    'reads rowid-keyed annotations for live-source graph messages',
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
      await overlayDatabase.setMessageNotes(42, 'rowid-keyed note');
      await overlayDatabase.setMessagePriority(42, 4);

      final state = await repository.readForMessage(messageId);

      expect(state.isStarred, isTrue);
      expect(state.isArchived, isTrue);
      expect(state.tags, contains('receipt'));
      expect(state.userNotes, 'rowid-keyed note');
      expect(state.priority, 4);
      expect(state.usedRowidAnnotationFallback, isTrue);
    },
  );

  test(
    'reads rowid-keyed annotation tags with commas as structured JSON',
    () async {
      final messageId = _messageId(47);
      await _insertGraphMessage(
        graphDatabase: graphDatabase,
        messageSsId: messageId,
        guid: 'guid-47',
      );
      await _insertRowidAnnotationTags(
        overlayDatabase,
        messageId: 47,
        tagsJson: '["invoice, paid","urgent"]',
      );

      final state = await repository.readForMessage(messageId);

      expect(state.tags, contains('invoice, paid'));
      expect(state.tags, contains('urgent'));
      expect(state.tags, isNot(contains('invoice')));
      expect(state.tags, isNot(contains('paid')));
      expect(state.usedRowidAnnotationFallback, isTrue);
    },
  );

  test(
    'ignores malformed rowid-keyed annotation tags without failing read',
    () async {
      final messageId = _messageId(48);
      await _insertGraphMessage(
        graphDatabase: graphDatabase,
        messageSsId: messageId,
        guid: 'guid-48',
      );
      await _insertRowidAnnotationTags(
        overlayDatabase,
        messageId: 48,
        tagsJson: 'not json',
      );

      final state = await repository.readForMessage(messageId);

      expect(state.tags, isEmpty);
      expect(state.usedRowidAnnotationFallback, isTrue);
    },
  );

  test(
    'does not read rowid-keyed annotations for non-live graph messages',
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
      await overlayDatabase.setMessageNotes(42, 'rowid-keyed note');
      await overlayDatabase.setMessagePriority(42, 4);

      final state = await repository.readForMessage(messageId);

      expect(state.isStarred, isFalse);
      expect(state.isArchived, isFalse);
      expect(state.tags, isEmpty);
      expect(state.userNotes, isNull);
      expect(state.priority, isNull);
      expect(state.usedRowidAnnotationFallback, isFalse);
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

  test('reads unique GUID tag overlays with commas atomically', () async {
    final messageId = _messageId(49);
    await _insertGraphMessage(
      graphDatabase: graphDatabase,
      messageSsId: messageId,
      guid: 'guid-49',
    );
    await overlayDatabase.addMessageUserTags(
      messageGuid: 'guid-49',
      tags: <String>['invoice, paid', 'urgent'],
    );

    final state = await repository.readForMessage(messageId);

    expect(state.tags, contains('invoice, paid'));
    expect(state.tags, contains('urgent'));
    expect(state.tags, isNot(contains('invoice')));
    expect(state.tags, isNot(contains('paid')));
    expect(state.usedGuidFallback, isTrue);
    expect(state.skippedGuidFallbackBecauseAmbiguous, isFalse);
  });

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
    'graph-native writes use message_ss_id and override rowid-keyed fallback',
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
      final guidKeyedFlag = await overlayDatabase.getMessageUserFlag('guid-45');

      expect(state.hasGraphNativeOverlay, isTrue);
      expect(state.isStarred, isFalse);
      expect(state.isSaved, isTrue);
      expect(state.tags, contains('Graph'));
      expect(state.usedRowidAnnotationFallback, isFalse);
      expect(guidKeyedFlag, isNull);
    },
  );

  test(
    'graph-native overlay suppresses rowid-keyed annotation fields',
    () async {
      final messageId = _messageId(46);
      await _insertGraphMessage(
        graphDatabase: graphDatabase,
        messageSsId: messageId,
        guid: 'guid-46',
      );
      await overlayDatabase.toggleMessageStar(46);
      await overlayDatabase.setMessageArchived(messageId: 46, archived: true);
      await overlayDatabase.addMessageTags(46, <String>['Rowid']);
      await overlayDatabase.setMessageNotes(46, 'rowid-keyed note');
      await overlayDatabase.setMessagePriority(46, 5);
      await overlayDatabase.setMessageReminder(46, DateTime.utc(2026, 1, 2));

      await repository.setStarred(messageSsId: messageId, isStarred: false);
      await repository.setArchived(messageSsId: messageId, isArchived: false);
      await repository.setNotes(messageSsId: messageId, notes: 'graph note');
      await repository.setPriority(messageSsId: messageId, priority: 2);
      await repository.setReminder(
        messageSsId: messageId,
        remindAt: DateTime.utc(2027, 3, 4),
      );
      await repository.addTags(messageSsId: messageId, tags: <String>['Graph']);

      final state = await repository.readForMessage(messageId);

      expect(state.hasGraphNativeOverlay, isTrue);
      expect(state.isStarred, isFalse);
      expect(state.isArchived, isFalse);
      expect(state.userNotes, 'graph note');
      expect(state.priority, 2);
      expect(state.remindAtUtc, '2027-03-04T00:00:00.000Z');
      expect(state.tags, contains('Graph'));
      expect(state.tags, isNot(contains('Rowid')));
      expect(state.usedRowidAnnotationFallback, isFalse);
    },
  );
}

int _messageId(int sourceRowId) {
  return SourceScopedRowKey.pack(
    sourceId: liveChatDbSourceId,
    sourceRowId: sourceRowId,
  );
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

Future<void> _insertRowidAnnotationTags(
  OverlayDatabase overlayDatabase, {
  required int messageId,
  required String tagsJson,
}) {
  return overlayDatabase.customStatement(
    '''
    INSERT INTO message_annotations (
      message_id,
      tags,
      is_starred,
      is_archived,
      created_at_utc,
      updated_at_utc
    ) VALUES (?, ?, 0, 0, ?, ?)
    ''',
    <Object?>[
      messageId,
      tagsJson,
      '2026-06-28T00:00:00.000Z',
      '2026-06-28T00:00:00.000Z',
    ],
  );
}
