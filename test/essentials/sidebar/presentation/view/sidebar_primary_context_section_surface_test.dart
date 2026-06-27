import 'package:flutter/material.dart' show Brightness;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/app_mode/feature_level_providers.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view/sidebar_primary_context_section_surface.dart';

void main() {
  group('SidebarPrimaryContextSectionSurface', () {
    testWidgets('uses a quiet borderless light-mode tint', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            platformBrightnessProvider.overrideWith((ref) => Brightness.light),
          ],
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: SidebarPrimaryContextSectionSurface(
              children: [Text('hero'), Text('Click the name…')],
            ),
          ),
        ),
      );

      final decoratedBox = tester.widget<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      final decoration = decoratedBox.decoration as BoxDecoration;

      expect(decoration.color, const Color(0x07000000));
      expect(decoration.border, isNull);
      expect(decoration.borderRadius, BorderRadius.circular(10));
    });

    testWidgets('uses a calm dark-mode tint without adding border chrome', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            platformBrightnessProvider.overrideWith((ref) => Brightness.dark),
          ],
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: SidebarPrimaryContextSectionSurface(
              children: [Text('hero'), Text('Click the name…')],
            ),
          ),
        ),
      );

      final decoratedBox = tester.widget<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      final decoration = decoratedBox.decoration as BoxDecoration;

      expect(decoration.color, const Color(0x10FFFFFF));
      expect(decoration.border, isNull);
      expect(decoration.borderRadius, BorderRadius.circular(10));
    });
  });
}
