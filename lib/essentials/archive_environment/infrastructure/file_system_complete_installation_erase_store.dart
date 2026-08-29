import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../application/complete_installation_erase_store.dart';
import '../domain/archive_access_authority.dart';
import '../domain/complete_installation_erase_transaction.dart';
import 'file_system_archive_marker_store.dart';

final class FileSystemCompleteInstallationEraseStore
    implements CompleteInstallationEraseStore {
  const FileSystemCompleteInstallationEraseStore();

  static const transactionFileName =
      '.messagelens-complete-installation-erase.json';
  static const _processLockFileName = 'MessageLens.instance.lock';

  @override
  Future<void> begin({
    required ArchiveAccessAuthority authority,
    required CompleteInstallationEraseTransaction transaction,
  }) async {
    _validateRoot(authority.rootPath);
    await _validateAdmittedRootIdentity(authority);
    final transactionFile = File(authority.resolvePath(transactionFileName));
    if (transactionFile.existsSync()) {
      throw StateError('A complete installation erase is already pending.');
    }
    final temporary = File('${transactionFile.path}.tmp');
    await temporary.writeAsString(
      '${jsonEncode(transaction.toJson())}\n',
      flush: true,
    );
    await temporary.rename(transactionFile.path);
  }

  @override
  Future<void> eraseOwnedState({
    required ArchiveAccessAuthority authority,
  }) async {
    final root = Directory(authority.rootPath);
    _validateRoot(root.path);
    await _rejectUnsafeDescendants(root);
    if (!root.existsSync()) {
      throw StateError('The admitted MessageLens archive root is unavailable.');
    }

    await for (final entity in root.list(followLinks: false)) {
      final name = path.basename(entity.path);
      if (name == _processLockFileName || name == transactionFileName) {
        continue;
      }
      await _deleteWithoutFollowingLinks(entity);
    }
  }

  @override
  Future<void> installVirginIdentity({
    required ArchiveAccessAuthority authority,
    required CompleteInstallationEraseTransaction transaction,
  }) async {
    final markerStore = FileSystemArchiveMarkerStore(
      rootPath: authority.rootPath,
    );
    final existingMarker = await markerStore.read();
    if (existingMarker == null) {
      await markerStore.createInitialMarker(transaction.virginMarker);
    } else if (existingMarker.archiveInstanceId !=
            transaction.newArchiveInstanceId ||
        existingMarker.environment != transaction.environment) {
      throw StateError(
        'A different archive identity appeared during complete erase.',
      );
    }

    final unexpectedNames = <String>[];
    await for (final entity in Directory(
      authority.rootPath,
    ).list(followLinks: false)) {
      final name = path.basename(entity.path);
      if (name != _processLockFileName &&
          name != transactionFileName &&
          name != FileSystemArchiveMarkerStore.markerFileName) {
        unexpectedNames.add(name);
      }
    }
    if (unexpectedNames.isNotEmpty) {
      throw StateError(
        'Virgin archive verification found unexpected artifacts: '
        '${unexpectedNames.join(', ')}',
      );
    }
  }

  @override
  Future<void> complete({required ArchiveAccessAuthority authority}) async {
    final transactionFile = File(authority.resolvePath(transactionFileName));
    if (!transactionFile.existsSync()) {
      throw StateError(
        'Complete installation erase cannot finish without its transaction.',
      );
    }
    await transactionFile.delete();
  }

  @override
  Future<CompleteInstallationEraseTransaction?> readPending({
    required String canonicalRootPath,
  }) async {
    _validateRoot(canonicalRootPath);
    final file = File(path.join(canonicalRootPath, transactionFileName));
    if (!file.existsSync()) {
      return null;
    }
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map) {
      throw const FormatException(
        'Complete installation erase transaction must be an object.',
      );
    }
    return CompleteInstallationEraseTransaction.fromJson(
      Map<String, Object?>.from(decoded),
    );
  }

  void _validateRoot(String rootPath) {
    final normalized = path.normalize(path.absolute(rootPath));
    if (normalized == path.rootPrefix(normalized) ||
        normalized == '/Volumes' ||
        normalized == Platform.environment['HOME'] ||
        path.basename(normalized).isEmpty) {
      throw StateError('Unsafe MessageLens erase root: $normalized');
    }
    if (FileSystemEntity.typeSync(normalized, followLinks: false) ==
        FileSystemEntityType.link) {
      throw StateError('MessageLens erase root may not be a symbolic link.');
    }
  }

  Future<void> _validateAdmittedRootIdentity(
    ArchiveAccessAuthority authority,
  ) async {
    final marker = await FileSystemArchiveMarkerStore(
      rootPath: authority.rootPath,
    ).read();
    if (marker == null) {
      if (authority.mode != ArchiveAccessMode.completeEraseOnly &&
          authority.mode != ArchiveAccessMode.legacyTesterInstallDetected) {
        throw StateError(
          'A fully admitted archive must retain its identity until erase '
          'authorization is durable.',
        );
      }
      return;
    }
    if (marker.environment != authority.identity.environment ||
        marker.archiveInstanceId != authority.identity.archiveInstanceId) {
      throw StateError(
        'Complete erase authority does not match the archive marker.',
      );
    }
  }

  Future<void> _rejectUnsafeDescendants(Directory root) async {
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      final type = FileSystemEntity.typeSync(entity.path, followLinks: false);
      if (type == FileSystemEntityType.link) {
        throw StateError(
          'Complete erase refuses an archive containing symbolic links.',
        );
      }
      final name = path.basename(entity.path);
      if (name == 'chat.db' ||
          (name == FileSystemArchiveMarkerStore.markerFileName &&
              path.dirname(entity.path) != path.normalize(root.path))) {
        throw StateError(
          'Complete erase found source or nested archive data inside the '
          'MessageLens-owned root: ${entity.path}',
        );
      }
    }
  }

  Future<void> _deleteWithoutFollowingLinks(FileSystemEntity entity) async {
    final type = FileSystemEntity.typeSync(entity.path, followLinks: false);
    if (type == FileSystemEntityType.link) {
      throw StateError('Symbolic links cannot be erased: ${entity.path}');
    }
    if (type == FileSystemEntityType.directory) {
      final directory = Directory(entity.path);
      await for (final child in directory.list(followLinks: false)) {
        await _deleteWithoutFollowingLinks(child);
      }
      await directory.delete();
      return;
    }
    if (type == FileSystemEntityType.file) {
      await File(entity.path).delete();
      return;
    }
    throw StateError('Unsupported archive artifact: ${entity.path}');
  }
}
