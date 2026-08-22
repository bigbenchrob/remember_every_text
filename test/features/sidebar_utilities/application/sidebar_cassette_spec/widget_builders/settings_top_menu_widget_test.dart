import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/payloads/settings_top_menu_cassette_payload.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/settings_top_menu_widget.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/settings_top_menu_row.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';

void main() {
  testWidgets('tracked Settings menu opens outside its fixed-height cell', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          home: Center(
            child: SizedBox(
              width: 280,
              height: 40,
              child: SettingsTopMenuWidget(
                panelPresentation:
                    SettingsTopMenuPanelPresentation.anchoredOverlay,
                payload: SettingsTopMenuCassettePayload(
                  cassetteIndex: 0,
                  promptLabel: 'Choose setting or action',
                  persistentContextActionId:
                      SettingsMenuActionId.messageHistoryCoverage,
                  rows: <SettingsTopMenuRow>[
                    SettingsTopMenuGroupHeaderRow(label: 'Message Data'),
                    SettingsTopMenuActionRow.persistentContext(
                      label: 'Message History Coverage',
                      actionId: SettingsMenuActionId.messageHistoryCoverage,
                    ),
                    SettingsTopMenuActionRow.persistentContext(
                      label: 'Historical Archives',
                      actionId: SettingsMenuActionId.historicalArchives,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Message Data'), findsNothing);
    await tester.tap(find.text('Message history coverage report'));
    await tester.pump();

    expect(find.text('Message Data'), findsOneWidget);
    expect(find.text('Historical Archives'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tapAt(const Offset(4, 4));
    await tester.pump();

    expect(find.text('Message Data'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
