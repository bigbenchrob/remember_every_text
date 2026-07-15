import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/config/theme/widgets/layout/vertical_column_bands.dart';

void main() {
  group('ResolvedTrackPlan', () {
    test('resolves each track to the maximum declared height requirement', () {
      final plan = ResolvedTrackPlan.resolve(
        requirements: const <TrackRequirement>[
          TrackRequirement(trackId: TrackId.trackA, height: 72),
          TrackRequirement(trackId: TrackId.trackA, height: 96),
          TrackRequirement(trackId: TrackId.trackA, height: 84),
          TrackRequirement(trackId: TrackId.trackB, height: 0),
          TrackRequirement(trackId: TrackId.trackB, height: 34),
        ],
      );

      expect(plan.heightFor(TrackId.trackA, fallback: 1), 96);
      expect(plan.heightFor(TrackId.trackB, fallback: 1), 34);
    });

    test('uses fallback height when a track has no requirements', () {
      final plan = ResolvedTrackPlan.resolve(
        requirements: const <TrackRequirement>[],
      );

      expect(plan.heightFor(TrackId.trackA, fallback: 72), 72);
    });
  });

  group('TitleColumnBand', () {
    testWidgets('uses resolved Track A height when a plan scope is present', (
      tester,
    ) async {
      final plan = ResolvedTrackPlan.resolve(
        requirements: const <TrackRequirement>[
          TrackRequirement(trackId: TrackId.trackA, height: 96),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ResolvedTrackPlanScope(
              plan: plan,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [TitleColumnBand(child: SizedBox.shrink())],
              ),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(TitleColumnBand)).height, 96);
    });

    testWidgets('Search page Track A has no hidden page top inset', (
      tester,
    ) async {
      final plan = ResolvedTrackPlan.resolve(
        pageTopInset: SearchPageTrackRequirements.pageTopInset,
        requirements: const <TrackRequirement>[
          TrackRequirement(
            trackId: TrackId.trackA,
            height: SearchPageTrackRequirements.sidebarTopMenuTrigger,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ResolvedTrackPlanScope(
              plan: plan,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [TitleColumnBand(child: SizedBox.shrink())],
              ),
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(TitleColumnBand)).height,
        SearchPageTrackRequirements.sidebarTopMenuTrigger,
      );
    });

    testWidgets('keeps its default height without a plan scope', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [TitleColumnBand(child: SizedBox.shrink())],
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(TitleColumnBand)).height,
        TitleColumnBand.defaultHeight,
      );
    });
  });

  group('ContextColumnBand', () {
    testWidgets('uses resolved Track B height when a plan scope is present', (
      tester,
    ) async {
      final plan = ResolvedTrackPlan.resolve(
        requirements: const <TrackRequirement>[
          TrackRequirement(
            trackId: TrackId.trackB,
            height: SearchPageTrackRequirements.metadataLine,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ResolvedTrackPlanScope(
              plan: plan,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [ContextColumnBand(child: SizedBox.shrink())],
              ),
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(ContextColumnBand)).height,
        SearchPageTrackRequirements.metadataLine,
      );
    });

    testWidgets('keeps its default height without a plan scope', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [ContextColumnBand(child: SizedBox.shrink())],
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(ContextColumnBand)).height,
        ContextColumnBand.defaultHeight,
      );
    });
  });
}
