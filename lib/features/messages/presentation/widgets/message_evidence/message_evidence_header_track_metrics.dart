import '../../../../../config/theme/widgets/layout/cross_column_track_plan.dart';

/// Presentation metrics for Message Evidence header track occupants.
///
/// These constants describe the natural outer size of fixed-height header
/// presentations. Page layout code may depend on these contracts, but should
/// not duplicate the numbers independently.
abstract final class MessageEvidenceHeaderTrackMetrics {
  const MessageEvidenceHeaderTrackMetrics._();

  static const double searchControlsRowHeight = 30;
  static const double supportingContextLineHeight = 15;
  static const double supportingContextBottomInset = 8;

  static const double postMetadataSearchControlsHeight =
      supportingContextLineHeight +
      supportingContextBottomInset +
      searchControlsRowHeight;
}

/// Declares the Search-page C2 requirement for the post-metadata message
/// evidence controls.
///
/// The current presentation may include the supporting context line and the
/// search controls row. The occupant remains semantically neutral to the track
/// coordinator: it contributes only a track id and natural height.
class MessageEvidencePostMetadataControlsTrackOccupant
    extends FixedHeightTrackOccupant {
  const MessageEvidencePostMetadataControlsTrackOccupant()
    : super(
        trackId: TrackId.trackC,
        height:
            MessageEvidenceHeaderTrackMetrics.postMetadataSearchControlsHeight,
      );
}
