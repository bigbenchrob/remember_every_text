import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'legacy tester inspection remains read-only and provider-independent',
    () {
      final source = _read(
        'lib/essentials/archive_environment/infrastructure/'
        'read_only_sqlite_legacy_tester_install_inspector.dart',
      );

      expect(source, contains('OpenMode.readOnly'));
      expect(source, contains('PRAGMA query_only = ON'));
      expect(source, isNot(contains('feature_level_providers')));
      expect(source, isNot(contains('DatabaseProvider')));
      expect(source, isNot(contains('openDatabase(')));
      expect(source, isNot(contains('createInitialMarker')));
      expect(source, isNot(contains('MigrationStrategy')));
      expect(source, isNot(contains('.delete(')));
    },
  );

  test('unmarked production admission requires exact positive proof', () {
    final source = _read(
      'lib/essentials/archive_environment/application/'
      'archive_admission_service.dart',
    );

    expect(source, contains('legacyTesterInstallInspector.inspect(claim)'));
    expect(source, contains('LegacyTesterInstallInspectionKind.notLegacy'));
    expect(
      source,
      contains('LegacyTesterInstallInspectionKind.inspectionFailed'),
    );
    expect(source, contains('ArchiveAccessMode.legacyTesterInstallDetected'));
    expect(
      source,
      isNot(contains('mode: ArchiveAccessMode.completeEraseOnly')),
    );
  });

  test('legacy recognition exposes only its exact authorized deletion', () {
    final source = _read(
      'lib/essentials/onboarding/presentation/'
      'legacy_tester_install_detected_view.dart',
    );
    final startupSource = _read('lib/main.dart');

    expect(source, contains('legacyTesterInstallDeletionActionProvider'));
    expect(source, contains('Delete Old Data and Continue'));
    expect(source, isNot(contains('Complete Erase')));
    expect(source, isNot(contains('Erase MessageLens')));
    expect(source, isNot(contains('Start Fresh')));
    expect(
      startupSource.indexOf('ArchiveAccessMode.legacyTesterInstallDetected'),
      lessThan(
        startupSource.indexOf(
          'ref.watch(messageLensInstallationStateProvider)',
        ),
      ),
    );
  });

  test('legacy deletion service does not open or migrate current stores', () {
    final service = _read(
      'lib/essentials/onboarding/application/'
      'legacy_tester_install_deletion_service.dart',
    );
    final provider = _read(
      'lib/essentials/onboarding/application/'
      'legacy_tester_install_deletion_service_provider.dart',
    );

    for (final source in [service, provider]) {
      expect(source, isNot(contains('working_ss')));
      expect(source, isNot(contains('macos_import_ss')));
      expect(source, isNot(contains('Migration')));
      expect(source, isNot(contains('DatabaseProvider')));
    }
    expect(
      provider,
      contains('ArchiveMutationOperation.legacyTesterInstallDeletion'),
    );
  });
}

String _read(String relativePath) {
  return File('${Directory.current.path}/$relativePath').readAsStringSync();
}
