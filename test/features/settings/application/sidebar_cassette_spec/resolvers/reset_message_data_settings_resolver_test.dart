import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/settings_info_actions_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/reset_message_data_settings_resolver.dart';

void main() {
  group('ResetMessageDataSettingsResolver', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'returns a single reset-message-data cassette payload with inline action',
      () {
        final payload = container
            .read(resetMessageDataSettingsResolverProvider.notifier)
            .resolve(cassetteIndex: 1);

        expect(payload, isA<SettingsInfoActionsCassettePayload>());
        expect(payload.title, 'Reset Message Data');
        expect(payload.bodyText, contains('Start Fresh'));
        expect(payload.bodyText, contains('archived attachments'));
        expect(
          payload.bodyText,
          isNot(contains('removes all MessageLens-owned local data')),
        );
        expect(payload.bodyText, contains('Apple Messages'));
        expect(payload.actions, hasLength(1));
        expect(payload.actions.single.label, 'Reset message data…');
        expect(payload.actions.single.intent, isA<ResetMessageDataRequested>());
      },
    );
  });
}
