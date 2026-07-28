import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/archive_access_authority.dart';

part 'archive_access_authority_provider.g.dart';

/// Non-persistent admission signal for infrastructure that can operate without
/// archive access.
///
/// Ordinary persistent consumers must use [archiveAccessAuthorityProvider].
/// This nullable seam exists for facades such as the application logger that
/// can retain in-memory behavior before admission while withholding their
/// persistent writer.
@Riverpod(keepAlive: true)
ArchiveAccessAuthority? admittedArchiveAccessAuthority(Ref ref) => null;

/// Required root capability. The application bootstrap must override this
/// provider's admission source before persistent providers are read.
@Riverpod(keepAlive: true)
ArchiveAccessAuthority archiveAccessAuthority(Ref ref) {
  final authority = ref.watch(admittedArchiveAccessAuthorityProvider);
  if (authority == null) {
    throw StateError(
      'Archive access authority was requested before archive admission.',
    );
  }
  return authority;
}
