import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/widget_builders/handle_filter_widget.dart';
import 'package:remember_this_text/features/contacts/feature_level_providers.dart';

void main() {
  group('HandleFilterWidget', () {
    testWidgets('shows loading status while handle options load', (
      tester,
    ) async {
      final completer = Completer<List<LinkedHandle>>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            handlesForContactProvider(
              contactId: 42,
            ).overrideWith((ref) => completer.future),
          ],
          child: const MacosApp(
            home: HandleFilterWidget(
              contactId: 42,
              selectedHandleId: null,
              cassetteIndex: 0,
            ),
          ),
        ),
      );

      expect(find.text('Loading handle options...'), findsOneWidget);

      completer.complete(const <LinkedHandle>[]);
      await tester.pumpAndSettle();
    });

    testWidgets('shows error status when handle options fail', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            handlesForContactProvider(contactId: 42).overrideWith((ref) {
              throw StateError('reader unavailable');
            }),
          ],
          child: const MacosApp(
            home: HandleFilterWidget(
              contactId: 42,
              selectedHandleId: null,
              cassetteIndex: 0,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.textContaining('Unable to load handle options.'),
        findsOneWidget,
      );
    });
  });
}
