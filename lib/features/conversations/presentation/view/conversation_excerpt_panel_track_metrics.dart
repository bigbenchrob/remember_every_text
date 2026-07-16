import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';

/// Presentation metrics for Conversation excerpt-panel track occupants.
///
/// These constants describe the natural outer size of excerpt panel
/// presentations. Page layout code may depend on these contracts, but should
/// not duplicate the numbers independently.
abstract final class ConversationExcerptPanelTrackMetrics {
  const ConversationExcerptPanelTrackMetrics._();

  static const int excerptLabelMaxLines = 2;
  static const double excerptLabelLineHeight = 15;

  static const double excerptLabelHeight =
      excerptLabelLineHeight * excerptLabelMaxLines;
}

/// Declares the current Search-page D3 requirement for the Conversation
/// excerpt label.
///
/// The occupant remains semantically neutral to the track coordinator: it
/// contributes only a track id and natural height.
class ConversationExcerptLabelTrackOccupant extends FixedHeightTrackOccupant {
  const ConversationExcerptLabelTrackOccupant()
    : super(
        trackId: TrackId.trackD,
        height: ConversationExcerptPanelTrackMetrics.excerptLabelHeight,
      );
}
