import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolvers/display_name_info_resolver.dart';

void main() {
  group('DisplayNameInfoResolver', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('returns static feature-info payload', () {
      final payload = container
          .read(displayNameInfoResolverProvider.notifier)
          .resolve(cassetteIndex: 0);

      expect(payload, isA<StaticFeatureInfoSidebarCassettePayload>());
      expect(payload.title, 'Contact Names');
      expect(
        payload.footnote,
        'Your custom name will be used throughout the app.',
      );
      expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
    });
  });
}
