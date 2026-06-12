import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/full_disk_access.dart';
import 'macos_full_disk_access.dart';

part 'full_disk_access_provider.g.dart';

@riverpod
FullDiskAccess fullDiskAccess(Ref ref) {
  return const MacosFullDiskAccess();
}
