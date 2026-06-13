import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/contacts/domain/participant_origin.dart';
import 'package:remember_this_text/features/contacts/feature_level_providers.dart';

import '../../../essentials/conversation_graph/conversation_graph_test_database.dart';

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

  test('contact profile reads graph contact and applies override', () async {
    await graphDb.database.insert('contacts', <String, Object?>{
      'contact_id': 9001,
      'display_name': 'Claire Merriman Campbell',
      'given_name': 'Claire',
      'family_name': 'Campbell',
    });
    await overlayDb.setParticipantDisplayNameOverride(9001, 'Claire');

    final profile = await container.read(
      contactProfileProvider(contactId: 9001).future,
    );

    expect(profile?.contactId, 9001);
    expect(profile?.displayName, 'Claire');
    expect(profile?.origin, ParticipantOrigin.overlayOverride);
  });

  test('handles for contact reads graph contact handles first', () async {
    await graphDb.database.insert('contacts', <String, Object?>{
      'contact_id': 9001,
      'display_name': 'Claire',
    });
    await graphDb.database.insert('handles', <String, Object?>{
      'ss_id': 7001,
      'id': '+17789908506',
      'service': 'iMessage',
    });
    await graphDb.database.insert('canonical_handles', <String, Object?>{
      'canonical_handle_ss_id': 7001,
      'display_handle': '+1 (778) 990-8506',
      'normalized_identifier': '17789908506',
      'service': 'iMessage',
      'alias_count': 1,
    });
    await graphDb.database.insert('contact_to_handle', <String, Object?>{
      'contact_id': 9001,
      'handle_ss_id': 7001,
      'handle_value': '+17789908506',
    });

    final handles = await container.read(
      handlesForContactProvider(contactId: 9001).future,
    );

    expect(handles, hasLength(1));
    expect(handles.single.handleId, 7001);
    expect(handles.single.displayValue, '+1 (778) 990-8506');
    expect(handles.single.service, 'iMessage');
    expect(handles.single.isOverrideLink, isFalse);
  });

  test(
    'handles for contact resolves overlay links through graph handles',
    () async {
      final graphHandleId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 42,
      );
      await graphDb.database.insert('handles', <String, Object?>{
        'ss_id': graphHandleId,
        'id': '6049995969',
        'service': 'SMS',
      });
      await graphDb.database.insert('canonical_handles', <String, Object?>{
        'canonical_handle_ss_id': graphHandleId,
        'display_handle': '+1 (604) 999-5969',
        'normalized_identifier': '16049995969',
        'service': 'SMS',
        'alias_count': 1,
      });
      await overlayDb.setHandleOverride(42, 9001);

      final handles = await container.read(
        handlesForContactProvider(contactId: 9001).future,
      );

      expect(handles, hasLength(1));
      expect(handles.single.handleId, graphHandleId);
      expect(handles.single.displayValue, '+1 (604) 999-5969');
      expect(handles.single.service, 'SMS');
      expect(handles.single.isOverrideLink, isTrue);
    },
  );
}
