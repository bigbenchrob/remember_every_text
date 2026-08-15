import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../conversation_graph/feature_level_providers.dart'
    show chatDbSourceProbeReaderProvider;
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../infrastructure/system/macos_full_disk_access.dart';
import 'full_disk_access.dart';

part 'full_disk_access_provider.g.dart';

@riverpod
FullDiskAccess fullDiskAccess(Ref ref) {
  final sourceProbe = ref.watch(chatDbSourceProbeReaderProvider);
  return MacosFullDiskAccess(
    messagesDatabaseReadProbe: sourceProbe.readMaxRowId,
    onReadFailure: (error, stackTrace) {
      scheduleMicrotask(
        () => ref
            .read(appLoggerProvider.notifier)
            .warn(
              'FullDiskAccess: Messages database exists but could not be read',
              source: 'MacosFullDiskAccess',
              context: <String, Object?>{
                'error': error.toString(),
                'stackTrace': stackTrace.toString(),
              },
            ),
      );
    },
  );
}
