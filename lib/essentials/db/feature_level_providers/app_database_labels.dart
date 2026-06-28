import '../app_database_files.dart';

final class AppDatabaseLabels {
  const AppDatabaseLabels();

  String get sourceScopedImport =>
      appDatabaseFileName(AppDatabaseFile.sourceScopedImport);

  String get conversationGraph =>
      appDatabaseFileName(AppDatabaseFile.conversationGraph);
}

const appDatabaseLabels = AppDatabaseLabels();
