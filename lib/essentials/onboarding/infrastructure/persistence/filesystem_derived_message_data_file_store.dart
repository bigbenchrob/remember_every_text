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
    return _isRegularFile(
      path.join(databaseDirectory, _validatedDatabaseBaseName(baseName)),
    );
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
      final basePath = path.join(
        databaseDirectory,
        _validatedDatabaseBaseName(baseName),
      );
      for (final filePath in <String>[
        basePath,
        '$basePath-wal',
        '$basePath-shm',
      ]) {
        if (_isRegularFile(filePath)) {
          await File(filePath).delete();
          deletedFilePaths.add(filePath);
        }
      }
    }

    return deletedFilePaths;
  }

  String _validatedDatabaseBaseName(String baseName) {
    if (baseName.isEmpty ||
        path.isAbsolute(baseName) ||
        baseName != path.basename(baseName) ||
        baseName.contains(r'\')) {
      throw ArgumentError.value(
        baseName,
        'baseName',
        'must be a database file base name, not a path',
      );
    }
    return baseName;
  }

  bool _isRegularFile(String filePath) {
    return FileSystemEntity.typeSync(filePath, followLinks: false) ==
        FileSystemEntityType.file;
  }
}
