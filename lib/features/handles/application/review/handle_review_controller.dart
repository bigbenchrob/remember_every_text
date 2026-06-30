import 'handle_review_store.dart';

/// Application-level handle review actions.
///
/// This keeps presentation code out of overlay persistence details while
/// preserving the existing "reviewed but unlinked" semantics.
class HandleReviewController {
  const HandleReviewController({required HandleReviewStore store})
    : _store = store;

  final HandleReviewStore _store;

  Future<void> markReviewed({required int handleId}) {
    return _store.markReviewed(handleId: handleId);
  }
}
