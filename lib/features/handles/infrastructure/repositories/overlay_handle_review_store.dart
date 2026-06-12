import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/review/handle_review_store.dart';

class OverlayHandleReviewStore implements HandleReviewStore {
  const OverlayHandleReviewStore({required OverlayDatabase overlayDatabase})
    : _overlayDatabase = overlayDatabase;

  final OverlayDatabase _overlayDatabase;

  @override
  Future<void> markReviewed({required int handleId}) {
    return _overlayDatabase.setHandleReviewed(handleId);
  }

  @override
  Future<void> dismissHandle(String normalizedHandle) {
    return _overlayDatabase.dismissHandle(normalizedHandle);
  }

  @override
  Future<void> restoreHandle(String normalizedHandle) {
    return _overlayDatabase.restoreHandle(normalizedHandle);
  }
}
