import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/handles/application/settings_cassette_spec/payloads/manual_linking_cassette_payload.dart';
import 'package:remember_this_text/features/handles/application/settings_cassette_spec/payloads/spam_management_cassette_payload.dart';
import 'package:remember_this_text/features/handles/application/settings_cassette_spec/resolvers/manual_linking_resolver.dart';
import 'package:remember_this_text/features/handles/application/settings_cassette_spec/resolvers/spam_management_resolver.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/payloads/stray_emails_cassette_payload.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/payloads/stray_phone_numbers_cassette_payload.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/payloads/unmatched_handles_cassette_payload.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/resolvers/stray_emails_resolver.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/resolvers/stray_phones_resolver.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/resolvers/unmatched_handles_resolver.dart';

void main() {
  group('Handles sidebar/settings inert payload resolvers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('manual linking resolver returns inert payload', () async {
      final payload = await container
          .read(manualLinkingResolverProvider.notifier)
          .resolve();

      expect(payload, isA<ManualLinkingCassettePayload>());
      expect(
        payload.renderKind,
        SidebarCassetteRenderKind.placementGovernedFeature,
      );
      expect(payload.role, SidebarCassetteRole.action);
      expect(payload.shouldExpand, isTrue);
    });

    test('spam management resolver returns inert payload', () async {
      final payload = await container
          .read(spamManagementResolverProvider.notifier)
          .resolve();

      expect(payload, isA<SpamManagementCassettePayload>());
      expect(
        payload.renderKind,
        SidebarCassetteRenderKind.placementGovernedFeature,
      );
      expect(payload.role, SidebarCassetteRole.action);
      expect(payload.shouldExpand, isTrue);
    });

    test('unmatched handles resolver returns inert payload', () async {
      final payload = await container
          .read(unmatchedHandlesResolverProvider.notifier)
          .resolve();

      expect(payload, isA<UnmatchedHandlesCassettePayload>());
      expect(
        payload.renderKind,
        SidebarCassetteRenderKind.placementGovernedFeature,
      );
      expect(payload.role, SidebarCassetteRole.contextPrimary);
      expect(payload.shouldExpand, isTrue);
    });

    test('stray phones resolver returns inert payload', () async {
      final payload = await container
          .read(strayPhonesResolverProvider.notifier)
          .resolve();

      expect(payload, isA<StrayPhoneNumbersCassettePayload>());
      expect(
        payload.renderKind,
        SidebarCassetteRenderKind.placementGovernedFeature,
      );
      expect(payload.role, SidebarCassetteRole.contextPrimary);
      expect(payload.shouldExpand, isTrue);
    });

    test('stray emails resolver returns inert payload', () async {
      final payload = await container
          .read(strayEmailsResolverProvider.notifier)
          .resolve();

      expect(payload, isA<StrayEmailsCassettePayload>());
      expect(
        payload.renderKind,
        SidebarCassetteRenderKind.placementGovernedFeature,
      );
      expect(payload.role, SidebarCassetteRole.contextPrimary);
      expect(payload.shouldExpand, isTrue);
    });
  });
}
