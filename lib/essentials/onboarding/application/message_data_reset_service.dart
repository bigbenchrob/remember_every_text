import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart';
import '../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../logging/application/app_logger.dart';
import '../../navigation/application/app_navigator_key.dart';
import '../../source_scoped_import/infrastructure/import_database_provider.dart';
import 'onboarding_environment_report_provider.dart';
import 'onboarding_gate_provider.dart';

part 'message_data_reset_service.g.dart';

const _resetCompletionDialogExitDelay = Duration(milliseconds: 140);

const derivedMessageDataDatabaseBaseNames = <String>[
  'macos_import.db',
  'working.db',
  importDatabaseFileName,
  conversationGraphDatabaseFileName,
];

const importLedgerDatabaseBaseNames = <String>[
  'macos_import.db',
  importDatabaseFileName,
];

abstract interface class MessageDataResetService {
  Future<void> resetDerivedData();

  Future<void> clearImportLedgers();

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
        'Closing import databases before reset',
        source: 'MessageDataResetService',
      );
      await _closeImportDatabase();
      await _closeSourceScopedImportDatabase();
      logger.info(
        'Closing projection databases before reset',
        source: 'MessageDataResetService',
      );
      await _closeWorkingDatabase();
      await _closeConversationGraphDatabase();

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
      _ref.invalidate(importDatabaseProvider);
      _ref.invalidate(driftWorkingDatabaseProvider);
      _ref.invalidate(driftConversationGraphDatabaseProvider);
      _ref.invalidate(conversationGraphReadinessProvider);
      _ref.invalidate(conversationGraphPopulatedProvider);
      _ref.read(messageDataVersionProvider.notifier).bump();

      final importDbPath = path.join(databaseDirectoryPath, 'macos_import.db');
      final workingDbPath = path.join(databaseDirectoryPath, 'working.db');
      final sourceScopedImportDbPath = path.join(
        databaseDirectoryPath,
        importDatabaseFileName,
      );
      final conversationGraphDbPath = path.join(
        databaseDirectoryPath,
        conversationGraphDatabaseFileName,
      );

      logger.info(
        'Invalidated import and projection database providers after reset',
        source: 'MessageDataResetService',
        context: {
          'importDbExistsAfterReset': File(importDbPath).existsSync(),
          'workingDbExistsAfterReset': File(workingDbPath).existsSync(),
          'sourceScopedImportDbExistsAfterReset': File(
            sourceScopedImportDbPath,
          ).existsSync(),
          'conversationGraphDbExistsAfterReset': File(
            conversationGraphDbPath,
          ).existsSync(),
        },
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
  Future<void> clearImportLedgers() async {
    final logger = _ref.read(appLoggerProvider.notifier);
    logger.warn(
      'Clearing import ledger databases',
      source: 'MessageDataResetService',
    );

    try {
      await _closeImportDatabase();
      await _closeSourceScopedImportDatabase();

      final deletedFilePaths = await _deleteDatabaseBaseFiles(
        importLedgerDatabaseBaseNames,
      );
      logger.info(
        'Deleted import ledger database files',
        source: 'MessageDataResetService',
        context: {
          'deletedCount': deletedFilePaths.length,
          'deletedFiles': deletedFilePaths,
        },
      );

      _ref.invalidate(sqfliteImportDatabaseProvider);
      _ref.invalidate(importDatabaseProvider);
      _ref.read(messageDataVersionProvider.notifier).bump();
    } catch (error, stackTrace) {
      logger.error(
        'Clear import ledgers failed',
        source: 'MessageDataResetService',
        context: {
          'error': error.toString(),
          'stack': stackTrace.toString().split('\n').take(10).join('\n'),
        },
      );
      rethrow;
    }
  }

  @override
  Future<void> confirmResetAndPrepareReimport() async {
    final logger = _ref.read(appLoggerProvider.notifier);
    final proceedDialogContext = appNavigatorKey.currentContext;

    if (proceedDialogContext == null || !proceedDialogContext.mounted) {
      logger.error(
        'Reset requested without a navigator context; aborting destructive action',
        source: 'MessageDataResetService',
      );
      return;
    }

    bool shouldProceed;
    try {
      shouldProceed = await _showResetProceedDialog(proceedDialogContext);
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

    final onboardingStatusBeforeDialog = _ref.read(onboardingGateProvider);
    final environmentReportAsync = _ref.read(
      onboardingEnvironmentReportProvider,
    );
    final environmentReport = environmentReportAsync.valueOrNull;

    logger.info(
      'Reset flow snapshot before completion dialog',
      source: 'MessageDataResetService',
      context: {
        'onboardingStatus': onboardingStatusBeforeDialog.name,
        'environmentReportLoading': environmentReportAsync.isLoading,
        'environmentState': environmentReport?.state.name,
        'environmentBlocker': environmentReport?.blockerKind.name,
        'hasPopulatedAppDatabases': environmentReport?.hasPopulatedAppDatabases,
        'importDbExists': environmentReport?.importDatabase.exists,
        'importDbRowCount': environmentReport?.importDatabase.rowCount,
        'workingDbExists': environmentReport?.workingDatabase.exists,
        'workingDbRowCount': environmentReport?.workingDatabase.rowCount,
      },
    );

    logger.info(
      'Showing reset completion dialog before onboarding reimport flow',
      source: 'MessageDataResetService',
    );
    final completionDialogContext = appNavigatorKey.currentContext;
    if (completionDialogContext == null || !completionDialogContext.mounted) {
      logger.warn(
        'Reset completion dialog skipped because navigator context is no longer mounted',
        source: 'MessageDataResetService',
      );
    } else {
      try {
        await _showResetCompletionDialog(completionDialogContext);
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

    await Future<void>.delayed(_resetCompletionDialogExitDelay);

    logger.info(
      'Refreshing onboarding environment after message data reset',
      source: 'MessageDataResetService',
    );
    _ref.read(onboardingGateProvider.notifier).refreshEnvironment();
  }

  Future<void> _closeImportDatabase() async {
    if (!_databaseBaseFileExists('macos_import.db')) {
      return;
    }
    try {
      final ledgerDb = await _ref.read(sqfliteImportDatabaseProvider.future);
      await ledgerDb.close();
    } catch (_) {}
  }

  Future<void> _closeWorkingDatabase() async {
    if (!_databaseBaseFileExists('working.db')) {
      return;
    }
    try {
      final workingDb = await _ref.read(driftWorkingDatabaseProvider.future);
      await workingDb.close();
    } catch (_) {}
  }

  Future<void> _closeSourceScopedImportDatabase() async {
    if (!_databaseBaseFileExists(importDatabaseFileName)) {
      return;
    }
    try {
      final ledgerDb = await _ref.read(importDatabaseProvider.future);
      await ledgerDb.close();
    } catch (_) {}
  }

  Future<void> _closeConversationGraphDatabase() async {
    if (!_databaseBaseFileExists(conversationGraphDatabaseFileName)) {
      return;
    }
    try {
      final graphDb = await _ref.read(
        driftConversationGraphDatabaseProvider.future,
      );
      await graphDb.close();
    } catch (_) {}
  }

  bool _databaseBaseFileExists(String baseName) {
    return File(path.join(databaseDirectoryPath, baseName)).existsSync();
  }

  Future<List<String>> _deleteDerivedDatabaseFiles() async {
    return _deleteDatabaseBaseFiles(derivedMessageDataDatabaseBaseNames);
  }

  Future<List<String>> _deleteDatabaseBaseFiles(List<String> baseNames) async {
    final deletedFilePaths = <String>[];
    for (final baseName in baseNames) {
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
