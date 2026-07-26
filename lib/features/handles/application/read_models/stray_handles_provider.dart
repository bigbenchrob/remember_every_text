import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart'
    show
        driftConversationGraphDatabaseProvider,
        messageDataVersionProvider,
        overlayDatabaseProvider;
import '../../domain/entities/stray_handle_endpoint_kind.dart';
import '../../domain/utilities/handle_normalizer.dart';
import '../../infrastructure/repositories/graph_stray_handles_read_repository.dart';
import 'stray_handle_summary.dart';
import 'stray_handles_read_repository.dart';

part 'stray_handles_provider.g.dart';

@riverpod
Future<StrayHandlesReadRepository> strayHandlesReadRepository(Ref ref) async {
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return GraphStrayHandlesReadRepository(
    graphDb: graphDb,
    overlayDb: overlayDb,
  );
}

/// Returns all handles that are truly "stray": no graph contact link and no
/// linked override (participant or virtual participant) in the overlay DB.
///
/// Handles with an overlay row that has only `reviewed_at` set (both
/// participant IDs null) are still included — they are reviewed but unlinked.
///
/// Excludes dismissed handles; those are only visible in the Dismissed escape
/// hatch view via [dismissedHandlesProvider].
@Riverpod(keepAlive: true)
class StrayHandles extends _$StrayHandles {
  @override
  Future<List<StrayHandleSummary>> build() async {
    ref.watch(messageDataVersionProvider);
    final repository = await ref.watch(
      strayHandlesReadRepositoryProvider.future,
    );
    return repository.readActiveStrayHandles();
  }

  /// Applies a completed overlay dismissal to the loaded active projection.
  ///
  /// The database-wide source aggregation remains the restart authority. This
  /// targeted cache update prevents a completed one-row disposition change
  /// from replacing the visible list with a loading state.
  void removeDismissedSource(String normalizedHandle) {
    final handles = state.valueOrNull;
    if (handles == null) {
      return;
    }
    state = AsyncData(
      handles
          .where(
            (handle) =>
                normalizeHandleIdentifier(handle.handleValue) !=
                normalizedHandle,
          )
          .toList(growable: false),
    );
  }
}

/// Returns active unresolved endpoints compatible with identity discovery.
@riverpod
AsyncValue<List<StrayHandleSummary>> unknownSourceIdentificationHandles(
  Ref ref,
) {
  return ref
      .watch(strayHandlesProvider)
      .whenData(
        (allStrays) => allStrays
            .where((handle) {
              return handle.endpointKind != StrayHandleEndpointKind.shortCode;
            })
            .toList(growable: false),
      );
}

/// Returns active unresolved endpoints with the structural shape of a short
/// code. This is not a spam or automation verdict.
@riverpod
AsyncValue<List<StrayHandleSummary>> numericSenderIdHandles(Ref ref) {
  return ref
      .watch(strayHandlesProvider)
      .whenData(
        (allStrays) => allStrays
            .where((handle) {
              return handle.endpointKind == StrayHandleEndpointKind.shortCode;
            })
            .toList(growable: false),
      );
}

/// Returns only dismissed handles for the escape hatch view.
@Riverpod(keepAlive: true)
class DismissedHandles extends _$DismissedHandles {
  @override
  Future<List<StrayHandleSummary>> build() async {
    ref.watch(messageDataVersionProvider);
    final repository = await ref.watch(
      strayHandlesReadRepositoryProvider.future,
    );
    return repository.readDismissedStrayHandles();
  }

  /// Applies a completed overlay restoration to the loaded recovery projection.
  void removeRestoredSource(String normalizedHandle) {
    final handles = state.valueOrNull;
    if (handles == null) {
      return;
    }
    state = AsyncData(
      handles
          .where(
            (handle) =>
                normalizeHandleIdentifier(handle.handleValue) !=
                normalizedHandle,
          )
          .toList(growable: false),
    );
  }
}

/// Returns dismissed endpoints compatible with identity discovery.
@riverpod
AsyncValue<List<StrayHandleSummary>>
dismissedUnknownSourceIdentificationHandles(Ref ref) {
  return ref
      .watch(dismissedHandlesProvider)
      .whenData(
        (dismissed) => dismissed
            .where((handle) {
              return handle.endpointKind != StrayHandleEndpointKind.shortCode;
            })
            .toList(growable: false),
      );
}

/// Returns dismissed endpoints with the structural shape of a short code.
@riverpod
AsyncValue<List<StrayHandleSummary>> dismissedNumericSenderIdHandles(Ref ref) {
  return ref
      .watch(dismissedHandlesProvider)
      .whenData(
        (dismissed) => dismissed
            .where((handle) {
              return handle.endpointKind == StrayHandleEndpointKind.shortCode;
            })
            .toList(growable: false),
      );
}
