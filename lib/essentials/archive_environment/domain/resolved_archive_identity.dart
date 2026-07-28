import 'archive_build_identity.dart';
import 'archive_environment.dart';
import 'archive_instance_id.dart';

/// Fully validated archive identity, immutable for the process lifetime.
final class ResolvedArchiveIdentity {
  const ResolvedArchiveIdentity({
    required this.environment,
    required this.buildIdentity,
    required this.archiveInstanceId,
    required this.canonicalRootPath,
    required this.bundleIdentifier,
    required this.productName,
  });

  final ArchiveEnvironment environment;
  final ArchiveBuildIdentity buildIdentity;
  final ArchiveInstanceId archiveInstanceId;
  final String canonicalRootPath;
  final String bundleIdentifier;
  final String productName;
}
