import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/application.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/onboarding/application/application_relauncher.dart';
import 'package:remember_this_text/essentials/onboarding/application/legacy_tester_install_deletion_service.dart';

void main() {
  test(
    'legacy deletion uses exact capability and deterministic order',
    () async {
      final authority = _legacyAuthority();
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(authority),
        ],
      );
      addTearDown(container.dispose);
      final events = <String>[];
      final service = LegacyTesterInstallDeletionServiceImpl(
        authority: authority,
        runWithMutationAuthority: (action) {
          return container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability(
                operation: ArchiveMutationOperation.legacyTesterInstallDeletion,
                ownerLabel: 'legacy-delete-test',
                action: action,
              );
        },
        resources: ArchiveOwnedResourceRegistry(),
        store: _RecordingStore(events),
        verifyVirginInstallation: () async {
          events.add('verified-virgin');
        },
        relauncher: _RecordingRelauncher(events),
        currentTime: () => DateTime.utc(2026, 8, 29),
      );

      await service.deleteAndRelaunch();

      expect(events, [
        'read-pending',
        'began',
        'erased',
        'installed',
        'verified-virgin',
        'completed',
        'relaunched',
      ]);
    },
  );

  test('open current-store resource prevents deletion', () async {
    final authority = _legacyAuthority();
    final container = ProviderContainer(
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(authority),
      ],
    );
    addTearDown(container.dispose);
    final events = <String>[];
    final resources = ArchiveOwnedResourceRegistry()
      ..register(identity: Object(), label: 'unexpected store', close: () {});
    final service = LegacyTesterInstallDeletionServiceImpl(
      authority: authority,
      runWithMutationAuthority: (action) {
        return container
            .read(archiveMutationCoordinatorProvider.notifier)
            .runWithCapability(
              operation: ArchiveMutationOperation.legacyTesterInstallDeletion,
              ownerLabel: 'legacy-delete-test',
              action: action,
            );
      },
      resources: resources,
      store: _RecordingStore(events),
      verifyVirginInstallation: () async {},
      relauncher: _RecordingRelauncher(events),
    );

    await expectLater(service.deleteAndRelaunch(), throwsA(isA<StateError>()));
    expect(events, isEmpty);
  });

  test('retry resumes a durable pending archive replacement', () async {
    final authority = _legacyAuthority();
    final container = ProviderContainer(
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(authority),
      ],
    );
    addTearDown(container.dispose);
    final events = <String>[];
    final pending = CompleteInstallationEraseTransaction(
      formatVersion: CompleteInstallationEraseTransaction.currentFormatVersion,
      environment: authority.identity.environment,
      newArchiveInstanceId: ArchiveInstanceId(
        '22222222-2222-4222-8222-222222222222',
      ),
      createdAtUtc: DateTime.utc(2026, 8, 29),
    );
    final service = LegacyTesterInstallDeletionServiceImpl(
      authority: authority,
      runWithMutationAuthority: (action) {
        return container
            .read(archiveMutationCoordinatorProvider.notifier)
            .runWithCapability(
              operation: ArchiveMutationOperation.legacyTesterInstallDeletion,
              ownerLabel: 'legacy-delete-test',
              action: action,
            );
      },
      resources: ArchiveOwnedResourceRegistry(),
      store: _RecordingStore(events, pending: pending),
      verifyVirginInstallation: () async {
        events.add('verified-virgin');
      },
      relauncher: _RecordingRelauncher(events),
    );

    await service.deleteAndRelaunch();

    expect(events, isNot(contains('began')));
    expect(
      events,
      containsAllInOrder(['erased', 'installed', 'verified-virgin']),
    );
  });
}

ArchiveAccessAuthority _legacyAuthority() => ArchiveAccessAuthority(
  identity: ResolvedArchiveIdentity(
    environment: ArchiveEnvironment.production,
    buildIdentity: ArchiveBuildIdentity.productionRelease,
    archiveInstanceId: ArchiveInstanceId(
      '11111111-1111-4111-8111-111111111111',
    ),
    canonicalRootPath: '/tmp/legacy-tester-service-test',
    bundleIdentifier: 'com.bigbenchsoftware.MessageLens',
    productName: 'MessageLens',
  ),
  mode: ArchiveAccessMode.legacyTesterInstallDetected,
);

final class _RecordingStore implements CompleteInstallationEraseStore {
  _RecordingStore(this.events, {this.pending});

  final List<String> events;
  final CompleteInstallationEraseTransaction? pending;

  @override
  Future<void> begin({
    required ArchiveAccessAuthority authority,
    required CompleteInstallationEraseTransaction transaction,
  }) async {
    events.add('began');
  }

  @override
  Future<void> complete({required ArchiveAccessAuthority authority}) async {
    events.add('completed');
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
  Future<CompleteInstallationEraseTransaction?> readPending({
    required String canonicalRootPath,
  }) async {
    events.add('read-pending');
    return pending;
  }
}

final class _RecordingRelauncher implements ApplicationRelauncher {
  _RecordingRelauncher(this.events);

  final List<String> events;

  @override
  Future<void> relaunchAfterArchiveReplacement() async {
    events.add('relaunched');
  }
}
