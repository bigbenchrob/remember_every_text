import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      expect(payload.title, 'Historical Archives');
      expect(
        payload.bodyText,
        contains('Older Messages folders may contain message records'),
      );
      expect(payload.bodyText, contains('projects them into'));
      expect(payload.bodyText, isNot(contains('migrates them into')));
      expect(payload.knownSources, isEmpty);
      expect(payload.footnote, contains('source-scoped graph'));
      expect(payload.footnote, isNot(contains('real import wiring')));
    });

    test('passes known source summaries into the payload', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const knownSources = [
        HistoricalArchiveSidebarSourceSummary(
          label: 'Archive-2017',
          dateRangeLabel: 'Date range: not yet available',
          messageCountLabel: 'Total messages: 42',
          statusLabel: 'Current status: Preflight complete',
          lastRunSummaryLabel:
              'Estimated new messages: 10 | Estimated duplicates: 32',
          lastImportedLabel: 'Last imported: not recorded yet',
        ),
      ];

      final payload = container
          .read(historicalArchivesSettingsResolverProvider.notifier)
          .resolve(cassetteIndex: 1, knownSources: knownSources);

      expect(payload.knownSources, knownSources);
    });
  });
}
