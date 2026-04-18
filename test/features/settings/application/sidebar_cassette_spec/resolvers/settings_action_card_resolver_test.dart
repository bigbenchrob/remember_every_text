import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/settings_action_card_resolver.dart';

void main() {
  group('SettingsActionCardResolver', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('returns a placement-governed action card payload', () {
      final payload = container
          .read(settingsActionCardResolverProvider.notifier)
          .resolve(
            cassetteIndex: 1,
            actions: const [
              SidebarActionDescriptor(
                label: 'Send log data…',
                intent: SendLogsRequested(),
                tone: SidebarActionTone.primary,
              ),
            ],
          );

      expect(payload.actions, hasLength(1));
      expect(payload.actions.single.label, 'Send log data…');
      expect(payload.actions.single.intent, isA<SendLogsRequested>());
      expect(payload.actions.single.tone, SidebarActionTone.primary);
    });
  });
}
