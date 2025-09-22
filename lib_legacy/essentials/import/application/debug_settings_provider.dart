import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'debug_settings_provider.g.dart';

/// Debug settings for the import system
@riverpod
class ImportDebugSettings extends _$ImportDebugSettings {
  @override
  ImportDebugSettingsState build() => const ImportDebugSettingsState();

  /// Toggle database logging on/off
  void updateDatabaseLogging({required bool enabled}) {
    state = state.copyWith(enableDatabaseLogging: enabled);
  }

  /// Toggle progress logging on/off
  void updateProgressLogging({required bool enabled}) {
    state = state.copyWith(enableProgressLogging: enabled);
  }

  /// Toggle error logging on/off
  void updateErrorLogging({required bool enabled}) {
    state = state.copyWith(enableErrorDetailsLogging: enabled);
  }

  /// Enable all debugging options
  void enableAllDebugging() {
    state = state.copyWith(
      enableDatabaseLogging: true,
      enableProgressLogging: true,
      enableErrorDetailsLogging: true,
    );
  }

  /// Disable all debugging options (except errors, which are recommended)
  void disableAllDebugging() {
    state = state.copyWith(
      enableDatabaseLogging: false,
      enableProgressLogging: false,
      enableErrorDetailsLogging:
          true, // Keep errors enabled for troubleshooting
    );
  }
}

/// State class for import debug settings
class ImportDebugSettingsState {
  const ImportDebugSettingsState({
    this.enableDatabaseLogging = false,
    this.enableProgressLogging = false,
    this.enableErrorDetailsLogging = true, // Keep error details on by default
  });

  /// Enable detailed database access logging
  final bool enableDatabaseLogging;

  /// Enable import progress logging
  final bool enableProgressLogging;

  /// Enable detailed error logging (recommended to keep enabled)
  final bool enableErrorDetailsLogging;

  ImportDebugSettingsState copyWith({
    bool? enableDatabaseLogging,
    bool? enableProgressLogging,
    bool? enableErrorDetailsLogging,
  }) {
    return ImportDebugSettingsState(
      enableDatabaseLogging:
          enableDatabaseLogging ?? this.enableDatabaseLogging,
      enableProgressLogging:
          enableProgressLogging ?? this.enableProgressLogging,
      enableErrorDetailsLogging:
          enableErrorDetailsLogging ?? this.enableErrorDetailsLogging,
    );
  }
}

/// Extension to provide convenient debug logging methods
extension ImportDebugSettingsX on ImportDebugSettingsState {
  /// Log database operations if enabled
  void logDatabase(String message) {
    if (enableDatabaseLogging) {
      print('🔍 [DB DEBUG] $message');
    }
  }

  /// Log progress operations if enabled
  void logProgress(String message) {
    if (enableProgressLogging) {
      print('📈 [PROGRESS DEBUG] $message');
    }
  }

  /// Log error details (always enabled by default for troubleshooting)
  void logError(String message) {
    if (enableErrorDetailsLogging) {
      print('❌ [ERROR DEBUG] $message');
    }
  }
}
