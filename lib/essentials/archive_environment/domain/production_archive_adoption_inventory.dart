import 'archive_environment.dart';
import 'archive_instance_id.dart';

final class ProductionArchiveInventoryFileRecord {
  const ProductionArchiveInventoryFileRecord({
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

  factory ProductionArchiveInventoryFileRecord.fromJson(
    Map<String, Object?> json,
  ) {
    final relativePath = json['relativePath'];
    final length = json['length'];
    final digest = json['sha256'];
    final isSqliteDatabase = json['isSqliteDatabase'];
    if (relativePath is! String ||
        length is! int ||
        digest is! String ||
        isSqliteDatabase is! bool) {
      throw const FormatException(
        'Invalid production archive inventory file record.',
      );
    }
    return ProductionArchiveInventoryFileRecord(
      relativePath: relativePath,
      length: length,
      sha256Digest: digest,
      isSqliteDatabase: isSqliteDatabase,
    );
  }
}

/// Read-only evidence and marker plan for adopting an archive in place.
///
/// This inventory contains no archive payload and is not a recovery backup.
final class ProductionArchiveAdoptionInventory {
  const ProductionArchiveAdoptionInventory({
    required this.formatVersion,
    required this.inventoryId,
    required this.sourceEnvironment,
    required this.plannedArchiveInstanceId,
    required this.sourceRootPath,
    required this.createdAtUtc,
    required this.files,
  });

  static const currentFormatVersion = 1;

  final int formatVersion;
  final String inventoryId;
  final ArchiveEnvironment sourceEnvironment;
  final ArchiveInstanceId plannedArchiveInstanceId;
  final String sourceRootPath;
  final DateTime createdAtUtc;
  final List<ProductionArchiveInventoryFileRecord> files;

  int get totalBytes =>
      files.fold<int>(0, (total, file) => total + file.length);

  Map<String, Object> toJson() {
    return <String, Object>{
      'formatVersion': formatVersion,
      'inventoryId': inventoryId,
      'sourceEnvironment': sourceEnvironment.serializedName,
      'plannedArchiveInstanceId': plannedArchiveInstanceId.value,
      'sourceRootPath': sourceRootPath,
      'createdAtUtc': createdAtUtc.toUtc().toIso8601String(),
      'files': <Object>[for (final file in files) file.toJson()],
    };
  }

  factory ProductionArchiveAdoptionInventory.fromJson(
    Map<String, Object?> json,
  ) {
    final formatVersion = json['formatVersion'];
    final inventoryId = json['inventoryId'];
    final sourceEnvironment = json['sourceEnvironment'];
    final plannedArchiveInstanceId = json['plannedArchiveInstanceId'];
    final sourceRootPath = json['sourceRootPath'];
    final createdAtUtc = json['createdAtUtc'];
    final files = json['files'];
    if (formatVersion is! int ||
        inventoryId is! String ||
        sourceEnvironment is! String ||
        plannedArchiveInstanceId is! String ||
        sourceRootPath is! String ||
        createdAtUtc is! String ||
        files is! List) {
      throw const FormatException(
        'Invalid production archive adoption inventory.',
      );
    }
    final parsedCreatedAt = DateTime.tryParse(createdAtUtc);
    if (parsedCreatedAt == null || !parsedCreatedAt.isUtc) {
      throw const FormatException(
        'Inventory createdAtUtc must be an ISO-8601 UTC timestamp.',
      );
    }

    return ProductionArchiveAdoptionInventory(
      formatVersion: formatVersion,
      inventoryId: inventoryId,
      sourceEnvironment: ArchiveEnvironment.parse(sourceEnvironment),
      plannedArchiveInstanceId: ArchiveInstanceId(plannedArchiveInstanceId),
      sourceRootPath: sourceRootPath,
      createdAtUtc: parsedCreatedAt,
      files: <ProductionArchiveInventoryFileRecord>[
        for (final file in files)
          if (file is Map)
            ProductionArchiveInventoryFileRecord.fromJson(
              Map<String, Object?>.from(file),
            )
          else
            throw const FormatException('Invalid inventory file entry.'),
      ],
    );
  }
}
