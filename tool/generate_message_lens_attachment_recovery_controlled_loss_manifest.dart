import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_environment/domain/archive_marker.dart';
import 'package:sqlite3/sqlite3.dart';

const _manifestSchemaVersion = 1;
const _targetFileCount = 7;
const _minimumPreferredBytes = 128 * 1024;
const _maximumPreferredBytes = 5 * 1024 * 1024;
const _minimumFallbackBytes = 16 * 1024;
const _maximumFallbackBytes = 12 * 1024 * 1024;

Future<void> main(List<String> arguments) async {
  final options = _parseArguments(arguments);
  final receivingRoot = _canonicalDirectory(options.receivingRoot);
  final donorRoot = _canonicalDirectory(options.donorRoot);
  final outputPath = path.normalize(path.absolute(options.outputPath));
  if (receivingRoot == donorRoot) {
    throw StateError('Donor and receiving archive roots must be different.');
  }
  if (path.isWithin(receivingRoot, outputPath) ||
      path.isWithin(donorRoot, outputPath)) {
    throw StateError('The manifest must be written outside both archives.');
  }
  final receivingMarker = _readMarker(receivingRoot);
  if (receivingMarker.environment.serializedName != 'development') {
    throw StateError(
      'Controlled loss requires a development receiving archive.',
    );
  }

  final receiving = _readArchiveEvidence(receivingRoot);
  final donor = _readArchiveEvidence(donorRoot);
  final selected = await _selectCandidates(
    receivingRoot: receivingRoot,
    donorRoot: donorRoot,
    receiving: receiving,
    donor: donor,
  );
  if (selected.length < 5) {
    throw StateError(
      'Only ${selected.length} safe payloads were available; at least 5 are required.',
    );
  }

  final manifest = <String, Object?>{
    'schemaVersion': _manifestSchemaVersion,
    'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
    'purpose': 'MessageLens attachment recovery controlled-loss rehearsal',
    'receivingArchive': <String, Object?>{
      'rootPath': receivingRoot,
      'archiveInstanceId': receivingMarker.archiveInstanceId.value,
      'environment': receivingMarker.environment.serializedName,
    },
    'donorArchive': <String, Object?>{
      'rootPath': donorRoot,
      'archiveInstanceId': _readOptionalMarker(
        donorRoot,
      )?.archiveInstanceId.value,
    },
    'fileCount': selected.length,
    'totalBytes': selected.fold<int>(0, (sum, item) => sum + item.sizeBytes),
    'items': [for (final item in selected) item.toJson()],
  };
  final outputFile = File(outputPath);
  await outputFile.parent.create(recursive: true);
  final temporary = File('$outputPath.tmp');
  await temporary.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(manifest)}\n',
    flush: true,
  );
  await temporary.rename(outputPath);

  stdout.writeln('Controlled-loss manifest: $outputPath');
  stdout.writeln('Files: ${selected.length}');
  stdout.writeln('Bytes: ${manifest['totalBytes']}');
  for (final item in selected) {
    stdout.writeln(
      '${item.messageGuid} / ${item.attachmentRowId}: '
      '${item.sizeBytes} bytes',
    );
  }
}

Future<List<_ManifestItem>> _selectCandidates({
  required String receivingRoot,
  required String donorRoot,
  required _ArchiveEvidence receiving,
  required _ArchiveEvidence donor,
}) async {
  final exact = <_UnverifiedCandidate>[];
  for (final donorEntry in donor.relationships.entries) {
    final donorRelationships = donorEntry.value;
    final receivingRelationships = receiving.relationships[donorEntry.key];
    final donorClaims = donor.payloads[donorEntry.key];
    final receivingClaims = receiving.payloads[donorEntry.key];
    if (donorRelationships.length != 1 ||
        receivingRelationships?.length != 1 ||
        donorClaims?.length != 1 ||
        receivingClaims?.length != 1) {
      continue;
    }
    final donorRelationship = donorRelationships.single;
    final receivingRelationship = receivingRelationships!.single;
    final donorClaim = donorClaims!.single;
    final receivingClaim = receivingClaims!.single;
    if (!_sameRelationship(donorRelationship, receivingRelationship) ||
        !(donorRelationship.mimeType?.startsWith('image/') ?? false) ||
        donorClaim.sizeBytes != receivingClaim.sizeBytes ||
        donorClaim.sizeBytes <= 0) {
      continue;
    }
    final donorPath = _boundedPayloadPath(donorRoot, donorClaim.relativePath);
    final receivingPath = _boundedPayloadPath(
      receivingRoot,
      receivingClaim.relativePath,
    );
    if (donorPath == null || receivingPath == null) {
      continue;
    }
    final donorFile = File(donorPath);
    final receivingFile = File(receivingPath);
    if (!_isRegularFile(donorFile.path) ||
        !_isRegularFile(receivingFile.path) ||
        donorFile.lengthSync() != donorClaim.sizeBytes ||
        receivingFile.lengthSync() != receivingClaim.sizeBytes) {
      continue;
    }
    final donorStoredHash = donorClaim.sha256?.trim().toLowerCase();
    final receivingStoredHash = receivingClaim.sha256?.trim().toLowerCase();
    if (donorStoredHash != null &&
        donorStoredHash.isNotEmpty &&
        receivingStoredHash != null &&
        receivingStoredHash.isNotEmpty &&
        donorStoredHash != receivingStoredHash) {
      continue;
    }
    exact.add(
      _UnverifiedCandidate(
        relationship: donorRelationship,
        donorPath: donorFile.path,
        receivingPath: receivingFile.path,
        sizeBytes: donorClaim.sizeBytes,
        donorStoredHash: donorStoredHash,
        receivingStoredHash: receivingStoredHash,
      ),
    );
  }

  final preferred = exact
      .where(
        (candidate) =>
            candidate.sizeBytes >= _minimumPreferredBytes &&
            candidate.sizeBytes <= _maximumPreferredBytes,
      )
      .toList(growable: false);
  final fallback = exact
      .where(
        (candidate) =>
            candidate.sizeBytes >= _minimumFallbackBytes &&
            candidate.sizeBytes <= _maximumFallbackBytes,
      )
      .toList(growable: false);
  final pool = preferred.length >= 5 ? preferred : fallback;
  pool.sort((left, right) {
    final size = left.sizeBytes.compareTo(right.sizeBytes);
    return size != 0
        ? size
        : left.relationship.key.compareTo(right.relationship.key);
  });

  final selected = <_ManifestItem>[];
  for (final candidate in pool) {
    final donorHash = await _sha256File(File(candidate.donorPath));
    final receivingHash = await _sha256File(File(candidate.receivingPath));
    if (donorHash != receivingHash ||
        !_storedHashMatches(candidate.donorStoredHash, donorHash) ||
        !_storedHashMatches(candidate.receivingStoredHash, receivingHash)) {
      continue;
    }
    selected.add(
      _ManifestItem(
        messageGuid: candidate.relationship.messageGuid,
        attachmentRowId: candidate.relationship.attachmentRowId,
        receivingPath: candidate.receivingPath,
        donorPath: candidate.donorPath,
        sizeBytes: candidate.sizeBytes,
        sha256: donorHash,
      ),
    );
    if (selected.length == _targetFileCount) {
      break;
    }
  }
  return selected;
}

bool _sameRelationship(_Relationship left, _Relationship right) {
  if (left.messageRowId != right.messageRowId ||
      left.attachmentRowId != right.attachmentRowId ||
      left.messageGuid.trim() != right.messageGuid.trim()) {
    return false;
  }
  final leftGuid = left.attachmentGuid?.trim() ?? '';
  final rightGuid = right.attachmentGuid?.trim() ?? '';
  return leftGuid.isEmpty || rightGuid.isEmpty || leftGuid == rightGuid;
}

bool _storedHashMatches(String? storedHash, String actualHash) {
  return storedHash == null || storedHash.isEmpty || storedHash == actualHash;
}

_ArchiveEvidence _readArchiveEvidence(String root) {
  final importDatabase = _openReadOnlyDatabase(
    path.join(root, 'macos_import_ss.db'),
  );
  final overlayDatabase = _openReadOnlyDatabase(
    path.join(root, 'user_overlays.db'),
  );
  try {
    final sourceRows = importDatabase.select('''
      SELECT source_id
      FROM source_registry
      WHERE source_kind = 'live_chat_db'
      ORDER BY source_id
    ''');
    if (sourceRows.length != 1) {
      throw StateError(
        'Archive must contain exactly one live Messages source.',
      );
    }
    final sourceId = sourceRows.single['source_id'] as int;
    final relationshipGroups = <String, List<_Relationship>>{};
    for (final row in importDatabase.select(
      '''
      SELECT
        m.source_rowid AS message_rowid,
        m.guid AS message_guid,
        a.source_rowid AS attachment_rowid,
        a.guid AS attachment_guid,
        a.mime_type
      FROM message_to_attachment AS ma
      JOIN messages AS m ON m.ss_id = ma.message_ss_id
      JOIN attachments AS a ON a.ss_id = ma.attachment_ss_id
      WHERE ma.message_source_id = ?
        AND ma.attachment_source_id = ?
      ORDER BY m.source_rowid, a.source_rowid
      ''',
      <Object?>[sourceId, sourceId],
    )) {
      final relationship = _Relationship(
        messageRowId: row['message_rowid'] as int,
        messageGuid: row['message_guid'] as String,
        attachmentRowId: row['attachment_rowid'] as int,
        attachmentGuid: row['attachment_guid'] as String?,
        mimeType: row['mime_type'] as String?,
      );
      relationshipGroups
          .putIfAbsent(relationship.key, () => <_Relationship>[])
          .add(relationship);
    }

    final payloadGroups = <String, List<_PayloadClaim>>{};
    for (final row in overlayDatabase.select('''
      SELECT message_guid, import_attachment_id, archive_relative_path,
             file_size_bytes, content_hash
      FROM archived_attachments
      ORDER BY message_guid, import_attachment_id
    ''')) {
      final messageGuid = row['message_guid'] as String;
      final attachmentRowId = row['import_attachment_id'] as int;
      final key = _identityKey(messageGuid, attachmentRowId);
      payloadGroups
          .putIfAbsent(key, () => <_PayloadClaim>[])
          .add(
            _PayloadClaim(
              relativePath: row['archive_relative_path'] as String,
              sizeBytes: row['file_size_bytes'] as int,
              sha256: row['content_hash'] as String?,
            ),
          );
    }
    return _ArchiveEvidence(
      relationships: relationshipGroups,
      payloads: payloadGroups,
    );
  } finally {
    importDatabase.dispose();
    overlayDatabase.dispose();
  }
}

Database _openReadOnlyDatabase(String databasePath) {
  if (!_isRegularFile(databasePath)) {
    throw StateError('Required archive database is unavailable: $databasePath');
  }
  final database = sqlite3.open(databasePath, mode: OpenMode.readOnly);
  database.execute('PRAGMA query_only = ON;');
  database.execute('PRAGMA busy_timeout = 3000;');
  return database;
}

ArchiveMarker _readMarker(String root) {
  final marker = _readOptionalMarker(root);
  if (marker == null) {
    throw StateError('Receiving archive has no archive identity marker.');
  }
  return marker;
}

ArchiveMarker? _readOptionalMarker(String root) {
  final markerFile = File(path.join(root, '.messagelens-archive.json'));
  if (!_isRegularFile(markerFile.path)) {
    return null;
  }
  final decoded = jsonDecode(markerFile.readAsStringSync());
  if (decoded is! Map) {
    throw StateError('Archive marker is not a JSON object.');
  }
  return ArchiveMarker.fromJson(Map<String, Object?>.from(decoded));
}

String _canonicalDirectory(String rawPath) {
  final normalized = path.normalize(path.absolute(rawPath));
  if (FileSystemEntity.typeSync(normalized, followLinks: false) !=
      FileSystemEntityType.directory) {
    throw StateError('Archive root is not a regular directory: $normalized');
  }
  return Directory(normalized).resolveSymbolicLinksSync();
}

String? _boundedPayloadPath(String archiveRoot, String relativePath) {
  if (relativePath.isEmpty || path.isAbsolute(relativePath)) {
    return null;
  }
  final payloadRoot = path.normalize(
    path.join(archiveRoot, 'attachment_archive'),
  );
  final candidate = path.normalize(path.join(payloadRoot, relativePath));
  if (!path.isWithin(payloadRoot, candidate) ||
      _containsSymbolicLink(payloadRoot, relativePath)) {
    return null;
  }
  return candidate;
}

bool _containsSymbolicLink(String root, String relativePath) {
  var cursor = root;
  if (FileSystemEntity.typeSync(cursor, followLinks: false) ==
      FileSystemEntityType.link) {
    return true;
  }
  for (final component in path.split(relativePath)) {
    cursor = path.join(cursor, component);
    if (FileSystemEntity.typeSync(cursor, followLinks: false) ==
        FileSystemEntityType.link) {
      return true;
    }
  }
  return false;
}

bool _isRegularFile(String filePath) {
  return FileSystemEntity.typeSync(filePath, followLinks: false) ==
      FileSystemEntityType.file;
}

Future<String> _sha256File(File file) async {
  final digestSink = _DigestSink();
  final conversion = sha256.startChunkedConversion(digestSink);
  await file.openRead().forEach(conversion.add);
  conversion.close();
  return digestSink.value.toString();
}

String _identityKey(String messageGuid, int attachmentRowId) {
  return '${messageGuid.trim()}\u0000$attachmentRowId';
}

_Options _parseArguments(List<String> arguments) {
  String? valueFor(String name) {
    final index = arguments.indexOf(name);
    if (index < 0 || index + 1 >= arguments.length) {
      return null;
    }
    return arguments[index + 1];
  }

  final receivingRoot = valueFor('--receiving-root');
  final donorRoot = valueFor('--donor-root');
  final outputPath = valueFor('--output');
  if (receivingRoot == null || donorRoot == null || outputPath == null) {
    stderr.writeln(
      'Usage: dart run tool/generate_message_lens_attachment_recovery_controlled_loss_manifest.dart '
      '--receiving-root <development archive> --donor-root <intact archive> '
      '--output <manifest.json>',
    );
    exitCode = 64;
    throw const FormatException('Missing required arguments.');
  }
  return _Options(
    receivingRoot: receivingRoot,
    donorRoot: donorRoot,
    outputPath: outputPath,
  );
}

final class _Options {
  const _Options({
    required this.receivingRoot,
    required this.donorRoot,
    required this.outputPath,
  });

  final String receivingRoot;
  final String donorRoot;
  final String outputPath;
}

final class _ArchiveEvidence {
  const _ArchiveEvidence({required this.relationships, required this.payloads});

  final Map<String, List<_Relationship>> relationships;
  final Map<String, List<_PayloadClaim>> payloads;
}

final class _Relationship {
  const _Relationship({
    required this.messageRowId,
    required this.messageGuid,
    required this.attachmentRowId,
    required this.attachmentGuid,
    required this.mimeType,
  });

  final int messageRowId;
  final String messageGuid;
  final int attachmentRowId;
  final String? attachmentGuid;
  final String? mimeType;

  String get key => _identityKey(messageGuid, attachmentRowId);
}

final class _PayloadClaim {
  const _PayloadClaim({
    required this.relativePath,
    required this.sizeBytes,
    required this.sha256,
  });

  final String relativePath;
  final int sizeBytes;
  final String? sha256;
}

final class _UnverifiedCandidate {
  const _UnverifiedCandidate({
    required this.relationship,
    required this.donorPath,
    required this.receivingPath,
    required this.sizeBytes,
    required this.donorStoredHash,
    required this.receivingStoredHash,
  });

  final _Relationship relationship;
  final String donorPath;
  final String receivingPath;
  final int sizeBytes;
  final String? donorStoredHash;
  final String? receivingStoredHash;
}

final class _ManifestItem {
  const _ManifestItem({
    required this.messageGuid,
    required this.attachmentRowId,
    required this.receivingPath,
    required this.donorPath,
    required this.sizeBytes,
    required this.sha256,
  });

  final String messageGuid;
  final int attachmentRowId;
  final String receivingPath;
  final String donorPath;
  final int sizeBytes;
  final String sha256;

  Map<String, Object> toJson() => <String, Object>{
    'canonicalAttachmentIdentity': <String, Object>{
      'messageGuid': messageGuid,
      'importAttachmentId': attachmentRowId,
    },
    'receivingPath': receivingPath,
    'donorPath': donorPath,
    'expectedSizeBytes': sizeBytes,
    'expectedSha256': sha256,
  };
}

final class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) {
    value = data;
  }

  @override
  void close() {}
}
