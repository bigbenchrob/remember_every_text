import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../db/feature_level_providers.dart';
import 'application/window_state_service.dart';
import 'domain/ports/window_manager_port.dart';
import 'domain/ports/window_storage_port.dart';
import 'infrastructure/persistence/macos_window_manager.dart';
import 'infrastructure/persistence/overlay_window_storage.dart';

/// Infrastructure dependencies
final _windowStorageProvider = Provider<WindowStoragePort>(
  (ref) => OverlayWindowStorage(
    overlayDb: ref.watch(overlayDatabaseProvider.future),
  ),
);

final _windowManagerProvider = Provider<WindowManagerPort>(
  (ref) => MacosWindowManager(),
);

/// Application dependencies - This is the ONLY export from this feature
final windowStateServiceProvider = Provider<WindowStateService>((ref) {
  return WindowStateService(
    storage: ref.watch(_windowStorageProvider),
    windowManager: ref.watch(_windowManagerProvider),
  );
});
