import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/search/application/graph_message_search.dart';
import 'package:remember_this_text/essentials/search/infrastructure/repositories/graph_search_repository.dart';

import '../../../conversation_graph/conversation_graph_test_database.dart';

void main() {
  late ConversationGraphDatabase graphDatabase;
  late OverlayDatabase overlayDatabase;
  late SqliteGraphSearchRepository repository;

  setUp(() async {
    graphDatabase = await openConversationGraphTestDatabase();
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    await overlayDatabase.customSelect('SELECT 1').get();
    repository = SqliteGraphSearchRepository(
      graphDatabase: graphDatabase,
      overlayDatabase: overlayDatabase,
    );
  });

  tearDown(() async {
    await graphDatabase.close();
    await overlayDatabase.close();
  });

  test('searches graph message text and returns message_ss_id', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 1001,
      guid: 'guid-1001',
      text: 'The settlement offer is ready.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 1002,
      guid: 'guid-1002',
      text: 'Unrelated dinner plan.',
      dateUtc: '2026-05-02T12:00:00Z',
    );

    final results = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      query: 'settlement',
      matchAnyTerm: false,
      filterSaved: false,
    );

    expect(results, <int>[1001]);
  });

  test('conversation scope does not leak matches from other chats', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 2001,
      guid: 'guid-2001',
      text: 'Flower delivery confirmed.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await _insertMessage(
      graphDatabase,
      messageId: 2002,
      guid: 'guid-2002',
      text: 'Flower delivery confirmed.',
      dateUtc: '2026-05-02T12:00:00Z',
    );
    await _insertChatMessage(graphDatabase, chatId: 501, messageId: 2001);
    await _insertChatMessage(graphDatabase, chatId: 502, messageId: 2002);

    final results = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.conversation(501),
      query: 'flower',
      matchAnyTerm: false,
      filterSaved: false,
    );

    expect(results, <int>[2001]);
  });

  test('reads graph-native saved overlay by message_ss_id', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 3001,
      guid: 'guid-3001',
      text: 'Graph-native saved message.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await overlayDatabase.customStatement(
      '''
      INSERT INTO message_intent_overlays (
        message_ss_id,
        is_saved,
        created_at_utc,
        updated_at_utc
      ) VALUES (?, 1, ?, ?)
      ''',
      <Object?>[3001, _now, _now],
    );

    final results = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      query: '',
      matchAnyTerm: false,
      filterSaved: true,
    );

    expect(results, <int>[3001]);
  });

  test(
    'uses unique GUID-keyed saved overlay as compatibility bridge',
    () async {
      await _insertMessage(
        graphDatabase,
        messageId: 4001,
        guid: 'guid-4001',
        text: 'GUID-keyed saved message.',
        dateUtc: '2026-05-01T12:00:00Z',
      );
      await overlayDatabase.setMessageSaved(
        messageGuid: 'guid-4001',
        isSaved: true,
      );

      final results = await repository.searchMessageIds(
        scope: const GraphMessageSearchScope.global(),
        query: '',
        matchAnyTerm: false,
        filterSaved: true,
      );

      expect(results, <int>[4001]);
    },
  );

  test(
    'does not use GUID-keyed saved overlay when GUID is ambiguous',
    () async {
      await _insertMessage(
        graphDatabase,
        messageId: 5001,
        guid: 'shared-guid',
        text: 'First occurrence.',
        dateUtc: '2026-05-01T12:00:00Z',
      );
      await _insertMessage(
        graphDatabase,
        messageId: 5002,
        guid: 'shared-guid',
        text: 'Second occurrence.',
        dateUtc: '2026-05-02T12:00:00Z',
      );
      await overlayDatabase.setMessageSaved(
        messageGuid: 'shared-guid',
        isSaved: true,
      );

      final results = await repository.searchMessageIds(
        scope: const GraphMessageSearchScope.global(),
        query: '',
        matchAnyTerm: false,
        filterSaved: true,
      );

      expect(results, isEmpty);
    },
  );

  test('searches graph-native tags by message_ss_id', () async {
    await _insertMessage(
      graphDatabase,
      messageId: 6001,
      guid: 'guid-6001',
      text: 'Ordinary text.',
      dateUtc: '2026-05-01T12:00:00Z',
    );
    await overlayDatabase.customStatement(
      '''
      INSERT INTO message_intent_tags (
        message_ss_id,
        tag_display,
        tag_normalized,
        created_at_utc,
        updated_at_utc
      ) VALUES (?, ?, ?, ?, ?)
      ''',
      <Object?>[6001, 'Legal review', 'legal review', _now, _now],
    );

    final results = await repository.searchMessageIds(
      scope: const GraphMessageSearchScope.global(),
      query: 'legal',
      matchAnyTerm: false,
      filterSaved: false,
    );

    expect(results, <int>[6001]);
  });
}

const _now = '2026-05-30T12:00:00Z';

Future<void> _insertMessage(
  ConversationGraphDatabase graphDatabase, {
  required int messageId,
  required String guid,
  required String text,
  required String dateUtc,
}) {
  return graphDatabase.database.insert('messages', <String, Object?>{
    'ss_id': messageId,
    'guid': guid,
    'is_from_me': 0,
    'date_utc': dateUtc,
    'text': text,
  });
}

Future<void> _insertChatMessage(
  ConversationGraphDatabase graphDatabase, {
  required int chatId,
  required int messageId,
}) {
  return graphDatabase.database.insert('chat_to_message', <String, Object?>{
    'chat_ss_id': chatId,
    'message_ss_id': messageId,
  });
}
