import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/constants/domain/contact_constants.dart';
import 'package:remember_this_text/domain_driven_development/value_objects.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_importers/domain/entities/db_import_result.dart';
import 'package:remember_this_text/essentials/db_importers/presentation/view_model/db_import_control_provider.dart';
import 'package:remember_this_text/essentials/db_migrate/domain/entities/db_migration_result.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_aggregate.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_entity.dart';
import 'package:remember_this_text/features/address_book_folders/domain/value_objects/value_objects.dart';
import 'package:remember_this_text/features/address_book_folders/feature_level_providers.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/contact_chooser_snapshot_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/filtered_picker_sections_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/grouped_contacts_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/picker_filter_mode_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/unified_picker_sections_provider.dart';
import 'package:remember_this_text/features/contacts/domain/participant_origin.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/contacts_list_repository.dart';

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
      'maps reset-required startup reports to recoveringFailedAttempt',
      () async {
        container = ProviderContainer(
          overrides: [
            onboardingEnvironmentReportProvider.overrideWith(
              (ref) async => _report(
                state: OnboardingEnvironmentState.migrationFailed,
                blockerKind: OnboardingBlockerKind.migrationFailed,
                shouldResetAppDatabasesBeforeImport: true,
                resetAppDatabasesReason:
                    'projection_state indicates incomplete working projection',
              ),
            ),
          ],
        );

        expect(
          await _readGateStatus(container),
          OnboardingStatus.recoveringFailedAttempt,
        );
      },
    );

    test(
      'maps missing import ledger recovery reports to recoveringFailedAttempt',
      () async {
        container = ProviderContainer(
          overrides: [
            onboardingEnvironmentReportProvider.overrideWith(
              (ref) async => _report(
                state: OnboardingEnvironmentState.migrationFailed,
                blockerKind: OnboardingBlockerKind.importDatabaseMissing,
                shouldResetAppDatabasesBeforeImport: true,
                resetAppDatabasesReason:
                    'macos_import.db is missing while working.db remains incomplete',
              ),
            ),
          ],
        );

        expect(
          await _readGateStatus(container),
          OnboardingStatus.recoveringFailedAttempt,
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
          UncontrolledProviderScope(
            container: container,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Consumer(
                builder: (context, ref, child) {
                  final status = ref.watch(onboardingGateProvider);
                  seenStatuses.add(status);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        await container.read(onboardingEnvironmentReportProvider.future);

        await tester.pump();
        await tester.pump();

        expect(_FakeDbImportControlViewModel.resetCallCount, 1);
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

    testWidgets('successful reimport invalidates contact picker providers', (
      tester,
    ) async {
      final recomputeCounts = <String, int>{
        'contacts': 0,
        'grouped': 0,
        'filtered': 0,
        'snapshot': 0,
      };
      _SuccessfulDbImportControlViewModel.importCallCount = 0;
      _SuccessfulDbImportControlViewModel.migrationCallCount = 0;

      addTearDown(() {
        _SuccessfulDbImportControlViewModel.importCallCount = 0;
        _SuccessfulDbImportControlViewModel.migrationCallCount = 0;
      });

      container = ProviderContainer(
        overrides: [
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => _report(
              state: OnboardingEnvironmentState.ready,
              blockerKind: OnboardingBlockerKind.none,
            ),
          ),
          dbImportControlViewModelProvider.overrideWith(
            _SuccessfulDbImportControlViewModel.new,
          ),
          sqfliteImportDatabaseProvider.overrideWith((ref) async {
            return SqfliteImportDatabase(
              databaseDirectory: sharedDatabaseDir.path,
              databaseName: 'macos_import.db',
              debugSettings: const ImportDebugSettingsState(),
            );
          }),
          contactsListRepositoryProvider.overrideWith((ref) async {
            recomputeCounts['contacts'] = recomputeCounts['contacts']! + 1;
            return const <ContactSummary>[_aliceContact];
          }),
          groupedContactsProvider.overrideWith((ref) async {
            recomputeCounts['grouped'] = recomputeCounts['grouped']! + 1;
            return const GroupedContacts(
              groups: {
                'A': [_aliceContact],
              },
              letterCounts: {'A': 1},
              availableLetters: ['A'],
            );
          }),
          filteredPickerSectionsProvider.overrideWith((ref) async {
            recomputeCounts['filtered'] = recomputeCounts['filtered']! + 1;
            return _allSections;
          }),
          contactChooserSnapshotProvider.overrideWith((ref) {
            recomputeCounts['snapshot'] = recomputeCounts['snapshot']! + 1;
            return const ContactChooserSnapshot.ready(
              pickerMode: ContactPickerMode.flat,
              pickerFilterMode: PickerFilterMode.all,
              filteredSections: _allSections,
            );
          }),
        ],
      );

      final contactsSub = container.listen(
        contactsListRepositoryProvider,
        (_, __) {},
        fireImmediately: true,
      );
      final groupedSub = container.listen(
        groupedContactsProvider,
        (_, __) {},
        fireImmediately: true,
      );
      final filteredSub = container.listen(
        filteredPickerSectionsProvider,
        (_, __) {},
        fireImmediately: true,
      );
      final snapshotSub = container.listen(
        contactChooserSnapshotProvider,
        (_, __) {},
        fireImmediately: true,
      );

      addTearDown(() {
        contactsSub.close();
        groupedSub.close();
        filteredSub.close();
        snapshotSub.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox.shrink(),
          ),
        ),
      );

      await container.read(onboardingEnvironmentReportProvider.future);
      await container.read(contactsListRepositoryProvider.future);
      await container.read(groupedContactsProvider.future);
      await container.read(filteredPickerSectionsProvider.future);
      container.read(contactChooserSnapshotProvider);
      expect(
        container.read(onboardingGateProvider),
        OnboardingStatus.notNeeded,
      );
      await tester.pump();

      final baselineCounts = Map<String, int>.from(recomputeCounts);

      final reimportFuture = container
          .read(onboardingGateProvider.notifier)
          .startReimport();
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await reimportFuture.timeout(const Duration(seconds: 1));

      await container.read(contactsListRepositoryProvider.future);
      await container.read(groupedContactsProvider.future);
      await container.read(filteredPickerSectionsProvider.future);
      container.read(contactChooserSnapshotProvider);

      expect(_SuccessfulDbImportControlViewModel.importCallCount, 1);
      expect(_SuccessfulDbImportControlViewModel.migrationCallCount, 1);
      expect(
        recomputeCounts['contacts'],
        greaterThan(baselineCounts['contacts']!),
      );
      expect(
        recomputeCounts['grouped'],
        greaterThan(baselineCounts['grouped']!),
      );
      expect(
        recomputeCounts['filtered'],
        greaterThan(baselineCounts['filtered']!),
      );
      expect(
        recomputeCounts['snapshot'],
        greaterThan(baselineCounts['snapshot']!),
      );
    });
  });
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

class _FakeDbImportControlViewModel extends DbImportControlViewModel {
  static int resetCallCount = 0;
  static Completer<void>? resetCompleter;
  static void Function()? onResetStarted;

  @override
  DbImportControlState build() {
    return const DbImportControlState();
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

class _SuccessfulDbImportControlViewModel extends DbImportControlViewModel {
  static int importCallCount = 0;
  static int migrationCallCount = 0;

  @override
  DbImportControlState build() {
    return const DbImportControlState();
  }

  @override
  Future<void> startImport({String? sourceChatDbOverride}) async {
    importCallCount += 1;
    state = state.copyWith(
      lastImportResult: const DbImportResult(batchId: 1, success: true),
    );
  }

  @override
  Future<void> startMigration({
    bool skipImportCheck = false,
    bool Function()? shouldCancel,
  }) async {
    migrationCallCount += 1;
    state = state.copyWith(
      lastMigrationResult: const DbMigrationResult(batchId: 1, success: true),
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

const ContactSummary _aliceContact = ContactSummary(
  participantId: 1,
  displayName: 'Alice Abel',
  autoGeneratedName: 'Alice Abel',
  shortName: 'Alice',
  totalChats: 1,
  totalMessages: 3,
  origin: ParticipantOrigin.working,
  handleCount: 1,
);

const UnifiedPickerSections _allSections = UnifiedPickerSections(
  sections: [
    PickerSection(
      key: 'A',
      label: 'A',
      contacts: [_aliceContact],
      type: PickerSectionType.alphabetical,
    ),
  ],
  alphabeticalLetters: ['A'],
  alphabeticalStartIndex: 0,
  allFavoriteIds: <int>{},
);
