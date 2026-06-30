import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/current_visible_month_provider.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_scope.dart';

void main() {
  test('publishes visible month per timeline scope', () {
    const claireScope = ContactAllMessagesEvidenceScope(contactId: 42);
    const globalScope = GlobalMessagesEvidenceScope();
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final claireProvider = currentVisibleMonthForScopeProvider(
      scope: claireScope,
    );
    final globalProvider = currentVisibleMonthForScopeProvider(
      scope: globalScope,
    );

    expect(container.read(claireProvider), isNull);
    expect(container.read(globalProvider), isNull);

    container.read(claireProvider.notifier).setVisibleMonthKey('2026-05');

    expect(container.read(claireProvider), '2026-05');
    expect(container.read(globalProvider), isNull);
  });
}
