import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/onboarding/application/start_fresh_artifact_policy.dart';

void main() {
  test('every canonical app database declares Start Fresh semantics', () {
    final policies = <AppDatabaseFile, StartFreshArtifactPolicy>{
      for (final databaseFile in AppDatabaseFile.values)
        databaseFile: appDatabaseStartFreshPolicy(databaseFile),
    };

    expect(policies, hasLength(AppDatabaseFile.values.length));
    expect(
      policies[AppDatabaseFile.sourceScopedImport]?.action,
      StartFreshArtifactAction.discard,
    );
    expect(
      policies[AppDatabaseFile.conversationGraph]?.action,
      StartFreshArtifactAction.discard,
    );
    expect(
      policies[AppDatabaseFile.overlay]?.action,
      StartFreshArtifactAction.selectivelyReset,
    );
    expect(
      policies[AppDatabaseFile.presence]?.action,
      StartFreshArtifactAction.selectivelyReset,
    );
  });

  test('preservation and identity roots are never discard targets', () {
    final byPath = <String, StartFreshArtifactPolicy>{
      for (final policy in startFreshRootArtifactPolicies)
        policy.relativePath: policy,
    };

    for (final path in <String>[
      'attachment_archive',
      'application_logs',
      '.messagelens-archive.json',
      'MessageLens.instance.lock',
    ]) {
      expect(byPath[path]?.action, StartFreshArtifactAction.preserve);
    }
  });

  test('no external Apple or donor path is a Start Fresh target', () {
    final paths = <String>{
      for (final databaseFile in AppDatabaseFile.values)
        appDatabaseStartFreshPolicy(databaseFile).relativePath,
      for (final policy in startFreshRootArtifactPolicies) policy.relativePath,
    };

    expect(paths, isNot(contains('chat.db')));
    expect(paths.where((path) => path.startsWith('/')), isEmpty);
    expect(paths.where((path) => path.contains('AddressBook')), isEmpty);
  });
}
