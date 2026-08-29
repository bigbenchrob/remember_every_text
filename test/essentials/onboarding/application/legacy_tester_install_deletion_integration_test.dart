import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_environment/application.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure/read_only_sqlite_legacy_tester_install_inspector.dart';
import 'package:remember_this_text/essentials/onboarding/application/application_relauncher.dart';
import 'package:remember_this_text/essentials/onboarding/application/complete_installation_erase_virgin_verifier.dart';
import 'package:remember_this_text/essentials/onboarding/application/legacy_tester_install_deletion_service.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';

import '../../../test_support/legacy_tester_install_fixture.dart';

void main() {
  test(
    'exact legacy proof deletes only owned root and establishes virgin identity',
    () async {
      final sandbox = await Directory.systemTemp.createTemp(
        'legacy-tester-delete-integration-',
      );
      addTearDown(() async {
        if (sandbox.existsSync()) {
          await sandbox.delete(recursive: true);
        }
      });
      final root = Directory(path.join(sandbox.path, 'MessageLens'));
      await createExactLegacyTesterInstall(root);
      await Directory(
        path.join(root.path, 'attachment_archive', 'payloads'),
      ).create(recursive: true);
      await File(
        path.join(root.path, 'attachment_archive', 'payloads', 'legacy.bin'),
      ).writeAsString('disposable tester payload');
      await Directory(path.join(root.path, 'derived_media')).create();
      await File(
        path.join(root.path, 'derived_media', 'thumbnail'),
      ).writeAsString('derived');
      await Directory(path.join(root.path, 'logs')).create();
      await File(
        path.join(root.path, 'logs', 'legacy.log'),
      ).writeAsString('log');
      await File(
        path.join(root.path, 'unknown-legacy-file'),
      ).writeAsString('unknown');

      final externalMessages = File(path.join(sandbox.path, 'chat.db'));
      final externalContacts = File(
        path.join(sandbox.path, 'AddressBook.sqlitedb'),
      );
      final externalDonor = File(
        path.join(sandbox.path, 'historical-donor.db'),
      );
      await externalMessages.writeAsString('apple messages');
      await externalContacts.writeAsString('apple contacts');
      await externalDonor.writeAsString('historical donor');
      final externalBefore = {
        externalMessages.path: await externalMessages.readAsBytes(),
        externalContacts.path: await externalContacts.readAsBytes(),
        externalDonor.path: await externalDonor.readAsBytes(),
      };

      const inspector = ReadOnlySqliteLegacyTesterInstallInspector();
      final claim = NativeArchiveClaim(
        environment: ArchiveEnvironment.production,
        buildIdentity: ArchiveBuildIdentity.productionRelease,
        bundleIdentifier:
            ArchiveIdentityValidator.defaultProductionBundleIdentifier,
        productName: ArchiveIdentityValidator.defaultProductionProductName,
        canonicalRootPath: root.path,
        productionSignatureIsValid: true,
      );
      final inspection = await inspector.inspect(claim);
      expect(inspection.provesLegacyTesterInstall, isTrue);

      final authority = ArchiveAccessAuthority(
        identity: ResolvedArchiveIdentity(
          environment: ArchiveEnvironment.production,
          buildIdentity: ArchiveBuildIdentity.productionRelease,
          archiveInstanceId: ArchiveInstanceId(
            '11111111-1111-4111-8111-111111111111',
          ),
          canonicalRootPath: root.path,
          bundleIdentifier: claim.bundleIdentifier,
          productName: claim.productName,
        ),
        mode: ArchiveAccessMode.legacyTesterInstallDetected,
      );
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(authority),
        ],
      );
      addTearDown(container.dispose);
      final relauncher = _RecordingRelauncher();
      MessageLensInstallationState? verifiedState;
      final service = LegacyTesterInstallDeletionServiceImpl(
        authority: authority,
        runWithMutationAuthority: (action) {
          return container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability(
                operation: ArchiveMutationOperation.legacyTesterInstallDeletion,
                ownerLabel: 'legacy-delete-integration',
                action: action,
              );
        },
        resources: ArchiveOwnedResourceRegistry(),
        store: const FileSystemCompleteInstallationEraseStore(),
        verifyVirginInstallation: () async {
          verifiedState = await const CompleteInstallationEraseVirginVerifier(
            evidenceReader: SqliteMessageLensInstallationEvidenceReader(),
          ).verify(archiveRootPath: root.path);
        },
        relauncher: relauncher,
      );

      await service.deleteAndRelaunch();

      expect(verifiedState?.kind, MessageLensInstallationStateKind.virgin);
      expect(relauncher.calls, 1);
      for (final entry in externalBefore.entries) {
        expect(await File(entry.key).readAsBytes(), entry.value);
      }
      for (final removed in [
        'macos_import.db',
        'working.db',
        'user_overlays.db',
        'attachment_archive',
        'derived_media',
        'logs',
        'unknown-legacy-file',
      ]) {
        expect(
          FileSystemEntity.typeSync(
            path.join(root.path, removed),
            followLinks: false,
          ),
          FileSystemEntityType.notFound,
        );
      }
      final marker = await FileSystemArchiveMarkerStore(
        rootPath: root.path,
      ).read();
      expect(marker?.environment, ArchiveEnvironment.production);
      expect(
        marker?.archiveInstanceId,
        isNot(authority.identity.archiveInstanceId),
      );
      expect(
        await const FileSystemCompleteInstallationEraseStore().readPending(
          canonicalRootPath: root.path,
        ),
        isNull,
      );
      expect(
        (await inspector.inspect(claim)).provesLegacyTesterInstall,
        isFalse,
      );
      expect(
        await root.list().map((entity) => path.basename(entity.path)).toSet(),
        {FileSystemArchiveMarkerStore.markerFileName},
      );
    },
  );

  test('interrupted deletion cannot become a completed installation', () async {
    final sandbox = await Directory.systemTemp.createTemp(
      'legacy-tester-partial-delete-',
    );
    addTearDown(() async {
      if (sandbox.existsSync()) {
        await sandbox.delete(recursive: true);
      }
    });
    final root = Directory(path.join(sandbox.path, 'MessageLens'));
    await createExactLegacyTesterInstall(root);
    final authority = ArchiveAccessAuthority(
      identity: ResolvedArchiveIdentity(
        environment: ArchiveEnvironment.production,
        buildIdentity: ArchiveBuildIdentity.productionRelease,
        archiveInstanceId: ArchiveInstanceId(
          '11111111-1111-4111-8111-111111111111',
        ),
        canonicalRootPath: root.path,
        bundleIdentifier: 'com.bigbenchsoftware.MessageLens',
        productName: 'MessageLens',
      ),
      mode: ArchiveAccessMode.legacyTesterInstallDetected,
    );
    final transaction = CompleteInstallationEraseTransaction(
      formatVersion: CompleteInstallationEraseTransaction.currentFormatVersion,
      environment: ArchiveEnvironment.production,
      newArchiveInstanceId: ArchiveInstanceId(
        '22222222-2222-4222-8222-222222222222',
      ),
      createdAtUtc: DateTime.utc(2026, 8, 29),
    );
    const store = FileSystemCompleteInstallationEraseStore();

    await store.begin(authority: authority, transaction: transaction);
    await store.eraseOwnedState(authority: authority);

    expect(await store.readPending(canonicalRootPath: root.path), isNotNull);
    expect(
      File(
        path.join(root.path, FileSystemArchiveMarkerStore.markerFileName),
      ).existsSync(),
      isFalse,
    );
  });
}

final class _RecordingRelauncher implements ApplicationRelauncher {
  var calls = 0;

  @override
  Future<void> relaunchAfterArchiveReplacement() async {
    calls += 1;
  }
}
