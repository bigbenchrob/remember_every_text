import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show admittedArchiveAccessAuthorityProvider;
import 'package:remember_this_text/essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;

import '../../../test_support/test_archive_fixture.dart';

void main() {
  test('retains in-memory diagnostics before archive admission', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final logger = container.read(appLoggerProvider.notifier);
    logger.info('pre-admission diagnostic', source: 'Test');

    expect(container.read(appLoggerProvider), hasLength(1));
    expect(() => logger.writer, throwsStateError);
  });

  test('enables persistent logging only inside admitted archive', () async {
    final fixture = await TestArchiveFixture.create(
      prefix: 'messagelens_app_logger_test_',
    );
    final container = ProviderContainer(
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          fixture.authority,
        ),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await Future<void>.delayed(Duration.zero);
      await fixture.dispose();
    });

    final logger = container.read(appLoggerProvider.notifier);

    expect(
      logger.writer.logDir.path,
      fixture.authority.resolvePath('application_logs'),
    );
  });
}
