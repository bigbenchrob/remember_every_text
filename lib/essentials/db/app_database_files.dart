import 'package:path/path.dart' as path;

/// Physical app database files known to the central database layer.
///
/// This is a lifecycle/diagnostic boundary. Ordinary import, graph,
/// repository, and feature code should depend on database providers,
/// repositories, or semantic services instead of physical filenames.
enum AppDatabaseFile {
  sourceScopedImport,
  conversationGraph,
  overlay,
  retiredMacosImport,
  retiredWorking,
}

const _sourceScopedImportDatabaseFileName = 'macos_import_ss.db';
const _conversationGraphDatabaseFileName = 'working_ss.db';
const _overlayDatabaseFileName = 'user_overlays.db';
const _retiredMacosImportDatabaseFileName = 'macos_import.db';
const _retiredWorkingDatabaseFileName = 'working.db';

String appDatabaseFileName(AppDatabaseFile databaseFile) {
  return switch (databaseFile) {
    AppDatabaseFile.sourceScopedImport => _sourceScopedImportDatabaseFileName,
    AppDatabaseFile.conversationGraph => _conversationGraphDatabaseFileName,
    AppDatabaseFile.overlay => _overlayDatabaseFileName,
    AppDatabaseFile.retiredMacosImport => _retiredMacosImportDatabaseFileName,
    AppDatabaseFile.retiredWorking => _retiredWorkingDatabaseFileName,
  };
}

String appDatabasePath(
  AppDatabaseFile databaseFile, {
  required String databaseDirectory,
}) {
  return path.join(databaseDirectory, appDatabaseFileName(databaseFile));
}

List<String> appDatabaseFileNames(Iterable<AppDatabaseFile> databaseFiles) {
  return <String>[
    for (final databaseFile in databaseFiles) appDatabaseFileName(databaseFile),
  ];
}
