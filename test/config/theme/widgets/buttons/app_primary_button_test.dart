import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/config/theme/colors/theme_colors.dart';
import 'package:remember_this_text/config/theme/widgets/buttons/app_primary_button.dart';

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
            child: AppPrimaryButton(
              onPressed: () {
                activationCount += 1;
              },
              child: const Text('Add Messages to MessageLens'),
            ),
          ),
        ),
      ),
    );

    final button = find.byType(AppPrimaryButton);
    final container = ProviderScope.containerOf(tester.element(button));
    final colors = container.read(themeColorsProvider.notifier);
    expect(_fillColor(tester), colors.buttons.primaryBackground);

    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await pointer.addPointer(location: Offset.zero);
    await pointer.moveTo(tester.getCenter(button));
    await tester.pumpAndSettle();
    expect(_fillColor(tester), colors.buttons.primaryBackgroundHovered);

    await pointer.down(tester.getCenter(button));
    await tester.pump(const Duration(milliseconds: 120));
    expect(_fillColor(tester), colors.buttons.primaryBackgroundPressed);
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
      0.98,
    );

    await pointer.up();
    await tester.pumpAndSettle();
    expect(activationCount, 1);
    expect(_fillColor(tester), colors.buttons.primaryBackgroundHovered);
  });

  testWidgets('disabled button stays visibly disabled and cannot activate', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: AppPrimaryButton(
              onPressed: null,
              child: Text('Unavailable'),
            ),
          ),
        ),
      ),
    );

    final button = find.byType(AppPrimaryButton);
    final container = ProviderScope.containerOf(tester.element(button));
    final colors = container.read(themeColorsProvider.notifier);
    expect(_fillColor(tester), colors.buttons.primaryBackgroundDisabled);

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(_fillColor(tester), colors.buttons.primaryBackgroundDisabled);
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
  });
}

Color _fillColor(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byType(AppPrimaryButton),
      matching: find.byType(AnimatedContainer),
    ),
  );
  final decoration = container.decoration! as BoxDecoration;
  return decoration.color!;
}
