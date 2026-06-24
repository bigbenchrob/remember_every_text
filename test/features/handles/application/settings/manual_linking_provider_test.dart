import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/handles/application/settings_cassette_spec/resolver_tools/manual_linking_provider.dart';

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

  group('ManualLinkingProvider', () {
    test('lists graph unlinked handles', () async {
      await _insertGraphHandle(graphDb, handleSsId: 7001, chatSsId: 6001);

      final handles = await container.read(unlinkedHandlesProvider.future);

      expect(handles, hasLength(1));
      expect(handles.single.id, 7001);
      expect(handles.single.handleId, '+16043078325');
      expect(handles.single.chatCount, 1);
    });

    test('excludes graph handles already linked to a graph contact', () async {
      await _insertGraphHandle(graphDb, handleSsId: 7002, chatSsId: 6002);
      await graphDb.database.insert('contacts', <String, Object?>{
        'contact_id': 9001,
        'display_name': 'Claire',
      });
      await graphDb.database.insert('contact_to_handle', <String, Object?>{
        'contact_id': 9001,
        'handle_ss_id': 7002,
        'handle_value': '+17789908506',
      });

      final handles = await container.read(unlinkedHandlesProvider.future);

      expect(handles, isEmpty);
    });

    test(
      'graph handle visibility overrides rowid-keyed blacklist variant',
      () async {
        final graphHandleId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: 42,
        );
        await _insertGraphHandle(
          graphDb,
          handleSsId: graphHandleId,
          chatSsId: 6005,
        );
        await overlayDb.setHandleVisibility(
          42,
          isVisible: false,
          isBlacklisted: true,
        );
        await overlayDb.setHandleVisibility(
          graphHandleId,
          isVisible: true,
          isBlacklisted: false,
        );

        final handles = await container.read(unlinkedHandlesProvider.future);

        expect(handles, hasLength(1));
        expect(handles.single.id, graphHandleId);
      },
    );

    test(
      'available participants read graph contacts with user override',
      () async {
        await graphDb.database.insert('contacts', <String, Object?>{
          'contact_id': 9002,
          'display_name': 'Claire Merriman Campbell',
        });
        await overlayDb.setParticipantDisplayNameOverride(9002, 'Claire');

        final participants = await container.read(
          availableParticipantsProvider.future,
        );

        expect(participants, hasLength(1));
        expect(participants.single.id, 9002);
        expect(participants.single.displayName, 'Claire');
      },
    );

    test(
      'available participant handle count includes rowid-keyed overlay links',
      () async {
        const rowidKeyedContactId = 17;
        final graphContactId = SourceScopedRowKey.pack(
          sourceId: liveAddressBookSourceId,
          sourceRowId: rowidKeyedContactId,
        );
        await graphDb.database.insert('contacts', <String, Object?>{
          'contact_id': graphContactId,
          'display_name': 'Claire Merriman Campbell',
        });
        await overlayDb.setParticipantDisplayNameOverride(
          rowidKeyedContactId,
          'Claire',
        );
        await overlayDb.setHandleOverride(42, rowidKeyedContactId);

        final participants = await container.read(
          availableParticipantsProvider.future,
        );

        expect(participants, hasLength(1));
        expect(participants.single.id, graphContactId);
        expect(participants.single.displayName, 'Claire');
        expect(participants.single.handleCount, 1);
      },
    );

    test(
      'available participant handle count deduplicates rowid-keyed graph variants',
      () async {
        const rowidKeyedContactId = 17;
        final graphContactId = SourceScopedRowKey.pack(
          sourceId: liveAddressBookSourceId,
          sourceRowId: rowidKeyedContactId,
        );
        final graphHandleId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: 42,
        );
        await graphDb.database.insert('contacts', <String, Object?>{
          'contact_id': graphContactId,
          'display_name': 'Claire Merriman Campbell',
        });
        await overlayDb.setParticipantDisplayNameOverride(
          rowidKeyedContactId,
          'Claire',
        );
        await overlayDb.setHandleOverride(42, rowidKeyedContactId);
        await overlayDb.setHandleOverride(graphHandleId, rowidKeyedContactId);

        final participants = await container.read(
          availableParticipantsProvider.future,
        );

        expect(participants, hasLength(1));
        expect(participants.single.id, graphContactId);
        expect(participants.single.handleCount, 1);
      },
    );

    test('linking a graph handle writes overlay-only intent', () async {
      final graphHandleId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 7003,
      );
      await _insertGraphHandle(
        graphDb,
        handleSsId: graphHandleId,
        chatSsId: 6003,
      );
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: 9003,
      );
      await graphDb.database.insert('contacts', <String, Object?>{
        'contact_id': graphContactId,
        'display_name': 'Cathie Campbell',
      });

      await container
          .read(manualLinkingProvider.notifier)
          .linkHandleToParticipant(
            handleId: graphHandleId,
            participantId: graphContactId,
          );

      final override = await overlayDb.getHandleOverride(graphHandleId);

      expect(override?.participantId, graphContactId);
    });

    test(
      'creating a contact for a graph handle writes virtual overlay only',
      () async {
        final graphHandleId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: 7004,
        );
        await _insertGraphHandle(
          graphDb,
          handleSsId: graphHandleId,
          chatSsId: 6004,
        );

        await container
            .read(manualLinkingProvider.notifier)
            .createParticipantForHandle(
              handleId: graphHandleId,
              displayName: 'New Source',
            );

        final override = await overlayDb.getHandleOverride(graphHandleId);
        final virtualContacts = await overlayDb.getVirtualParticipants();

        expect(virtualContacts.single.displayName, 'New Source');
        expect(override?.virtualParticipantId, virtualContacts.single.id);
      },
    );
  });
}

Future<void> _insertGraphHandle(
  ConversationGraphDatabase graphDb, {
  required int handleSsId,
  required int chatSsId,
}) async {
  await graphDb.database.insert('handles', <String, Object?>{
    'ss_id': handleSsId,
    'id': '+16043078325',
    'service': 'SMS',
  });
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
