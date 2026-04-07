import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/contact_message_scope_toggle_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/contact_selection_control_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/handle_filter_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolvers/contact_selection_control_resolver.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolvers/handle_filter_resolver.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolvers/message_scope_toggle_resolver.dart';

void main() {
  group('Contact sidebar control resolvers', () {
    test('selection control resolver returns inert payload', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final payload = await container
          .read(contactSelectionControlResolverProvider.notifier)
          .resolve(contactId: 42, cassetteIndex: 2);

      expect(payload, isA<ContactSelectionControlCassettePayload>());
      final viewModel = payload as ContactSelectionControlCassettePayload;

      expect(viewModel.contactId, 42);
      expect(viewModel.cassetteIndex, 2);
      expect(viewModel.role, SidebarCassetteRole.action);
      expect(viewModel.placementMode, SidebarBodyPlacementMode.fullWidth);
      expect(
        viewModel.contentAlignment,
        SidebarBodyContentAlignment.leftAnchored,
      );
      expect(viewModel.isNaked, isTrue);
    });

    test('message scope toggle resolver returns inert payload', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final payload = await container
          .read(messageScopeToggleResolverProvider.notifier)
          .resolve(contactId: 42, cassetteIndex: 3);

      expect(payload, isA<ContactMessageScopeToggleCassettePayload>());
      final viewModel = payload as ContactMessageScopeToggleCassettePayload;

      expect(viewModel.contactId, 42);
      expect(viewModel.role, SidebarCassetteRole.filter);
      expect(viewModel.placementMode, SidebarBodyPlacementMode.fullWidth);
      expect(
        viewModel.contentAlignment,
        SidebarBodyContentAlignment.insetControl,
      );
      expect(viewModel.isNaked, isTrue);
    });

    test('handle filter resolver returns inert payload', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final payload = await container
          .read(handleFilterResolverProvider.notifier)
          .resolve(contactId: 42, selectedHandleId: 7, cassetteIndex: 4);

      expect(payload, isA<HandleFilterCassettePayload>());
      final viewModel = payload as HandleFilterCassettePayload;

      expect(viewModel.contactId, 42);
      expect(viewModel.selectedHandleId, 7);
      expect(viewModel.cassetteIndex, 4);
      expect(viewModel.role, SidebarCassetteRole.filter);
      expect(viewModel.placementMode, SidebarBodyPlacementMode.fullWidth);
      expect(
        viewModel.contentAlignment,
        SidebarBodyContentAlignment.insetControl,
      );
      expect(viewModel.isNaked, isTrue);
    });
  });
}
