import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/attachments/feature_level_providers.dart'
    as attachments_feature;

void main() {
  group('attachments placeholder cassette coordinators', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('feature cassette placeholder returns static info payload', () {
      final payload = container
          .read(
            attachments_feature.featureCassetteSpecCoordinatorProvider.notifier,
          )
          .buildForSpec(null);

      expect(payload, isA<StaticFeatureInfoSidebarCassettePayload>());
      expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
      expect(
        (payload as StaticFeatureInfoSidebarCassettePayload).title,
        'Attachments',
      );
      expect(payload.bodyText, 'Coming soon');
    });

    test('settings cassette placeholder returns static info payload', () {
      final payload = container
          .read(
            attachments_feature
                .settingsCassetteSpecCoordinatorProvider
                .notifier,
          )
          .buildForSpec(null);

      expect(payload, isA<StaticFeatureInfoSidebarCassettePayload>());
      expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
      expect(
        (payload as StaticFeatureInfoSidebarCassettePayload).title,
        'Attachment Settings',
      );
      expect(payload.bodyText, 'Coming soon');
    });
  });
}
