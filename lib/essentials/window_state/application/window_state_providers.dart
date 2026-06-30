import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/persistence/window_state_infrastructure_providers.dart';
import 'window_state_service.dart';

part 'window_state_providers.g.dart';

/// Application dependencies - This is the ONLY public service from this feature.
@Riverpod(keepAlive: true)
WindowStateService windowStateService(WindowStateServiceRef ref) {
  return WindowStateService(
    storage: ref.watch(windowStoragePortProvider),
    windowManager: ref.watch(windowManagerPortProvider),
  );
}
