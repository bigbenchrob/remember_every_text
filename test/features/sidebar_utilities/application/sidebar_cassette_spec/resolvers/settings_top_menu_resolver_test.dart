import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_body_model.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/resolvers/settings_top_menu_resolver.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';

void main() {
  group('SettingsTopMenuResolver', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('returns a dropdown body model for the settings menu', () async {
      final viewModel = await container
          .read(settingsTopMenuResolverProvider.notifier)
          .resolve(currentChoice: SettingsMenuChoice.actions);

      final bodyModel = viewModel.bodyModel;

      expect(viewModel.child, isNull);
      expect(bodyModel, isA<SidebarDropdownBodyModel>());

      final dropdown = bodyModel! as SidebarDropdownBodyModel;
      expect(dropdown.promptLabel, isEmpty);
      expect(dropdown.selectedOptionId, SettingsMenuChoice.actions.id);
      expect(dropdown.options, hasLength(1));

      final intent = dropdown.options.single.selectionIntent;
      expect(intent, isA<SettingsMenuChanged>());
      expect(
        (intent as SettingsMenuChanged).choice,
        SidebarSettingsMenuChoice.actions,
      );
    });
  });
}
