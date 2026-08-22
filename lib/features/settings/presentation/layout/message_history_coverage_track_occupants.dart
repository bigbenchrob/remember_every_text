import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';

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
    title: TextTrackOccupant(
      text: 'Message History Coverage',
      style: typography.title1,
    ),
  );
}
