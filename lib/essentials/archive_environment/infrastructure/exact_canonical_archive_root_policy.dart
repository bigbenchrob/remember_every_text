import 'package:path/path.dart' as path;

import '../domain/archive_environment.dart';
import '../domain/canonical_archive_root_policy.dart';

/// Exact environment/root policy assembled by trusted bootstrap code.
final class ExactCanonicalArchiveRootPolicy
    implements CanonicalArchiveRootPolicy {
  ExactCanonicalArchiveRootPolicy({
    required Map<ArchiveEnvironment, String> canonicalRoots,
    required this.platformApplicationSupportRoot,
  }) : _canonicalRoots = Map<ArchiveEnvironment, String>.unmodifiable(
         canonicalRoots.map(
           (environment, root) => MapEntry(environment, path.normalize(root)),
         ),
       );

  final Map<ArchiveEnvironment, String> _canonicalRoots;
  final String platformApplicationSupportRoot;

  @override
  bool isCanonicalRoot({
    required ArchiveEnvironment environment,
    required String rootPath,
  }) {
    final expectedRoot = _canonicalRoots[environment];
    return expectedRoot != null && path.normalize(rootPath) == expectedRoot;
  }

  @override
  bool isPlatformApplicationSupportPath(String rootPath) {
    final normalizedApplicationSupport = path.normalize(
      platformApplicationSupportRoot,
    );
    final normalizedRoot = path.normalize(rootPath);
    return normalizedRoot == normalizedApplicationSupport ||
        path.isWithin(normalizedApplicationSupport, normalizedRoot);
  }
}
