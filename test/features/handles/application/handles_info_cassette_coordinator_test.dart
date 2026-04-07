import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/handles/application/info_cassette_spec/coordinators/info_cassette_coordinator.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_info_cassette_spec.dart';

void main() {
  group('HandlesInfoCassetteCoordinator', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'returns static feature-info payload for stray emails explanation',
      () async {
        final payload = await container
            .read(handlesInfoCassetteCoordinatorProvider.notifier)
            .buildViewModel(
              const HandlesInfoCassetteSpec.infoCard(
                key: HandlesInfoKey.strayEmailsExplanation,
                childVariant: HandlesCassetteChildVariant.strayEmails,
              ),
              cassetteIndex: 0,
            );

        expect(payload, isA<StaticFeatureInfoSidebarCassettePayload>());
        final infoPayload = payload as StaticFeatureInfoSidebarCassettePayload;
        expect(infoPayload.bodyText, contains('email addresses'));
        expect(infoPayload.renderKind, SidebarCassetteRenderKind.featureInfo);
      },
    );

    test(
      'returns static feature-info payload for stray phones explanation',
      () async {
        final payload = await container
            .read(handlesInfoCassetteCoordinatorProvider.notifier)
            .buildViewModel(
              const HandlesInfoCassetteSpec.infoCard(
                key: HandlesInfoKey.strayPhoneNumbersExplanation,
                childVariant: HandlesCassetteChildVariant.strayPhoneNumbers,
              ),
              cassetteIndex: 0,
            );

        expect(payload, isA<StaticFeatureInfoSidebarCassettePayload>());
        final infoPayload = payload as StaticFeatureInfoSidebarCassettePayload;
        expect(infoPayload.bodyText, contains('phone numbers'));
        expect(infoPayload.renderKind, SidebarCassetteRenderKind.featureInfo);
      },
    );
  });
}
