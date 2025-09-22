import '../entities/window_state_entity.dart';

abstract class WindowStoragePort {
  Future<void> saveWindowState(WindowStateEntity state);

  Future<WindowStateEntity?> loadWindowState();

  Future<void> clearWindowState();
}
