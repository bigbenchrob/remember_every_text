import 'stray_handle_summary.dart';

abstract interface class StrayHandlesReadRepository {
  Future<List<StrayHandleSummary>> readActiveStrayHandles();

  Future<List<StrayHandleSummary>> readDismissedStrayHandles();

  /// Reads one canonical source directly, independent of investigation lists.
  Future<StrayHandleSummary?> readHandleSource({required int handleId});
}
