/// Persistence boundary for user review state on handles.
abstract interface class HandleReviewStore {
  Future<void> markReviewed({required int handleId});

  Future<void> dismissHandle(String normalizedHandle);

  Future<void> restoreHandle(String normalizedHandle);
}
