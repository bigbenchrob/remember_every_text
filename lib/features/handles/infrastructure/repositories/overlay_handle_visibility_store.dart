import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/settings_cassette_spec/resolver_tools/handle_visibility_store.dart';

class OverlayHandleVisibilityStore implements HandleVisibilityStore {
  const OverlayHandleVisibilityStore({required OverlayDatabase overlayDatabase})
    : _overlayDatabase = overlayDatabase;

  final OverlayDatabase _overlayDatabase;

  @override
  Future<List<HandleVisibilityIntent>> readAll() async {
    final rows = await _overlayDatabase.getAllHandleVisibilities();
    return [
      for (final row in rows)
        HandleVisibilityIntent(
          handleId: row.handleId,
          isVisible: row.isVisible,
          isBlacklisted: row.isBlacklisted,
        ),
    ];
  }

  @override
  Future<void> blockHandle(int handleId) {
    return _overlayDatabase.setHandleVisibility(
      handleId,
      isVisible: false,
      isBlacklisted: true,
    );
  }

  @override
  Future<void> unblockHandle(int handleId) {
    return _overlayDatabase.deleteHandleVisibility(handleId);
  }
}
