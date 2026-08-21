import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/source_scoped_import/domain/historical_archive_source_identity.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/historical_archives_settings_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/historical_archives_settings_resolver.dart';

void main() {
  group('HistoricalArchivesSettingsResolver', () {
    test('returns the historical archives shell payload', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final payload = container
          .read(historicalArchivesSettingsResolverProvider.notifier)
          .resolve(cassetteIndex: 1);

      expect(payload, isA<HistoricalArchivesSettingsCassettePayload>());
      expect(payload.title, isNull);
      expect(
        payload.bodyText,
        'Add older message history to MessageLens without replacing your current data.',
      );
      expect(payload.bodyText, isNot(contains('Messages folders')));
      expect(payload.bodyText, isNot(contains('chat.db')));
      expect(payload.bodyText, contains('without replacing'));
      expect(payload.bodyText, isNot(contains('Choose where')));
      expect(payload.knownSources, isEmpty);
      expect(payload.footnote, isNull);
    });

    test('passes known source summaries into the payload', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final knownSources = [
        HistoricalArchiveSidebarSourceSummary(
          identity: HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
            '/Archives/2017/chat.db',
          ),
          label: 'Archive-2017',
          dateRangeLabel: 'Date range: not yet available',
          messageCountLabel: 'Total messages: 42',
          importedOnLabel: 'Imported on: Apr 29, 2026',
        ),
      ];

      final payload = container
          .read(historicalArchivesSettingsResolverProvider.notifier)
          .resolve(cassetteIndex: 1, knownSources: knownSources);

      expect(payload.knownSources, knownSources);
    });
  });
}
