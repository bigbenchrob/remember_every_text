import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/config/theme/widgets/layout/vertical_column_bands.dart';
import 'package:remember_this_text/features/conversations/presentation/view/conversation_excerpt_panel_track_metrics.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_evidence/message_evidence_header_track_metrics.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/top_chat_menu_widget.dart';

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

    testWidgets('resolves from TrackOccupant requirements only', (
      tester,
    ) async {
      const titleStyle = TextStyle(fontSize: 20, height: 1.15);
      const metadataStyle = TextStyle(fontSize: 14, height: 1.25);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              final requirementContext =
                  TrackRequirementContext.fromBuildContext(
                    context,
                    availableWidth: double.infinity,
                  );
              const titleOccupant = TextTrackOccupant(
                trackId: TrackId.trackA,
                text: 'All messages',
                style: titleStyle,
              );
              const metadataOccupant = TextTrackOccupant(
                trackId: TrackId.trackB,
                text: 'Jan 1, 2014 to Jul 14, 2026 135,053 messages',
                style: metadataStyle,
              );
              final plan = ResolvedTrackPlan.fromOccupants(
                occupants: [titleOccupant, metadataOccupant],
                context: requirementContext,
              );

              expect(
                plan.heightFor(TrackId.trackA, fallback: 1),
                titleOccupant.requirement(requirementContext).height,
              );
              expect(
                plan.heightFor(TrackId.trackB, fallback: 1),
                metadataOccupant.requirement(requirementContext).height,
              );

              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });

  group('TextTrackOccupant', () {
    testWidgets('calculates and builds from the same text presentation', (
      tester,
    ) async {
      const style = TextStyle(fontSize: 20, height: 1.15);
      const occupant = TextTrackOccupant(
        trackId: TrackId.trackA,
        text: 'Conversation',
        style: style,
      );

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: TrackOccupantView(occupant: occupant)),
        ),
      );

      expect(find.text('Conversation'), findsOneWidget);
      expect(tester.getSize(find.byType(TrackOccupantView)).height, 23);
      final context = tester.element(find.byType(TrackOccupantView));
      final requirementContext = TrackRequirementContext.fromBuildContext(
        context,
        availableWidth: double.infinity,
      );
      expect(occupant.requirement(requirementContext).height, 23);
    });
  });

  group('FixedHeightTrackOccupant', () {
    testWidgets('lets C2 declare fixed height as a normal track requirement', (
      tester,
    ) async {
      const occupant = FixedHeightTrackOccupant(
        trackId: TrackId.trackC,
        height: 8,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              final requirementContext =
                  TrackRequirementContext.fromBuildContext(
                    context,
                    availableWidth: double.infinity,
                  );
              expect(
                occupant.requirement(requirementContext),
                isA<TrackRequirement>()
                    .having(
                      (requirement) => requirement.trackId,
                      'trackId',
                      TrackId.trackC,
                    )
                    .having((requirement) => requirement.height, 'height', 8),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets(
      'message evidence search controls declare their presentation height',
      (tester) async {
        const occupant = MessageEvidenceSearchControlsTrackOccupant();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                final requirementContext =
                    TrackRequirementContext.fromBuildContext(
                      context,
                      availableWidth: double.infinity,
                    );
                expect(
                  occupant.requirement(requirementContext),
                  isA<TrackRequirement>()
                      .having(
                        (requirement) => requirement.trackId,
                        'trackId',
                        TrackId.trackC,
                      )
                      .having(
                        (requirement) => requirement.height,
                        'height',
                        MessageEvidenceHeaderTrackMetrics
                            .searchControlsRowHeight,
                      ),
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );

    testWidgets(
      'message evidence supporting context declares its own track height',
      (tester) async {
        const occupant = MessageEvidenceSupportingContextTrackOccupant();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                final requirementContext =
                    TrackRequirementContext.fromBuildContext(
                      context,
                      availableWidth: double.infinity,
                    );
                expect(
                  occupant.requirement(requirementContext),
                  isA<TrackRequirement>()
                      .having(
                        (requirement) => requirement.trackId,
                        'trackId',
                        TrackId.trackD,
                      )
                      .having(
                        (requirement) => requirement.height,
                        'height',
                        MessageEvidenceHeaderTrackMetrics
                            .supportingContextHeight,
                      ),
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );

    testWidgets('conversation excerpt label declares a D-track height', (
      tester,
    ) async {
      const occupant = ConversationExcerptLabelTrackOccupant();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              final requirementContext =
                  TrackRequirementContext.fromBuildContext(
                    context,
                    availableWidth: double.infinity,
                  );
              expect(
                occupant.requirement(requirementContext),
                isA<TrackRequirement>()
                    .having(
                      (requirement) => requirement.trackId,
                      'trackId',
                      TrackId.trackD,
                    )
                    .having(
                      (requirement) => requirement.height,
                      'height',
                      ConversationExcerptPanelTrackMetrics.excerptLabelHeight,
                    ),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets(
      'a fixed E occupant can contribute an ordinary 16 px allocation',
      (tester) async {
        const occupant = FixedHeightTrackOccupant(
          trackId: TrackId.trackE,
          height: 16,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                final requirementContext =
                    TrackRequirementContext.fromBuildContext(
                      context,
                      availableWidth: double.infinity,
                    );
                expect(
                  occupant.requirement(requirementContext),
                  isA<TrackRequirement>()
                      .having(
                        (requirement) => requirement.trackId,
                        'trackId',
                        TrackId.trackE,
                      )
                      .having(
                        (requirement) => requirement.height,
                        'height',
                        16,
                      ),
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  });

  group('TopChatMenuPresentationMetrics', () {
    testWidgets(
      'derives trigger height from the shared presentation contract',
      (tester) async {
        const style = TextStyle(fontSize: 14, height: 1.25);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                final requirementContext =
                    TrackRequirementContext.fromBuildContext(
                      context,
                      availableWidth: double.infinity,
                    );
                expect(
                  TopChatMenuPresentationMetrics.naturalTriggerHeight(
                    selectedValueStyle: style,
                    context: requirementContext,
                  ),
                  42,
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  });

  group('TrackCellColumnBand Track A', () {
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
                children: [
                  TrackCellColumnBand(
                    trackId: TrackId.trackA,
                    child: SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(TrackCellColumnBand)).height, 96);
    });

    testWidgets('Search page Track A has no hidden page top inset', (
      tester,
    ) async {
      const style = TextStyle(fontSize: 14, height: 1.25);
      late final double expectedHeight;

      await tester.pumpWidget(
        ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                final requirementContext =
                    TrackRequirementContext.fromBuildContext(
                      context,
                      availableWidth: double.infinity,
                    );
                expectedHeight =
                    TopChatMenuPresentationMetrics.naturalTriggerHeight(
                      selectedValueStyle: style,
                      context: requirementContext,
                    );
                final plan = ResolvedTrackPlan.resolve(
                  requirements: [
                    TrackRequirement(
                      trackId: TrackId.trackA,
                      height: expectedHeight,
                    ),
                  ],
                );
                return ResolvedTrackPlanScope(
                  plan: plan,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TrackCellColumnBand(
                        trackId: TrackId.trackA,
                        child: SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(TrackCellColumnBand)).height,
        expectedHeight,
      );
    });

    testWidgets('uses caller fallback height without a plan scope', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TrackCellColumnBand(
                  trackId: TrackId.trackA,
                  fallbackHeight: 72,
                  child: SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(TrackCellColumnBand)).height,
        72,
      );
    });
  });

  group('TrackCellColumnBand Track B', () {
    testWidgets('uses resolved Track B height when a plan scope is present', (
      tester,
    ) async {
      const metadataOccupant = TextTrackOccupant(
        trackId: TrackId.trackB,
        text: 'Jan 1, 2014 to Jul 14, 2026 135,053 messages',
        style: TextStyle(fontSize: 14, height: 1.25),
      );
      late final double expectedHeight;

      await tester.pumpWidget(
        ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                final requirementContext =
                    TrackRequirementContext.fromBuildContext(
                      context,
                      availableWidth: double.infinity,
                    );
                expectedHeight = metadataOccupant
                    .requirement(requirementContext)
                    .height;
                final plan = ResolvedTrackPlan.resolve(
                  requirements: [
                    TrackRequirement(
                      trackId: TrackId.trackB,
                      height: expectedHeight,
                    ),
                  ],
                );
                return ResolvedTrackPlanScope(
                  plan: plan,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TrackCellColumnBand(
                        trackId: TrackId.trackB,
                        child: SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(TrackCellColumnBand)).height,
        expectedHeight,
      );
    });

    testWidgets('uses caller fallback height without a plan scope', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TrackCellColumnBand(
                  trackId: TrackId.trackB,
                  fallbackHeight: 166,
                  child: SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(TrackCellColumnBand)).height,
        166,
      );
    });
  });

  group('TrackCellColumnBand', () {
    testWidgets('honors resolved Track C allocation for an empty cell', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                final requirementContext =
                    TrackRequirementContext.fromBuildContext(
                      context,
                      availableWidth: double.infinity,
                    );
                final plan = ResolvedTrackPlan.fromOccupants(
                  occupants: const [
                    FixedHeightTrackOccupant(
                      trackId: TrackId.trackC,
                      height: 8,
                    ),
                  ],
                  context: requirementContext,
                );
                return ResolvedTrackPlanScope(
                  plan: plan,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [TrackCellColumnBand(trackId: TrackId.trackC)],
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(TrackCellColumnBand)).height, 8);
    });

    testWidgets('can bottom-align content within a resolved track cell', (
      tester,
    ) async {
      const childKey = ValueKey<String>('track-cell-child');

      await tester.pumpWidget(
        ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                final requirementContext =
                    TrackRequirementContext.fromBuildContext(
                      context,
                      availableWidth: double.infinity,
                    );
                final plan = ResolvedTrackPlan.fromOccupants(
                  occupants: const [
                    FixedHeightTrackOccupant(
                      trackId: TrackId.trackC,
                      height: 52,
                    ),
                  ],
                  context: requirementContext,
                );
                return ResolvedTrackPlanScope(
                  plan: plan,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TrackCellColumnBand(
                        trackId: TrackId.trackC,
                        childPlacement: ColumnBandChildPlacement.bottomLeft(),
                        child: SizedBox(key: childKey, width: 20, height: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(TrackCellColumnBand)).height, 52);
      expect(tester.getTopLeft(find.byKey(childKey)).dy, 40);
    });
  });
}
