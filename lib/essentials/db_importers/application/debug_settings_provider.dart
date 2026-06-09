import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'debug_settings_provider.g.dart';

/// Debug settings for retained import database diagnostics.
@riverpod
class ImportDebugSettings extends _$ImportDebugSettings {
  @override
  ImportDebugSettingsState build() => const ImportDebugSettingsState();

  /// Toggle database logging on/off
  void updateDatabaseLogging({required bool enabled}) {
    state = state.copyWith(enableDatabaseLogging: enabled);
  }

  /// Enable database diagnostic logging.
  void enableDatabaseLogging() {
    state = state.copyWith(enableDatabaseLogging: true);
  }

  /// Disable database diagnostic logging.
  void disableDatabaseLogging() {
    state = state.copyWith(enableDatabaseLogging: false);
  }
}

/// State class for retained import database debug settings.
class ImportDebugSettingsState {
  const ImportDebugSettingsState({this.enableDatabaseLogging = false});

  /// Enable detailed database access logging
  final bool enableDatabaseLogging;

  ImportDebugSettingsState copyWith({bool? enableDatabaseLogging}) {
    return ImportDebugSettingsState(
      enableDatabaseLogging:
          enableDatabaseLogging ?? this.enableDatabaseLogging,
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
}
