import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:remember_this_text/features/contacts/application/read_models/contacts_list_repository_provider.dart';
import 'package:remember_this_text/features/contacts/presentation/widgets/contact_picker_dialog.dart';

import '../../../../test_utils/contact_summary_fixture.dart';

void main() {
  group('ContactPickerDialog', () {
    testWidgets('filters contacts and returns the selected id', (tester) async {
      int? selectedParticipantId;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contactsListRepositoryProvider.overrideWith(
              (ref) async => [
                buildContactSummary(
                  participantId: 17,
                  displayName: 'Claire Campbell',
                ),
                buildContactSummary(
                  participantId: 24,
                  displayName: 'Cathie Campbell',
                ),
              ],
            ),
          ],
          child: MacosApp(
            home: Builder(
              builder: (context) {
                return PushButton(
                  controlSize: ControlSize.regular,
                  onPressed: () async {
                    selectedParticipantId = await ContactPickerDialog.show(
                      context,
                    );
                  },
                  child: const Text('Open picker'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();

      expect(find.text('Assign to Contact'), findsOneWidget);
      expect(find.text('Claire Campbell'), findsOneWidget);
      expect(find.text('Cathie Campbell'), findsOneWidget);

      await tester.enterText(find.byType(MacosSearchField), 'cath');
      await tester.pumpAndSettle();

      expect(find.text('Claire Campbell'), findsNothing);
      expect(find.text('Cathie Campbell'), findsOneWidget);

      await tester.tap(find.text('Cathie Campbell'));
      await tester.pump();
      await tester.tap(find.text('Assign'));
      await tester.pumpAndSettle();

      expect(find.text('Assign to Contact'), findsNothing);
      expect(selectedParticipantId, 24);
    });
  });
}
