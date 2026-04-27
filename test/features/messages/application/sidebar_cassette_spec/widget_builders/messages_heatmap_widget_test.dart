import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/config/theme/spacing/app_spacing.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_cassette_sectioning.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/widget_builders/messages_heatmap_widget.dart';
import 'package:remember_this_text/features/messages/domain/calendar_heatmap_timeline_data.dart';

void main() {
  group('MessageHeatmapContent', () {
    testWidgets(
      'uses the shared visualization rhythm for summary and legend spacing',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: MessageHeatmapContent(
                data: _sampleTimelineData(),
                selectedMonthKey: null,
                onMonthTap: (_, __, ___) {},
              ),
            ),
          ),
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is SizedBox &&
                widget.width == null &&
                widget.height == sidebarCassetteVisualizationContentSpacing,
          ),
          findsNWidgets(2),
        );
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is SizedBox &&
                widget.width == null &&
                widget.height == AppSpacing.cassetteContentGap,
          ),
          findsNothing,
        );
      },
    );
  });
}

CalendarHeatmapTimelineData _sampleTimelineData() {
  return CalendarHeatmapTimelineData(
    yearRows: [
      YearRow(
        year: 2024,
        months: List<MonthData>.generate(12, (index) {
          final month = index + 1;
          if (month == 1) {
            return MonthData(
              year: 2024,
              month: month,
              messageCount: 15,
              intensity: MonthIntensity.mediumGray,
              chatId: 7,
            );
          }

          return MonthData(
            year: 2024,
            month: month,
            messageCount: 0,
            intensity: MonthIntensity.empty,
            chatId: 7,
          );
        }),
        hasMessages: true,
      ),
    ],
    firstMessageDate: DateTime(2024, 1, 1),
    lastMessageDate: DateTime(2024, 12, 1),
    totalMessages: 15,
    maxMonthCount: 15,
  );
}
