import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart' show overlayDatabaseProvider;
import '../domain/ports/window_manager_port.dart';
import '../domain/ports/window_storage_port.dart';
import '../infrastructure/persistence/macos_window_manager.dart';
import '../infrastructure/persistence/overlay_window_storage.dart';
import 'window_state_service.dart';

part 'window_state_providers.g.dart';

/// Infrastructure dependencies.
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

/// Application dependencies - This is the ONLY public service from this feature.
@Riverpod(keepAlive: true)
WindowStateService windowStateService(WindowStateServiceRef ref) {
  return WindowStateService(
    storage: ref.watch(windowStoragePortProvider),
    windowManager: ref.watch(windowManagerPortProvider),
  );
}
