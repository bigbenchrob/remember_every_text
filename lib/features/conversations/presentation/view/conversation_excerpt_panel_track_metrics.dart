import 'package:flutter/widgets.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../core/util/date_label_formatter.dart';
import '../widgets/conversation_signature_card.dart';

/// Presentation metrics for Conversation excerpt-panel track occupants.
///
/// These constants describe the natural outer size of excerpt panel
/// presentations. Page layout code may depend on these contracts, but should
/// not duplicate the numbers independently.
abstract final class ConversationExcerptPanelTrackMetrics {
  const ConversationExcerptPanelTrackMetrics._();

  /// Stable width shared by Conversation identity and temporal-orientation
  /// presentations in the end panel.
  static const double canonicalContentWidth =
      ConversationSignatureCardPresentationMetrics.canonicalWidth;
}

TextStyle conversationExcerptTemporalOrientationStyle(
  ThemeColors colors,
  ThemeTypography typography,
) {
  return typography.title3.copyWith(
    color: colors.status.warning.withValues(alpha: 0.84),
  );
}

String? conversationExcerptTemporalOrientationLabel(DateTime? anchorDate) {
  if (anchorDate == null) {
    return null;
  }
  return DateLabelFormatter.longMonthYear(anchorDate);
}

/// Track adapter for the month/year orientation of a Conversation excerpt.
final class ConversationExcerptTemporalOrientationTrackOccupant
    implements TrackOccupant {
  const ConversationExcerptTemporalOrientationTrackOccupant({
    required this.label,
    required this.style,
  });

  final String label;
  final TextStyle style;

  @override
  OccupantDimensionalClaim dimensionalClaim(
    PresentationConstraints constraints,
  ) {
    return TextTrackOccupant(
      text: label,
      style: style,
      maxLines: 1,
    ).dimensionalClaim(
      PresentationConstraints(
        availableWidth:
            ConversationExcerptPanelTrackMetrics.canonicalContentWidth,
        textScaler: constraints.textScaler,
        textDirection: constraints.textDirection,
        locale: constraints.locale,
      ),
    );
  }

  @override
  Widget buildPresentation(
    BuildContext context,
    ResolvedTrackAllocation allocation,
  ) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: ConversationExcerptPanelTrackMetrics.canonicalContentWidth,
        child: Text(
          label,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
