import 'dart:convert';

import '../../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/onboarding_failure_store.dart';
import '../../domain/onboarding_environment_report.dart';

class OverlayOnboardingFailureStorage implements OnboardingFailureStore {
  OverlayOnboardingFailureStorage({
    required Future<OverlayDatabase> overlayDb,
    void Function(String settingKey, Object error, StackTrace stackTrace)?
    onReadFailure,
  }) : _overlayDb = overlayDb,
       _onReadFailure = onReadFailure;

  static const String _importFailureKey = 'onboarding_last_import_result';
  static const String _graphProjectionFailureKey =
      'onboarding_last_graph_projection_result';
  // Keep the historical key readable so existing persisted setup failures
  // survive the graph-projection terminology change.
  static const String _historicalGraphProjectionFailureKey =
      'onboarding_last_migration_result';
  static const String _recordedAtKey = 'recorded_at_utc';

  final Future<OverlayDatabase> _overlayDb;
  final void Function(String settingKey, Object error, StackTrace stackTrace)?
  _onReadFailure;

  @override
  Future<OnboardingPipelineFailure?> loadSourceImportFailure() async {
    return (await loadSourceImportFailureEntry())?.failure;
  }

  @override
  Future<PersistedOnboardingSourceImportFailure?>
  loadSourceImportFailureEntry() async {
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

      return PersistedOnboardingSourceImportFailure(
        recordedAt: _asDateTime(decoded[_recordedAtKey]),
        failure: OnboardingPipelineFailure(
          phase: OnboardingPipelinePhase.import,
          batchId: batchId,
          message: decoded['error'] as String?,
        ),
      );
    } catch (error, stackTrace) {
      _onReadFailure?.call(_importFailureKey, error, stackTrace);
      return null;
    }
  }

  @override
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

  @override
  Future<void> clearSourceImportFailure() async {
    await _clearSetting(_importFailureKey);
  }

  @override
  Future<OnboardingPipelineFailure?> loadGraphProjectionResult() async {
    return (await loadGraphProjectionResultEntry())?.failure;
  }

  @override
  Future<PersistedOnboardingGraphProjectionResult?>
  loadGraphProjectionResultEntry() async {
    return await _loadGraphProjectionResultFromKey(
          _graphProjectionFailureKey,
        ) ??
        await _loadGraphProjectionResultFromKey(
          _historicalGraphProjectionFailureKey,
        );
  }

  @override
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

  @override
  Future<void> clearGraphProjectionResult() async {
    await _clearSetting(_graphProjectionFailureKey);
    await _clearSetting(_historicalGraphProjectionFailureKey);
  }

  Future<PersistedOnboardingGraphProjectionResult?>
  _loadGraphProjectionResultFromKey(String settingKey) async {
    try {
      final overlayDb = await _overlayDb;
      final rawValue = await overlayDb.readOverlaySetting(settingKey);
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
    } catch (error, stackTrace) {
      _onReadFailure?.call(settingKey, error, stackTrace);
      return null;
    }
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
