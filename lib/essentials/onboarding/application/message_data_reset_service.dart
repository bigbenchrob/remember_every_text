import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart';
import '../../logging/application/app_logger.dart';

part 'message_data_reset_service.g.dart';

abstract interface class MessageDataResetService {
  Future<void> resetDerivedData();

  Future<void> resetAndQuit();
}

final class MessageDataResetServiceImpl implements MessageDataResetService {
  MessageDataResetServiceImpl(this._ref);

  final Ref _ref;

  @override
  Future<void> resetDerivedData() async {
    final logger = _ref.read(appLoggerProvider.notifier);
    logger.warn(
      'Reset Message Data requested',
      source: 'MessageDataResetService',
    );

    _ref.read(dbMaintenanceLockProvider.notifier).begin();
    try {
      await _closeImportDatabase();
      await _closeWorkingDatabase();
      await _deleteDerivedDatabaseFiles();

      _ref.invalidate(sqfliteImportDatabaseProvider);
      _ref.invalidate(driftWorkingDatabaseProvider);
      _ref.read(messageDataVersionProvider.notifier).bump();

      logger.warn(
        'Derived message data reset complete',
        source: 'MessageDataResetService',
        context: {
          'preserved': 'overlay database, preferences, attachment archive',
        },
      );
    } catch (error, stackTrace) {
      logger.error(
        'Reset Message Data failed',
        source: 'MessageDataResetService',
        context: {
          'error': error.toString(),
          'stack': stackTrace.toString().split('\n').take(10).join('\n'),
        },
      );
      rethrow;
    } finally {
      _ref.read(dbMaintenanceLockProvider.notifier).end();
    }
  }

  @override
  Future<void> resetAndQuit() async {
    await resetDerivedData();

    final writer = _ref.read(appLoggerProvider.notifier).writer;
    await writer.close();
    exit(0);
  }

  Future<void> _closeImportDatabase() async {
    try {
      final ledgerDb = await _ref.read(sqfliteImportDatabaseProvider.future);
      await ledgerDb.close();
    } catch (_) {}
  }

  Future<void> _closeWorkingDatabase() async {
    try {
      final workingDb = await _ref.read(driftWorkingDatabaseProvider.future);
      await workingDb.close();
    } catch (_) {}
  }

  Future<void> _deleteDerivedDatabaseFiles() async {
    for (final baseName in <String>['macos_import.db', 'working.db']) {
      final basePath = path.join(databaseDirectoryPath, baseName);
      for (final filePath in <String>[
        basePath,
        '$basePath-wal',
        '$basePath-shm',
      ]) {
        final file = File(filePath);
        if (file.existsSync()) {
          await file.delete();
        }
      }
    }
  }
}

@riverpod
MessageDataResetService messageDataResetService(Ref ref) {
  return MessageDataResetServiceImpl(ref);
}
