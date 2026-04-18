import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

void main() {
  group('SidebarUtilityCassetteSpec JSON', () {
    test('top chat menu preserves durable selected choice through JSON', () {
      const spec = SidebarUtilityCassetteSpec.topChatMenu(
        selectedChoice: TopChatMenuChoice.searchAllMessages,
      );

      final json = spec.toJson();
      final restored = SidebarUtilityCassetteSpec.fromJson(json);

      expect(json, containsPair('selectedChoice', 'searchAllMessages'));
      expect(restored, spec);
    });

    test('settings menu does not serialize transient expanded action', () {
      const spec = SidebarUtilityCassetteSpec.settingsMenu(
        expandedActionId: SettingsMenuActionId.sendLogs,
      );

      final json = spec.toJson();
      final restored = SidebarUtilityCassetteSpec.fromJson(json);

      expect(json.containsKey('expandedActionId'), isFalse);
      expect(json, equals({'runtimeType': 'settingsMenu'}));
      expect(restored, const SidebarUtilityCassetteSpec.settingsMenu());
    });

    test('settings menu ignores injected expanded action during fromJson', () {
      final restored = SidebarUtilityCassetteSpec.fromJson({
        'runtimeType': 'settingsMenu',
        'expandedActionId': 'sendLogs',
      });

      expect(restored, const SidebarUtilityCassetteSpec.settingsMenu());
    });
  });
}
