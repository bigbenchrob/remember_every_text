import 'archive_environment.dart';
import 'archive_instance_id.dart';
import 'archive_marker.dart';

final class CompleteInstallationEraseTransaction {
  const CompleteInstallationEraseTransaction({
    required this.formatVersion,
    required this.environment,
    required this.newArchiveInstanceId,
    required this.createdAtUtc,
  });

  static const int currentFormatVersion = 1;

  final int formatVersion;
  final ArchiveEnvironment environment;
  final ArchiveInstanceId newArchiveInstanceId;
  final DateTime createdAtUtc;

  ArchiveMarker get virginMarker => ArchiveMarker(
    formatVersion: ArchiveMarker.currentFormatVersion,
    environment: environment,
    archiveInstanceId: newArchiveInstanceId,
    createdAtUtc: createdAtUtc,
  );

  Map<String, Object> toJson() => {
    'formatVersion': formatVersion,
    'environment': environment.serializedName,
    'newArchiveInstanceId': newArchiveInstanceId.value,
    'createdAtUtc': createdAtUtc.toUtc().toIso8601String(),
  };

  factory CompleteInstallationEraseTransaction.fromJson(
    Map<String, Object?> json,
  ) {
    final formatVersion = json['formatVersion'];
    final environment = json['environment'];
    final newArchiveInstanceId = json['newArchiveInstanceId'];
    final createdAtUtc = json['createdAtUtc'];
    if (formatVersion is! int || formatVersion != currentFormatVersion) {
      throw const FormatException(
        'Complete installation erase transaction version is invalid.',
      );
    }
    if (environment is! String ||
        newArchiveInstanceId is! String ||
        createdAtUtc is! String) {
      throw const FormatException(
        'Complete installation erase transaction is malformed.',
      );
    }
    final parsedCreatedAt = DateTime.tryParse(createdAtUtc);
    if (parsedCreatedAt == null || !parsedCreatedAt.isUtc) {
      throw const FormatException(
        'Complete installation erase transaction time must be UTC.',
      );
    }
    return CompleteInstallationEraseTransaction(
      formatVersion: formatVersion,
      environment: ArchiveEnvironment.parse(environment),
      newArchiveInstanceId: ArchiveInstanceId(newArchiveInstanceId),
      createdAtUtc: parsedCreatedAt,
    );
  }
}
