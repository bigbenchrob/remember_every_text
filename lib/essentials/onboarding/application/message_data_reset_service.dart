import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/app_database_files.dart';
import '../../db/feature_level_providers/db_maintenance_lock_provider.dart'
    show dbMaintenanceLockProvider;
import '../../db/feature_level_providers/message_data_version_provider.dart'
    show messageDataVersionProvider;
import '../../db/feature_level_providers/persistent_database_providers.dart'
    show
        driftConversationGraphDatabaseProvider,
        sourceScopedImportDatabaseProvider;
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../navigation/application/app_navigator_key.dart';
import '../domain/onboarding_environment_report.dart';
import '../domain/onboarding_status.dart';
import 'derived_message_data_file_store.dart';
import 'derived_message_data_file_store_provider.dart';
import 'onboarding_environment_report_provider.dart';
import 'onboarding_gate_provider.dart';

part 'message_data_reset_service.g.dart';

const _resetCompletionDialogExitDelay = Duration(milliseconds: 140);

const retiredDatabaseCleanupFiles = <AppDatabaseFile>[
  AppDatabaseFile.retiredMacosImport,
  AppDatabaseFile.retiredWorking,
];

const activeGraphDerivedDatabaseFiles = <AppDatabaseFile>[
  AppDatabaseFile.sourceScopedImport,
  AppDatabaseFile.conversationGraph,
];

List<String> get retiredDatabaseCleanupBaseNames =>
    appDatabaseFileNames(retiredDatabaseCleanupFiles);

List<String> get activeGraphDerivedDatabaseBaseNames =>
    appDatabaseFileNames(activeGraphDerivedDatabaseFiles);

List<String> get messageDataResetPostCleanupCheckBaseNames =>
    appDatabaseFileNames(<AppDatabaseFile>[
      ...activeGraphDerivedDatabaseFiles,
      ...retiredDatabaseCleanupFiles,
    ]);

abstract interface class MessageDataResetService {
  Future<void> resetDerivedData();

  Future<void> confirmResetAndPrepareReimport();
}

final class MessageDataResetServiceImpl implements MessageDataResetService {
  MessageDataResetServiceImpl(this._dependencies);

  final _MessageDataResetDependencies _dependencies;

  @override
  Future<void> resetDerivedData() async {
    final logger = _dependencies.logger;
    logger.warn(
      'Reset Message Data requested',
      source: 'MessageDataResetService',
    );

    _dependencies.beginMaintenance();
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

      final fileStore = _dependencies.fileStore;
      final deletedActiveGraphFilePaths = await fileStore
          .deleteDatabaseBaseFiles(activeGraphDerivedDatabaseBaseNames);
      logger.info(
        'Deleted active graph derived database files',
        source: 'MessageDataResetService',
        context: {
          'deletedCount': deletedActiveGraphFilePaths.length,
          'deletedFiles': deletedActiveGraphFilePaths,
        },
      );
      final deletedRetiredCleanupFilePaths = await fileStore
          .deleteDatabaseBaseFiles(retiredDatabaseCleanupBaseNames);
      logger.info(
        'Deleted retired database cleanup files',
        source: 'MessageDataResetService',
        context: {
          'deletedCount': deletedRetiredCleanupFilePaths.length,
          'deletedFiles': deletedRetiredCleanupFilePaths,
        },
      );

      _dependencies.invalidateDerivedMessageDataProviders();
      _dependencies.bumpMessageDataVersion();

      final databaseExistsAfterReset = fileStore.databaseExistenceByBaseName(
        messageDataResetPostCleanupCheckBaseNames,
      );

      logger.info(
        'Invalidated graph database providers and checked retired file cleanup',
        source: 'MessageDataResetService',
        context: {
          'retiredMacosImportCleanupFileExistsAfterReset':
              databaseExistsAfterReset[appDatabaseFileName(
                AppDatabaseFile.retiredMacosImport,
              )],
          'retiredWorkingCleanupFileExistsAfterReset':
              databaseExistsAfterReset[appDatabaseFileName(
                AppDatabaseFile.retiredWorking,
              )],
          'sourceScopedImportDbExistsAfterReset':
              databaseExistsAfterReset[appDatabaseFileName(
                AppDatabaseFile.sourceScopedImport,
              )],
          'conversationGraphDbExistsAfterReset':
              databaseExistsAfterReset[appDatabaseFileName(
                AppDatabaseFile.conversationGraph,
              )],
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
      _dependencies.endMaintenance();
    }
  }

  @override
  Future<void> confirmResetAndPrepareReimport() async {
    final logger = _dependencies.logger;
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

    final onboardingStatusBeforeDialog = _dependencies.readOnboardingStatus();
    final environmentReportAsync = _dependencies.readEnvironmentReport();
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
    _dependencies.refreshOnboardingEnvironment();
  }

  Future<void> _closeSourceScopedImportDatabase() async {
    final fileStore = _dependencies.fileStore;
    if (!fileStore.databaseBaseFileExists(
      appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
    )) {
      return;
    }
    try {
      await _dependencies.closeSourceScopedImportDatabase();
    } catch (error, stackTrace) {
      _logResetCloseWarning(
        message: 'Failed to close source-scoped import database before reset',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _closeConversationGraphDatabase() async {
    final fileStore = _dependencies.fileStore;
    if (!fileStore.databaseBaseFileExists(
      appDatabaseFileName(AppDatabaseFile.conversationGraph),
    )) {
      return;
    }
    try {
      await _dependencies.closeConversationGraphDatabase();
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
    _dependencies.logger.warn(
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

final class _MessageDataResetDependencies {
  const _MessageDataResetDependencies({
    required this.logger,
    required this.fileStore,
    required this.beginMaintenance,
    required this.endMaintenance,
    required this.bumpMessageDataVersion,
    required this.invalidateDerivedMessageDataProviders,
    required this.closeSourceScopedImportDatabase,
    required this.closeConversationGraphDatabase,
    required this.readOnboardingStatus,
    required this.readEnvironmentReport,
    required this.refreshOnboardingEnvironment,
  });

  final _MessageDataResetLogSink logger;
  final DerivedMessageDataFileStore fileStore;
  final VoidCallback beginMaintenance;
  final VoidCallback endMaintenance;
  final VoidCallback bumpMessageDataVersion;
  final VoidCallback invalidateDerivedMessageDataProviders;
  final Future<void> Function() closeSourceScopedImportDatabase;
  final Future<void> Function() closeConversationGraphDatabase;
  final OnboardingStatus Function() readOnboardingStatus;
  final AsyncValue<OnboardingEnvironmentReport> Function()
  readEnvironmentReport;
  final VoidCallback refreshOnboardingEnvironment;
}

final class _MessageDataResetLogSink {
  const _MessageDataResetLogSink({
    required this.info,
    required this.warn,
    required this.error,
  });

  final void Function(
    String message, {
    String? source,
    Map<String, dynamic>? context,
  })
  info;

  final void Function(
    String message, {
    String? source,
    Map<String, dynamic>? context,
  })
  warn;

  final void Function(
    String message, {
    String? source,
    Map<String, dynamic>? context,
  })
  error;
}

@riverpod
MessageDataResetService messageDataResetService(Ref ref) {
  final logger = ref.read(appLoggerProvider.notifier);
  return MessageDataResetServiceImpl(
    _MessageDataResetDependencies(
      logger: _MessageDataResetLogSink(
        info: logger.info,
        warn: logger.warn,
        error: logger.error,
      ),
      fileStore: ref.read(derivedMessageDataFileStoreProvider),
      beginMaintenance: ref.read(dbMaintenanceLockProvider.notifier).begin,
      endMaintenance: ref.read(dbMaintenanceLockProvider.notifier).end,
      bumpMessageDataVersion: ref
          .read(messageDataVersionProvider.notifier)
          .bump,
      invalidateDerivedMessageDataProviders: () {
        ref.invalidate(sourceScopedImportDatabaseProvider);
        ref.invalidate(driftConversationGraphDatabaseProvider);
      },
      closeSourceScopedImportDatabase: () async {
        final ledgerDb = await ref.read(
          sourceScopedImportDatabaseProvider.future,
        );
        await ledgerDb.close();
      },
      closeConversationGraphDatabase: () async {
        final graphDb = await ref.read(
          driftConversationGraphDatabaseProvider.future,
        );
        await graphDb.close();
      },
      readOnboardingStatus: () {
        return ref.read(onboardingGateProvider);
      },
      readEnvironmentReport: () {
        return ref.read(onboardingEnvironmentReportProvider);
      },
      refreshOnboardingEnvironment: () {
        ref.read(onboardingGateProvider.notifier).refreshEnvironment();
      },
    ),
  );
}
