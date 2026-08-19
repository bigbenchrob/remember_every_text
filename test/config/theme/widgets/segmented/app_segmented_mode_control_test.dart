import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/config/theme/colors/theme_colors.dart';
import 'package:remember_this_text/config/theme/widgets/theme_widgets.dart';

enum _Mode { first, second }

void main() {
  testWidgets('renders options and reports selected mode', (tester) async {
    final selectedValues = <_Mode>[];

    await tester.pumpWidget(
      ProviderScope(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: AppSegmentedModeControl<_Mode>(
            options: _Mode.values,
            selectedOption: _Mode.first,
            onSelected: selectedValues.add,
            labelBuilder: (mode) {
              return switch (mode) {
                _Mode.first => 'First',
                _Mode.second => 'Second',
              };
            },
          ),
        ),
      ),
    );

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);

    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();

    expect(selectedValues, [_Mode.second]);
  });

  testWidgets('disabled options are visible but cannot report selection', (
    tester,
  ) async {
    final selectedValues = <_Mode>[];

    await tester.pumpWidget(
      ProviderScope(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: AppSegmentedModeControl<_Mode>(
            options: _Mode.values,
            selectedOption: _Mode.first,
            onSelected: selectedValues.add,
            isOptionEnabled: (mode) => mode == _Mode.first,
            labelBuilder: (mode) {
              return switch (mode) {
                _Mode.first => 'First',
                _Mode.second => 'Second',
              };
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();

    expect(selectedValues, isEmpty);
    final disabledStyle = tester
        .widget<AnimatedDefaultTextStyle>(
          find.ancestor(
            of: find.text('Second'),
            matching: find.byType(AnimatedDefaultTextStyle),
          ),
        )
        .style;
    final container = ProviderScope.containerOf(
      tester.element(find.text('Second')),
    );
    final colors = container.read(themeColorsProvider.notifier);
    expect(disabledStyle.color, colors.content.textDisabled);
    final disabledSemantics = tester.widget<Semantics>(
      find.ancestor(of: find.text('Second'), matching: find.byType(Semantics)),
    );
    expect(disabledSemantics.properties.enabled, isFalse);
  });
}
