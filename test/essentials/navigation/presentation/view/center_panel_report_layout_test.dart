import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/navigation/presentation/view/center_panel_report_layout.dart';

void main() {
  group('PanelSection', () {
    test('fullWidth with one child is valid', () {
      final section = PanelSection<String>(
        layoutStyle: PanelSectionLayoutStyle.fullWidth,
        children: const ['hero'],
      );

      expect(section.children, ['hero']);
    });

    test('fullWidth with two children is invalid', () {
      expect(
        () => PanelSection<String>(
          layoutStyle: PanelSectionLayoutStyle.fullWidth,
          children: const ['left', 'right'],
        ),
        throwsArgumentError,
      );
    });

    test('twoColumn with two children is valid', () {
      final section = PanelSection<String>(
        layoutStyle: PanelSectionLayoutStyle.twoColumn,
        children: const ['left', 'right'],
      );

      expect(section.children, ['left', 'right']);
    });

    test('twoColumn with one child is invalid', () {
      expect(
        () => PanelSection<String>(
          layoutStyle: PanelSectionLayoutStyle.twoColumn,
          children: const ['left'],
        ),
        throwsArgumentError,
      );
    });

    test('twoColumnEqualHeight with two children is valid', () {
      final section = PanelSection<String>(
        layoutStyle: PanelSectionLayoutStyle.twoColumnEqualHeight,
        children: const ['left', 'right'],
      );

      expect(section.children, ['left', 'right']);
    });

    test('no orphan half-width panel can be produced', () {
      expect(
        () => PanelSection<String>(
          layoutStyle: PanelSectionLayoutStyle.twoColumnEqualHeight,
          children: const ['left'],
        ),
        throwsArgumentError,
      );
    });
  });

  group('CenterPanelReportLayout', () {
    testWidgets('twoColumnEqualHeight enforces equal heights', (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              width: 420,
              child: CenterPanelReportLayout<int>(
                sections: [
                  PanelSection<int>(
                    layoutStyle: PanelSectionLayoutStyle.twoColumnEqualHeight,
                    children: const [1, 2],
                  ),
                ],
                childBuilder: (context, layoutStyle, child) {
                  return ColoredBox(
                    key: Key('panel-$child'),
                    color: CupertinoColors.systemGrey4,
                    child: SizedBox(height: child == 1 ? 48 : 140),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byKey(const Key('panel-1'))).height,
        tester.getSize(find.byKey(const Key('panel-2'))).height,
      );
    });
  });
}
