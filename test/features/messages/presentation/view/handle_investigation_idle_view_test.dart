import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';
import 'package:remember_this_text/features/messages/presentation/view/handle_investigation_idle_view.dart';

void main() {
  testWidgets('renders the Identify investigation without source controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MacosApp(
          home: HandleInvestigationIdleView(
            investigation: StrayHandleInvestigation.identifySources,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Messages not linked to a contact'), findsOneWidget);
    expect(
      find.text(
        'These phone numbers, email addresses, and business identities could '
        "not be matched to a contact in your Mac's Contacts data.",
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('Select one to review its messages.'),
      findsOneWidget,
    );
    expect(find.text('Create Contact'), findsNothing);
    expect(find.text('Dismiss'), findsNothing);
  });

  testWidgets('renders the Numeric IDs investigation from the same view', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MacosApp(
          home: HandleInvestigationIdleView(
            investigation: StrayHandleInvestigation.numericSenderIds,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Messages from numeric IDs'), findsOneWidget);
    expect(
      find.textContaining('Numeric IDs are commonly used'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Nothing here requires action.'),
      findsOneWidget,
    );
  });
}
