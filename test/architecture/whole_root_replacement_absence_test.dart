import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/onboarding/application/start_fresh_artifact_policy.dart';

void main() {
  test('runtime exposes no whole-root replacement capability', () async {
    const forbiddenSymbols = <String>[
      'CompleteInstallationEraseService',
      'CompleteInstallationEraseStore',
      'FileSystemCompleteInstallationEraseStore',
      'CompleteInstallationEraseRequested',
      'ArchiveAccessMode',
      'completeEraseOnly',
      'completeInstallationErase',
      'relaunchAfterArchiveReplacement',
      'eraseOwnedState',
      'installVirginIdentity',
    ];

    final violations = <String>[];
    await for (final entity in Directory('lib').list(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final source = await entity.readAsString();
      for (final symbol in forbiddenSymbols) {
        if (source.contains(symbol)) {
          violations.add('${entity.path}: $symbol');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'No production API may reconstruct the retired active-root '
          'replacement capability.',
    );
  });

  test('Start Fresh remains an enumerated preservation-safe reset', () {
    final policies = <String, StartFreshArtifactAction>{
      for (final policy in startFreshRootArtifactPolicies)
        policy.relativePath: policy.action,
    };

    expect(policies['attachment_archive'], StartFreshArtifactAction.preserve);
    expect(policies['application_logs'], StartFreshArtifactAction.preserve);
    expect(
      policies['.messagelens-archive.json'],
      StartFreshArtifactAction.preserve,
    );

    final serviceSource = File(
      'lib/essentials/onboarding/application/start_fresh_service.dart',
    ).readAsStringSync();
    expect(serviceSource, isNot(contains('complete_installation_erase')));
    expect(serviceSource, isNot(contains('eraseOwnedState')));
    expect(serviceSource, isNot(contains('Directory(')));
  });

  test('legacy compatibility can remove only its obsolete journal', () {
    final source = File(
      'lib/essentials/onboarding/infrastructure/compatibility/'
      'legacy_complete_installation_erase_journal_compatibility.dart',
    ).readAsStringSync();

    expect(source, contains("'.messagelens-complete-installation-erase.json'"));
    expect(source, isNot(contains('recursive: true')));
    expect(source, isNot(contains('createInitialMarker')));
    expect(source, isNot(contains('Uuid')));
    expect(source, isNot(contains('ArchiveMutationCoordinator')));
    expect(source, isNot(contains('relaunch')));
    expect(source, isNot(contains('eraseOwnedState')));
    expect(source, isNot(contains('installVirginIdentity')));
  });

  test('startup cannot resume obsolete destructive transactions', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(
      source,
      contains('LegacyCompleteInstallationEraseJournalCompatibility'),
    );
    expect(source, isNot(contains('eraseOwnedState')));
    expect(source, isNot(contains('installVirginIdentity')));
    expect(source, isNot(contains('relaunchAfterArchiveReplacement')));
  });

  test('checkpoint restore retains absent-destination refusal', () {
    final source = File(
      'lib/essentials/archive_environment/infrastructure/'
      'file_system_archive_checkpoint_service.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('_requireAbsentDestination(restoreRoot);'),
      reason:
          'Offline checkpoint restore must never overwrite an existing root.',
    );
  });
}
