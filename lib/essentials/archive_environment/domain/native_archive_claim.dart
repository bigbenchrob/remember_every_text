import 'archive_build_identity.dart';
import 'archive_environment.dart';

/// Immutable application/archive facts established by native bootstrap.
final class NativeArchiveClaim {
  const NativeArchiveClaim({
    required this.environment,
    required this.buildIdentity,
    required this.bundleIdentifier,
    required this.productName,
    required this.canonicalRootPath,
    required this.productionSignatureIsValid,
  });

  final ArchiveEnvironment environment;
  final ArchiveBuildIdentity buildIdentity;
  final String bundleIdentifier;
  final String productName;
  final String canonicalRootPath;
  final bool productionSignatureIsValid;
}
