import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/settings_info_actions_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/send_logs_settings_resolver.dart';

void main() {
  group('SendLogsSettingsResolver', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('returns a single send-logs cassette payload with inline action', () {
      final payload = container
          .read(sendLogsSettingsResolverProvider.notifier)
          .resolve(cassetteIndex: 1);

      expect(payload, isA<SettingsInfoActionsCassettePayload>());
      expect(payload.title, isNull);
      expect(payload.bodyText, contains('database health diagnostics'));
      expect(payload.actions, hasLength(1));
      expect(payload.actions.single.label, 'Send log data…');
      expect(payload.actions.single.intent, isA<SendLogsRequested>());
    });
  });
}
