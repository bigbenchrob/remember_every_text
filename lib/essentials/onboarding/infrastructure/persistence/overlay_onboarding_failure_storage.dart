import 'dart:convert';

import '../../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../db_importers/domain/entities/db_import_result.dart';
import '../../../db_migrate/domain/entities/db_migration_result.dart';

class PersistedOnboardingImportResult {
  const PersistedOnboardingImportResult({
    required this.result,
    this.recordedAt,
  });

  final DbImportResult result;
  final DateTime? recordedAt;
}

class PersistedOnboardingMigrationResult {
  const PersistedOnboardingMigrationResult({
    required this.result,
    this.recordedAt,
  });

  final DbMigrationResult result;
  final DateTime? recordedAt;
}

class OverlayOnboardingFailureStorage {
  OverlayOnboardingFailureStorage({required Future<OverlayDatabase> overlayDb})
    : _overlayDb = overlayDb;

  static const String _importFailureKey = 'onboarding_last_import_result';
  static const String _migrationFailureKey = 'onboarding_last_migration_result';
  static const String _recordedAtKey = 'recorded_at_utc';

  final Future<OverlayDatabase> _overlayDb;

  Future<DbImportResult?> loadImportResult() async {
    return (await loadImportResultEntry())?.result;
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

      return PersistedOnboardingImportResult(
        recordedAt: _asDateTime(decoded[_recordedAtKey]),
        result: DbImportResult(
          batchId: batchId,
          success: success,
          error: decoded['error'] as String?,
          handlesImported: _asInt(decoded['handles_imported']) ?? 0,
          chatsImported: _asInt(decoded['chats_imported']) ?? 0,
          participantsImported: _asInt(decoded['participants_imported']) ?? 0,
          messagesImported: _asInt(decoded['messages_imported']) ?? 0,
          attachmentsImported: _asInt(decoded['attachments_imported']) ?? 0,
          messageAttachmentsImported:
              _asInt(decoded['message_attachments_imported']) ?? 0,
          reactionsImported: _asInt(decoded['reactions_imported']) ?? 0,
          contactChannelsImported:
              _asInt(decoded['contact_channels_imported']) ?? 0,
          contactsImported: _asInt(decoded['contacts_imported']) ?? 0,
          warnings: _asStringList(decoded['warnings']),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveImportResult(
    DbImportResult result, {
    DateTime? recordedAt,
  }) async {
    final summary = <String, Object?>{
      ...result.toSummaryMap(),
      _recordedAtKey: (recordedAt ?? DateTime.now().toUtc()).toIso8601String(),
    };
    await _writeJsonSetting(_importFailureKey, summary);
  }

  Future<void> clearImportResult() async {
    await _clearSetting(_importFailureKey);
  }

  Future<DbMigrationResult?> loadMigrationResult() async {
    return (await loadMigrationResultEntry())?.result;
  }

  Future<PersistedOnboardingMigrationResult?> loadMigrationResultEntry() async {
    try {
      final overlayDb = await _overlayDb;
      final rawValue = await overlayDb.readOverlaySetting(_migrationFailureKey);
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

      return PersistedOnboardingMigrationResult(
        recordedAt: _asDateTime(decoded[_recordedAtKey]),
        result: DbMigrationResult(
          batchId: batchId,
          success: success,
          error: decoded['error'] as String?,
          identitiesProjected: _asInt(decoded['identities_projected']) ?? 0,
          identityHandleLinksProjected:
              _asInt(decoded['identity_handle_links_projected']) ?? 0,
          chatsProjected: _asInt(decoded['chats_projected']) ?? 0,
          participantsProjected: _asInt(decoded['participants_projected']) ?? 0,
          messagesProjected: _asInt(decoded['messages_projected']) ?? 0,
          attachmentsProjected: _asInt(decoded['attachments_projected']) ?? 0,
          reactionsProjected: _asInt(decoded['reactions_projected']) ?? 0,
          warnings: _asStringList(decoded['warnings']),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveMigrationResult(
    DbMigrationResult result, {
    DateTime? recordedAt,
  }) async {
    final summary = <String, Object?>{
      ...result.toSummaryMap(),
      _recordedAtKey: (recordedAt ?? DateTime.now().toUtc()).toIso8601String(),
    };
    await _writeJsonSetting(_migrationFailureKey, summary);
  }

  Future<void> clearMigrationResult() async {
    await _clearSetting(_migrationFailureKey);
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

  int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value');
  }

  DateTime? _asDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value)?.toUtc();
  }

  List<String> _asStringList(Object? value) {
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }

    return const <String>[];
  }
}
