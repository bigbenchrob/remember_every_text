import 'package:flutter/widgets.dart';

import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../config/theme/widgets/segmented/app_segmented_mode_control.dart';
import '../../../../essentials/navigation/presentation/view/workspace_layout.dart';
import '../../application/sidebar_cassette_spec/payloads/historical_archives_settings_cassette_payload.dart';

const historicalArchivesSidebarHorizontalInset = AppSpacing.md;
const historicalArchivesSidebarTopInset = AppSpacing.md;
const historicalArchivesSidebarBottomInset = AppSpacing.md;
const historicalArchivesBodyToSourceTypeGap = AppSpacing.sm + AppSpacing.xs;
const historicalArchivesSourceToKnownFoldersGap =
    AppSpacing.xxl + AppSpacing.sm;
const historicalArchivesKnownFoldersHeadingToListGap = AppSpacing.sm;

const _segmentedControlOuterPadding = EdgeInsets.all(3);
const _segmentedControlSegmentPadding = EdgeInsets.symmetric(
  horizontal: 8,
  vertical: 5,
);

final class HistoricalArchivesSidebarTrackOccupants {
  const HistoricalArchivesSidebarTrackOccupants({
    required this.umbrella,
    required this.sourceTypeControl,
    required this.knownFoldersHeading,
  });

  final TrackOccupant umbrella;
  final TrackOccupant sourceTypeControl;
  final TrackOccupant knownFoldersHeading;
}

HistoricalArchivesSidebarTrackOccupants
buildHistoricalArchivesSidebarTrackOccupants({
  required ThemeTypography typography,
}) {
  return HistoricalArchivesSidebarTrackOccupants(
    umbrella: _HistoricalArchivesUmbrellaTrackOccupant(
      text: historicalArchivesSidebarDescription,
      style: typography.infoCardBody,
    ),
    sourceTypeControl: _HistoricalArchivesSourceTypeTrackOccupant(
      style: typography.caption.copyWith(fontWeight: FontWeight.w700),
    ),
    knownFoldersHeading: _HistoricalArchivesKnownFoldersHeadingTrackOccupant(
      style: typography.controlValue,
    ),
  );
}

final class _HistoricalArchivesUmbrellaTrackOccupant implements TrackOccupant {
  const _HistoricalArchivesUmbrellaTrackOccupant({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  OccupantDimensionalClaim dimensionalClaim(
    PresentationConstraints constraints,
  ) {
    final painter = _textPainter(
      text: text,
      style: style,
      constraints: constraints,
      maxWidth:
          WorkspaceLayout.navigationColumnWidth -
          (historicalArchivesSidebarHorizontalInset * 2),
    );
    return OccupantDimensionalClaim(
      naturalHeight:
          historicalArchivesSidebarTopInset +
          painter.height +
          historicalArchivesBodyToSourceTypeGap,
      preferredWidth: painter.width,
    );
  }

  @override
  Widget buildPresentation(
    BuildContext context,
    ResolvedTrackAllocation allocation,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        historicalArchivesSidebarHorizontalInset,
        historicalArchivesSidebarTopInset,
        historicalArchivesSidebarHorizontalInset,
        historicalArchivesBodyToSourceTypeGap,
      ),
      child: Text(text, style: style),
    );
  }
}

final class _HistoricalArchivesSourceTypeTrackOccupant
    implements TrackOccupant {
  const _HistoricalArchivesSourceTypeTrackOccupant({required this.style});

  final TextStyle style;

  @override
  OccupantDimensionalClaim dimensionalClaim(
    PresentationConstraints constraints,
  ) {
    final painter = _textPainter(
      text: 'Mac Messages',
      style: style,
      constraints: constraints,
      maxWidth: double.infinity,
      maxLines: 1,
    );
    return OccupantDimensionalClaim(
      naturalHeight:
          painter.height +
          (_segmentedControlOuterPadding.vertical) +
          (_segmentedControlSegmentPadding.vertical),
    );
  }

  @override
  Widget buildPresentation(
    BuildContext context,
    ResolvedTrackAllocation allocation,
  ) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: historicalArchivesSidebarHorizontalInset,
      ),
      child: HistoricalArchivesSourceTypeControl(),
    );
  }
}

final class _HistoricalArchivesKnownFoldersHeadingTrackOccupant
    implements TrackOccupant {
  const _HistoricalArchivesKnownFoldersHeadingTrackOccupant({
    required this.style,
  });

  final TextStyle style;

  @override
  OccupantDimensionalClaim dimensionalClaim(
    PresentationConstraints constraints,
  ) {
    final painter = _textPainter(
      text: 'Folders Already Added',
      style: style,
      constraints: constraints,
      maxWidth:
          WorkspaceLayout.navigationColumnWidth -
          (historicalArchivesSidebarHorizontalInset * 2),
      maxLines: 1,
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: historicalArchivesSidebarHorizontalInset,
      ),
      child: HistoricalArchivesKnownFoldersHeading(style: style),
    );
  }
}

TextPainter _textPainter({
  required String text,
  required TextStyle style,
  required PresentationConstraints constraints,
  required double maxWidth,
  int? maxLines,
}) {
  return TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: maxLines,
    textDirection: constraints.textDirection,
    textScaler: constraints.textScaler,
    locale: constraints.locale,
  )..layout(maxWidth: maxWidth);
}

class HistoricalArchivesSourceTypeControl extends StatelessWidget {
  const HistoricalArchivesSourceTypeControl({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSegmentedModeControl<HistoricalArchiveSourceType>(
      key: const ValueKey<String>('historical-archives-source-type-control'),
      options: HistoricalArchiveSourceType.values,
      selectedOption: HistoricalArchiveSourceType.messagesFolders,
      isOptionEnabled: (sourceType) =>
          sourceType == HistoricalArchiveSourceType.messagesFolders,
      onSelected: (_) {},
      labelBuilder: (sourceType) {
        return switch (sourceType) {
          HistoricalArchiveSourceType.messagesFolders => 'Mac Messages',
          HistoricalArchiveSourceType.messageLensDataFolders => 'MessageLens',
        };
      },
      padding: _segmentedControlOuterPadding,
      segmentPadding: _segmentedControlSegmentPadding,
    );
  }
}

class HistoricalArchivesKnownFoldersHeading extends StatelessWidget {
  const HistoricalArchivesKnownFoldersHeading({required this.style, super.key});

  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text('Folders Already Added', style: style);
  }
}

enum HistoricalArchiveSourceType { messagesFolders, messageLensDataFolders }
