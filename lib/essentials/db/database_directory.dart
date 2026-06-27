import 'package:path_provider/path_provider.dart';

/// The directory where all application databases are stored.
///
/// Initialized once at app startup via [initDatabaseDirectoryPath].
/// FOR DEVELOPER'S REFERENCE ONLY: path is
/// ~/Library/Application Support/com.bigbenchsoftware.MessageLens/ on macOS.
late final String databaseDirectoryPath;

/// Must be called once in `main()` after `WidgetsFlutterBinding.ensureInitialized()`.
Future<void> initDatabaseDirectoryPath() async {
  final appSupportDir = await getApplicationSupportDirectory();
  databaseDirectoryPath = appSupportDir.path;
}
