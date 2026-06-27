import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/persistent_database_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/contact_timeline_provider.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/global_messages_heatmap_provider.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/message_heatmap_navigation_actions_provider.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/message_heatmap_refresh_actions_provider.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/recovered_message_navigation_actions_provider.dart';
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

  test('focusMonth dispatches ordinary heatmap month focus', () async {
    final anchor = DateTime.utc(2026, 5);

    await container
        .read(messageHeatmapNavigationActionsProvider.notifier)
        .focusMonth(monthAnchor: anchor, contactId: 24);

    final flowState = container.read(sidebarFlowProvider);
    expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
    expect(flowState.chosenContactId, 24);
    expect(flowState.scrollToDate, anchor);
    expect(flowState.messageScope, SidebarFlowMessageScope.regular);
    expect(
      flowState.contactProjection,
      SidebarFlowContactProjection.allMessages,
    );
  });

  test(
    'selectContactProjection dispatches contact projection changes',
    () async {
      await container
          .read(messageHeatmapNavigationActionsProvider.notifier)
          .selectContactProjection(
            contactId: 24,
            projection: SidebarContactProjection.conversations,
          );

      final flowState = container.read(sidebarFlowProvider);
      expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
      expect(flowState.chosenContactId, 24);
      expect(
        flowState.contactProjection,
        SidebarFlowContactProjection.conversations,
      );
    },
  );

  test('recovered focusMonth dispatches recovered scope focus', () async {
    final anchor = DateTime.utc(2026, 4);

    await container
        .read(recoveredMessageNavigationActionsProvider.notifier)
        .focusMonth(monthAnchor: anchor, contactId: 24);

    final flowState = container.read(sidebarFlowProvider);
    expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
    expect(flowState.chosenContactId, 24);
    expect(flowState.scrollToDate, anchor);
    expect(flowState.messageScope, SidebarFlowMessageScope.recoveredDeleted);
  });

  test('openNoHandleFromMe dispatches recovered no-handle branch', () async {
    await container
        .read(recoveredMessageNavigationActionsProvider.notifier)
        .openNoHandleFromMe();

    final flowState = container.read(sidebarFlowProvider);
    expect(
      flowState.topMenuChoice,
      TopChatMenuChoice.recoveredNoHandleFromMeMessages,
    );
    expect(flowState.chosenContactId, isNull);
  });

  test('refreshGlobalHeatmap invalidates global heatmap data', () async {
    var builds = 0;
    final refreshContainer = ProviderContainer(
      overrides: [
        globalMessagesHeatmapProvider.overrideWith((ref) {
          builds++;
          return null;
        }),
      ],
    );
    addTearDown(refreshContainer.dispose);

    await refreshContainer.read(globalMessagesHeatmapProvider.future);
    expect(builds, 1);

    refreshContainer
        .read(messageHeatmapRefreshActionsProvider.notifier)
        .refreshGlobalHeatmap();
    await refreshContainer.read(globalMessagesHeatmapProvider.future);

    expect(builds, 2);
  });

  test(
    'refreshContactTimeline invalidates selected contact timeline',
    () async {
      var builds = 0;
      final timelineProvider = contactTimelineProvider(
        contactId: 24,
        filterHandleId: 7,
      );
      final refreshContainer = ProviderContainer(
        overrides: [
          timelineProvider.overrideWith((ref) {
            builds++;
            return null;
          }),
        ],
      );
      addTearDown(refreshContainer.dispose);

      await refreshContainer.read(timelineProvider.future);
      expect(builds, 1);

      refreshContainer
          .read(messageHeatmapRefreshActionsProvider.notifier)
          .refreshContactTimeline(contactId: 24, filterHandleId: 7);
      await refreshContainer.read(timelineProvider.future);

      expect(builds, 2);
    },
  );
}
