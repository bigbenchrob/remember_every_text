import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access.dart';
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/messages_source_history_sufficiency_test_agent.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_test_agent_ids.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/features/presence_iteration_simple/application/development_contacts_source_provider.dart';
import 'package:remember_this_text/features/presence_iteration_simple/application/presence_experiment_test_agent_resolver_provider.dart';

void main() {
  test('application composition resolves all onboarding Agents', () async {
    const contactsAgent = _ConstantTestAgent(result: false);
    final container = ProviderContainer(
      overrides: <Override>[
        fullDiskAccessProvider.overrideWithValue(
          const _ReadableFullDiskAccess(),
        ),
        developmentContactsSourceReadinessTestAgentProvider.overrideWith(
          (ref) async => contactsAgent,
        ),
      ],
    );
    addTearDown(container.dispose);

    final resolver = await container.read(
      presenceExperimentTestAgentResolverProvider.future,
    );

    expect(
      await resolver.resolve(messagesSourceReadableTestAgentId).evaluate(),
      isTrue,
    );
    expect(
      await resolver.resolve(messagesSourceAccessDeniedTestAgentId).evaluate(),
      isFalse,
    );
    expect(
      resolver.resolve(contactsSourceReadableTestAgentId),
      same(contactsAgent),
    );
    expect(
      resolver.resolve(messagesSourceHistorySufficientTestAgentId),
      isA<MessagesSourceHistorySufficiencyTestAgent>(),
    );
  });
}

final class _ConstantTestAgent implements TestAgent {
  const _ConstantTestAgent({required this.result});

  final bool result;

  @override
  Future<bool> evaluate() async => result;
}

final class _ReadableFullDiskAccess implements FullDiskAccess {
  const _ReadableFullDiskAccess();

  @override
  String get messagesDatabasePath => '/test/Library/Messages/chat.db';

  @override
  bool canReadMessagesDatabase() => true;

  @override
  MessagesSourceAccessResult inspectMessagesSourceAccess() =>
      MessagesSourceAccessResult.readable;

  @override
  Future<void> openSettings() async {}
}
