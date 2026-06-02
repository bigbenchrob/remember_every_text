import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/domain_driven_development/value_objects.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db_importers/domain/entities/db_import_result.dart';
import 'package:remember_this_text/essentials/db_importers/presentation/view_model/db_import_control_provider.dart';
import 'package:remember_this_text/essentials/db_migrate/domain/entities/db_migration_result.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_data_reset_service.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_aggregate.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_entity.dart';
import 'package:remember_this_text/features/address_book_folders/domain/value_objects/value_objects.dart';
import 'package:remember_this_text/features/address_book_folders/feature_level_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('onboardingGateProvider', () {
    late Directory sharedDatabaseDir;
    late ProviderContainer container;

    setUpAll(() async {
      sharedDatabaseDir = await Directory.systemTemp.createTemp(
        'onboarding_gate_provider_shared_db_dir',
      );
      databaseDirectoryPath = sharedDatabaseDir.path;
    });

    tearDownAll(() async {
      if (sharedDatabaseDir.existsSync()) {
        await sharedDatabaseDir.delete(recursive: true);
      }
    });

    tearDown(() {
      container.dispose();
    });

    test('maps permission-blocked environment to awaitingFda', () async {
      container = ProviderContainer(
        overrides: [
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => _report(
              state: OnboardingEnvironmentState.permissionBlocked,
              blockerKind: OnboardingBlockerKind.fullDiskAccessMissing,
              hasFullDiskAccess: false,
            ),
          ),
        ],
      );

      expect(await _readGateStatus(container), OnboardingStatus.awaitingFda);
    });

    test('maps ready environment to notNeeded', () async {
      container = ProviderContainer(
        overrides: [
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => _report(
              state: OnboardingEnvironmentState.ready,
              blockerKind: OnboardingBlockerKind.none,
            ),
          ),
        ],
      );

      expect(await _readGateStatus(container), OnboardingStatus.notNeeded);
    });

    test('keeps import failures inside awaitingUserAction contract', () async {
      container = ProviderContainer(
        overrides: [
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => _report(
              state: OnboardingEnvironmentState.importFailed,
              blockerKind: OnboardingBlockerKind.importFailed,
            ),
          ),
        ],
      );

      expect(
        await _readGateStatus(container),
        OnboardingStatus.awaitingUserAction,
      );
    });

    test(
      'keeps migration failures inside awaitingUserAction contract',
      () async {
        container = ProviderContainer(
          overrides: [
            onboardingEnvironmentReportProvider.overrideWith(
              (ref) async => _report(
                state: OnboardingEnvironmentState.migrationFailed,
                blockerKind: OnboardingBlockerKind.migrationFailed,
              ),
            ),
          ],
        );

        expect(
          await _readGateStatus(container),
          OnboardingStatus.awaitingUserAction,
        );
      },
    );

    test(
      'keeps sparse local history inside awaitingUserAction contract',
      () async {
        container = ProviderContainer(
          overrides: [
            onboardingEnvironmentReportProvider.overrideWith(
              (ref) async => _report(
                state: OnboardingEnvironmentState.sourceSparseOrUnsynced,
                blockerKind: OnboardingBlockerKind.sourceDataSparseOrUnsynced,
              ),
            ),
          ],
        );

        expect(
          await _readGateStatus(container),
          OnboardingStatus.awaitingUserAction,
        );
      },
    );

    test('preserves importing workflow status during report rebuilds', () {
      final status = OnboardingGate.resolveBuildStatus(
        reportAsync: AsyncData(
          _report(
            state: OnboardingEnvironmentState.importFailed,
            blockerKind: OnboardingBlockerKind.importFailed,
          ),
        ),
        workflowOverrideStatus: OnboardingStatus.importing,
        fallbackBuildStatus: () => OnboardingStatus.awaitingUserAction,
      );

      expect(status, OnboardingStatus.importing);
    });

    test('preserves completion status during report rebuilds', () {
      final status = OnboardingGate.resolveBuildStatus(
        reportAsync: AsyncData(
          _report(
            state: OnboardingEnvironmentState.ready,
            blockerKind: OnboardingBlockerKind.none,
          ),
        ),
        workflowOverrideStatus: OnboardingStatus.complete,
        fallbackBuildStatus: () => OnboardingStatus.notNeeded,
      );

      expect(status, OnboardingStatus.complete);
    });

    test('preserves recovery status during report rebuilds', () {
      final status = OnboardingGate.resolveBuildStatus(
        reportAsync: AsyncData(
          _report(
            state: OnboardingEnvironmentState.migrationFailed,
            blockerKind: OnboardingBlockerKind.migrationFailed,
          ),
        ),
        workflowOverrideStatus: OnboardingStatus.recoveringFailedAttempt,
        fallbackBuildStatus: () => OnboardingStatus.awaitingUserAction,
      );

      expect(status, OnboardingStatus.recoveringFailedAttempt);
    });

    test('falls back to derived status when no workflow override exists', () {
      final status = OnboardingGate.resolveBuildStatus(
        reportAsync: AsyncData(
          _report(
            state: OnboardingEnvironmentState.migrationFailed,
            blockerKind: OnboardingBlockerKind.migrationFailed,
          ),
        ),
        workflowOverrideStatus: null,
        fallbackBuildStatus: () => OnboardingStatus.notNeeded,
      );

      expect(status, OnboardingStatus.awaitingUserAction);
    });

    test('refreshEnvironment re-checks full disk access', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'onboarding_gate_provider_test',
      );
      final overlayDb = OverlayDatabase(NativeDatabase.memory());
      final messagesDbPath = _createReadableFile(tempDir.path, 'messages.db');
      final addressBookPath = _createReadableFile(
        tempDir.path,
        'AddressBook-v22.abcddb',
      );
      var hasFullDiskAccess = true;

      addTearDown(() async {
        await overlayDb.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });

      container = ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          onboardingFullDiskAccessProvider.overrideWith(
            (ref) => hasFullDiskAccess,
          ),
          onboardingMessagesDatabasePathProvider.overrideWith(
            (ref) => messagesDbPath,
          ),
          onboardingDatabaseDirectoryPathProvider.overrideWith(
            (ref) => tempDir.path,
          ),
          futureGetFolderAggregateProvider.overrideWith(
            (ref) async => right(_addressBookAggregate(addressBookPath)),
          ),
        ],
      );

      expect(
        await _readGateStatus(container),
        OnboardingStatus.awaitingUserAction,
      );

      hasFullDiskAccess = false;
      container.read(onboardingGateProvider.notifier).refreshEnvironment();

      expect(await _readGateStatus(container), OnboardingStatus.awaitingFda);
    });

    testWidgets(
      'settings reimport completes only when import and migration succeed',
      (tester) async {
        _FakeDbImportControlViewModel.resetFake();
        final resetService = _FakeMessageDataResetService();
        _FakeDbImportControlViewModel.importResult = const DbImportResult(
          batchId: 1,
          success: true,
        );
        _FakeDbImportControlViewModel.migrationResult = const DbMigrationResult(
          batchId: 1,
          success: true,
        );

        addTearDown(_FakeDbImportControlViewModel.resetFake);

        container = ProviderContainer(
          overrides: [
            onboardingEnvironmentReportProvider.overrideWith((ref) async {
              final migrationFailed =
                  _FakeDbImportControlViewModel.startMigrationCallCount > 0 &&
                  _FakeDbImportControlViewModel.migrationResult?.success ==
                      false;
              return _report(
                state: migrationFailed
                    ? OnboardingEnvironmentState.migrationFailed
                    : OnboardingEnvironmentState.ready,
                blockerKind: migrationFailed
                    ? OnboardingBlockerKind.migrationFailed
                    : OnboardingBlockerKind.none,
              );
            }),
            dbImportControlViewModelProvider.overrideWith(
              _FakeDbImportControlViewModel.new,
            ),
            messageDataResetServiceProvider.overrideWith((ref) => resetService),
          ],
        );

        await tester.pumpWidget(_GateHarness(container: container));
        expect(await _readGateStatus(container), OnboardingStatus.notNeeded);

        final reimportFuture = container
            .read(onboardingGateProvider.notifier)
            .startReimport();
        await tester.pump();
        await tester.pump();
        await reimportFuture;

        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.reimportComplete,
        );
        expect(_FakeDbImportControlViewModel.startImportCallCount, 1);
        expect(_FakeDbImportControlViewModel.startMigrationCallCount, 1);
        expect(resetService.clearImportLedgersCallCount, 1);
      },
    );

    testWidgets(
      'settings reimport returns to awaitingUserAction when graph-backed migration fails',
      (tester) async {
        _FakeDbImportControlViewModel.resetFake();
        final resetService = _FakeMessageDataResetService();
        _FakeDbImportControlViewModel.importResult = const DbImportResult(
          batchId: 1,
          success: true,
        );
        _FakeDbImportControlViewModel.migrationResult = const DbMigrationResult(
          batchId: 1,
          success: false,
          error: 'Conversation graph build failed',
        );

        addTearDown(_FakeDbImportControlViewModel.resetFake);

        container = ProviderContainer(
          overrides: [
            onboardingEnvironmentReportProvider.overrideWith((ref) async {
              final migrationFailed =
                  _FakeDbImportControlViewModel.startMigrationCallCount > 0 &&
                  _FakeDbImportControlViewModel.migrationResult?.success ==
                      false;
              return _report(
                state: migrationFailed
                    ? OnboardingEnvironmentState.migrationFailed
                    : OnboardingEnvironmentState.ready,
                blockerKind: migrationFailed
                    ? OnboardingBlockerKind.migrationFailed
                    : OnboardingBlockerKind.none,
              );
            }),
            dbImportControlViewModelProvider.overrideWith(
              _FakeDbImportControlViewModel.new,
            ),
            messageDataResetServiceProvider.overrideWith((ref) => resetService),
          ],
        );

        await tester.pumpWidget(_GateHarness(container: container));
        expect(await _readGateStatus(container), OnboardingStatus.notNeeded);

        final reimportFuture = container
            .read(onboardingGateProvider.notifier)
            .startReimport();
        await tester.pump();
        await tester.pump();
        await reimportFuture;

        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.awaitingUserAction,
        );
        expect(_FakeDbImportControlViewModel.startImportCallCount, 1);
        expect(_FakeDbImportControlViewModel.startMigrationCallCount, 1);
        expect(resetService.clearImportLedgersCallCount, 1);
      },
    );

    testWidgets(
      'automatically resets stale app databases once before returning to awaitingUserAction',
      (tester) async {
        var shouldReset = true;
        final seenStatuses = <OnboardingStatus>[];
        final resetCompleter = Completer<void>();
        _FakeDbImportControlViewModel.resetCallCount = 0;
        _FakeDbImportControlViewModel.resetCompleter = resetCompleter;
        _FakeDbImportControlViewModel.onResetStarted = () {
          shouldReset = false;
        };

        addTearDown(() {
          _FakeDbImportControlViewModel.resetCallCount = 0;
          _FakeDbImportControlViewModel.resetCompleter = null;
          _FakeDbImportControlViewModel.onResetStarted = null;
        });

        container = ProviderContainer(
          overrides: [
            onboardingEnvironmentReportProvider.overrideWith((ref) async {
              return _report(
                state: shouldReset
                    ? OnboardingEnvironmentState.migrationFailed
                    : OnboardingEnvironmentState.readyToImport,
                blockerKind: shouldReset
                    ? OnboardingBlockerKind.migrationFailed
                    : OnboardingBlockerKind.importDatabaseMissing,
                shouldResetAppDatabasesBeforeImport: shouldReset,
                resetAppDatabasesReason: shouldReset
                    ? 'Synthetic stale setup state for gate recovery test'
                    : null,
              );
            }),
            dbImportControlViewModelProvider.overrideWith(
              _FakeDbImportControlViewModel.new,
            ),
          ],
        );

        await tester.pumpWidget(
          _GateHarness(container: container, seenStatuses: seenStatuses),
        );

        await container.read(onboardingEnvironmentReportProvider.future);

        await tester.pump();
        await tester.pump();

        expect(_FakeDbImportControlViewModel.resetCallCount, 1);
        expect(seenStatuses, contains(OnboardingStatus.awaitingUserAction));
        expect(
          seenStatuses,
          contains(OnboardingStatus.recoveringFailedAttempt),
        );

        resetCompleter.complete();
        await tester.pump();
        await tester.pump();

        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.awaitingUserAction,
        );
        expect(_FakeDbImportControlViewModel.resetCallCount, 1);
      },
    );
  });
}

class _GateHarness extends StatelessWidget {
  const _GateHarness({required this.container, this.seenStatuses});

  final ProviderContainer container;
  final List<OnboardingStatus>? seenStatuses;

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: container,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Consumer(
          builder: (context, ref, child) {
            final status = ref.watch(onboardingGateProvider);
            seenStatuses?.add(status);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

Future<OnboardingStatus> _readGateStatus(ProviderContainer container) async {
  await container.read(onboardingEnvironmentReportProvider.future);
  return container.read(onboardingGateProvider);
}

OnboardingEnvironmentReport _report({
  required OnboardingEnvironmentState state,
  required OnboardingBlockerKind blockerKind,
  bool hasFullDiskAccess = true,
  bool shouldResetAppDatabasesBeforeImport = false,
  String? resetAppDatabasesReason,
}) {
  return OnboardingEnvironmentReport(
    state: state,
    blockerKind: blockerKind,
    syncPlausibility: OnboardingSyncPlausibility.unknown,
    messagesDatabase: const OnboardingDatabaseProbe(
      path: 'messages.db',
      exists: true,
      readable: true,
      rowCount: 100,
    ),
    addressBookDatabase: const OnboardingDatabaseProbe(
      path: 'addressbook.db',
      exists: true,
      readable: true,
      rowCount: 10,
    ),
    importDatabase: const OnboardingDatabaseProbe(
      path: 'macos_import.db',
      exists: true,
      readable: true,
      rowCount: 100,
    ),
    workingDatabase: const OnboardingDatabaseProbe(
      path: 'working.db',
      exists: true,
      readable: true,
      rowCount: 100,
    ),
    hasFullDiskAccess: hasFullDiskAccess,
    shouldResetAppDatabasesBeforeImport: shouldResetAppDatabasesBeforeImport,
    resetAppDatabasesReason: resetAppDatabasesReason,
  );
}

final class _FakeMessageDataResetService implements MessageDataResetService {
  int resetDerivedDataCallCount = 0;
  int clearImportLedgersCallCount = 0;
  int clearProjectionDatabasesCallCount = 0;
  int confirmResetAndPrepareReimportCallCount = 0;

  @override
  Future<void> resetDerivedData() async {
    resetDerivedDataCallCount += 1;
  }

  @override
  Future<void> clearImportLedgers() async {
    clearImportLedgersCallCount += 1;
  }

  @override
  Future<void> clearProjectionDatabases() async {
    clearProjectionDatabasesCallCount += 1;
  }

  @override
  Future<void> closeLegacyDatabasesForMigration() async {}

  @override
  Future<void> confirmResetAndPrepareReimport() async {
    confirmResetAndPrepareReimportCallCount += 1;
  }
}

class _FakeDbImportControlViewModel extends DbImportControlViewModel {
  static int resetCallCount = 0;
  static int startImportCallCount = 0;
  static int startMigrationCallCount = 0;
  static Completer<void>? resetCompleter;
  static void Function()? onResetStarted;
  static DbImportResult? importResult;
  static DbMigrationResult? migrationResult;

  static void resetFake() {
    resetCallCount = 0;
    startImportCallCount = 0;
    startMigrationCallCount = 0;
    resetCompleter = null;
    onResetStarted = null;
    importResult = null;
    migrationResult = null;
  }

  @override
  DbImportControlState build() {
    return const DbImportControlState();
  }

  @override
  Future<void> startImport({String? sourceChatDbOverride}) async {
    startImportCallCount += 1;
    state = state.copyWith(
      lastImportResult:
          importResult ?? const DbImportResult(batchId: 1, success: true),
    );
  }

  @override
  Future<void> startMigration({
    bool skipImportCheck = false,
    bool buildConversationGraph = true,
  }) async {
    startMigrationCallCount += 1;
    state = state.copyWith(
      lastMigrationResult:
          migrationResult ?? const DbMigrationResult(batchId: 1, success: true),
    );
  }

  @override
  Future<void> resetAllDatabases() async {
    resetCallCount += 1;
    onResetStarted?.call();
    state = state.copyWith(
      isProcessing: true,
      statusMessage: 'Resetting databases...',
    );
    await resetCompleter?.future;
    state = state.copyWith(
      isProcessing: false,
      statusMessage: 'Databases reset.',
    );
  }
}

String _createReadableFile(String directoryPath, String fileName) {
  final file = File('$directoryPath/$fileName');
  file.writeAsStringSync('fixture');
  return file.path;
}

AddressBookFolderAggregate _addressBookAggregate(String addressBookPath) {
  return AddressBookFolderAggregate([
    AddressBookFolderEntity(
      path: FolderPathValueObject(addressBookPath),
      shortPath: AddressBookFolderShortPath('TEST-SOURCE'),
      lastCreationDate: FolderCreationDate(DateTime.utc(2026, 03, 24)),
      lastModificationDate: FolderModificationDate(DateTime.utc(2026, 03, 24)),
      recordCount: NonZeroInt(12),
    ),
  ]);
}
