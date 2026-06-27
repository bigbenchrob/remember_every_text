import 'dart:io';

import 'package:path/path.dart' as path;

import '../../../db/database_directory.dart';
import '../../application/derived_message_data_file_store.dart';

final class FilesystemDerivedMessageDataFileStore
    implements DerivedMessageDataFileStore {
  const FilesystemDerivedMessageDataFileStore({String? databaseDirectory})
    : _databaseDirectory = databaseDirectory;

  final String? _databaseDirectory;

  String get databaseDirectory => _databaseDirectory ?? databaseDirectoryPath;

  @override
  bool databaseBaseFileExists(String baseName) {
    return File(path.join(databaseDirectory, baseName)).existsSync();
  }

  @override
  Map<String, bool> databaseExistenceByBaseName(List<String> baseNames) {
    return {
      for (final baseName in baseNames)
        baseName: databaseBaseFileExists(baseName),
    };
  }

  @override
  Future<List<String>> deleteDatabaseBaseFiles(List<String> baseNames) async {
    final deletedFilePaths = <String>[];
    for (final baseName in baseNames) {
      final basePath = path.join(databaseDirectory, baseName);
      for (final filePath in <String>[
        basePath,
        '$basePath-wal',
        '$basePath-shm',
      ]) {
        final file = File(filePath);
        if (file.existsSync()) {
          await file.delete();
          deletedFilePaths.add(filePath);
        }
      }
    }

    return deletedFilePaths;
  }
}
