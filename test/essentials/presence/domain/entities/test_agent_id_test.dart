import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/test_agent_id.dart';

void main() {
  group('TestAgentId', () {
    test('preserves its stable opaque string', () {
      final id = TestAgentId('onboarding.messages-source-readable');

      expect(id.value, 'onboarding.messages-source-readable');
    });

    test('uses value equality and matching hash semantics', () {
      final first = TestAgentId('onboarding.messages-source-readable');
      final second = TestAgentId('onboarding.messages-source-readable');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('keeps distinct identities distinct', () {
      final messages = TestAgentId('onboarding.messages-source-readable');
      final contacts = TestAgentId('onboarding.contacts-source-readable');

      expect(messages, isNot(contacts));
    });

    test('rejects empty and whitespace-only identities', () {
      expect(() => TestAgentId(''), throwsArgumentError);
      expect(() => TestAgentId('   '), throwsArgumentError);
    });
  });
}
