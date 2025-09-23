import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'application/window_state_service.dart';
import 'domain/ports/window_manager_port.dart';
import 'domain/ports/window_storage_port.dart';
import 'infrastructure/persistence/macos_window_manager.dart';
import 'infrastructure/persistence/shared_preferences_window_storage.dart';

/// Infrastructure dependencies
final _windowStorageProvider = Provider<WindowStoragePort>(
  (ref) => SharedPreferencesWindowStorage(),
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
