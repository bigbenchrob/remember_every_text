import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/features/messages/presentation/layout/unfamiliar_sources_message_track_occupants.dart';

void main() {
  testWidgets(
    'metrics claim includes the second run and run spacing at finite width',
    (tester) async {
      const occupant = HandleLensMetricsTrackOccupant(
        dateRangeLabel: 'May 12, 2018 to Jun 22, 2020',
        countLabel: '243 messages',
        style: TextStyle(fontSize: 14),
      );
      const wideConstraints = PresentationConstraints(
        availableWidth: 1000,
        textScaler: TextScaler.noScaling,
        textDirection: TextDirection.ltr,
      );
      const narrowConstraints = PresentationConstraints(
        availableWidth: 120,
        textScaler: TextScaler.noScaling,
        textDirection: TextDirection.ltr,
      );

      final wideClaim = occupant.dimensionalClaim(wideConstraints);
      final narrowClaim = occupant.dimensionalClaim(narrowConstraints);

      expect(
        narrowClaim.naturalHeight,
        closeTo((wideClaim.naturalHeight * 2) + 4, 0.001),
      );
      expect(narrowClaim.naturalHeight, greaterThan(wideClaim.naturalHeight));
      expect(narrowClaim.preferredWidth, wideClaim.preferredWidth);

      late Widget narrowPresentation;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              narrowPresentation = occupant.buildPresentation(
                context,
                const ResolvedTrackAllocation(
                  trackId: TrackId.trackD,
                  height: 40,
                  availableWidth: 120,
                ),
              );
              return narrowPresentation;
            },
          ),
        ),
      );
      expect(narrowPresentation, isA<Column>());

      late Widget widePresentation;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              widePresentation = occupant.buildPresentation(
                context,
                const ResolvedTrackAllocation(
                  trackId: TrackId.trackD,
                  height: 20,
                  availableWidth: 1000,
                ),
              );
              return widePresentation;
            },
          ),
        ),
      );
      expect(widePresentation, isA<Row>());
    },
  );
}
