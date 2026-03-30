import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/domain_driven_development/value_objects.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_aggregate.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_entity.dart';
import 'package:remember_this_text/features/address_book_folders/domain/value_objects/value_objects.dart';
import 'package:remember_this_text/features/address_book_folders/feature_level_providers.dart';

void main() {
  group('onboardingGateProvider', () {
    late ProviderContainer container;

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
  );
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
