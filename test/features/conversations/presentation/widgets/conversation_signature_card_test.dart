import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_signatures/conversation_signature.dart';
import 'package:remember_this_text/features/conversations/presentation/widgets/conversation_signature_card.dart';
import 'package:remember_this_text/features/conversations/presentation/widgets/conversation_signature_card_track_occupant.dart';

void main() {
  testWidgets('renders supplied data and slot without provider dependencies', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 260,
          child: ConversationSignatureCard(
            signature: const ConversationSignatureCardData(
              conversationId: 42,
              title: 'Claire and Cathie',
              titleContextLabel: 'Jun 2, 8:23 AM',
              summaryHighlight:
                  ConversationSignatureSummaryHighlight.messageCount,
              highlightedMonth: ConversationSignatureMonthMarker(
                year: 2026,
                month: 5,
              ),
              participantCount: 2,
              messageCount: 12,
              firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
              activityMonths: [
                ConversationSignatureMonth(
                  year: 2026,
                  month: 5,
                  messageCount: 12,
                ),
              ],
            ),
            style: _testStyle,
            monthColorForMessageCount: (_) => const Color(0xFF00AA00),
            trailing: const Text('action'),
            onPressed: () {
              tapCount++;
            },
          ),
        ),
      ),
    );

    expect(find.textContaining('Claire and Cathie'), findsOneWidget);
    expect(find.textContaining('+2'), findsOneWidget);
    expect(find.text('Jun 2, 8:23 AM'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('conversation-signature-highlighted-month-2026-5'),
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        '12 messages • 2026-05-01 - 2026-05-20',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('action'), findsOneWidget);

    await tester.tap(find.byType(AnimatedContainer));
    expect(tapCount, 1);
  });

  testWidgets('uses singular message label for one message', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 260,
          child: ConversationSignatureCard(
            signature: const ConversationSignatureCardData(
              conversationId: 42,
              title: 'Claire',
              participantCount: 1,
              messageCount: 1,
              firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-01T10:00:00.000Z',
              activityMonths: [],
            ),
            style: _testStyle,
            monthColorForMessageCount: (_) => const Color(0xFF00AA00),
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(
      find.textContaining('1 message • 2026-05-01', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('1 messages', findRichText: true), findsNothing);
  });

  testWidgets('renders supplied tag labels without provider dependencies', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 260,
          child: ConversationSignatureCard(
            signature: const ConversationSignatureCardData(
              conversationId: 42,
              title: 'Claire',
              participantCount: 1,
              messageCount: 10,
              firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-02T10:00:00.000Z',
              activityMonths: [],
              tagLabels: ['Family', 'Travel'],
            ),
            style: _testStyle,
            monthColorForMessageCount: (_) => const Color(0xFF00AA00),
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Family'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);
  });

  testWidgets('renders supplied chat hook as secondary identity line', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 260,
          child: ConversationSignatureCard(
            signature: const ConversationSignatureCardData(
              conversationId: 42,
              title: 'Claire',
              chatHookLabel: 'claire@student.ubco.ca',
              participantCount: 1,
              messageCount: 10,
              firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-02T10:00:00.000Z',
              activityMonths: [],
            ),
            style: _testStyle,
            monthColorForMessageCount: (_) => const Color(0xFF00AA00),
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Claire'), findsOneWidget);
    expect(find.text('claire@student.ubco.ca'), findsOneWidget);
  });

  testWidgets(
    'calculates one-row glyph requirement from presentation metrics',
    (tester) async {
      final months = _recentMonths(1);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              expect(
                ConversationSignatureCardPresentationMetrics.glyphNaturalHeight(
                  months: months,
                  availableWidth: 260,
                ),
                ConversationSignatureCardPresentationMetrics.glyphDotSize,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    },
  );

  testWidgets('calculates multi-row glyph requirement from finite width', (
    tester,
  ) async {
    final months = _recentMonths(36);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            final wideHeight =
                ConversationSignatureCardPresentationMetrics.glyphNaturalHeight(
                  months: months,
                  availableWidth: 260,
                );
            final narrowHeight =
                ConversationSignatureCardPresentationMetrics.glyphNaturalHeight(
                  months: months,
                  availableWidth: 72,
                );

            expect(narrowHeight, greaterThan(wideHeight));
            expect(
              narrowHeight,
              greaterThan(
                ConversationSignatureCardPresentationMetrics.glyphDotSize,
              ),
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('card occupant requirement increases with glyph height', (
    tester,
  ) async {
    final oneRowSignature = _signature(activityMonths: _recentMonths(1));
    final multiRowSignature = _signature(activityMonths: _recentMonths(36));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            final constraints = PresentationConstraints.fromBuildContext(
              context,
              availableWidth: 120,
            );
            final oneRowClaim = ConversationSignatureCardTrackOccupant(
              signature: oneRowSignature,
              style: _testStyle,
              includeFavouriteButton: false,
            ).dimensionalClaim(constraints);
            final multiRowClaim = ConversationSignatureCardTrackOccupant(
              signature: multiRowSignature,
              style: _testStyle,
              includeFavouriteButton: false,
            ).dimensionalClaim(constraints);

            expect(
              multiRowClaim.naturalHeight,
              greaterThan(oneRowClaim.naturalHeight),
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('card occupant requirement uses canonical card width', (
    tester,
  ) async {
    final signature = _signature(activityMonths: _recentMonths(36));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            final narrowClaim =
                ConversationSignatureCardTrackOccupant(
                  signature: signature,
                  style: _testStyle,
                  includeFavouriteButton: false,
                ).dimensionalClaim(
                  PresentationConstraints.fromBuildContext(
                    context,
                    availableWidth: 120,
                  ),
                );
            final wideClaim =
                ConversationSignatureCardTrackOccupant(
                  signature: signature,
                  style: _testStyle,
                  includeFavouriteButton: false,
                ).dimensionalClaim(
                  PresentationConstraints.fromBuildContext(
                    context,
                    availableWidth: 600,
                  ),
                );

            expect(wideClaim.naturalHeight, narrowClaim.naturalHeight);
            expect(
              wideClaim.preferredWidth,
              ConversationSignatureCardPresentationMetrics.canonicalWidth,
            );
            expect(
              wideClaim.minimumWidth,
              ConversationSignatureCardPresentationMetrics.canonicalWidth,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('rendered card height matches calculated natural requirement', (
    tester,
  ) async {
    const width = ConversationSignatureCardPresentationMetrics.canonicalWidth;
    final signature = _signature(activityMonths: _recentMonths(18));
    late final double calculatedHeight;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            final constraints = PresentationConstraints.fromBuildContext(
              context,
              availableWidth: width,
            );
            calculatedHeight =
                ConversationSignatureCardPresentationMetrics.naturalHeight(
                  signature: signature,
                  style: _testStyle,
                  constraints: constraints,
                );
            return UnconstrainedBox(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: ConversationSignatureCard(
                  signature: signature,
                  style: _testStyle,
                  monthColorForMessageCount: (_) => const Color(0xFF00AA00),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(AnimatedContainer)).height,
      closeTo(calculatedHeight, 0.001),
    );
  });

  testWidgets('rendered card uses canonical width in wider containers', (
    tester,
  ) async {
    final signature = _signature(activityMonths: _recentMonths(12));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 520,
            child: ConversationSignatureCard(
              signature: signature,
              style: _testStyle,
              monthColorForMessageCount: (_) => const Color(0xFF00AA00),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(AnimatedContainer)).width,
      ConversationSignatureCardPresentationMetrics.canonicalWidth,
    );
  });

  testWidgets('defaults canonical card placement to the leading edge', (
    tester,
  ) async {
    final signature = _signature(activityMonths: _recentMonths(12));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 520,
            child: ConversationSignatureCard(
              signature: signature,
              style: _testStyle,
              monthColorForMessageCount: (_) => const Color(0xFF00AA00),
            ),
          ),
        ),
      ),
    );

    expect(tester.getTopLeft(find.byType(AnimatedContainer)).dx, 0);
  });

  testWidgets('can center canonical card placement without changing width', (
    tester,
  ) async {
    final signature = _signature(activityMonths: _recentMonths(12));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 520,
            child: ConversationSignatureCard(
              signature: signature,
              style: _testStyle,
              monthColorForMessageCount: (_) => const Color(0xFF00AA00),
              horizontalPlacement: Alignment.center,
            ),
          ),
        ),
      ),
    );

    final cardSize = tester.getSize(find.byType(AnimatedContainer));
    expect(
      cardSize.width,
      ConversationSignatureCardPresentationMetrics.canonicalWidth,
    );
    expect(
      tester.getTopLeft(find.byType(AnimatedContainer)).dx,
      closeTo(
        (520 - ConversationSignatureCardPresentationMetrics.canonicalWidth) / 2,
        0.001,
      ),
    );
  });

  testWidgets('finite width changes glyph row count', (tester) async {
    final months = _recentMonths(24);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            final wideColumns =
                ConversationSignatureCardPresentationMetrics.glyphColumnsForWidth(
                  260,
                );
            final narrowColumns =
                ConversationSignatureCardPresentationMetrics.glyphColumnsForWidth(
                  72,
                );
            final wideRows =
                ConversationSignatureCardPresentationMetrics.chunkMonthsFromNewest(
                  ConversationSignatureCardPresentationMetrics.anchorMonthsToNow(
                    months,
                  ),
                  columns: wideColumns,
                ).length;
            final narrowRows =
                ConversationSignatureCardPresentationMetrics.chunkMonthsFromNewest(
                  ConversationSignatureCardPresentationMetrics.anchorMonthsToNow(
                    months,
                  ),
                  columns: narrowColumns,
                ).length;

            expect(narrowColumns, lessThan(wideColumns));
            expect(narrowRows, greaterThan(wideRows));
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });
}

ConversationSignatureCardData _signature({
  required List<ConversationSignatureMonth> activityMonths,
}) {
  return ConversationSignatureCardData(
    conversationId: 42,
    title: 'Claire',
    participantCount: 1,
    messageCount: 10,
    firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
    lastMessageAtUtc: '2026-05-02T10:00:00.000Z',
    activityMonths: activityMonths,
  );
}

List<ConversationSignatureMonth> _recentMonths(int count) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month - count + 1);
  return [
    for (var index = 0; index < count; index++)
      ConversationSignatureMonth(
        year: DateTime(start.year, start.month + index).year,
        month: DateTime(start.year, start.month + index).month,
        messageCount: index + 1,
      ),
  ];
}

const _testStyle = ConversationSignatureCardStyle(
  backgroundColor: Color(0x00000000),
  hoverBackgroundColor: Color(0x11000000),
  selectedBackgroundColor: Color(0x22000000),
  borderColor: Color(0x33000000),
  hoverBorderColor: Color(0x44000000),
  selectedBorderColor: Color(0x55000000),
  titleStyle: TextStyle(color: Color(0xFF111111), fontSize: 13),
  selectedTitleStyle: TextStyle(color: Color(0xFF111111), fontSize: 13),
  titleContextStyle: TextStyle(color: Color(0xFFCC6600), fontSize: 10),
  chatHookStyle: TextStyle(color: Color(0xFF777777), fontSize: 10),
  participantSuffixStyle: TextStyle(color: Color(0xFF777777), fontSize: 10),
  summaryStyle: TextStyle(color: Color(0xFF555555), fontSize: 11),
  summaryHighlightStyle: TextStyle(color: Color(0xFFCC6600), fontSize: 11),
  tagTextStyle: TextStyle(color: Color(0xFF666666), fontSize: 10),
  tagBackgroundColor: Color(0x11000000),
  tagBorderColor: Color(0x22000000),
  emptyMonthBorderColor: Color(0xFF999999),
);
