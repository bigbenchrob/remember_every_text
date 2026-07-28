import 'archive_environment.dart';

/// Supplies environment-specific root truth to the identity validator.
abstract interface class CanonicalArchiveRootPolicy {
  bool isCanonicalRoot({
    required ArchiveEnvironment environment,
    required String rootPath,
  });

  bool isPlatformApplicationSupportPath(String rootPath);
}
