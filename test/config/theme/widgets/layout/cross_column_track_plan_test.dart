import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/features/conversations/presentation/view/conversation_excerpt_panel_track_metrics.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_search_mode.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_evidence/message_evidence_header_track_metrics.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_evidence/message_evidence_track_occupants.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/top_chat_menu_widget.dart';

void main() {
  group('TextTrackOccupant', () {
    testWidgets('calculates and builds from the same text presentation', (
      tester,
    ) async {
      const style = TextStyle(fontSize: 20, height: 1.15);
      const occupant = TextTrackOccupant(text: 'Conversation', style: style);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              final constraints = PresentationConstraints.fromBuildContext(
                context,
                availableWidth: double.infinity,
              );
              final claim = occupant.dimensionalClaim(constraints);
              return Center(
                child: SizedBox(
                  width: 200,
                  height: claim.naturalHeight,
                  child: occupant.buildPresentation(
                    context,
                    ResolvedTrackAllocation(
                      trackId: TrackId.trackA,
                      height: claim.naturalHeight,
                      availableWidth: 200,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Conversation'), findsOneWidget);
      expect(tester.getSize(find.text('Conversation')).height, 23);
      final context = tester.element(find.text('Conversation'));
      final presentationConstraints = PresentationConstraints.fromBuildContext(
        context,
        availableWidth: double.infinity,
      );
      expect(
        occupant.dimensionalClaim(presentationConstraints).naturalHeight,
        23,
      );
    });
  });

  group('FixedHeightTrackOccupant', () {
    testWidgets('declares fixed dimensional truth without placement', (
      tester,
    ) async {
      const occupant = FixedHeightTrackOccupant(height: 8);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              final presentationConstraints =
                  PresentationConstraints.fromBuildContext(
                    context,
                    availableWidth: double.infinity,
                  );
              expect(
                occupant.dimensionalClaim(presentationConstraints),
                isA<OccupantDimensionalClaim>().having(
                  (claim) => claim.naturalHeight,
                  'naturalHeight',
                  8,
                ),
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
        final occupant = MessageEvidenceSearchControlsTrackOccupant(
          query: '',
          placeholder: 'Search',
          mode: MessageEvidenceSearchMode.allTerms,
          onQueryChanged: (_) {},
          onModeChanged: (_) {},
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                final presentationConstraints =
                    PresentationConstraints.fromBuildContext(
                      context,
                      availableWidth: double.infinity,
                    );
                expect(
                  occupant.dimensionalClaim(presentationConstraints),
                  isA<OccupantDimensionalClaim>().having(
                    (claim) => claim.naturalHeight,
                    'naturalHeight',
                    MessageEvidenceHeaderTrackMetrics.searchControlsRowHeight,
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
        const occupant = MessageEvidenceSupportingContextTrackOccupant(
          text: 'Message text contains "test"',
          style: TextStyle(fontSize: 15, height: 1),
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                final presentationConstraints =
                    PresentationConstraints.fromBuildContext(
                      context,
                      availableWidth: double.infinity,
                    );
                expect(
                  occupant.dimensionalClaim(presentationConstraints),
                  isA<OccupantDimensionalClaim>().having(
                    (claim) => claim.naturalHeight,
                    'naturalHeight',
                    15 +
                        MessageEvidenceHeaderTrackMetrics
                            .supportingContextBottomInset,
                  ),
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );

    testWidgets('conversation excerpt label uses its canonical render width', (
      tester,
    ) async {
      const occupant = ConversationExcerptLabelTrackOccupant(
        label: '21-message excerpt centered on the chosen message',
        style: TextStyle(fontSize: 15, height: 1),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              final presentationConstraints =
                  PresentationConstraints.fromBuildContext(
                    context,
                    availableWidth: double.infinity,
                  );
              expect(
                occupant.dimensionalClaim(presentationConstraints),
                isA<OccupantDimensionalClaim>().having(
                  (claim) => claim.naturalHeight,
                  'naturalHeight',
                  30,
                ),
              );
              return SizedBox(
                width: 500,
                height: 60,
                child: occupant.buildPresentation(
                  context,
                  const ResolvedTrackAllocation(
                    trackId: TrackId.trackD,
                    height: 30,
                    availableWidth: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(
        tester.getSize(
          find.text('21-message excerpt centered on the chosen message'),
        ),
        const Size(
          ConversationExcerptPanelTrackMetrics.canonicalContentWidth,
          30,
        ),
      );
    });

    testWidgets(
      'a fixed E occupant can contribute an ordinary 16 px allocation',
      (tester) async {
        const occupant = FixedHeightTrackOccupant(height: 16);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                final presentationConstraints =
                    PresentationConstraints.fromBuildContext(
                      context,
                      availableWidth: double.infinity,
                    );
                expect(
                  occupant.dimensionalClaim(presentationConstraints),
                  isA<OccupantDimensionalClaim>().having(
                    (claim) => claim.naturalHeight,
                    'naturalHeight',
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
                final presentationConstraints =
                    PresentationConstraints.fromBuildContext(
                      context,
                      availableWidth: double.infinity,
                    );
                expect(
                  TopChatMenuPresentationMetrics.naturalTriggerHeight(
                    selectedValueStyle: style,
                    constraints: presentationConstraints,
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
}
