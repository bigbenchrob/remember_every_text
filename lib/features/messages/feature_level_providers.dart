// =============================================================================
// PUBLIC API — Barrel exports
// =============================================================================

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/db/feature_level_providers.dart';
import '../contacts/feature_level_providers.dart';
import 'application/message_evidence/message_evidence_identity.dart';
import 'application/sidebar_cassette_spec/resolver_tools/conversation_signature_preferences_store.dart';
import 'application/user_metadata/message_overlay_controller.dart';
import 'application/user_metadata/message_overlay_repository.dart';
import 'domain/entities/message_overlay_state.dart';
import 'domain/message_evidence/recovered_message_evidence.dart';
import 'infrastructure/repositories/graph_message_overlay_repository.dart';
import 'infrastructure/repositories/graph_recovered_message_evidence_repository.dart';
import 'infrastructure/repositories/overlay_conversation_signature_preferences_store.dart';

export './application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';
export './application/sidebar_cassette_spec/coordinators/info_cassette_coordinator.dart';
export './application/sidebar_cassette_spec/payloads/conversation_signatures_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/messages_heatmap_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/recovered_no_handle_from_me_navigator_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/recovered_unlinked_navigator_cassette_payload.dart';
export './application/sidebar_cassette_spec/rendering/messages_cassette_body_builder.dart';
export './application/sidebar_cassette_spec/resolver_tools/contact_conversation_navigation_actions_provider.dart';
export './application/sidebar_cassette_spec/resolver_tools/conversation_navigation_actions_provider.dart';
export './application/sidebar_cassette_spec/resolver_tools/message_heatmap_navigation_actions_provider.dart';
export './application/sidebar_cassette_spec/resolver_tools/prewarm_contact_messages_provider.dart';
export './application/sidebar_cassette_spec/resolver_tools/recovered_message_navigation_actions_provider.dart';
export './application/user_metadata/message_overlay_controller.dart';
export './application/user_metadata/message_overlay_repository.dart';
export './application/view_spec/coordinators/view_spec_coordinator.dart';
export './application/view_spec/resolver_tools/recovered_messages_sidebar_provider.dart';
export './domain/message_evidence/message_evidence_scope.dart';

part 'feature_level_providers.g.dart';

@riverpod
Future<ConversationSignaturePreferencesStore>
conversationSignaturePreferencesStore(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayConversationSignaturePreferencesStore(
    overlayDatabase: overlayDatabase,
  );
}

@riverpod
Future<MessageOverlayRepository> messageOverlayRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return GraphMessageOverlayRepository(
    graphDatabase: graphDatabase,
    overlayDatabase: overlayDatabase,
  );
}

@riverpod
class MessageOverlay extends _$MessageOverlay {
  @override
  Future<MessageOverlayState> build(int messageSsId) async {
    return _load();
  }

  Future<void> setSaved({required bool isSaved}) async {
    final controller = await _controller();
    await controller.setSaved(isSaved: isSaved);
    await _refresh();
  }

  Future<void> toggleSaved() async {
    final controller = await _controller();
    await controller.toggleSaved();
    await _refresh();
  }

  Future<void> setStarred({required bool isStarred}) async {
    final controller = await _controller();
    await controller.setStarred(isStarred: isStarred);
    await _refresh();
  }

  Future<void> setArchived({required bool isArchived}) async {
    final controller = await _controller();
    await controller.setArchived(isArchived: isArchived);
    await _refresh();
  }

  Future<void> addTags(Iterable<String> tags) async {
    final controller = await _controller();
    await controller.addTags(tags);
    await _refresh();
  }

  Future<void> removeTag(String tag) async {
    final controller = await _controller();
    await controller.removeTag(tag);
    await _refresh();
  }

  Future<MessageOverlayState> _load() async {
    final controller = await _controller();
    return controller.read();
  }

  Future<void> _refresh() async {
    state = const AsyncLoading<MessageOverlayState>().copyWithPrevious(state);
    state = AsyncData(await _load());
  }

  Future<MessageOverlayController> _controller() async {
    final repository = await ref.watch(messageOverlayRepositoryProvider.future);
    return MessageOverlayController(
      repository: repository,
      messageSsId: canonicalMessageEvidenceId(messageSsId),
    );
  }
}

@riverpod
Future<RecoveredMessageEvidenceRepository> recoveredMessageEvidenceRepository(
  Ref ref,
) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final displayIdentityResolver = await ref.watch(
    displayIdentityResolverProvider.future,
  );
  return GraphRecoveredMessageEvidenceRepository(
    graphDb: graphDb,
    displayIdentityResolver: displayIdentityResolver,
  );
}

@riverpod
Stream<List<RecoveredUnlinkedMessageItem>> recoveredUnlinkedMessages(
  Ref ref, {
  int? contactId,
}) async* {
  final readiness = await ref.watch(conversationGraphReadinessProvider.future);
  if (!readiness.isReady) {
    yield const <RecoveredUnlinkedMessageItem>[];
    return;
  }

  final scopedHandleIds = contactId == null
      ? null
      : (await ref.watch(
          handlesForContactProvider(contactId: contactId).future,
        )).map((handle) => handle.handleId).toSet();
  final repository = await ref.watch(
    recoveredMessageEvidenceRepositoryProvider.future,
  );
  yield* repository.watchMessages(
    contactId: contactId,
    scopedHandleIds: scopedHandleIds,
  );
}
