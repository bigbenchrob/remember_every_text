import '../../db/app_database_files.dart';

enum StartFreshArtifactClassification {
  rebuildableDerivedState,
  userAuthoredState,
  preservationData,
  operationalMetadata,
  archiveIdentity,
  diagnostics,
}

enum StartFreshArtifactAction { discard, preserve, selectivelyReset }

final class StartFreshArtifactPolicy {
  const StartFreshArtifactPolicy({
    required this.relativePath,
    required this.classification,
    required this.action,
  });

  final String relativePath;
  final StartFreshArtifactClassification classification;
  final StartFreshArtifactAction action;
}

StartFreshArtifactPolicy appDatabaseStartFreshPolicy(
  AppDatabaseFile databaseFile,
) {
  return switch (databaseFile) {
    AppDatabaseFile.sourceScopedImport ||
    AppDatabaseFile.conversationGraph ||
    AppDatabaseFile.retiredMacosImport ||
    AppDatabaseFile.retiredWorking => StartFreshArtifactPolicy(
      relativePath: appDatabaseFileName(databaseFile),
      classification: StartFreshArtifactClassification.rebuildableDerivedState,
      action: StartFreshArtifactAction.discard,
    ),
    AppDatabaseFile.overlay => StartFreshArtifactPolicy(
      relativePath: appDatabaseFileName(databaseFile),
      classification: StartFreshArtifactClassification.userAuthoredState,
      action: StartFreshArtifactAction.selectivelyReset,
    ),
    AppDatabaseFile.presence => StartFreshArtifactPolicy(
      relativePath: appDatabaseFileName(databaseFile),
      classification: StartFreshArtifactClassification.operationalMetadata,
      action: StartFreshArtifactAction.selectivelyReset,
    ),
  };
}

const startFreshRootArtifactPolicies = <StartFreshArtifactPolicy>[
  StartFreshArtifactPolicy(
    relativePath: 'attachment_archive',
    classification: StartFreshArtifactClassification.preservationData,
    action: StartFreshArtifactAction.preserve,
  ),
  StartFreshArtifactPolicy(
    relativePath: 'derived_media',
    classification: StartFreshArtifactClassification.rebuildableDerivedState,
    action: StartFreshArtifactAction.preserve,
  ),
  StartFreshArtifactPolicy(
    relativePath: 'application_logs',
    classification: StartFreshArtifactClassification.diagnostics,
    action: StartFreshArtifactAction.preserve,
  ),
  StartFreshArtifactPolicy(
    relativePath: '.messagelens-archive.json',
    classification: StartFreshArtifactClassification.archiveIdentity,
    action: StartFreshArtifactAction.preserve,
  ),
  StartFreshArtifactPolicy(
    relativePath: 'MessageLens.instance.lock',
    classification: StartFreshArtifactClassification.archiveIdentity,
    action: StartFreshArtifactAction.preserve,
  ),
];
