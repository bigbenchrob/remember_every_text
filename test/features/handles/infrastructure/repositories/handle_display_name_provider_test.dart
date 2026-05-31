import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/handles/infrastructure/repositories/handle_display_name_provider.dart';

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
    await graphDb.close();
    await overlayDb.close();
  });

  test('graph contact identity wins over raw handle label', () async {
    await graphDb.database.insert('contacts', <String, Object?>{
      'contact_id': 9001,
      'display_name': 'Claire Merriman Campbell',
    });
    await graphDb.database.insert('handles', <String, Object?>{
      'ss_id': 7001,
      'id': '+17789908506',
      'service': 'iMessage',
    });
    await graphDb.database.insert('contact_to_handle', <String, Object?>{
      'contact_id': 9001,
      'handle_ss_id': 7001,
      'handle_value': '+17789908506',
    });
    await overlayDb.setParticipantDisplayNameOverride(9001, 'Claire');

    final label = await container.read(
      handleDisplayNameProvider(handleId: 7001).future,
    );

    expect(label, 'Claire');
  });

  test(
    'falls back to graph handle display when no contact identity exists',
    () async {
      await graphDb.database.insert('handles', <String, Object?>{
        'ss_id': 7002,
        'id': '+16043078325',
        'service': 'SMS',
      });

      final label = await container.read(
        handleDisplayNameProvider(handleId: 7002).future,
      );

      expect(label, '+16043078325');
    },
  );
}
