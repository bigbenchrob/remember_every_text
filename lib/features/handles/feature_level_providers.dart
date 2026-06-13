import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/db/feature_level_providers.dart';
import '../contacts/feature_level_providers.dart';
import 'application/review/handle_review_controller.dart';
import 'application/review/handle_review_store.dart';
import 'application/settings_cassette_spec/resolver_tools/handle_visibility_store.dart';
import 'application/settings_cassette_spec/resolver_tools/manual_linking_read_repository.dart';
import 'application/settings_cassette_spec/resolver_tools/spam_handles_repository.dart';
import 'infrastructure/repositories/graph_manual_linking_read_repository.dart';
import 'infrastructure/repositories/graph_spam_handles_repository.dart';
import 'infrastructure/repositories/handle_display_name_provider.dart';
import 'infrastructure/repositories/overlay_handle_review_store.dart';
import 'infrastructure/repositories/overlay_handle_visibility_store.dart';
import 'infrastructure/repositories/stray_handles_provider.dart';

// =============================================================================
// HANDLES FEATURE — PUBLIC API
// =============================================================================
//
// This barrel file exports only the public API of the handles feature.
// External code should import ONLY this file.
//
// Exports:
// - Coordinators (application surface handlers)
// - State providers needed externally
//
// Does NOT export:
// - Resolvers
// - Widget builders
// - Infrastructure details
// =============================================================================

export './application/info_cassette_spec/coordinators/info_cassette_coordinator.dart';
export './application/review/handle_review_controller.dart';
export './application/review/handle_review_store.dart';
export './application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';
export './application/sidebar_cassette_spec/payloads/stray_handles_mode_switcher_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/stray_handles_review_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/stray_handles_type_switcher_cassette_payload.dart';
export './application/sidebar_cassette_spec/rendering/handles_cassette_body_builder.dart';
export './application/state/stray_handle_mode_provider.dart';
export './infrastructure/repositories/handle_display_name_provider.dart';
export './infrastructure/repositories/stray_handles_provider.dart';

part 'feature_level_providers.g.dart';

@riverpod
Future<HandleVisibilityStore> handleVisibilityStore(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayHandleVisibilityStore(overlayDatabase: overlayDatabase);
}

@riverpod
Future<HandleReviewStore> handleReviewStore(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayHandleReviewStore(overlayDatabase: overlayDatabase);
}

@riverpod
Future<ManualLinkingReadRepository> manualLinkingReadRepository(Ref ref) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final virtualContacts = await ref.watch(virtualParticipantsProvider.future);
  return GraphManualLinkingReadRepository(
    graphDb: graphDb,
    overlayDb: overlayDb,
    virtualContacts: virtualContacts,
  );
}

@riverpod
Future<SpamHandlesRepository> spamHandlesRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final visibilityStore = await ref.watch(handleVisibilityStoreProvider.future);

  return GraphSpamHandlesRepository(
    graphDatabase: graphDatabase,
    visibilityStore: visibilityStore,
  );
}

@riverpod
class HandleReviewActions extends _$HandleReviewActions {
  @override
  FutureOr<void> build() {}

  Future<void> markReviewed({required int handleId}) async {
    final store = await ref.watch(handleReviewStoreProvider.future);
    final controller = HandleReviewController(store: store);
    await controller.markReviewed(handleId: handleId);
    _invalidateHandleReviewReads(handleId: handleId);
  }

  Future<void> dismissUnfamiliarHandle(String normalizedHandle) async {
    final store = await ref.watch(handleReviewStoreProvider.future);
    await store.dismissHandle(normalizedHandle);
    _invalidateHandleReviewReads();
  }

  Future<void> restoreUnfamiliarHandle(String normalizedHandle) async {
    final store = await ref.watch(handleReviewStoreProvider.future);
    await store.restoreHandle(normalizedHandle);
    _invalidateHandleReviewReads();
  }

  void _invalidateHandleReviewReads({int? handleId}) {
    ref.invalidate(strayHandlesProvider);
    ref.invalidate(spamCandidateHandlesProvider);
    ref.invalidate(dismissedHandlesProvider);
    if (handleId != null) {
      ref.invalidate(handleDisplayNameProvider(handleId: handleId));
    }
  }
}
