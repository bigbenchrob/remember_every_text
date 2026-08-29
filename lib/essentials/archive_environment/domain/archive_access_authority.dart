import 'package:path/path.dart' as path;

import 'resolved_archive_identity.dart';

enum ArchiveAccessMode { full, completeEraseOnly, legacyTesterInstallDetected }

/// Capability granting path access inside one validated archive root.
final class ArchiveAccessAuthority {
  const ArchiveAccessAuthority({
    required this.identity,
    this.mode = ArchiveAccessMode.full,
  });

  final ResolvedArchiveIdentity identity;
  final ArchiveAccessMode mode;

  String get rootPath => identity.canonicalRootPath;

  bool get permitsPersistentArchiveAccess => mode == ArchiveAccessMode.full;

  void requirePersistentArchiveAccess() {
    if (!permitsPersistentArchiveAccess) {
      throw StateError(
        'This restricted startup authority cannot open persistent stores.',
      );
    }
  }

  String resolvePath(String relativePath) {
    if (path.isAbsolute(relativePath)) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        'Archive paths must be relative to the admitted root.',
      );
    }

    final normalizedRoot = path.normalize(rootPath);
    final candidate = path.normalize(path.join(normalizedRoot, relativePath));
    if (candidate != normalizedRoot &&
        !path.isWithin(normalizedRoot, candidate)) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        'Archive path escapes the admitted root.',
      );
    }
    return candidate;
  }
}
