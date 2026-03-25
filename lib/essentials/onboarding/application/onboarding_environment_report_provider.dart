import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../features/address_book_folders/domain/entities/address_book_folder_aggregate.dart';
import '../../../features/address_book_folders/domain/failures/more_failures/failures.dart';
import '../../../features/address_book_folders/feature_level_providers.dart';
import '../../db/feature_level_providers.dart';
import '../../db_importers/domain/entities/db_import_result.dart';
import '../../db_importers/presentation/view_model/db_import_control_provider.dart';
import '../../db_migrate/domain/entities/db_migration_result.dart';
import '../domain/onboarding_environment_report.dart';
import '../infrastructure/persistence/overlay_onboarding_failure_storage.dart';
import 'fda_checker.dart';

part 'onboarding_environment_report_provider.g.dart';

const int _sparseMessagesThreshold = 10;

class OnboardingDevOverridesState {
  const OnboardingDevOverridesState({
    this.simulateFullDiskAccessBlocked = false,
    this.simulateMessagesDatabaseMissing = false,
    this.simulateAddressBookUnavailable = false,
    this.simulateSparseSourceHistory = false,
    this.simulateImportFailure = false,
    this.simulateMigrationFailure = false,
  });

  final bool simulateFullDiskAccessBlocked;
  final bool simulateMessagesDatabaseMissing;
  final bool simulateAddressBookUnavailable;
  final bool simulateSparseSourceHistory;
  final bool simulateImportFailure;
  final bool simulateMigrationFailure;

  bool get hasAnyOverride {
    return simulateFullDiskAccessBlocked ||
        simulateMessagesDatabaseMissing ||
        simulateAddressBookUnavailable ||
        simulateSparseSourceHistory ||
        simulateImportFailure ||
        simulateMigrationFailure;
  }

  OnboardingDevOverridesState copyWith({
    bool? simulateFullDiskAccessBlocked,
    bool? simulateMessagesDatabaseMissing,
    bool? simulateAddressBookUnavailable,
    bool? simulateSparseSourceHistory,
    bool? simulateImportFailure,
    bool? simulateMigrationFailure,
  }) {
    return OnboardingDevOverridesState(
      simulateFullDiskAccessBlocked:
          simulateFullDiskAccessBlocked ?? this.simulateFullDiskAccessBlocked,
      simulateMessagesDatabaseMissing:
          simulateMessagesDatabaseMissing ??
          this.simulateMessagesDatabaseMissing,
      simulateAddressBookUnavailable:
          simulateAddressBookUnavailable ?? this.simulateAddressBookUnavailable,
      simulateSparseSourceHistory:
          simulateSparseSourceHistory ?? this.simulateSparseSourceHistory,
      simulateImportFailure:
          simulateImportFailure ?? this.simulateImportFailure,
      simulateMigrationFailure:
          simulateMigrationFailure ?? this.simulateMigrationFailure,
    );
  }
}

@Riverpod(keepAlive: true)
class OnboardingDevOverrides extends _$OnboardingDevOverrides {
  @override
  OnboardingDevOverridesState build() {
    return const OnboardingDevOverridesState();
  }

  void setFullDiskAccessBlocked({required bool enabled}) {
    state = state.copyWith(simulateFullDiskAccessBlocked: enabled);
  }

  void setMessagesDatabaseMissing({required bool enabled}) {
    state = state.copyWith(simulateMessagesDatabaseMissing: enabled);
  }

  void setAddressBookUnavailable({required bool enabled}) {
    state = state.copyWith(simulateAddressBookUnavailable: enabled);
  }

  void setSparseSourceHistory({required bool enabled}) {
    state = state.copyWith(simulateSparseSourceHistory: enabled);
  }

  void setImportFailure({required bool enabled}) {
    state = state.copyWith(simulateImportFailure: enabled);
  }

  void setMigrationFailure({required bool enabled}) {
    state = state.copyWith(simulateMigrationFailure: enabled);
  }

  void clearAll() {
    state = const OnboardingDevOverridesState();
  }
}

@Riverpod(keepAlive: true)
bool onboardingFullDiskAccess(Ref ref) {
  return const FdaChecker().canReadMessagesDatabase();
}

@Riverpod(keepAlive: true)
String onboardingMessagesDatabasePath(Ref ref) {
  return FdaChecker.chatDbPath;
}

@Riverpod(keepAlive: true)
String onboardingDatabaseDirectoryPath(Ref ref) {
  return databaseDirectoryPath;
}

@Riverpod(keepAlive: true)
Future<OnboardingEnvironmentReport> onboardingEnvironmentReport(Ref ref) async {
  final evaluator = _OnboardingEnvironmentEvaluator(ref);
  return evaluator.evaluate();
}

class _OnboardingEnvironmentEvaluator {
  const _OnboardingEnvironmentEvaluator(this.ref);

  final Ref ref;

  Future<OnboardingEnvironmentReport> evaluate() async {
    final controlState = ref.watch(dbImportControlViewModelProvider);
    final devOverrides = ref.watch(onboardingDevOverridesProvider);
    final failureStorage = OverlayOnboardingFailureStorage(
      overlayDb: ref.watch(overlayDatabaseProvider.future),
    );
    final persistedImportEntry = await failureStorage.loadImportResultEntry();
    final persistedMigrationEntry = await failureStorage
        .loadMigrationResultEntry();
    final persistedImportResult = persistedImportEntry?.result;
    final persistedMigrationResult = persistedMigrationEntry?.result;
    final simulatedPipelineFailureActive =
        devOverrides.simulateImportFailure ||
        devOverrides.simulateMigrationFailure;
    final lastImportResult = devOverrides.simulateImportFailure
        ? const DbImportResult(
            batchId: -1,
            success: false,
            error: 'Simulated import failure from onboarding dev panel',
          )
        : simulatedPipelineFailureActive
        ? null
        : controlState.lastImportResult ?? persistedImportResult;
    final lastMigrationResult = devOverrides.simulateMigrationFailure
        ? const DbMigrationResult(
            batchId: -1,
            success: false,
            error: 'Simulated migration failure from onboarding dev panel',
          )
        : simulatedPipelineFailureActive
        ? null
        : controlState.lastMigrationResult ?? persistedMigrationResult;
    var hasFullDiskAccess = ref.watch(onboardingFullDiskAccessProvider);
    if (devOverrides.simulateFullDiskAccessBlocked) {
      hasFullDiskAccess = false;
    }
    final messagesDatabasePath = ref.watch(
      onboardingMessagesDatabasePathProvider,
    );
    final messagesProbe = devOverrides.simulateMessagesDatabaseMissing
        ? OnboardingDatabaseProbe(
            path: messagesDatabasePath,
            exists: false,
            readable: false,
          )
        : _probeFile(messagesDatabasePath);

    final addressBookProbe = devOverrides.simulateAddressBookUnavailable
        ? const _AddressBookProbeResult(
            probe: null,
            failureMessage:
                'Simulated unavailable Contacts source from onboarding dev panel',
          )
        : _probeAddressBook(
            await ref.watch(futureGetFolderAggregateProvider.future),
          );

    final databaseDirPath = ref.watch(onboardingDatabaseDirectoryPathProvider);
    final importDbPath = p.join(databaseDirPath, 'macos_import.db');
    final workingDbPath = p.join(databaseDirPath, 'working.db');

    final sourceMessageCount = devOverrides.simulateSparseSourceHistory
        ? 0
        : _readSqliteCount(
            dbPath: messagesDatabasePath,
            tableName: 'message',
            queryOnly: true,
          );
    final sourceAttachmentCount = _readSqliteCount(
      dbPath: messagesDatabasePath,
      tableName: 'attachment',
      queryOnly: true,
    );

    final importRowCount = await _readImportMessagesCount(importDbPath);
    final workingRowCount = await _readWorkingMessagesCount(workingDbPath);

    final importProbe = _probeFile(importDbPath, rowCount: importRowCount);
    final workingProbe = _probeFile(workingDbPath, rowCount: workingRowCount);

    final state = _classifyState(
      hasFullDiskAccess: hasFullDiskAccess,
      messagesProbe: messagesProbe,
      addressBookProbe: addressBookProbe,
      sourceMessageCount: sourceMessageCount,
      forceImportFailure: devOverrides.simulateImportFailure,
      forceMigrationFailure: devOverrides.simulateMigrationFailure,
      lastImportSucceeded: lastImportResult?.success,
      lastMigrationSucceeded: lastMigrationResult?.success,
      importProbe: importProbe,
      workingProbe: workingProbe,
    );

    final blockerKind = _classifyBlocker(
      state: state,
      hasFullDiskAccess: hasFullDiskAccess,
      messagesProbe: messagesProbe,
      addressBookProbe: addressBookProbe,
      sourceMessageCount: sourceMessageCount,
      forceImportFailure: devOverrides.simulateImportFailure,
      forceMigrationFailure: devOverrides.simulateMigrationFailure,
      lastImportSucceeded: lastImportResult?.success,
      lastMigrationSucceeded: lastMigrationResult?.success,
      importProbe: importProbe,
      workingProbe: workingProbe,
    );

    final syncPlausibility = _classifySyncPlausibility(
      hasFullDiskAccess: hasFullDiskAccess,
      sourceMessageCount: sourceMessageCount,
    );

    return OnboardingEnvironmentReport(
      state: state,
      blockerKind: blockerKind,
      syncPlausibility: syncPlausibility,
      messagesDatabase: messagesProbe.copyWith(rowCount: sourceMessageCount),
      addressBookDatabase: addressBookProbe.probe,
      importDatabase: importProbe,
      workingDatabase: workingProbe,
      hasFullDiskAccess: hasFullDiskAccess,
      sourceAttachmentCount: sourceAttachmentCount,
      addressBookFailureMessage: addressBookProbe.failureMessage,
      lastImportResult: lastImportResult,
      lastMigrationResult: lastMigrationResult,
      lastImportFailureRecordedAt: persistedImportEntry?.recordedAt,
      lastMigrationFailureRecordedAt: persistedMigrationEntry?.recordedAt,
      usingPersistedImportFailure:
          !devOverrides.simulateImportFailure &&
          !simulatedPipelineFailureActive &&
          controlState.lastImportResult == null &&
          persistedImportEntry != null,
      usingPersistedMigrationFailure:
          !devOverrides.simulateMigrationFailure &&
          !simulatedPipelineFailureActive &&
          controlState.lastMigrationResult == null &&
          persistedMigrationEntry != null,
    );
  }

  OnboardingEnvironmentState _classifyState({
    required bool hasFullDiskAccess,
    required OnboardingDatabaseProbe messagesProbe,
    required _AddressBookProbeResult addressBookProbe,
    required int? sourceMessageCount,
    required bool forceImportFailure,
    required bool forceMigrationFailure,
    required bool? lastImportSucceeded,
    required bool? lastMigrationSucceeded,
    required OnboardingDatabaseProbe importProbe,
    required OnboardingDatabaseProbe workingProbe,
  }) {
    if (!hasFullDiskAccess || !messagesProbe.readable) {
      return OnboardingEnvironmentState.permissionBlocked;
    }

    if (!messagesProbe.exists || !addressBookProbe.isAvailable) {
      return OnboardingEnvironmentState.sourceUnavailable;
    }

    if (sourceMessageCount != null &&
        sourceMessageCount <= _sparseMessagesThreshold) {
      return OnboardingEnvironmentState.sourceSparseOrUnsynced;
    }

    if (forceMigrationFailure) {
      return OnboardingEnvironmentState.migrationFailed;
    }

    if (forceImportFailure) {
      return OnboardingEnvironmentState.importFailed;
    }

    if (importProbe.hasData && workingProbe.hasData) {
      return OnboardingEnvironmentState.ready;
    }

    if (lastMigrationSucceeded == false) {
      return OnboardingEnvironmentState.migrationFailed;
    }

    if (lastImportSucceeded == false) {
      return OnboardingEnvironmentState.importFailed;
    }

    return OnboardingEnvironmentState.readyToImport;
  }

  OnboardingBlockerKind _classifyBlocker({
    required OnboardingEnvironmentState state,
    required bool hasFullDiskAccess,
    required OnboardingDatabaseProbe messagesProbe,
    required _AddressBookProbeResult addressBookProbe,
    required int? sourceMessageCount,
    required bool forceImportFailure,
    required bool forceMigrationFailure,
    required bool? lastImportSucceeded,
    required bool? lastMigrationSucceeded,
    required OnboardingDatabaseProbe importProbe,
    required OnboardingDatabaseProbe workingProbe,
  }) {
    if (!hasFullDiskAccess || !messagesProbe.readable) {
      return OnboardingBlockerKind.fullDiskAccessMissing;
    }

    if (!messagesProbe.exists) {
      return OnboardingBlockerKind.messagesDatabaseMissing;
    }

    if (!addressBookProbe.isAvailable) {
      return OnboardingBlockerKind.addressBookUnavailable;
    }

    if (state == OnboardingEnvironmentState.sourceSparseOrUnsynced ||
        (sourceMessageCount != null &&
            sourceMessageCount <= _sparseMessagesThreshold)) {
      return OnboardingBlockerKind.sourceDataSparseOrUnsynced;
    }

    if (forceMigrationFailure) {
      return OnboardingBlockerKind.migrationFailed;
    }

    if (forceImportFailure) {
      return OnboardingBlockerKind.importFailed;
    }

    if (lastMigrationSucceeded == false) {
      return OnboardingBlockerKind.migrationFailed;
    }

    if (lastImportSucceeded == false) {
      return OnboardingBlockerKind.importFailed;
    }

    if (!importProbe.exists) {
      return OnboardingBlockerKind.importDatabaseMissing;
    }

    if (!workingProbe.exists) {
      return OnboardingBlockerKind.workingDatabaseMissing;
    }

    if (!importProbe.hasData) {
      return OnboardingBlockerKind.importDatabaseEmpty;
    }

    if (!workingProbe.hasData) {
      return OnboardingBlockerKind.workingDatabaseEmpty;
    }

    return OnboardingBlockerKind.none;
  }

  OnboardingSyncPlausibility _classifySyncPlausibility({
    required bool hasFullDiskAccess,
    required int? sourceMessageCount,
  }) {
    if (!hasFullDiskAccess || sourceMessageCount == null) {
      return OnboardingSyncPlausibility.unknown;
    }

    if (sourceMessageCount <= _sparseMessagesThreshold) {
      return OnboardingSyncPlausibility.likelySparseOrUnsynced;
    }

    return OnboardingSyncPlausibility.likelySyncedOrLocallyAvailable;
  }

  OnboardingDatabaseProbe _probeFile(String filePath, {int? rowCount}) {
    final file = File(filePath);
    if (!file.existsSync()) {
      return OnboardingDatabaseProbe(
        path: filePath,
        exists: false,
        readable: false,
      );
    }

    try {
      final stat = file.statSync();
      final raf = file.openSync(mode: FileMode.read);
      raf.closeSync();

      return OnboardingDatabaseProbe(
        path: filePath,
        exists: true,
        readable: true,
        sizeBytes: stat.size,
        lastModified: stat.modified,
        rowCount: rowCount,
      );
    } catch (_) {
      return OnboardingDatabaseProbe(
        path: filePath,
        exists: true,
        readable: false,
        rowCount: rowCount,
      );
    }
  }

  _AddressBookProbeResult _probeAddressBook(
    Either<FolderRetrievalFailure, AddressBookFolderAggregate>
    addressBookEither,
  ) {
    return addressBookEither.fold(
      (failure) =>
          _AddressBookProbeResult(probe: null, failureMessage: failure.message),
      (aggregate) {
        final filePath = aggregate.mostRecentFolderPath;
        return _AddressBookProbeResult(probe: _probeFile(filePath));
      },
    );
  }

  Future<int?> _readImportMessagesCount(String dbPath) async {
    final file = File(dbPath);
    if (!file.existsSync() || file.lengthSync() == 0) {
      return null;
    }

    try {
      final importDb = await ref.watch(sqfliteImportDatabaseProvider.future);
      final database = await importDb.database;
      final result = await database.rawQuery(
        'SELECT COUNT(*) as count FROM messages',
      );
      final value = result.first['count'];
      return _asInt(value);
    } catch (_) {
      return null;
    }
  }

  Future<int?> _readWorkingMessagesCount(String dbPath) async {
    final file = File(dbPath);
    if (!file.existsSync() || file.lengthSync() == 0) {
      return null;
    }

    try {
      final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
      final result = await workingDb
          .customSelect('SELECT COUNT(*) as count FROM messages')
          .get();
      return _asInt(result.first.data['count']);
    } catch (_) {
      return null;
    }
  }

  int? _readSqliteCount({
    required String dbPath,
    required String tableName,
    bool queryOnly = false,
  }) {
    final file = File(dbPath);
    if (!file.existsSync()) {
      return null;
    }

    try {
      final db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
      try {
        if (queryOnly) {
          db.execute('PRAGMA query_only = ON;');
          db.execute('PRAGMA busy_timeout = 3000;');
        }
        final result = db.select('SELECT COUNT(*) as count FROM $tableName');
        if (result.isEmpty || result.first.values.isEmpty) {
          return null;
        }
        return _asInt(result.first.values.first);
      } finally {
        db.dispose();
      }
    } catch (_) {
      return null;
    }
  }

  int? _asInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value');
  }
}

class _AddressBookProbeResult {
  const _AddressBookProbeResult({required this.probe, this.failureMessage});

  final OnboardingDatabaseProbe? probe;
  final String? failureMessage;

  bool get isAvailable => probe != null && probe!.exists && probe!.readable;
}

extension on OnboardingDatabaseProbe {
  OnboardingDatabaseProbe copyWith({int? rowCount}) {
    return OnboardingDatabaseProbe(
      path: path,
      exists: exists,
      readable: readable,
      sizeBytes: sizeBytes,
      lastModified: lastModified,
      rowCount: rowCount ?? this.rowCount,
    );
  }
}
