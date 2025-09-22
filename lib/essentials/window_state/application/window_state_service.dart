import '../domain/entities/window_state_entity.dart';
import '../domain/ports/window_manager_port.dart';
import '../domain/ports/window_storage_port.dart';

/// Service to manage window state persistence and restoration
class WindowStateService {
  final WindowStoragePort _storage;
  final WindowManagerPort _windowManager;

  WindowStateService({
    required WindowStoragePort storage,
    required WindowManagerPort windowManager,
  }) : _storage = storage,
       _windowManager = windowManager;

  /// Load the saved window state or return default state
  Future<WindowStateEntity> loadWindowState() async {
    try {
      final state = await _storage.loadWindowState();
      return state ?? WindowStateEntity.defaultState();
    } catch (e) {
      return WindowStateEntity.defaultState();
    }
  }

  /// Save the current window state
  Future<void> saveWindowState(WindowStateEntity state) async {
    try {
      await _storage.saveWindowState(state);
    } catch (e) {
      // Silently fail - window state is not critical
    }
  }

  /// Save sidebar widths while preserving other window state
  Future<void> saveSidebarWidths({
    double? sidebarWidth,
    double? endSidebarWidth,
  }) async {
    try {
      print(
        '🔧 [saveSidebarWidths] Called with: sidebarWidth=$sidebarWidth, endSidebarWidth=$endSidebarWidth',
      );

      // First load the existing state to preserve current sidebar widths
      final existingState = await loadWindowState();
      print(
        '🔧 [saveSidebarWidths] Existing state: sidebar=${existingState.sidebarWidth}, endSidebar=${existingState.endSidebarWidth}',
      );

      // Get current window dimensions
      final frame = await _windowManager.getWindowFrame();
      final isMinimized = await _windowManager.isMinimized();

      // Calculate the final values
      final finalSidebarWidth = sidebarWidth ?? existingState.sidebarWidth;
      final finalEndSidebarWidth =
          endSidebarWidth ?? existingState.endSidebarWidth;
      print(
        '🔧 [saveSidebarWidths] Final values to save: sidebar=$finalSidebarWidth, endSidebar=$finalEndSidebarWidth',
      );

      // Create new state preserving existing sidebar widths unless specified
      final newState = WindowStateEntity(
        width: frame['width'] ?? existingState.width,
        height: frame['height'] ?? existingState.height,
        x: frame['x'] ?? existingState.x,
        y: frame['y'] ?? existingState.y,
        isMinimized: isMinimized,
        sidebarWidth: finalSidebarWidth,
        endSidebarWidth: finalEndSidebarWidth,
      );

      await _storage.saveWindowState(newState);
    } catch (e) {
      // Silently fail - sidebar state is not critical
    }
  }

  /// Apply window state to the actual window
  Future<void> applyWindowState(WindowStateEntity state) async {
    try {
      await _windowManager.setWindowFrame(
        x: state.x,
        y: state.y,
        width: state.width,
        height: state.height,
      );

      if (state.isMinimized) {
        await _windowManager.minimize();
      }
    } catch (e) {
      // Silently fail - window positioning is not critical
    }
  }

  /// Get current window state from the window manager
  Future<WindowStateEntity> getCurrentWindowState({
    double? sidebarWidth,
    double? endSidebarWidth,
  }) async {
    try {
      final frame = await _windowManager.getWindowFrame();
      final isMinimized = await _windowManager.isMinimized();

      return WindowStateEntity(
        width: frame['width'] ?? 1200.0,
        height: frame['height'] ?? 800.0,
        x: frame['x'] ?? 100.0,
        y: frame['y'] ?? 100.0,
        isMinimized: isMinimized,
        sidebarWidth: sidebarWidth ?? 320.0,
        endSidebarWidth: endSidebarWidth ?? 280.0,
      );
    } catch (e) {
      return WindowStateEntity.defaultState();
    }
  }

  /// Save current window state - convenience method for main.dart
  Future<void> saveCurrentWindowState() async {
    try {
      // Load existing state to preserve sidebar widths
      final existingState = await loadWindowState();

      // Get current window dimensions
      final frame = await _windowManager.getWindowFrame();
      final isMinimized = await _windowManager.isMinimized();

      // Create new state preserving sidebar widths from existing state
      final currentState = WindowStateEntity(
        width: frame['width'] ?? existingState.width,
        height: frame['height'] ?? existingState.height,
        x: frame['x'] ?? existingState.x,
        y: frame['y'] ?? existingState.y,
        isMinimized: isMinimized,
        sidebarWidth:
            existingState.sidebarWidth, // Preserve existing sidebar width
        endSidebarWidth: existingState
            .endSidebarWidth, // Preserve existing end sidebar width
      );

      await saveWindowState(currentState);
    } catch (e) {
      // If anything fails, fall back to the old method
      final currentState = await getCurrentWindowState();
      await saveWindowState(currentState);
    }
  }

  /// Restore window state and apply it - convenience method for main.dart
  Future<void> restoreWindowState() async {
    final state = await loadWindowState();
    await applyWindowState(state);
  }
}
