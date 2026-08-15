import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/identity/live_chat_graph_identity.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity_resolver_provider.dart';
import 'package:remember_this_text/features/handles/application/read_models/stray_handle_summary.dart';
import 'package:remember_this_text/features/handles/application/read_models/stray_handles_provider.dart';
import 'package:remember_this_text/features/handles/application/source_review/handle_source_review_actions_provider.dart';
import 'package:remember_this_text/features/handles/domain/utilities/handle_normalizer.dart';

import '../../../essentials/conversation_graph/conversation_graph_test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HandleSourceReviewActions', () {
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
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(identitiesByHandleKey: {});
          }),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await overlayDb.close();
      await graphDb.close();
    });

    test('dismisses an active source without marking it reviewed', () async {
      final handleId = canonicalLiveChatGraphId(7101);
      const endpoint = '+16043078325';
      await _insertGraphHandleEvidence(
        graphDb,
        handleSsId: handleId,
        handleValue: endpoint,
        messageSsId: 8101,
      );
      expect(
        (await container.read(strayHandlesProvider.future)).single.handleId,
        handleId,
      );
      final activeTransitions = <AsyncValue<List<StrayHandleSummary>>>[];
      final activeSubscription = container.listen(
        unknownSourceIdentificationHandlesProvider,
        (_, next) => activeTransitions.add(next),
        fireImmediately: true,
      );
      addTearDown(activeSubscription.close);
      activeTransitions.clear();

      final failure = await container
          .read(handleSourceReviewActionsProvider.notifier)
          .dismissSource(handleId: handleId);

      expect(failure, isNull);
      expect(await container.read(strayHandlesProvider.future), isEmpty);
      expect(
        container.read(unknownSourceIdentificationHandlesProvider).requireValue,
        isEmpty,
      );
      expect(
        activeTransitions.where((transition) => transition.isLoading),
        isEmpty,
        reason:
            'A successful one-source dismissal must update the loaded active '
            'projection without replacing the sidebar list with loading.',
      );
      expect(
        (await container.read(dismissedHandlesProvider.future)).single.handleId,
        handleId,
      );
      expect(
        await overlayDb.getAllDismissedHandles(),
        contains(normalizeHandleIdentifier(endpoint)),
      );
      expect(await overlayDb.getHandleOverride(handleId), isNull);
    });

    test('associates a source with an existing graph Contact', () async {
      final handleId = canonicalLiveChatGraphId(7102);
      final participantId = canonicalLiveChatGraphId(9102);
      await _insertGraphHandleEvidence(
        graphDb,
        handleSsId: handleId,
        handleValue: '+17789908506',
        messageSsId: 8102,
      );
      await graphDb.database.insert('contacts', <String, Object?>{
        'contact_id': participantId,
        'display_name': 'Existing Contact',
      });

      final failure = await container
          .read(handleSourceReviewActionsProvider.notifier)
          .associateSourceWithExistingContact(
            handleId: handleId,
            participantId: participantId,
          );

      expect(failure, isNull);
      final override = await overlayDb.getHandleOverride(handleId);
      expect(override?.participantId, participantId);
      expect(override?.virtualParticipantId, isNull);
      expect(await container.read(strayHandlesProvider.future), isEmpty);
    });

    test('creates a Contact and associates the source with it', () async {
      final handleId = canonicalLiveChatGraphId(7103);
      await _insertGraphHandleEvidence(
        graphDb,
        handleSsId: handleId,
        handleValue: 'person@example.com',
        messageSsId: 8103,
      );

      final failure = await container
          .read(handleSourceReviewActionsProvider.notifier)
          .createContactAndAssociateSource(
            handleId: handleId,
            displayName: 'New Contact',
          );

      expect(failure, isNull);
      final virtualParticipants = await overlayDb.getVirtualParticipants();
      expect(virtualParticipants.single.displayName, 'New Contact');
      final override = await overlayDb.getHandleOverride(handleId);
      expect(override?.virtualParticipantId, virtualParticipants.single.id);
      expect(override?.participantId, isNull);
      expect(await container.read(strayHandlesProvider.future), isEmpty);
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
    'normalized_identifier': normalizeHandleIdentifier(handleValue),
    'service': 'SMS',
    'alias_count': 1,
  });
  await graphDb.database.insert('messages', <String, Object?>{
    'ss_id': messageSsId,
    'guid': 'source-review-message-$messageSsId',
    'sender_handle_ss_id': handleSsId,
    'sender_canonical_handle_ss_id': handleSsId,
    'is_from_me': 0,
    'date_utc': '2026-05-20T10:00:00.000Z',
    'text': 'Source review evidence',
  });
}
