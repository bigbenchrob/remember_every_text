import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_test_agent_bindings.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_test_agent_ids.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent_resolver.dart';

void main() {
  test('owns the exact stable and distinct onboarding Agent IDs', () {
    expect(
      messagesSourceReadableTestAgentId.value,
      'onboarding.messages-source-readable',
    );
    expect(
      messagesSourceAccessDeniedTestAgentId.value,
      'onboarding.messages-source-access-denied',
    );
    expect(
      contactsSourceReadableTestAgentId.value,
      'onboarding.contacts-source-readable',
    );
    expect(
      messagesSourceHistorySufficientTestAgentId.value,
      'onboarding.messages-source-history-sufficient',
    );
    expect(
      messagesSourceReadableTestAgentId,
      isNot(contactsSourceReadableTestAgentId),
    );
    expect(<Object>{
      messagesSourceReadableTestAgentId,
      messagesSourceAccessDeniedTestAgentId,
      contactsSourceReadableTestAgentId,
      messagesSourceHistorySufficientTestAgentId,
    }, hasLength(4));
  });

  test('contributes exactly one binding for each onboarding Agent', () {
    const messagesAgent = _ConstantTestAgent(result: true);
    const messagesAccessDeniedAgent = _ConstantTestAgent(result: false);
    const contactsAgent = _ConstantTestAgent(result: false);
    const historyAgent = _ConstantTestAgent(result: true);

    final bindings = buildOnboardingTestAgentBindings(
      messagesSourceReadinessTestAgent: messagesAgent,
      messagesSourceAccessDeniedTestAgent: messagesAccessDeniedAgent,
      contactsSourceReadinessTestAgent: contactsAgent,
      messagesSourceHistorySufficiencyTestAgent: historyAgent,
    );

    expect(bindings, hasLength(4));
    expect(bindings[0].id, messagesSourceReadableTestAgentId);
    expect(bindings[0].agent, same(messagesAgent));
    expect(bindings[1].id, messagesSourceAccessDeniedTestAgentId);
    expect(bindings[1].agent, same(messagesAccessDeniedAgent));
    expect(bindings[2].id, contactsSourceReadableTestAgentId);
    expect(bindings[2].agent, same(contactsAgent));
    expect(bindings[3].id, messagesSourceHistorySufficientTestAgentId);
    expect(bindings[3].agent, same(historyAgent));
  });

  test('combined resolver resolves both onboarding Agents', () {
    const messagesAgent = _ConstantTestAgent(result: true);
    const contactsAgent = _ConstantTestAgent(result: false);
    final resolver = ImmutableTestAgentResolver(
      buildOnboardingTestAgentBindings(
        messagesSourceReadinessTestAgent: messagesAgent,
        messagesSourceAccessDeniedTestAgent: contactsAgent,
        contactsSourceReadinessTestAgent: contactsAgent,
        messagesSourceHistorySufficiencyTestAgent: messagesAgent,
      ),
    );

    expect(
      resolver.resolve(messagesSourceReadableTestAgentId),
      same(messagesAgent),
    );
    expect(
      resolver.resolve(messagesSourceAccessDeniedTestAgentId),
      same(contactsAgent),
    );
    expect(
      resolver.resolve(contactsSourceReadableTestAgentId),
      same(contactsAgent),
    );
    expect(
      resolver.resolve(messagesSourceHistorySufficientTestAgentId),
      same(messagesAgent),
    );
  });

  test('duplicate contributions fail mechanically', () {
    final bindings = buildOnboardingTestAgentBindings(
      messagesSourceReadinessTestAgent: const _ConstantTestAgent(result: true),
      messagesSourceAccessDeniedTestAgent: const _ConstantTestAgent(
        result: false,
      ),
      contactsSourceReadinessTestAgent: const _ConstantTestAgent(result: false),
      messagesSourceHistorySufficiencyTestAgent: const _ConstantTestAgent(
        result: true,
      ),
    );

    expect(
      () => ImmutableTestAgentResolver(<TestAgentBinding>[
        ...bindings,
        ...bindings,
      ]),
      throwsA(isA<DuplicateTestAgentBindingException>()),
    );
  });
}

final class _ConstantTestAgent implements TestAgent {
  const _ConstantTestAgent({required this.result});

  final bool result;

  @override
  Future<bool> evaluate() async => result;
}
