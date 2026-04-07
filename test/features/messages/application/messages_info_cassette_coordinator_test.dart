import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/config/theme/spacing/app_spacing.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/coordinators/info_cassette_coordinator.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/payloads/recovered_no_handle_from_me_navigator_cassette_payload.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/payloads/recovered_unlinked_navigator_cassette_payload.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_info_cassette_spec.dart';

void main() {
  group('MessagesInfoCassetteCoordinator', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('keeps search-all-messages on text info-card path', () async {
      final payload = await container
          .read(messagesInfoCassetteCoordinatorProvider.notifier)
          .buildViewModel(
            const MessagesInfoCassetteSpec.infoCard(
              key: MessagesInfoKey.searchAllMessages,
            ),
            cassetteIndex: 2,
          );

      expect(payload, isA<StaticFeatureInfoSidebarCassettePayload>());
      final infoPayload = payload as StaticFeatureInfoSidebarCassettePayload;
      expect(
        infoPayload.bodyText,
        contains('heatmap below represents all the messages'),
      );
      expect(infoPayload.renderKind, SidebarCassetteRenderKind.featureInfo);
    });

    test(
      'returns inert payload for recovered deleted messages entry',
      () async {
        final payload = await container
            .read(messagesInfoCassetteCoordinatorProvider.notifier)
            .buildViewModel(
              const MessagesInfoCassetteSpec.infoCard(
                key: MessagesInfoKey.recoveredDeletedMessages,
              ),
              cassetteIndex: 4,
            );

        expect(payload, isA<RecoveredUnlinkedNavigatorCassettePayload>());
        final navigatorPayload =
            payload as RecoveredUnlinkedNavigatorCassettePayload;
        expect(navigatorPayload.cassetteIndex, 4);
        expect(navigatorPayload.topSpacing, AppSpacing.lg);
        expect(
          navigatorPayload.renderKind,
          SidebarCassetteRenderKind.placementGovernedFeature,
        );
      },
    );

    test('returns inert payload for recovered no-handle entry', () async {
      final payload = await container
          .read(messagesInfoCassetteCoordinatorProvider.notifier)
          .buildViewModel(
            const MessagesInfoCassetteSpec.infoCard(
              key: MessagesInfoKey.recoveredNoHandleMessages,
            ),
            cassetteIndex: 5,
          );

      expect(payload, isA<RecoveredNoHandleFromMeNavigatorCassettePayload>());
      final navigatorPayload =
          payload as RecoveredNoHandleFromMeNavigatorCassettePayload;
      expect(navigatorPayload.cassetteIndex, 5);
      expect(navigatorPayload.topSpacing, 0);
      expect(
        navigatorPayload.renderKind,
        SidebarCassetteRenderKind.placementGovernedFeature,
      );
    });
  });
}
