import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/chats/feature_level_providers.dart'
    as chats_feature;

void main() {
  group('chats placeholder cassette coordinators', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('feature cassette placeholder returns static info payload', () {
      final payload = container
          .read(chats_feature.featureCassetteSpecCoordinatorProvider.notifier)
          .buildForSpec(null);

      expect(payload, isA<StaticFeatureInfoSidebarCassettePayload>());
      expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
      expect(
        (payload as StaticFeatureInfoSidebarCassettePayload).title,
        'Chats',
      );
      expect(payload.bodyText, 'Coming soon');
    });

    test('settings cassette placeholder returns static info payload', () {
      final payload = container
          .read(chats_feature.settingsCassetteSpecCoordinatorProvider.notifier)
          .buildForSpec(null);

      expect(payload, isA<StaticFeatureInfoSidebarCassettePayload>());
      expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
      expect(
        (payload as StaticFeatureInfoSidebarCassettePayload).title,
        'Chat Settings',
      );
      expect(payload.bodyText, 'Coming soon');
    });
  });
}
