import '../../../../essentials/conversation_graph/application/identity/retained_overlay_identity_bridge.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/settings_cassette_spec/resolver_tools/handle_visibility_store.dart';

class OverlayHandleVisibilityStore implements HandleVisibilityStore {
  const OverlayHandleVisibilityStore({required OverlayDatabase overlayDatabase})
    : _overlayDatabase = overlayDatabase;

  final OverlayDatabase _overlayDatabase;

  @override
  Future<List<HandleVisibilityIntent>> readAll() async {
    final rows = await _overlayDatabase.getAllHandleVisibilities();
    final intentsByCanonicalHandleId = <int, HandleVisibilityIntent>{};
    for (final row in rows) {
      final canonicalHandleId = canonicalHandleOverlayKey(row.handleId);
      final existing = intentsByCanonicalHandleId[canonicalHandleId];
      final rowUsesCanonicalKey = row.handleId == canonicalHandleId;
      if (existing != null && !rowUsesCanonicalKey) {
        continue;
      }
      intentsByCanonicalHandleId[canonicalHandleId] = HandleVisibilityIntent(
        handleId: canonicalHandleId,
        isVisible: row.isVisible,
        isBlacklisted: row.isBlacklisted,
      );
    }
    return intentsByCanonicalHandleId.values.toList(growable: false);
  }

  @override
  Future<void> blockHandle(int handleId) async {
    final canonicalHandleId = canonicalHandleOverlayKey(handleId);
    await _deleteHandleVisibilityVariants(handleId);
    await _overlayDatabase.setHandleVisibility(
      canonicalHandleId,
      isVisible: false,
      isBlacklisted: true,
    );
  }

  @override
  Future<void> unblockHandle(int handleId) async {
    await _deleteHandleVisibilityVariants(handleId);
  }

  Future<void> _deleteHandleVisibilityVariants(int handleId) async {
    for (final candidateId in handleOverlayKeyVariants(handleId)) {
      await _overlayDatabase.deleteHandleVisibility(candidateId);
    }
  }
}
