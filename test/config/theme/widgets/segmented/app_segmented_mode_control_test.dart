import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
}
