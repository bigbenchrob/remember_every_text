import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/actions/message_history_coverage_report_actions_provider.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/message_history_coverage_settings_resolver.dart';

void main() {
  test(
    'retry requests a fresh coverage report through the action boundary',
    () async {
      var requestCount = 0;
      final container = ProviderContainer(
        overrides: [
          messageHistoryCoverageReportProvider.overrideWith((ref) async {
            requestCount += 1;
            return MessageHistoryCoverageReport.reconciled(
              totalCurrentMessages: 1,
              accountedInConversations: 1,
              recoveredUnlinked: 0,
              unaccounted: 0,
              earliestMessageDate: DateTime.utc(2026, 8, 22),
              latestMessageDate: DateTime.utc(2026, 8, 22),
              generatedAt: DateTime.utc(2026, 8, 22),
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      await container.read(messageHistoryCoverageReportProvider.future);
      expect(requestCount, 1);

      container
          .read(messageHistoryCoverageReportActionsProvider.notifier)
          .retry();
      await container.read(messageHistoryCoverageReportProvider.future);

      expect(requestCount, 2);
    },
  );
}
