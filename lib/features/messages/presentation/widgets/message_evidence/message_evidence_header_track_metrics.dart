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

  static const double supportingContextHeight =
      supportingContextLineHeight + supportingContextBottomInset;
}

/// Declares the Search-page C2 requirement for the Message Evidence search
/// controls.
///
/// The occupant remains semantically neutral to the track coordinator: it
/// contributes only a track id and natural height.
class MessageEvidenceSearchControlsTrackOccupant
    extends FixedHeightTrackOccupant {
  const MessageEvidenceSearchControlsTrackOccupant()
    : super(
        trackId: TrackId.trackC,
        height: MessageEvidenceHeaderTrackMetrics.searchControlsRowHeight,
      );
}

/// Declares the Search-page D2 requirement for the Message Evidence supporting
/// context line.
class MessageEvidenceSupportingContextTrackOccupant
    extends FixedHeightTrackOccupant {
  const MessageEvidenceSupportingContextTrackOccupant()
    : super(
        trackId: TrackId.trackD,
        height: MessageEvidenceHeaderTrackMetrics.supportingContextHeight,
      );
}
