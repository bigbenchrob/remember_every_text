import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/message_history_coverage_settings_resolver.dart';

void main() {
  group('MessageHistoryCoverageSettingsResolver', () {
    test('returns the overview info payload', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final payload = container
          .read(messageHistoryCoverageSettingsResolverProvider.notifier)
          .resolveOverview(cassetteIndex: 2);

      expect(payload, isA<StaticFeatureInfoSidebarCassettePayload>());
      expect(payload.title, 'Message History Coverage');
      expect(
        payload.bodyText,
        contains(
          'MessageLens compares the messages stored in your Mac\'s Messages database (chat.db) with the messages it has imported and organized.',
        ),
      );
      expect(payload.footnote, isNull);
    });

    test('returns the how-to-read info payload', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final payload = container
          .read(messageHistoryCoverageSettingsResolverProvider.notifier)
          .resolveHowToRead(cassetteIndex: 3);

      expect(payload.title, 'How to read this report');
      expect(payload.topSpacing, 10);
      expect(
        payload.bodyText,
        contains('Messages on this Mac are grouped into:'),
      );
      expect(
        payload.bodyText,
        contains('• Messages recovered but not linked to a conversation'),
      );
      expect(payload.footnote, isNull);
    });

    test('returns the older-messages note payload', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final payload = container
          .read(messageHistoryCoverageSettingsResolverProvider.notifier)
          .resolveOlderMessagesNote(cassetteIndex: 4);

      expect(payload.title, 'About older messages');
      expect(payload.topSpacing, 16);
      expect(
        payload.bodyText,
        'This report only reflects the messages stored on this Mac.\n\nIf you expected to see older messages, they may exist on another device or in iCloud but are not present here.',
      );
      expect(payload.footnote, isNull);
    });
  });
}
