import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

import '../../db/application/read_only_sql_guard.dart';
import '../application/archive_checkpoint_service.dart';
import '../domain/archive_checkpoint_exception.dart';
import '../domain/archive_checkpoint_manifest.dart';
import '../domain/archive_checkpoint_receipt.dart';
import '../domain/archive_environment.dart';
import '../domain/archive_marker.dart';
import 'file_system_archive_marker_store.dart';

final class FileSystemArchiveCheckpointService
    implements ArchiveCheckpointService {
  const FileSystemArchiveCheckpointService();

  static const manifestFileName = '.messagelens-checkpoint.json';

  @override
  Future<ArchiveCheckpointManifest> createOfflineCheckpoint({
    required String sourceRootPath,
    required String checkpointRootPath,
  }) async {
    final sourceRoot = _canonicalDirectoryPath(sourceRootPath);
    final checkpointRoot = _canonicalProspectivePath(checkpointRootPath);
    final marker = await FileSystemArchiveMarkerStore(
      rootPath: sourceRoot,
    ).read();
    if (marker == null) {
      throw const ArchiveCheckpointException(
        'Checkpoint source does not contain an archive marker.',
      );
    }

    return _createCheckpoint(
      sourceRoot: sourceRoot,
      checkpointRoot: checkpointRoot,
      archiveMarker: marker,
      archiveMarkerIncluded: true,
    );
  }

  /// Checkpoints an offline, unmarked archive before explicit production
  /// adoption. The planned marker identity is recorded in the manifest but is
  /// not written to either the source or checkpoint payload.
  Future<ArchiveCheckpointManifest> createProductionAdoptionCheckpoint({
    required String sourceRootPath,
    required String checkpointRootPath,
    required ArchiveMarker plannedMarker,
  }) async {
    final sourceRoot = _canonicalDirectoryPath(sourceRootPath);
    final checkpointRoot = _canonicalProspectivePath(checkpointRootPath);
    if (plannedMarker.environment != ArchiveEnvironment.production) {
      throw const ArchiveCheckpointException(
        'An adoption checkpoint requires a production marker plan.',
      );
    }
    final existingMarker = await FileSystemArchiveMarkerStore(
      rootPath: sourceRoot,
    ).read();
    if (existingMarker != null) {
      throw const ArchiveCheckpointException(
        'Production adoption requires an unmarked source archive.',
      );
    }

    return _createCheckpoint(
      sourceRoot: sourceRoot,
      checkpointRoot: checkpointRoot,
      archiveMarker: plannedMarker,
      archiveMarkerIncluded: false,
    );
  }

  Future<ArchiveCheckpointManifest> _createCheckpoint({
    required String sourceRoot,
    required String checkpointRoot,
    required ArchiveMarker archiveMarker,
    required bool archiveMarkerIncluded,
  }) async {
    _requireSeparateRoots(sourceRoot, checkpointRoot);
    _requireOfflineSource(sourceRoot);
    _requireAbsentDestination(checkpointRoot);

    final createdAtUtc = DateTime.now().toUtc();
    final checkpointId =
        '${archiveMarker.archiveInstanceId.value}-'
        '${createdAtUtc.microsecondsSinceEpoch}';
    final temporaryRoot = '$checkpointRoot.partial-$checkpointId';
    final temporaryDirectory = Directory(temporaryRoot);
    await temporaryDirectory.create(recursive: true);

    try {
      final sourceFiles = await _inventoryFiles(sourceRoot);
      final records = <ArchiveCheckpointFileRecord>[];
      for (final sourceFile in sourceFiles) {
        final relativePath = path.relative(sourceFile.path, from: sourceRoot);
        if (relativePath ==
            FileSystemArchiveMarkerStore.bootstrapFileNames.first) {
          continue;
        }
        final isSqliteDatabase = _isSqliteMainDatabase(relativePath);
        if (isSqliteDatabase) {
          _requireHealthySqlite(sourceFile.path);
        }
        final destinationFile = File(path.join(temporaryRoot, relativePath));
        await destinationFile.parent.create(recursive: true);
        await sourceFile.copy(destinationFile.path);
        records.add(
          ArchiveCheckpointFileRecord(
            relativePath: relativePath,
            length: await destinationFile.length(),
            sha256Digest: await _digestFile(destinationFile),
            isSqliteDatabase: isSqliteDatabase,
          ),
        );
      }
      records.sort(
        (left, right) => left.relativePath.compareTo(right.relativePath),
      );

      final manifest = ArchiveCheckpointManifest(
        formatVersion: ArchiveCheckpointManifest.currentFormatVersion,
        checkpointId: checkpointId,
        sourceEnvironment: archiveMarker.environment,
        sourceArchiveInstanceId: archiveMarker.archiveInstanceId,
        sourceRootPath: sourceRoot,
        createdAtUtc: createdAtUtc,
        archiveMarkerIncluded: archiveMarkerIncluded,
        files: List<ArchiveCheckpointFileRecord>.unmodifiable(records),
      );
      await File(
        path.join(temporaryRoot, manifestFileName),
      ).writeAsString('${jsonEncode(manifest.toJson())}\n', flush: true);
      await temporaryDirectory.rename(checkpointRoot);
      await _verifyPayload(
        rootPath: checkpointRoot,
        manifest: manifest,
        requireNoAdditionalFiles: false,
      );
      return manifest;
    } on Object {
      if (temporaryDirectory.existsSync()) {
        await temporaryDirectory.delete(recursive: true);
      }
      rethrow;
    }
  }

  @override
  Future<ArchiveCheckpointReceipt> restoreAndVerify({
    required String checkpointRootPath,
    required String disposableRestoreRootPath,
  }) async {
    final checkpointRoot = _canonicalDirectoryPath(checkpointRootPath);
    final restoreRoot = _canonicalProspectivePath(disposableRestoreRootPath);
    _requireSeparateRoots(checkpointRoot, restoreRoot);
    _requireAbsentDestination(restoreRoot);

    final manifestFile = File(path.join(checkpointRoot, manifestFileName));
    final manifest = await _readManifest(manifestFile);
    await _verifyPayload(
      rootPath: checkpointRoot,
      manifest: manifest,
      requireNoAdditionalFiles: false,
    );

    final restoreDirectory = Directory(restoreRoot);
    await restoreDirectory.create(recursive: true);
    try {
      for (final record in manifest.files) {
        final sourceFile = File(path.join(checkpointRoot, record.relativePath));
        final destinationFile = File(
          path.join(restoreRoot, record.relativePath),
        );
        await destinationFile.parent.create(recursive: true);
        await sourceFile.copy(destinationFile.path);
      }
      await _verifyPayload(
        rootPath: restoreRoot,
        manifest: manifest,
        requireNoAdditionalFiles: true,
      );
      final restoredMarker = await FileSystemArchiveMarkerStore(
        rootPath: restoreRoot,
      ).read();
      if (manifest.archiveMarkerIncluded &&
          (restoredMarker == null ||
              restoredMarker.environment != manifest.sourceEnvironment ||
              restoredMarker.archiveInstanceId !=
                  manifest.sourceArchiveInstanceId)) {
        throw const ArchiveCheckpointException(
          'Restored archive identity does not match the checkpoint manifest.',
        );
      }
      if (!manifest.archiveMarkerIncluded && restoredMarker != null) {
        throw const ArchiveCheckpointException(
          'Unmarked adoption restore unexpectedly contains an archive marker.',
        );
      }

      return ArchiveCheckpointReceipt(
        checkpointId: manifest.checkpointId,
        sourceEnvironment: manifest.sourceEnvironment,
        sourceArchiveInstanceId: manifest.sourceArchiveInstanceId,
        sourceRootPath: manifest.sourceRootPath,
        checkpointRootPath: checkpointRoot,
        manifestDigest: await _digestFile(manifestFile),
        verifiedAtUtc: DateTime.now().toUtc(),
      );
    } on Object {
      if (restoreDirectory.existsSync()) {
        await restoreDirectory.delete(recursive: true);
      }
      rethrow;
    }
  }

  @override
  Future<bool> checkpointStillMatchesSource(
    ArchiveCheckpointReceipt receipt,
  ) async {
    try {
      final checkpointRoot = _canonicalDirectoryPath(
        receipt.checkpointRootPath,
      );
      final manifestFile = File(path.join(checkpointRoot, manifestFileName));
      if (await _digestFile(manifestFile) != receipt.manifestDigest) {
        return false;
      }
      final manifest = await _readManifest(manifestFile);
      if (manifest.checkpointId != receipt.checkpointId ||
          manifest.sourceEnvironment != receipt.sourceEnvironment ||
          manifest.sourceArchiveInstanceId != receipt.sourceArchiveInstanceId ||
          manifest.sourceRootPath != receipt.sourceRootPath) {
        return false;
      }
      await _verifyPayload(
        rootPath: receipt.sourceRootPath,
        manifest: manifest,
        requireNoAdditionalFiles: true,
      );
      return true;
    } on Object {
      return false;
    }
  }

  Future<ArchiveCheckpointManifest> readAndVerifyCheckpoint(
    String checkpointRootPath,
  ) async {
    final checkpointRoot = _canonicalDirectoryPath(checkpointRootPath);
    final manifest = await _readManifest(
      File(path.join(checkpointRoot, manifestFileName)),
    );
    await _verifyPayload(
      rootPath: checkpointRoot,
      manifest: manifest,
      requireNoAdditionalFiles: false,
    );
    return manifest;
  }

  Future<bool> adoptionCheckpointMatchesTarget({
    required String checkpointRootPath,
    required String targetRootPath,
    required bool allowPlannedMarker,
  }) async {
    try {
      final manifest = await readAndVerifyCheckpoint(checkpointRootPath);
      if (manifest.archiveMarkerIncluded) {
        return false;
      }
      final targetRoot = _canonicalDirectoryPath(targetRootPath);
      _requireOfflineSource(targetRoot);
      await _verifyPayload(
        rootPath: targetRoot,
        manifest: manifest,
        requireNoAdditionalFiles: true,
        ignoredAdditionalPaths: allowPlannedMarker
            ? const <String>{FileSystemArchiveMarkerStore.markerFileName}
            : const <String>{},
      );
      return true;
    } on Object {
      return false;
    }
  }

  Future<ArchiveCheckpointManifest> _readManifest(File file) async {
    if (!file.existsSync()) {
      throw const ArchiveCheckpointException('Checkpoint manifest is missing.');
    }
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) {
        throw const FormatException('Checkpoint manifest must be an object.');
      }
      final manifest = ArchiveCheckpointManifest.fromJson(
        Map<String, Object?>.from(decoded),
      );
      if (manifest.formatVersion !=
          ArchiveCheckpointManifest.currentFormatVersion) {
        throw const FormatException('Unsupported checkpoint format version.');
      }
      return manifest;
    } catch (error) {
      throw ArchiveCheckpointException(
        'Checkpoint manifest could not be decoded: $error',
      );
    }
  }

  Future<void> _verifyPayload({
    required String rootPath,
    required ArchiveCheckpointManifest manifest,
    required bool requireNoAdditionalFiles,
    Set<String> ignoredAdditionalPaths = const <String>{},
  }) async {
    final expectedPaths = <String>{};
    for (final record in manifest.files) {
      expectedPaths.add(record.relativePath);
      final file = File(path.join(rootPath, record.relativePath));
      if (!file.existsSync() ||
          await file.length() != record.length ||
          await _digestFile(file) != record.sha256Digest) {
        throw ArchiveCheckpointException(
          'Checkpoint payload mismatch: ${record.relativePath}',
        );
      }
      if (record.isSqliteDatabase) {
        _requireHealthySqlite(file.path);
      }
    }

    if (requireNoAdditionalFiles) {
      final actualPaths = <String>{
        for (final file in await _inventoryFiles(rootPath))
          path.relative(file.path, from: rootPath),
      };
      actualPaths.remove(manifestFileName);
      actualPaths.removeAll(FileSystemArchiveMarkerStore.bootstrapFileNames);
      actualPaths.removeAll(ignoredAdditionalPaths);
      if (actualPaths.length != expectedPaths.length ||
          !actualPaths.containsAll(expectedPaths)) {
        throw const ArchiveCheckpointException(
          'Restored archive contains files not described by the manifest.',
        );
      }
    }
  }

  void _requireHealthySqlite(String databasePath) {
    final database = sqlite3.open(databasePath, mode: OpenMode.readOnly);
    try {
      database.execute('PRAGMA query_only = ON;');
      database.execute('PRAGMA busy_timeout = 3000;');
      const sql = 'PRAGMA integrity_check';
      assertReadOnlySql(sql, boundary: 'Archive checkpoint integrity check');
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
          'Archive checkpoints do not follow symbolic links: ${entity.path}',
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

  void _requireSeparateRoots(String sourceRoot, String destinationRoot) {
    if (sourceRoot == destinationRoot ||
        path.isWithin(sourceRoot, destinationRoot) ||
        path.isWithin(destinationRoot, sourceRoot)) {
      throw const ArchiveCheckpointException(
        'Checkpoint source and destination roots must be independent.',
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
        'Archive has an active process claim and cannot be checkpointed offline.',
      );
    }
  }

  void _requireAbsentDestination(String rootPath) {
    if (FileSystemEntity.typeSync(rootPath, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw ArchiveCheckpointException(
        'Checkpoint destination already exists: $rootPath',
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
