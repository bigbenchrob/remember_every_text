import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/persistent_database_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/contact_message_scope_actions_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/handle_filter_actions_provider.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';

void main() {
  late OverlayDatabase overlayDb;
  late ProviderContainer container;

  setUp(() {
    overlayDb = OverlayDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await overlayDb.close();
  });

  test('selectScope dispatches recovered contact message scope', () async {
    await container
        .read(contactMessageScopeActionsProvider.notifier)
        .selectScope(
          contactId: 24,
          cassetteIndex: 0,
          scope: ContactMessageScopeChoice.recoveredDeleted,
        );

    final flowState = container.read(sidebarFlowProvider);
    expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
    expect(flowState.chosenContactId, 24);
    expect(flowState.messageScope, SidebarFlowMessageScope.recoveredDeleted);
    expect(
      flowState.contactProjection,
      SidebarFlowContactProjection.allMessages,
    );
  });

  test('selectHandle dispatches handle-filter contact scope', () async {
    await container
        .read(handleFilterActionsProvider.notifier)
        .selectHandle(contactId: 24, handleId: 7, cassetteIndex: 0);

    final flowState = container.read(sidebarFlowProvider);
    expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
    expect(flowState.chosenContactId, 24);
    expect(flowState.selectedHandleId, 7);
    expect(flowState.messageScope, SidebarFlowMessageScope.regular);
    expect(
      flowState.contactProjection,
      SidebarFlowContactProjection.allMessages,
    );
  });
}
