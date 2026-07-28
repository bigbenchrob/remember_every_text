import 'archive_environment.dart';
import 'archive_instance_id.dart';

final class ArchiveCheckpointFileRecord {
  const ArchiveCheckpointFileRecord({
    required this.relativePath,
    required this.length,
    required this.sha256Digest,
    required this.isSqliteDatabase,
  });

  final String relativePath;
  final int length;
  final String sha256Digest;
  final bool isSqliteDatabase;

  Map<String, Object> toJson() {
    return <String, Object>{
      'relativePath': relativePath,
      'length': length,
      'sha256': sha256Digest,
      'isSqliteDatabase': isSqliteDatabase,
    };
  }

  factory ArchiveCheckpointFileRecord.fromJson(Map<String, Object?> json) {
    final relativePath = json['relativePath'];
    final length = json['length'];
    final digest = json['sha256'];
    final isSqliteDatabase = json['isSqliteDatabase'];
    if (relativePath is! String ||
        length is! int ||
        digest is! String ||
        isSqliteDatabase is! bool) {
      throw const FormatException('Invalid checkpoint file record.');
    }
    return ArchiveCheckpointFileRecord(
      relativePath: relativePath,
      length: length,
      sha256Digest: digest,
      isSqliteDatabase: isSqliteDatabase,
    );
  }
}

final class ArchiveCheckpointManifest {
  const ArchiveCheckpointManifest({
    required this.formatVersion,
    required this.checkpointId,
    required this.sourceEnvironment,
    required this.sourceArchiveInstanceId,
    required this.sourceRootPath,
    required this.createdAtUtc,
    required this.archiveMarkerIncluded,
    required this.files,
  });

  static const currentFormatVersion = 1;

  final int formatVersion;
  final String checkpointId;
  final ArchiveEnvironment sourceEnvironment;
  final ArchiveInstanceId sourceArchiveInstanceId;
  final String sourceRootPath;
  final DateTime createdAtUtc;
  final bool archiveMarkerIncluded;
  final List<ArchiveCheckpointFileRecord> files;

  int get totalBytes =>
      files.fold<int>(0, (total, file) => total + file.length);

  Map<String, Object> toJson() {
    return <String, Object>{
      'formatVersion': formatVersion,
      'checkpointId': checkpointId,
      'sourceEnvironment': sourceEnvironment.serializedName,
      'sourceArchiveInstanceId': sourceArchiveInstanceId.value,
      'sourceRootPath': sourceRootPath,
      'createdAtUtc': createdAtUtc.toUtc().toIso8601String(),
      'archiveMarkerIncluded': archiveMarkerIncluded,
      'files': <Object>[for (final file in files) file.toJson()],
    };
  }

  factory ArchiveCheckpointManifest.fromJson(Map<String, Object?> json) {
    final formatVersion = json['formatVersion'];
    final checkpointId = json['checkpointId'];
    final sourceEnvironment = json['sourceEnvironment'];
    final sourceArchiveInstanceId = json['sourceArchiveInstanceId'];
    final sourceRootPath = json['sourceRootPath'];
    final createdAtUtc = json['createdAtUtc'];
    final archiveMarkerIncluded = json['archiveMarkerIncluded'] ?? true;
    final files = json['files'];
    if (formatVersion is! int ||
        checkpointId is! String ||
        sourceEnvironment is! String ||
        sourceArchiveInstanceId is! String ||
        sourceRootPath is! String ||
        createdAtUtc is! String ||
        archiveMarkerIncluded is! bool ||
        files is! List) {
      throw const FormatException('Invalid archive checkpoint manifest.');
    }
    final parsedCreatedAt = DateTime.tryParse(createdAtUtc);
    if (parsedCreatedAt == null || !parsedCreatedAt.isUtc) {
      throw const FormatException(
        'Checkpoint createdAtUtc must be an ISO-8601 UTC timestamp.',
      );
    }

    return ArchiveCheckpointManifest(
      formatVersion: formatVersion,
      checkpointId: checkpointId,
      sourceEnvironment: ArchiveEnvironment.parse(sourceEnvironment),
      sourceArchiveInstanceId: ArchiveInstanceId(sourceArchiveInstanceId),
      sourceRootPath: sourceRootPath,
      createdAtUtc: parsedCreatedAt,
      archiveMarkerIncluded: archiveMarkerIncluded,
      files: <ArchiveCheckpointFileRecord>[
        for (final file in files)
          if (file is Map)
            ArchiveCheckpointFileRecord.fromJson(
              Map<String, Object?>.from(file),
            )
          else
            throw const FormatException('Invalid checkpoint file entry.'),
      ],
    );
  }
}
