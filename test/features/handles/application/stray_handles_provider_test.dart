import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/handles/domain/utilities/handle_normalizer.dart'
    as handle_normalizer;
import 'package:remember_this_text/features/handles/feature_level_providers.dart';

import '../../../essentials/conversation_graph/conversation_graph_test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('strayHandlesProvider', () {
    late ConversationGraphDatabase graphDb;
    late OverlayDatabase overlayDb;
    late ProviderContainer container;

    setUp(() async {
      graphDb = await openConversationGraphTestDatabase();
      overlayDb = OverlayDatabase(NativeDatabase.memory());

      container = ProviderContainer(
        overrides: [
          driftConversationGraphDatabaseProvider.overrideWith(
            (ref) async => graphDb,
          ),
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await overlayDb.close();
      await graphDb.close();
    });

    test(
      'returns graph-native stray handles when graph evidence exists',
      () async {
        await _insertGraphHandleEvidence(
          graphDb,
          handleSsId: 7001,
          handleValue: '+16043078325',
          messageSsId: 8001,
        );

        final results = await container.read(strayHandlesProvider.future);

        expect(results, hasLength(1));
        expect(results.single.handleId, 7001);
        expect(results.single.handleValue, '+16043078325');
        expect(results.single.totalMessages, 1);
      },
    );

    test('excludes graph handles linked to a graph contact', () async {
      await _insertGraphHandleEvidence(
        graphDb,
        handleSsId: 7002,
        handleValue: '+17789908506',
        messageSsId: 8002,
      );
      await graphDb.database.insert('contacts', <String, Object?>{
        'contact_id': 9001,
        'display_name': 'Claire',
      });
      await graphDb.database.insert('contact_to_handle', <String, Object?>{
        'contact_id': 9001,
        'handle_ss_id': 7002,
        'handle_value': '+17789908506',
      });

      final results = await container.read(strayHandlesProvider.future);

      expect(results, isEmpty);
    });

    test('routes dismissed graph handles to dismissed escape hatch', () async {
      await _insertGraphHandleEvidence(
        graphDb,
        handleSsId: 7003,
        handleValue: '+16048173537',
        messageSsId: 8003,
      );
      await overlayDb.dismissHandle(
        handle_normalizer.normalizeHandleIdentifier('+16048173537'),
      );

      final activeResults = await container.read(strayHandlesProvider.future);
      final dismissedResults = await container.read(
        dismissedHandlesProvider.future,
      );

      expect(activeResults, isEmpty);
      expect(dismissedResults, hasLength(1));
      expect(dismissedResults.single.handleId, 7003);
      expect(dismissedResults.single.handleValue, '+16048173537');
    });
  });
}

Future<void> _insertGraphHandleEvidence(
  ConversationGraphDatabase graphDb, {
  required int handleSsId,
  required String handleValue,
  required int messageSsId,
}) async {
  await graphDb.database.insert('handles', <String, Object?>{
    'ss_id': handleSsId,
    'id': handleValue,
    'service': 'SMS',
  });
  await graphDb.database.insert('canonical_handles', <String, Object?>{
    'canonical_handle_ss_id': handleSsId,
    'display_handle': handleValue,
    'normalized_identifier': handle_normalizer.normalizeHandleIdentifier(
      handleValue,
    ),
    'service': 'SMS',
    'alias_count': 1,
  });
  await graphDb.database.insert('messages', <String, Object?>{
    'ss_id': messageSsId,
    'guid': 'graph-message-$messageSsId',
    'sender_handle_ss_id': handleSsId,
    'sender_canonical_handle_ss_id': handleSsId,
    'is_from_me': 0,
    'date_utc': '2026-05-20T10:00:00.000Z',
    'text': 'Graph sender evidence',
  });
}
