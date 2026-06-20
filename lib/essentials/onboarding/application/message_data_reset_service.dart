import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart';
import '../../logging/feature_level_providers.dart';
import '../../navigation/application/app_navigator_key.dart';
import '../../source_scoped_import/feature_level_providers.dart';
import '../feature_level_providers.dart';
import 'onboarding_environment_report_provider.dart';
import 'onboarding_gate_provider.dart';

part 'message_data_reset_service.g.dart';

const _resetCompletionDialogExitDelay = Duration(milliseconds: 140);

const retiredCleanupDatabaseBaseNames = <String>[
  retiredMacosImportDatabaseFileName,
  retiredWorkingDatabaseFileName,
];

const activeGraphDatabaseBaseNames = <String>[
  sourceScopedImportDatabaseFileName,
  conversationGraphDatabaseFileName,
];

const derivedMessageDataDatabaseBaseNames = <String>[
  ...retiredCleanupDatabaseBaseNames,
  ...activeGraphDatabaseBaseNames,
];

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
        'Closing source-scoped import database before reset',
        source: 'MessageDataResetService',
      );
      await _closeSourceScopedImportDatabase();
      logger.info(
        'Closing source-scoped graph database before reset',
        source: 'MessageDataResetService',
      );
      await _closeConversationGraphDatabase();

      final fileStore = _ref.read(derivedMessageDataFileStoreProvider);
      final deletedFilePaths = await fileStore.deleteDatabaseBaseFiles(
        derivedMessageDataDatabaseBaseNames,
      );
      logger.info(
        'Deleted derived database files',
        source: 'MessageDataResetService',
        context: {
          'deletedCount': deletedFilePaths.length,
          'deletedFiles': deletedFilePaths,
        },
      );

      _ref.invalidate(sourceScopedImportDatabaseProvider);
      _ref.invalidate(driftConversationGraphDatabaseProvider);
      _ref.invalidate(conversationGraphReadinessProvider);
      _ref.invalidate(conversationGraphPopulatedProvider);
      _ref.read(messageDataVersionProvider.notifier).bump();

      final databaseExistsAfterReset = fileStore.databaseExistenceByBaseName(
        derivedMessageDataDatabaseBaseNames,
      );

      logger.info(
        'Invalidated graph database providers and checked retired file cleanup',
        source: 'MessageDataResetService',
        context: {
          'retiredMacosImportDbExistsAfterReset':
              databaseExistsAfterReset[retiredMacosImportDatabaseFileName],
          'retiredWorkingDbExistsAfterReset':
              databaseExistsAfterReset[retiredWorkingDatabaseFileName],
          'sourceScopedImportDbExistsAfterReset':
              databaseExistsAfterReset[sourceScopedImportDatabaseFileName],
          'conversationGraphDbExistsAfterReset':
              databaseExistsAfterReset[conversationGraphDatabaseFileName],
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
        'sourceScopedImportDbExists':
            environmentReport?.sourceScopedImportDatabase.exists,
        'sourceScopedImportDbRowCount':
            environmentReport?.sourceScopedImportDatabase.rowCount,
        'conversationGraphExists': environmentReport?.conversationGraph.exists,
        'conversationGraphRowCount':
            environmentReport?.conversationGraph.rowCount,
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

  Future<void> _closeSourceScopedImportDatabase() async {
    final fileStore = _ref.read(derivedMessageDataFileStoreProvider);
    if (!fileStore.databaseBaseFileExists(sourceScopedImportDatabaseFileName)) {
      return;
    }
    try {
      final ledgerDb = await _ref.read(
        sourceScopedImportDatabaseProvider.future,
      );
      await ledgerDb.close();
    } catch (error, stackTrace) {
      _logResetCloseWarning(
        message: 'Failed to close source-scoped import database before reset',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _closeConversationGraphDatabase() async {
    final fileStore = _ref.read(derivedMessageDataFileStoreProvider);
    if (!fileStore.databaseBaseFileExists(conversationGraphDatabaseFileName)) {
      return;
    }
    try {
      final graphDb = await _ref.read(
        driftConversationGraphDatabaseProvider.future,
      );
      await graphDb.close();
    } catch (error, stackTrace) {
      _logResetCloseWarning(
        message: 'Failed to close conversation graph database before reset',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _logResetCloseWarning({
    required String message,
    required Object error,
    required StackTrace stackTrace,
  }) {
    _ref
        .read(appLoggerProvider.notifier)
        .warn(
          message,
          source: 'MessageDataResetService',
          context: {
            'error': error.toString(),
            'stack': stackTrace.toString().split('\n').take(5).join('\n'),
          },
        );
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
