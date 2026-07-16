import 'package:flutter/widgets.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../widgets/conversation_signature_card.dart';

/// Presentation metrics for Conversation excerpt-panel track occupants.
///
/// These constants describe the natural outer size of excerpt panel
/// presentations. Page layout code may depend on these contracts, but should
/// not duplicate the numbers independently.
abstract final class ConversationExcerptPanelTrackMetrics {
  const ConversationExcerptPanelTrackMetrics._();

  static const int excerptLabelMaxLines = 2;

  /// Stable width shared by Conversation identity and excerpt-label
  /// presentations in the end panel.
  static const double canonicalContentWidth =
      ConversationSignatureCardPresentationMetrics.canonicalWidth;

  static double excerptLabelMinimumNaturalHeight({
    required TextStyle style,
    required PresentationConstraints constraints,
  }) {
    return TextTrackOccupant(text: 'M', style: style)
        .dimensionalClaim(
          PresentationConstraints(
            availableWidth: canonicalContentWidth,
            textScaler: constraints.textScaler,
            textDirection: constraints.textDirection,
            locale: constraints.locale,
          ),
        )
        .naturalHeight;
  }
}

TextStyle conversationExcerptLabelStyle(
  ThemeColors colors,
  ThemeTypography typography,
) {
  return typography.caption.copyWith(
    color: colors.content.textSecondary.withValues(alpha: 0.78),
    fontWeight: FontWeight.w500,
  );
}

String conversationExcerptLabel(int count) {
  if (count <= 1) {
    return 'Excerpt centered on the chosen message';
  }
  return '$count-message excerpt centered on the chosen message';
}

/// Track adapter for the approved Conversation excerpt description.
final class ConversationExcerptLabelTrackOccupant implements TrackOccupant {
  const ConversationExcerptLabelTrackOccupant({
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
      maxLines: ConversationExcerptPanelTrackMetrics.excerptLabelMaxLines,
      softWrap: true,
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
          maxLines: ConversationExcerptPanelTrackMetrics.excerptLabelMaxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
