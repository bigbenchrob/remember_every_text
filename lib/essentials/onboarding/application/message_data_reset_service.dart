import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart';
import '../../logging/application/app_logger.dart';
import '../../navigation/application/app_navigator_key.dart';

part 'message_data_reset_service.g.dart';

abstract interface class MessageDataResetService {
  Future<void> resetDerivedData();

  Future<void> confirmResetAndPrepareReimport();
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
      logger.info(
        'Closing import database before reset',
        source: 'MessageDataResetService',
      );
      await _closeImportDatabase();
      logger.info(
        'Closing working database before reset',
        source: 'MessageDataResetService',
      );
      await _closeWorkingDatabase();

      final deletedFilePaths = await _deleteDerivedDatabaseFiles();
      logger.info(
        'Deleted derived database files',
        source: 'MessageDataResetService',
        context: {
          'deletedCount': deletedFilePaths.length,
          'deletedFiles': deletedFilePaths,
        },
      );

      _ref.invalidate(sqfliteImportDatabaseProvider);
      _ref.invalidate(driftWorkingDatabaseProvider);
      _ref.read(messageDataVersionProvider.notifier).bump();

      logger.info(
        'Invalidated import and working database providers after reset',
        source: 'MessageDataResetService',
      );

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
  Future<void> confirmResetAndPrepareReimport() async {
    final logger = _ref.read(appLoggerProvider.notifier);
    final navigatorContext = appNavigatorKey.currentContext;

    if (navigatorContext == null) {
      logger.error(
        'Reset requested without a navigator context; aborting destructive action',
        source: 'MessageDataResetService',
      );
      return;
    }

    bool shouldProceed;
    try {
      shouldProceed = await _showResetProceedDialog(navigatorContext);
    } catch (error, stackTrace) {
      logger.error(
        'Failed to show reset confirmation dialog',
        source: 'MessageDataResetService',
        context: {
          'error': error.toString(),
          'stack': stackTrace.toString().split('\n').take(10).join('\n'),
        },
      );
      return;
    }

    if (!shouldProceed) {
      logger.warn(
        'Reset Message Data canceled before deletion',
        source: 'MessageDataResetService',
      );
      return;
    }

    await resetDerivedData();

    logger.info(
      'Showing reset completion dialog before onboarding reimport flow',
      source: 'MessageDataResetService',
    );
    try {
      await _showResetCompletionDialog(navigatorContext);
    } catch (error, stackTrace) {
      logger.error(
        'Failed to show reset completion dialog',
        source: 'MessageDataResetService',
        context: {
          'error': error.toString(),
          'stack': stackTrace.toString().split('\n').take(10).join('\n'),
        },
      );
    }
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

  Future<List<String>> _deleteDerivedDatabaseFiles() async {
    final deletedFilePaths = <String>[];
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
          deletedFilePaths.add(filePath);
        }
      }
    }

    return deletedFilePaths;
  }

  Future<bool> _showResetProceedDialog(BuildContext context) async {
    final result = await showMacosAlertDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return MacosAlertDialog(
          appIcon: const FlutterLogo(size: 64),
          title: const Text('Reset MessageLens Databases?'),
          message: const Text(
            'Clicking Proceed will delete the database files belonging to MessageLens but will not touch the original macOS databases. No Messages or Contacts data will be lost; this only returns MessageLens to a clean import state. Your preference settings, including contact favourites, will be preserved. Any recovered image files that were already archived will also be left intact.\n\nClick Proceed to continue or Cancel to abort.',
          ),
          primaryButton: PushButton(
            controlSize: ControlSize.large,
            onPressed: () {
              Navigator.of(dialogContext, rootNavigator: true).pop(true);
            },
            child: const Text('Proceed'),
          ),
          secondaryButton: PushButton(
            controlSize: ControlSize.large,
            onPressed: () {
              Navigator.of(dialogContext, rootNavigator: true).pop(false);
            },
            child: const Text('Cancel'),
          ),
        );
      },
    );

    return result ?? false;
  }

  Future<void> _showResetCompletionDialog(BuildContext context) async {
    await showMacosAlertDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return MacosAlertDialog(
          appIcon: const FlutterLogo(size: 64),
          title: const Text('MessageLens Databases Cleared'),
          message: const Text(
            'Your MessageLens databases have been cleared. You will now be guided through reimporting your data.',
          ),
          primaryButton: PushButton(
            controlSize: ControlSize.large,
            onPressed: () {
              Navigator.of(dialogContext, rootNavigator: true).pop();
            },
            child: const Text('OK'),
          ),
        );
      },
    );
  }
}

@riverpod
MessageDataResetService messageDataResetService(Ref ref) {
  return MessageDataResetServiceImpl(ref);
}
