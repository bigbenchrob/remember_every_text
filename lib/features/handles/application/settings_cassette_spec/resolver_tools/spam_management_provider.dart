import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'handle_visibility_store_provider.dart';
import 'spam_handles_repository.dart';
import 'spam_handles_repository_provider.dart';

export 'spam_handles_repository.dart';

part 'spam_management_provider.g.dart';

enum SpamFilterStatus { all, blacklisted, visible }

/// Provider for managing spam/blacklisted handles
@riverpod
Future<List<SpamHandleInfo>> spamHandles(Ref ref) async {
  final repository = await ref.watch(spamHandlesRepositoryProvider.future);
  return repository.readSpamHandles();
}

/// Provider for spam management operations
@riverpod
class SpamManagement extends _$SpamManagement {
  @override
  Future<void> build() async {
    // No initial state needed
  }

  /// Block a handle (mark as blacklisted)
  Future<void> blockHandle(int handleId) async {
    final visibilityStore = await ref.watch(
      handleVisibilityStoreProvider.future,
    );
    await visibilityStore.blockHandle(handleId);

    // Refresh the spam handles list
    ref.invalidate(spamHandlesProvider);
  }

  /// Unblock a handle (remove from blacklist)
  Future<void> unblockHandle(int handleId) async {
    final visibilityStore = await ref.watch(
      handleVisibilityStoreProvider.future,
    );
    await visibilityStore.unblockHandle(handleId);

    // Refresh the spam handles list
    ref.invalidate(spamHandlesProvider);
  }

  /// Get statistics about spam filtering
  Future<SpamStats> getSpamStats() async {
    final handles = await ref.watch(spamHandlesProvider.future);

    final totalHandles = handles.length;
    final blacklistedHandles = handles.where((h) => h.isBlacklisted).length;
    final visibleHandles = handles.where((h) => h.isVisible).length;

    return SpamStats(
      totalHandles: totalHandles,
      blacklistedHandles: blacklistedHandles,
      visibleHandles: visibleHandles,
    );
  }
}

class SpamStats {
  const SpamStats({
    required this.totalHandles,
    required this.blacklistedHandles,
    required this.visibleHandles,
  });

  final int totalHandles;
  final int blacklistedHandles;
  final int visibleHandles;

  double get blacklistPercentage =>
      totalHandles > 0 ? (blacklistedHandles / totalHandles) * 100 : 0.0;
}
