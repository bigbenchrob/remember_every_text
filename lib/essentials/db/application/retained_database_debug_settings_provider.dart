import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'retained_database_debug_settings_provider.g.dart';

/// Debug settings for retained database diagnostics.
@riverpod
class RetainedDatabaseDebugSettings extends _$RetainedDatabaseDebugSettings {
  @override
  RetainedDatabaseDebugSettingsState build() {
    return const RetainedDatabaseDebugSettingsState();
  }

  /// Toggle retained database diagnostic logging on or off.
  void updateDatabaseLogging({required bool enabled}) {
    state = state.copyWith(enableDatabaseLogging: enabled);
  }

  /// Enable retained database diagnostic logging.
  void enableDatabaseLogging() {
    state = state.copyWith(enableDatabaseLogging: true);
  }

  /// Disable retained database diagnostic logging.
  void disableDatabaseLogging() {
    state = state.copyWith(enableDatabaseLogging: false);
  }
}

/// State class for retained database debug settings.
class RetainedDatabaseDebugSettingsState {
  const RetainedDatabaseDebugSettingsState({
    this.enableDatabaseLogging = false,
  });

  /// Enable detailed retained database access logging.
  final bool enableDatabaseLogging;

  RetainedDatabaseDebugSettingsState copyWith({
    bool? enableDatabaseLogging,
  }) {
    return RetainedDatabaseDebugSettingsState(
      enableDatabaseLogging:
          enableDatabaseLogging ?? this.enableDatabaseLogging,
    );
  }
}

/// Extension to provide convenient retained database debug logging methods.
extension RetainedDatabaseDebugSettingsX on RetainedDatabaseDebugSettingsState {
  /// Log retained database operations if enabled.
  void logDatabase(String message) {
    if (enableDatabaseLogging) {
      print('[RETAINED DB DEBUG] $message');
    }
  }
}
