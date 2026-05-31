import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/handles/application/settings_cassette_spec/resolver_tools/spam_management_provider.dart';

import '../../../../essentials/conversation_graph/conversation_graph_test_database.dart';

void main() {
  late ConversationGraphDatabase graphDb;
  late OverlayDatabase overlayDb;
  late ProviderContainer container;

  setUp(() async {
    graphDb = await openConversationGraphTestDatabase();
    overlayDb = OverlayDatabase(NativeDatabase.memory());
    await overlayDb.customSelect('SELECT 1').get();

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

  group('spamHandlesProvider', () {
    test('reads graph canonical handles with chat counts', () async {
      await _insertGraphHandle(graphDb, handleSsId: 7001, chatSsId: 6001);

      final handles = await container.read(spamHandlesProvider.future);

      expect(handles, hasLength(1));
      expect(handles.single.id, 7001);
      expect(handles.single.handleId, '+16043078325');
      expect(handles.single.isBlacklisted, isFalse);
      expect(handles.single.isVisible, isTrue);
      expect(handles.single.chatCount, 1);
    });

    test('applies overlay visibility over graph handle facts', () async {
      await _insertGraphHandle(graphDb, handleSsId: 7002, chatSsId: 6002);
      await overlayDb.setHandleVisibility(
        7002,
        isVisible: false,
        isBlacklisted: true,
      );

      final handles = await container.read(spamHandlesProvider.future);

      expect(handles.single.id, 7002);
      expect(handles.single.isBlacklisted, isTrue);
      expect(handles.single.isVisible, isFalse);
    });

    test('block and unblock write overlay-only visibility intent', () async {
      await _insertGraphHandle(graphDb, handleSsId: 7003, chatSsId: 6003);

      await container.read(spamManagementProvider.notifier).blockHandle(7003);
      final blocked = await overlayDb.getHandleVisibility(7003);

      expect(blocked?.isBlacklisted, isTrue);
      expect(blocked?.isVisible, isFalse);

      await container.read(spamManagementProvider.notifier).unblockHandle(7003);
      final unblocked = await overlayDb.getHandleVisibility(7003);

      expect(unblocked, isNull);
    });
  });
}

Future<void> _insertGraphHandle(
  ConversationGraphDatabase graphDb, {
  required int handleSsId,
  required int chatSsId,
}) async {
  await graphDb.database.insert('canonical_handles', <String, Object?>{
    'canonical_handle_ss_id': handleSsId,
    'display_handle': '+16043078325',
    'normalized_identifier': '16043078325',
    'service': 'SMS',
    'alias_count': 1,
  });
  await graphDb.database.insert('chats', <String, Object?>{
    'ss_id': chatSsId,
    'guid': 'chat-$chatSsId',
    'service': 'SMS',
    'is_group': 0,
  });
  await graphDb.database.insert('chat_to_handle', <String, Object?>{
    'chat_ss_id': chatSsId,
    'handle_ss_id': handleSsId,
  });
}
