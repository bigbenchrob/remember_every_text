import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/test_agent_id.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent_resolver.dart';

void main() {
  group('TestAgent', () {
    test('evaluates true asynchronously', () async {
      const agent = _BooleanTestAgent(result: true);

      await expectLater(agent.evaluate(), completion(isTrue));
    });

    test('evaluates false asynchronously', () async {
      const agent = _BooleanTestAgent(result: false);

      await expectLater(agent.evaluate(), completion(isFalse));
    });
  });

  group('ImmutableTestAgentResolver', () {
    test('resolves one ID to its Agent', () {
      final id = TestAgentId('owner.first-fact');
      const agent = _BooleanTestAgent(result: true);
      final resolver = ImmutableTestAgentResolver(<TestAgentBinding>[
        TestAgentBinding(id: id, agent: agent),
      ]);

      expect(resolver.resolve(TestAgentId('owner.first-fact')), same(agent));
    });

    test('resolves several IDs independently', () {
      final firstId = TestAgentId('owner.first-fact');
      final secondId = TestAgentId('owner.second-fact');
      const firstAgent = _BooleanTestAgent(result: true);
      const secondAgent = _BooleanTestAgent(result: false);
      final resolver = ImmutableTestAgentResolver(<TestAgentBinding>[
        TestAgentBinding(id: firstId, agent: firstAgent),
        TestAgentBinding(id: secondId, agent: secondAgent),
      ]);

      expect(resolver.resolve(firstId), same(firstAgent));
      expect(resolver.resolve(secondId), same(secondAgent));
    });

    test('fails explicitly when an ID is missing', () {
      final missingId = TestAgentId('owner.missing-fact');
      final resolver = ImmutableTestAgentResolver(const <TestAgentBinding>[]);

      expect(
        () => resolver.resolve(missingId),
        throwsA(
          isA<MissingTestAgentBindingException>().having(
            (error) => error.id,
            'id',
            missingId,
          ),
        ),
      );
    });

    test('rejects duplicate IDs during construction', () {
      final duplicateId = TestAgentId('owner.duplicate-fact');

      expect(
        () => ImmutableTestAgentResolver(<TestAgentBinding>[
          TestAgentBinding(
            id: duplicateId,
            agent: const _BooleanTestAgent(result: true),
          ),
          TestAgentBinding(
            id: TestAgentId('owner.duplicate-fact'),
            agent: const _BooleanTestAgent(result: false),
          ),
        ]),
        throwsA(
          isA<DuplicateTestAgentBindingException>().having(
            (error) => error.id,
            'id',
            duplicateId,
          ),
        ),
      );
    });

    test('keeps a resolved false result as an ordinary fact', () async {
      final id = TestAgentId('owner.false-fact');
      final resolver = ImmutableTestAgentResolver(<TestAgentBinding>[
        TestAgentBinding(id: id, agent: const _BooleanTestAgent(result: false)),
      ]);

      await expectLater(resolver.resolve(id).evaluate(), completion(isFalse));
    });

    test('does not convert an Agent exception into false', () async {
      final id = TestAgentId('owner.throwing-fact');
      final resolver = ImmutableTestAgentResolver(<TestAgentBinding>[
        TestAgentBinding(id: id, agent: const _ThrowingTestAgent()),
      ]);

      await expectLater(
        resolver.resolve(id).evaluate(),
        throwsA(isA<StateError>()),
      );
    });

    test('copies bindings and exposes no later mutation path', () {
      final id = TestAgentId('owner.original-fact');
      const agent = _BooleanTestAgent(result: true);
      final bindings = <TestAgentBinding>[
        TestAgentBinding(id: id, agent: agent),
      ];
      final resolver = ImmutableTestAgentResolver(bindings);

      bindings
        ..clear()
        ..add(
          TestAgentBinding(
            id: TestAgentId('owner.later-fact'),
            agent: const _BooleanTestAgent(result: false),
          ),
        );

      expect(resolver.resolve(id), same(agent));
      expect(
        () => resolver.resolve(TestAgentId('owner.later-fact')),
        throwsA(isA<MissingTestAgentBindingException>()),
      );
    });
  });
}

final class _BooleanTestAgent implements TestAgent {
  const _BooleanTestAgent({required this.result});

  final bool result;

  @override
  Future<bool> evaluate() async => result;
}

final class _ThrowingTestAgent implements TestAgent {
  const _ThrowingTestAgent();

  @override
  Future<bool> evaluate() async {
    throw StateError('Deliberate test failure.');
  }
}
