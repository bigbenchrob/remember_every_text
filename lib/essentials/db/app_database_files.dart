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

const _sourceScopedImportFile = 'macos_import_ss.db';
const _conversationGraphFile = 'working_ss.db';
const _overlayFile = 'user_overlays.db';
const _retiredMacosImportFile = 'macos_import.db';
const _retiredWorkingFile = 'working.db';

String appDatabaseFileName(AppDatabaseFile databaseFile) {
  return switch (databaseFile) {
    AppDatabaseFile.sourceScopedImport => _sourceScopedImportFile,
    AppDatabaseFile.conversationGraph => _conversationGraphFile,
    AppDatabaseFile.overlay => _overlayFile,
    AppDatabaseFile.retiredMacosImport => _retiredMacosImportFile,
    AppDatabaseFile.retiredWorking => _retiredWorkingFile,
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
