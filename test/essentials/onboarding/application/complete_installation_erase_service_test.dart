import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/application.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/onboarding/application/application_relauncher.dart';
import 'package:remember_this_text/essentials/onboarding/application/complete_installation_erase_service.dart';

void main() {
  test(
    'closes resources, erases, verifies identity, then relaunches',
    () async {
      final authority = _authority();
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWith(
            (ref) => authority,
          ),
        ],
      );
      addTearDown(container.dispose);
      final events = <String>[];
      final resources = ArchiveOwnedResourceRegistry();
      final resourceIdentity = Object();
      resources.register(
        identity: resourceIdentity,
        label: 'opened database',
        close: () async => events.add('closed'),
      );
      final store = _RecordingEraseStore(events);
      final relauncher = _RecordingRelauncher(events);
      final service = CompleteInstallationEraseServiceImpl(
        authority: authority,
        runWithMutationAuthority: (action) {
          return container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability(
                operation: ArchiveMutationOperation.completeInstallationErase,
                ownerLabel: 'test-complete-erase',
                action: action,
              );
        },
        resources: resources,
        store: store,
        stopBackgroundWork: () => events.add('stopped'),
        invalidatePersistentProviders: () => events.add('invalidated'),
        verifyVirginInstallation: () async => events.add('verified'),
        relauncher: relauncher,
        currentTime: () => DateTime.utc(2026, 8, 27),
      );

      await service.eraseAndRelaunch();

      expect(events, [
        'stopped',
        'closed',
        'invalidated',
        'began',
        'erased',
        'installed',
        'verified',
        'completed',
        'relaunched',
      ]);
      expect(resources.openResourceCount, 0);
    },
  );
}

ArchiveAccessAuthority _authority() => ArchiveAccessAuthority(
  identity: ResolvedArchiveIdentity(
    environment: ArchiveEnvironment.development,
    buildIdentity: ArchiveBuildIdentity.developmentDebug,
    archiveInstanceId: ArchiveInstanceId(
      '11111111-1111-4111-8111-111111111111',
    ),
    canonicalRootPath: '/tmp/MessageLens-complete-erase-test',
    bundleIdentifier: 'com.bigbenchsoftware.MessageLens.development',
    productName: 'MessageLens Development',
  ),
);

final class _RecordingEraseStore implements CompleteInstallationEraseStore {
  _RecordingEraseStore(this.events);

  final List<String> events;

  @override
  Future<void> begin({
    required ArchiveAccessAuthority authority,
    required CompleteInstallationEraseTransaction transaction,
  }) async {
    events.add('began');
  }

  @override
  Future<void> eraseOwnedState({
    required ArchiveAccessAuthority authority,
  }) async {
    events.add('erased');
  }

  @override
  Future<void> installVirginIdentity({
    required ArchiveAccessAuthority authority,
    required CompleteInstallationEraseTransaction transaction,
  }) async {
    events.add('installed');
  }

  @override
  Future<void> complete({required ArchiveAccessAuthority authority}) async {
    events.add('completed');
  }

  @override
  Future<CompleteInstallationEraseTransaction?> readPending({
    required String canonicalRootPath,
  }) async => null;
}

final class _RecordingRelauncher implements ApplicationRelauncher {
  _RecordingRelauncher(this.events);

  final List<String> events;

  @override
  Future<void> relaunchAfterArchiveReplacement() async {
    events.add('relaunched');
  }
}
