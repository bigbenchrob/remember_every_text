import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart' show overlayDatabaseProvider;
import '../../domain/ports/window_manager_port.dart';
import '../../domain/ports/window_storage_port.dart';
import 'macos_window_manager.dart';
import 'overlay_window_storage.dart';

part 'window_state_infrastructure_providers.g.dart';

@Riverpod(keepAlive: true)
WindowStoragePort windowStoragePort(WindowStoragePortRef ref) {
  return OverlayWindowStorage(
    overlayDb: ref.watch(overlayDatabaseProvider.future),
  );
}

@Riverpod(keepAlive: true)
WindowManagerPort windowManagerPort(WindowManagerPortRef ref) {
  return MacosWindowManager();
}
