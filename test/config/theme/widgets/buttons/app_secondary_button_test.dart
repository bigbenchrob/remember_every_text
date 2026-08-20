import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/config/theme/colors/theme_colors.dart';
import 'package:remember_this_text/config/theme/widgets/buttons/app_secondary_button.dart';

void main() {
  testWidgets('exposes token-owned hover and pressed presentation', (
    tester,
  ) async {
    var activationCount = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: AppSecondaryButton(
              onPressed: () {
                activationCount += 1;
              },
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Text('Choose Messages Folder...'),
              ),
            ),
          ),
        ),
      ),
    );

    final button = find.byType(AppSecondaryButton);
    final container = ProviderScope.containerOf(tester.element(button));
    final colors = container.read(themeColorsProvider.notifier);
    expect(_fillColor(tester), colors.buttons.secondaryBackground);

    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await pointer.addPointer(location: Offset.zero);
    await pointer.moveTo(tester.getCenter(button));
    await tester.pumpAndSettle();
    expect(_fillColor(tester), colors.buttons.secondaryBackgroundHovered);

    await pointer.down(tester.getCenter(button));
    await tester.pump(const Duration(milliseconds: 120));
    expect(_fillColor(tester), colors.buttons.secondaryBackgroundPressed);
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
      0.98,
    );

    await pointer.up();
    await tester.pumpAndSettle();
    expect(activationCount, 1);
    expect(_fillColor(tester), colors.buttons.secondaryBackgroundHovered);
  });

  testWidgets('disabled button stays disabled and cannot activate', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: AppSecondaryButton(
              onPressed: null,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text('Unavailable'),
              ),
            ),
          ),
        ),
      ),
    );

    final button = find.byType(AppSecondaryButton);
    final container = ProviderScope.containerOf(tester.element(button));
    final colors = container.read(themeColorsProvider.notifier);
    expect(_fillColor(tester), colors.buttons.secondaryBackgroundDisabled);

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(_fillColor(tester), colors.buttons.secondaryBackgroundDisabled);
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
  });
}

Color _fillColor(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byType(AppSecondaryButton),
      matching: find.byType(AnimatedContainer),
    ),
  );
  final decoration = container.decoration! as BoxDecoration;
  return decoration.color!;
}
