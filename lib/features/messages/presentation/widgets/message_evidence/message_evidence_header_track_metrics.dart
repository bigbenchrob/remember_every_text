import 'package:flutter/widgets.dart';

import '../../../../../config/theme/widgets/layout/cross_column_track_plan.dart';

/// Presentation metrics for Message Evidence header track occupants.
///
/// These constants describe the natural outer size of fixed-height header
/// presentations. Page layout code may depend on these contracts, but should
/// not duplicate the numbers independently.
abstract final class MessageEvidenceHeaderTrackMetrics {
  const MessageEvidenceHeaderTrackMetrics._();

  static const double searchControlsRowHeight = 30;
  static const double supportingContextBottomInset = 8;

  static double supportingContextMinimumNaturalHeight({
    required TextStyle style,
    required PresentationConstraints constraints,
  }) {
    final lineHeight = TextTrackOccupant(text: 'M', style: style)
        .dimensionalClaim(
          PresentationConstraints(
            availableWidth: constraints.availableWidth,
            textScaler: constraints.textScaler,
            textDirection: constraints.textDirection,
            locale: constraints.locale,
          ),
        )
        .naturalHeight;
    return lineHeight + supportingContextBottomInset;
  }
}
