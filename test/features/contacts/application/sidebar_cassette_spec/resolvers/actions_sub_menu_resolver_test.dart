import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_body_model.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolvers/actions_sub_menu_resolver.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';

void main() {
  group('ActionsSubMenuResolver', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('returns a dropdown body model for settings actions', () {
      final viewModel = container
          .read(actionsSubMenuResolverProvider.notifier)
          .resolve(currentChoice: ActionsMenuChoice.sendLogs);

      final bodyModel = viewModel.bodyModel;

      expect(viewModel.child, isNull);
      expect(bodyModel, isA<SidebarDropdownBodyModel>());

      final dropdown = bodyModel! as SidebarDropdownBodyModel;
      expect(dropdown.promptLabel, 'Choose an action:');
      expect(dropdown.selectedOptionId, ActionsMenuChoice.sendLogs.id);
      expect(dropdown.options, hasLength(ActionsMenuChoice.values.length));

      final sendLogsOption = dropdown.options.firstWhere(
        (option) => option.id == ActionsMenuChoice.sendLogs.id,
      );
      expect(sendLogsOption.selectionIntent, isA<SettingsActionChosen>());
      expect(
        (sendLogsOption.selectionIntent as SettingsActionChosen).choice,
        SidebarSettingsActionChoice.sendLogs,
      );
    });
  });
}
