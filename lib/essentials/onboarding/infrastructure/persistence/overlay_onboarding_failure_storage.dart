import 'dart:convert';

import '../../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../domain/onboarding_environment_report.dart';

class PersistedOnboardingImportResult {
  const PersistedOnboardingImportResult({
    required this.failure,
    this.recordedAt,
  });

  final OnboardingPipelineFailure failure;
  final DateTime? recordedAt;
}

class PersistedOnboardingGraphProjectionResult {
  const PersistedOnboardingGraphProjectionResult({
    required this.failure,
    this.recordedAt,
  });

  final OnboardingPipelineFailure failure;
  final DateTime? recordedAt;
}

class OverlayOnboardingFailureStorage {
  OverlayOnboardingFailureStorage({required Future<OverlayDatabase> overlayDb})
    : _overlayDb = overlayDb;

  static const String _importFailureKey = 'onboarding_last_import_result';
  // Keep the historical key so existing persisted setup failures remain
  // readable after the graph-projection terminology change.
  static const String _graphProjectionFailureKey =
      'onboarding_last_migration_result';
  static const String _recordedAtKey = 'recorded_at_utc';

  final Future<OverlayDatabase> _overlayDb;

  Future<OnboardingPipelineFailure?> loadImportResult() async {
    return (await loadImportResultEntry())?.failure;
  }

  Future<PersistedOnboardingImportResult?> loadImportResultEntry() async {
    try {
      final overlayDb = await _overlayDb;
      final rawValue = await overlayDb.readOverlaySetting(_importFailureKey);
      if (rawValue == null || rawValue.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final batchId = decoded['batch_id'] as int?;
      final success = decoded['success'] as bool?;
      if (batchId == null || success == null) {
        return null;
      }
      if (success) {
        return null;
      }

      return PersistedOnboardingImportResult(
        recordedAt: _asDateTime(decoded[_recordedAtKey]),
        failure: OnboardingPipelineFailure(
          phase: OnboardingPipelinePhase.import,
          batchId: batchId,
          message: decoded['error'] as String?,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveImportFailure({
    required String message,
    int batchId = -1,
    DateTime? recordedAt,
    List<String> warnings = const <String>[],
  }) async {
    final summary = <String, Object?>{
      'batch_id': batchId,
      'success': false,
      'error': message,
      'warnings': warnings,
      _recordedAtKey: (recordedAt ?? DateTime.now().toUtc()).toIso8601String(),
    };
    await _writeJsonSetting(_importFailureKey, summary);
  }

  Future<void> clearImportResult() async {
    await _clearSetting(_importFailureKey);
  }

  Future<OnboardingPipelineFailure?> loadGraphProjectionResult() async {
    return (await loadGraphProjectionResultEntry())?.failure;
  }

  Future<PersistedOnboardingGraphProjectionResult?>
  loadGraphProjectionResultEntry() async {
    try {
      final overlayDb = await _overlayDb;
      final rawValue = await overlayDb.readOverlaySetting(
        _graphProjectionFailureKey,
      );
      if (rawValue == null || rawValue.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final batchId = decoded['batch_id'] as int?;
      final success = decoded['success'] as bool?;
      if (batchId == null || success == null) {
        return null;
      }
      if (success) {
        return null;
      }

      return PersistedOnboardingGraphProjectionResult(
        recordedAt: _asDateTime(decoded[_recordedAtKey]),
        failure: OnboardingPipelineFailure(
          phase: OnboardingPipelinePhase.graphProjection,
          batchId: batchId,
          message: decoded['error'] as String?,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveGraphProjectionFailure({
    required String message,
    int batchId = -1,
    DateTime? recordedAt,
  }) async {
    final summary = <String, Object?>{
      'batch_id': batchId,
      'success': false,
      'error': message,
      _recordedAtKey: (recordedAt ?? DateTime.now().toUtc()).toIso8601String(),
    };
    await _writeJsonSetting(_graphProjectionFailureKey, summary);
  }

  Future<void> clearGraphProjectionResult() async {
    await _clearSetting(_graphProjectionFailureKey);
  }

  Future<void> _writeJsonSetting(
    String settingKey,
    Map<String, Object?> value,
  ) async {
    final overlayDb = await _overlayDb;
    await overlayDb.writeOverlaySetting(
      settingKey: settingKey,
      settingValue: jsonEncode(value),
    );
  }

  Future<void> _clearSetting(String settingKey) async {
    final overlayDb = await _overlayDb;
    await overlayDb.writeOverlaySetting(
      settingKey: settingKey,
      settingValue: '',
    );
  }

  DateTime? _asDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value)?.toUtc();
  }
}
