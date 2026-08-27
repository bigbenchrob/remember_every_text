import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/complete_installation_erase_authorization_dialog.dart';

void main() {
  testWidgets('states both erased and protected data explicitly', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: CompleteInstallationEraseAuthorizationDialog()),
        ),
      ),
    );

    expect(
      find.text('Erase this MessageLens setup and start over?'),
      findsOneWidget,
    );
    expect(find.textContaining('attachment copies archived'), findsOneWidget);
    expect(find.textContaining('Apple Messages, Contacts'), findsOneWidget);
    expect(find.text('Erase and Start Over'), findsOneWidget);
  });
}
