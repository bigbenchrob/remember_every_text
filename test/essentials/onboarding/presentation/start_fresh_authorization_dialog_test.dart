import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/onboarding/presentation/start_fresh_authorization_dialog.dart';

void main() {
  testWidgets('describes the preservation-safe Start Fresh boundary', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: StartFreshAuthorizationDialog()),
      ),
    );

    expect(find.text('Start with a clean MessageLens setup?'), findsOneWidget);
    expect(find.textContaining('rebuildable imported-message'), findsOneWidget);
    expect(find.textContaining('Apple Messages and Contacts'), findsOneWidget);
    expect(find.textContaining('archived attachment payloads'), findsOneWidget);
    expect(
      find.textContaining('Historical Archive source folders'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Start Fresh'), findsOneWidget);
  });
}
