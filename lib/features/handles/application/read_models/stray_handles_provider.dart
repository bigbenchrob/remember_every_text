import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
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
@riverpod
Future<List<StrayHandleSummary>> strayHandles(Ref ref) async {
  final repository = await ref.watch(strayHandlesReadRepositoryProvider.future);
  return repository.readActiveStrayHandles();
}

/// Returns only stray handles that match junk-like heuristics.
@riverpod
Future<List<StrayHandleSummary>> spamCandidateHandles(Ref ref) async {
  final allStrays = await ref.watch(strayHandlesProvider.future);
  final candidates = allStrays.where((h) => h.junkScore >= 3).toList();
  candidates.sort((a, b) => b.junkScore.compareTo(a.junkScore));
  return candidates;
}

/// Returns only dismissed handles for the escape hatch view.
@riverpod
Future<List<StrayHandleSummary>> dismissedHandles(Ref ref) async {
  final repository = await ref.watch(strayHandlesReadRepositoryProvider.future);
  return repository.readDismissedStrayHandles();
}
