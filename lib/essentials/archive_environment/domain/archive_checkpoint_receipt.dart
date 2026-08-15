import 'archive_access_authority.dart';
import 'archive_environment.dart';
import 'archive_instance_id.dart';

final class ArchiveCheckpointReceipt {
  const ArchiveCheckpointReceipt({
    required this.checkpointId,
    required this.sourceEnvironment,
    required this.sourceArchiveInstanceId,
    required this.sourceRootPath,
    required this.checkpointRootPath,
    required this.manifestDigest,
    required this.verifiedAtUtc,
  });

  final String checkpointId;
  final ArchiveEnvironment sourceEnvironment;
  final ArchiveInstanceId sourceArchiveInstanceId;
  final String sourceRootPath;
  final String checkpointRootPath;
  final String manifestDigest;
  final DateTime verifiedAtUtc;

  bool matches(ArchiveAccessAuthority authority) {
    return sourceEnvironment == authority.identity.environment &&
        sourceArchiveInstanceId == authority.identity.archiveInstanceId &&
        sourceRootPath == authority.rootPath;
  }
}
