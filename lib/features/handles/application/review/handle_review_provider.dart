import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import '../../infrastructure/repositories/overlay_handle_review_store.dart';
import '../read_models/handle_display_name_provider.dart';
import '../read_models/stray_handles_provider.dart'
    show
        dismissedNumericSenderIdHandlesProvider,
        dismissedUnknownSourceIdentificationHandlesProvider,
        dismissedHandlesProvider,
        numericSenderIdHandlesProvider,
        unknownSourceIdentificationHandlesProvider,
        strayHandlesProvider;
import 'handle_review_controller.dart';
import 'handle_review_store.dart';

part 'handle_review_provider.g.dart';

@riverpod
Future<HandleReviewStore> handleReviewStore(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return OverlayHandleReviewStore(overlayDatabase: overlayDatabase);
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
    ref
        .read(strayHandlesProvider.notifier)
        .removeDismissedSource(normalizedHandle);
    _invalidateDismissedHandleReads();
  }

  Future<void> restoreUnfamiliarHandle(String normalizedHandle) async {
    final store = await ref.watch(handleReviewStoreProvider.future);
    await store.restoreHandle(normalizedHandle);
    ref
        .read(dismissedHandlesProvider.notifier)
        .removeRestoredSource(normalizedHandle);
    _invalidateActiveHandleReads();
  }

  void _invalidateHandleReviewReads({int? handleId}) {
    _invalidateActiveHandleReads();
    _invalidateDismissedHandleReads();
    if (handleId != null) {
      ref.invalidate(handleDisplayNameProvider(handleId: handleId));
    }
  }

  void _invalidateActiveHandleReads() {
    ref.invalidate(strayHandlesProvider);
    ref.invalidate(unknownSourceIdentificationHandlesProvider);
    ref.invalidate(numericSenderIdHandlesProvider);
  }

  void _invalidateDismissedHandleReads() {
    ref.invalidate(dismissedHandlesProvider);
    ref.invalidate(dismissedUnknownSourceIdentificationHandlesProvider);
    ref.invalidate(dismissedNumericSenderIdHandlesProvider);
  }
}
