import 'archive_environment.dart';
import 'archive_instance_id.dart';

/// Versioned identity marker stored at the root of an admitted archive.
final class ArchiveMarker {
  const ArchiveMarker({
    required this.formatVersion,
    required this.environment,
    required this.archiveInstanceId,
    required this.createdAtUtc,
  });

  static const int currentFormatVersion = 1;

  final int formatVersion;
  final ArchiveEnvironment environment;
  final ArchiveInstanceId archiveInstanceId;
  final DateTime createdAtUtc;

  Map<String, Object> toJson() {
    return <String, Object>{
      'formatVersion': formatVersion,
      'environment': environment.serializedName,
      'archiveInstanceId': archiveInstanceId.value,
      'createdAtUtc': createdAtUtc.toUtc().toIso8601String(),
    };
  }

  factory ArchiveMarker.fromJson(Map<String, Object?> json) {
    final formatVersion = json['formatVersion'];
    final environment = json['environment'];
    final archiveInstanceId = json['archiveInstanceId'];
    final createdAtUtc = json['createdAtUtc'];

    if (formatVersion is! int) {
      throw const FormatException(
        'Archive marker formatVersion must be an integer.',
      );
    }
    if (environment is! String) {
      throw const FormatException(
        'Archive marker environment must be a string.',
      );
    }
    if (archiveInstanceId is! String) {
      throw const FormatException(
        'Archive marker archiveInstanceId must be a string.',
      );
    }
    if (createdAtUtc is! String) {
      throw const FormatException(
        'Archive marker createdAtUtc must be a string.',
      );
    }

    final parsedCreatedAt = DateTime.tryParse(createdAtUtc);
    if (parsedCreatedAt == null || !parsedCreatedAt.isUtc) {
      throw const FormatException(
        'Archive marker createdAtUtc must be an ISO-8601 UTC timestamp.',
      );
    }

    return ArchiveMarker(
      formatVersion: formatVersion,
      environment: ArchiveEnvironment.parse(environment),
      archiveInstanceId: ArchiveInstanceId(archiveInstanceId),
      createdAtUtc: parsedCreatedAt,
    );
  }
}
