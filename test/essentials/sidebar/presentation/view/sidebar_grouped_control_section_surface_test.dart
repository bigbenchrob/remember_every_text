import 'package:flutter/material.dart' show Brightness;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/presentation/view/sidebar_grouped_control_section_surface.dart';
import 'package:remember_this_text/providers.dart';

void main() {
  group('SidebarGroupedControlSectionSurface', () {
    testWidgets('uses a perceptible but borderless light-mode tint', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            platformBrightnessProvider.overrideWith((ref) => Brightness.light),
          ],
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: SidebarGroupedControlSectionSurface(
              children: [Text('scope'), Text('filter')],
            ),
          ),
        ),
      );

      final decoratedBox = tester.widget<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      final decoration = decoratedBox.decoration as BoxDecoration;

      expect(decoration.color, const Color(0x0A000000));
      expect(decoration.border, isNull);
      expect(decoration.borderRadius, BorderRadius.circular(10));
    });

    testWidgets('uses a stronger but still calm dark-mode tint', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            platformBrightnessProvider.overrideWith((ref) => Brightness.dark),
          ],
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: SidebarGroupedControlSectionSurface(
              children: [Text('scope'), Text('filter')],
            ),
          ),
        ),
      );

      final decoratedBox = tester.widget<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      final decoration = decoratedBox.decoration as BoxDecoration;

      expect(decoration.color, const Color(0x14FFFFFF));
      expect(decoration.border, isNull);
      expect(decoration.borderRadius, BorderRadius.circular(10));
    });

    testWidgets('uses the reusable grouped-controls layout contract', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SidebarGroupedControlSectionSurface(
              children: [Text('scope'), Text('filter')],
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(
        padding.padding,
        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(column.mainAxisSize, MainAxisSize.min);
    });
  });
}
