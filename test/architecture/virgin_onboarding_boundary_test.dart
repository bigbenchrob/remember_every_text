import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Virgin first import cannot reach reset or checkpoint machinery', () {
    final source = _read(
      'lib/essentials/onboarding/application/'
      'virgin_onboarding_import_executor.dart',
    );

    expect(source, contains('VirginOnboardingImportExecutor'));
    expect(source, contains('OnboardingOperationStage.messageDataBuild'));
    expect(source, isNot(contains('MessageDataResetService')));
    expect(source, isNot(contains('messageDataReset')));
    expect(source, isNot(contains('verifiedArchiveCheckpointProvider')));
    expect(source, isNot(contains('archive_adoption')));
  });

  test('installation classification imports no writable provider seams', () {
    final provider = _read(
      'lib/essentials/onboarding/application/'
      'message_lens_installation_state_provider.dart',
    );
    final reader = _read(
      'lib/essentials/onboarding/infrastructure/persistence/'
      'sqlite_message_lens_installation_evidence_reader.dart',
    );

    expect(provider, isNot(contains('onboardingOperationControllerProvider')));
    expect(provider, isNot(contains('overlayDatabaseProvider')));
    expect(provider, isNot(contains('appLoggerProvider')));
    expect(reader, contains('OpenMode.readOnly'));
    expect(reader, contains('PRAGMA query_only = ON'));
    expect(reader, isNot(contains('MigrationStrategy')));
    expect(reader, isNot(contains('openDatabase(')));
  });

  test('classification precedes persistent logging and window restoration', () {
    final source = _read('lib/main.dart');
    final mainSource = source.substring(source.indexOf('void main() async'));
    final classification = mainSource.indexOf(
      'messageLensInstallationStateProvider.future',
    );
    final persistentLogger = mainSource.indexOf('appLoggerProvider.notifier');
    final windowRestore = mainSource.indexOf('restoreWindowState()');

    expect(classification, greaterThanOrEqualTo(0));
    expect(classification, lessThan(persistentLogger));
    expect(classification, lessThan(windowRestore));
    expect(
      source,
      contains('shouldRestorePersistedWindowStateAfterClassification'),
    );
  });
}

String _read(String relativePath) {
  return File('${Directory.current.path}/$relativePath').readAsStringSync();
}
