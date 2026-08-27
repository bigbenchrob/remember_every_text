import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/onboarding/application/start_fresh_artifact_policy.dart';

void main() {
  test(
    'complete erase remains distinct from preservation-safe Start Fresh',
    () {
      expect(
        ArchiveMutationOperation.completeInstallationErase,
        isNot(ArchiveMutationOperation.startFresh),
      );
      final policies = {
        for (final policy in startFreshRootArtifactPolicies)
          policy.relativePath: policy.action,
      };
      expect(policies['attachment_archive'], StartFreshArtifactAction.preserve);
      expect(policies['application_logs'], StartFreshArtifactAction.preserve);
      expect(
        policies['.messagelens-archive.json'],
        StartFreshArtifactAction.preserve,
      );
    },
  );

  test('complete erase store has one infrastructure implementation', () async {
    final implementers = <String>[];
    await for (final entity in Directory('lib').list(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final source = await entity.readAsString();
      if (source.contains('implements CompleteInstallationEraseStore')) {
        implementers.add(entity.path);
      }
    }
    expect(
      implementers,
      <String>[
        [
          'lib/essentials/archive_environment/infrastructure/',
          'file_system_complete_installation_erase_store.dart',
        ].join(),
      ],
      reason:
          'Full installation erasure belongs to one exact filesystem '
          'boundary, not feature or UI code.',
    );
  });

  test(
    'ordinary Start Fresh cannot depend on complete erase infrastructure',
    () {
      final source = File(
        'lib/essentials/onboarding/application/start_fresh_service.dart',
      ).readAsStringSync();
      expect(source, isNot(contains('complete_installation_erase')));
      expect(source, isNot(contains('completeInstallationErase')));
    },
  );
}
