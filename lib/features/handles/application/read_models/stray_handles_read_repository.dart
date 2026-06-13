import 'stray_handle_summary.dart';

abstract interface class StrayHandlesReadRepository {
  Future<List<StrayHandleSummary>> readActiveStrayHandles();

  Future<List<StrayHandleSummary>> readDismissedStrayHandles();
}
