import 'dart:math' as math;

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
  static const double searchLeadingSlotWidth = 15;
  static const double searchLeadingGap = 8;

  /// Aligns status ink with the visible leading edge of macOS text-field chrome.
  static const double searchStatusFieldChromeInset = 6;
  static const double investigationStatusIndicatorRadius = 6;

  static double investigationStatusMinimumNaturalHeight({
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
    return math.max(lineHeight, investigationStatusIndicatorRadius * 2);
  }
}
