import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';

const messageHistoryCoverageTitleKey = Key(
  'message-history-coverage-page-title',
);

/// Canonical horizontal geometry for the Message History Coverage center
/// column. Track allocation remains exclusively vertical.
abstract final class MessageHistoryCoverageCenterColumnGeometry {
  const MessageHistoryCoverageCenterColumnGeometry._();

  static const horizontalInset = AppSpacing.xl;
  static const maximumReadableWidth = 720.0;

  static double readableWidth(double availableWidth) {
    return math.max(
      0,
      math.min(maximumReadableWidth, availableWidth - (horizontalInset * 2)),
    );
  }
}

/// Applies the center-column geometry shared by Track occupants and native
/// report content.
class MessageHistoryCoverageCenterColumn extends StatelessWidget {
  const MessageHistoryCoverageCenterColumn({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal:
              MessageHistoryCoverageCenterColumnGeometry.horizontalInset,
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: MessageHistoryCoverageCenterColumnGeometry
                  .maximumReadableWidth,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class MessageHistoryCoverageTitle extends StatelessWidget {
  const MessageHistoryCoverageTitle({required this.style, super.key});

  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return MessageHistoryCoverageCenterColumn(
      child: Semantics(
        header: true,
        child: Text(
          'Message History Coverage',
          key: messageHistoryCoverageTitleKey,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Settings-owned presentation occupants for Message History Coverage.
///
/// Navigation places these occupants. Settings owns their wording and natural
/// dimensional claims.
final class MessageHistoryCoverageTrackOccupants {
  const MessageHistoryCoverageTrackOccupants({required this.title});

  final TrackOccupant title;
}

MessageHistoryCoverageTrackOccupants messageHistoryCoverageTrackOccupants({
  required ThemeTypography typography,
}) {
  return MessageHistoryCoverageTrackOccupants(
    title: messageHistoryCoverageTitleTrackOccupant(style: typography.title1),
  );
}

TrackOccupant messageHistoryCoverageTitleTrackOccupant({
  required TextStyle style,
}) {
  return _MessageHistoryCoverageTitleTrackOccupant(style: style);
}

final class _MessageHistoryCoverageTitleTrackOccupant implements TrackOccupant {
  const _MessageHistoryCoverageTitleTrackOccupant({required this.style});

  final TextStyle style;

  @override
  OccupantDimensionalClaim dimensionalClaim(
    PresentationConstraints constraints,
  ) {
    final painter =
        TextPainter(
          text: TextSpan(text: 'Message History Coverage', style: style),
          maxLines: 1,
          ellipsis: '\u2026',
          textDirection: constraints.textDirection,
          textScaler: constraints.textScaler,
          locale: constraints.locale,
        )..layout(
          maxWidth: MessageHistoryCoverageCenterColumnGeometry.readableWidth(
            constraints.availableWidth,
          ),
        );
    return OccupantDimensionalClaim(
      naturalHeight: painter.height,
      preferredWidth: painter.width,
    );
  }

  @override
  Widget buildPresentation(
    BuildContext context,
    ResolvedTrackAllocation allocation,
  ) {
    return MessageHistoryCoverageTitle(style: style);
  }
}
