import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

import '../../db/application/read_only_sql_guard.dart';
import '../domain/archive_checkpoint_exception.dart';
import '../domain/archive_environment.dart';
import '../domain/archive_marker.dart';
import '../domain/production_archive_adoption_inventory.dart';
import 'file_system_archive_marker_store.dart';

/// Creates and verifies read-only evidence for in-place production adoption.
final class FileSystemProductionArchiveAdoptionInventoryService {
  const FileSystemProductionArchiveAdoptionInventoryService();

  static const manifestFileName = '.messagelens-adoption-inventory.json';

  Future<ProductionArchiveAdoptionInventory> create({
    required String sourceRootPath,
    required String inventoryRootPath,
    required ArchiveMarker plannedMarker,
  }) async {
    final sourceRoot = _canonicalDirectoryPath(sourceRootPath);
    final inventoryRoot = _canonicalProspectivePath(inventoryRootPath);
    if (plannedMarker.environment != ArchiveEnvironment.production) {
      throw const ArchiveCheckpointException(
        'A production adoption inventory requires a production marker plan.',
      );
    }
    if (await FileSystemArchiveMarkerStore(rootPath: sourceRoot).read() !=
        null) {
      throw const ArchiveCheckpointException(
        'Production adoption requires an unmarked source archive.',
      );
    }
    _requireSeparateRoots(sourceRoot, inventoryRoot);
    _requireOfflineSource(sourceRoot);
    _requireAbsentDestination(inventoryRoot);

    final inventoryId =
        '${plannedMarker.archiveInstanceId.value}-'
        '${plannedMarker.createdAtUtc.microsecondsSinceEpoch}';
    final temporaryRoot = '$inventoryRoot.partial-$inventoryId';
    final temporaryDirectory = Directory(temporaryRoot);
    await temporaryDirectory.create(recursive: true);

    try {
      final records = await _inventorySource(sourceRoot);
      _requireOfflineSource(sourceRoot);
      final inventory = ProductionArchiveAdoptionInventory(
        formatVersion: ProductionArchiveAdoptionInventory.currentFormatVersion,
        inventoryId: inventoryId,
        sourceEnvironment: plannedMarker.environment,
        plannedArchiveInstanceId: plannedMarker.archiveInstanceId,
        sourceRootPath: sourceRoot,
        createdAtUtc: plannedMarker.createdAtUtc,
        files: List<ProductionArchiveInventoryFileRecord>.unmodifiable(records),
      );
      await File(
        path.join(temporaryRoot, manifestFileName),
      ).writeAsString('${jsonEncode(inventory.toJson())}\n', flush: true);
      await temporaryDirectory.rename(inventoryRoot);
      return inventory;
    } on Object {
      if (temporaryDirectory.existsSync()) {
        await temporaryDirectory.delete(recursive: true);
      }
      rethrow;
    }
  }

  Future<ProductionArchiveAdoptionInventory> read(
    String inventoryRootPath,
  ) async {
    final inventoryRoot = _canonicalDirectoryPath(inventoryRootPath);
    final manifestFile = File(path.join(inventoryRoot, manifestFileName));
    if (!manifestFile.existsSync()) {
      throw const ArchiveCheckpointException(
        'Production archive adoption inventory is missing.',
      );
    }
    try {
      final decoded = jsonDecode(await manifestFile.readAsString());
      if (decoded is! Map) {
        throw const FormatException('Inventory manifest must be an object.');
      }
      final inventory = ProductionArchiveAdoptionInventory.fromJson(
        Map<String, Object?>.from(decoded),
      );
      if (inventory.formatVersion !=
          ProductionArchiveAdoptionInventory.currentFormatVersion) {
        throw const FormatException('Unsupported inventory format version.');
      }
      return inventory;
    } catch (error) {
      throw ArchiveCheckpointException(
        'Production archive adoption inventory could not be decoded: $error',
      );
    }
  }

  Future<bool> inventoryMatchesTarget({
    required String inventoryRootPath,
    required String targetRootPath,
    required bool allowPlannedMarker,
  }) async {
    try {
      final inventory = await read(inventoryRootPath);
      if (inventory.sourceEnvironment != ArchiveEnvironment.production) {
        return false;
      }
      final targetRoot = _canonicalDirectoryPath(targetRootPath);
      if (targetRoot != inventory.sourceRootPath) {
        return false;
      }
      _requireOfflineSource(targetRoot);
      await _verifyTarget(
        rootPath: targetRoot,
        inventory: inventory,
        allowPlannedMarker: allowPlannedMarker,
      );
      return true;
    } on Object {
      return false;
    }
  }

  Future<List<ProductionArchiveInventoryFileRecord>> _inventorySource(
    String rootPath,
  ) async {
    final records = <ProductionArchiveInventoryFileRecord>[];
    for (final file in await _inventoryFiles(rootPath)) {
      final relativePath = path.relative(file.path, from: rootPath);
      if (FileSystemArchiveMarkerStore.bootstrapFileNames.contains(
        relativePath,
      )) {
        continue;
      }
      final isSqliteDatabase = _isSqliteMainDatabase(relativePath);
      if (isSqliteDatabase) {
        _requireHealthySqlite(file.path);
      }
      records.add(
        ProductionArchiveInventoryFileRecord(
          relativePath: relativePath,
          length: await file.length(),
          sha256Digest: await _digestFile(file),
          isSqliteDatabase: isSqliteDatabase,
        ),
      );
    }
    records.sort(
      (left, right) => left.relativePath.compareTo(right.relativePath),
    );
    return records;
  }

  Future<void> _verifyTarget({
    required String rootPath,
    required ProductionArchiveAdoptionInventory inventory,
    required bool allowPlannedMarker,
  }) async {
    final expectedPaths = <String>{};
    for (final record in inventory.files) {
      expectedPaths.add(record.relativePath);
      final file = File(path.join(rootPath, record.relativePath));
      if (!file.existsSync() ||
          await file.length() != record.length ||
          await _digestFile(file) != record.sha256Digest) {
        throw ArchiveCheckpointException(
          'Production archive inventory mismatch: ${record.relativePath}',
        );
      }
      if (record.isSqliteDatabase) {
        _requireHealthySqlite(file.path);
      }
    }

    final actualPaths = <String>{
      for (final file in await _inventoryFiles(rootPath))
        path.relative(file.path, from: rootPath),
    };
    actualPaths.removeAll(FileSystemArchiveMarkerStore.bootstrapFileNames);
    if (allowPlannedMarker) {
      actualPaths.remove(FileSystemArchiveMarkerStore.markerFileName);
    }
    if (actualPaths.length != expectedPaths.length ||
        !actualPaths.containsAll(expectedPaths)) {
      throw const ArchiveCheckpointException(
        'Production archive contains files not described by its inventory.',
      );
    }
  }

  void _requireHealthySqlite(String databasePath) {
    final database = sqlite3.open(databasePath, mode: OpenMode.readOnly);
    try {
      database.execute('PRAGMA query_only = ON;');
      database.execute('PRAGMA busy_timeout = 3000;');
      const sql = 'PRAGMA integrity_check';
      assertReadOnlySql(
        sql,
        boundary: 'Production archive adoption inventory integrity check',
      );
      final rows = database.select(sql);
      if (rows.length != 1 || rows.first.values.first != 'ok') {
        throw ArchiveCheckpointException(
          'SQLite integrity check failed: $databasePath',
        );
      }
    } finally {
      database.dispose();
    }
  }

  Future<List<File>> _inventoryFiles(String rootPath) async {
    final result = <File>[];
    await for (final entity in Directory(
      rootPath,
    ).list(recursive: true, followLinks: false)) {
      final type = FileSystemEntity.typeSync(entity.path, followLinks: false);
      if (type == FileSystemEntityType.link) {
        throw ArchiveCheckpointException(
          'Production archive inventories do not follow symbolic links: '
          '${entity.path}',
        );
      }
      if (type == FileSystemEntityType.file) {
        result.add(File(entity.path));
      }
    }
    result.sort((left, right) => left.path.compareTo(right.path));
    return result;
  }

  String _canonicalDirectoryPath(String value) {
    final normalized = path.normalize(path.absolute(value));
    if (FileSystemEntity.typeSync(normalized, followLinks: false) !=
        FileSystemEntityType.directory) {
      throw ArchiveCheckpointException('Directory does not exist: $normalized');
    }
    return Directory(normalized).resolveSymbolicLinksSync();
  }

  String _canonicalProspectivePath(String value) {
    final normalized = path.normalize(path.absolute(value));
    final parent = Directory(path.dirname(normalized));
    if (!parent.existsSync()) {
      parent.createSync(recursive: true);
    }
    return path.join(
      parent.resolveSymbolicLinksSync(),
      path.basename(normalized),
    );
  }

  void _requireSeparateRoots(String sourceRoot, String inventoryRoot) {
    if (sourceRoot == inventoryRoot ||
        path.isWithin(sourceRoot, inventoryRoot) ||
        path.isWithin(inventoryRoot, sourceRoot)) {
      throw const ArchiveCheckpointException(
        'Archive and inventory roots must be independent.',
      );
    }
  }

  void _requireOfflineSource(String rootPath) {
    final lockPath = path.join(
      rootPath,
      FileSystemArchiveMarkerStore.bootstrapFileNames.first,
    );
    if (File(lockPath).existsSync()) {
      throw const ArchiveCheckpointException(
        'Archive has an active process claim and cannot be inventoried.',
      );
    }
  }

  void _requireAbsentDestination(String rootPath) {
    if (FileSystemEntity.typeSync(rootPath, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw ArchiveCheckpointException(
        'Inventory destination already exists: $rootPath',
      );
    }
  }

  bool _isSqliteMainDatabase(String relativePath) {
    return path.extension(relativePath).toLowerCase() == '.db';
  }

  Future<String> _digestFile(File file) async {
    return (await sha256.bind(file.openRead()).first).toString();
  }
}
