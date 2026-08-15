import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/config/theme/widgets/theme_widgets.dart';

void main() {
  testWidgets('does not open or select options when disabled', (tester) async {
    final selectedValues = <String>[];

    await tester.pumpWidget(
      ProviderScope(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: AppThemeWidgets.dropdownMenu<String>(
            options: const ['One', 'Two'],
            selectedOption: 'One',
            onSelected: selectedValues.add,
            optionLabelBuilder: (value) => value,
            isEnabled: false,
          ),
        ),
      ),
    );

    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsNothing);

    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();

    expect(find.text('Two'), findsNothing);
    expect(selectedValues, isEmpty);
  });

  testWidgets('anchored panel opens outside a constrained trigger cell', (
    tester,
  ) async {
    final selectedValues = <String>[];

    await tester.pumpWidget(
      ProviderScope(
        child: WidgetsApp(
          color: const Color(0xFFFFFFFF),
          pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) =>
                builder(context),
          ),
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 300,
              height: 44,
              child: AppThemeWidgets.dropdownMenu<String>(
                options: const ['One', 'Two'],
                selectedOption: 'One',
                onSelected: selectedValues.add,
                optionLabelBuilder: (value) => value,
                outerPadding: EdgeInsets.zero,
                panelPresentation: AppDropdownPanelPresentation.anchoredOverlay,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Two'), findsOneWidget);

    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();

    expect(selectedValues, const ['Two']);
    expect(find.text('Two'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
