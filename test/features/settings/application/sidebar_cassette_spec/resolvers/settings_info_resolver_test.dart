import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/settings_info_resolver.dart';

void main() {
  group('SettingsInfoResolver', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('returns a static feature info payload', () {
      final payload = container
          .read(settingsInfoResolverProvider.notifier)
          .resolve(title: 'Text Size', bodyText: 'Coming soon');

      expect(payload.title, 'Text Size');
      expect(payload.bodyText, 'Coming soon');
    });
  });
}
