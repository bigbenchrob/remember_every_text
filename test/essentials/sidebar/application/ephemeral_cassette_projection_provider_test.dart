import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/ephemeral_cassette_projection_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_cassette_spec.dart';

void main() {
  group('ephemeralCassetteProjectionProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('replaceProjection is replace-only rather than accumulative', () {
      final notifier = container.read(
        ephemeralCassetteProjectionProvider(SidebarMode.settings).notifier,
      );

      notifier.replaceProjection(
        const CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel()),
      );
      notifier.replaceProjection(
        const CassetteSpec.settings(
          SettingsCassetteSpec.resetMessageDataPanel(),
        ),
      );

      expect(
        container
            .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
            .cassettes,
        equals([
          const CassetteSpec.settings(
            SettingsCassetteSpec.resetMessageDataPanel(),
          ),
        ]),
      );
    });

    test('ephemeral settings root is terminal and derives no stable child', () {
      final notifier = container.read(
        ephemeralCassetteProjectionProvider(SidebarMode.settings).notifier,
      );

      notifier.replaceProjection(
        const CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel()),
      );

      expect(
        container
            .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
            .cassettes,
        equals([
          const CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel()),
        ]),
      );
    });
  });
}
