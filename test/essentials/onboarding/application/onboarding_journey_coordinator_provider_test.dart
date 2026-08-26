import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_journey_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingJourneyCoordinator', () {
    test(
      'derives exactly one typed Episode from one coherent report',
      () async {
        final reports = _MutableReportSource(
          _report(
            state: OnboardingEnvironmentState.permissionBlocked,
            blockerKind: OnboardingBlockerKind.fullDiskAccessMissing,
            hasFullDiskAccess: false,
          ),
        );
        final container = _container(reports);
        addTearDown(container.dispose);

        await _settleReport(container);
        expect(
          container.read(onboardingJourneyCoordinatorProvider),
          isA<OnboardingNeedsMessagesAccess>(),
        );

        reports.current = _report(
          state: OnboardingEnvironmentState.sourceUnavailable,
          blockerKind: OnboardingBlockerKind.addressBookUnavailable,
        );
        container.invalidate(onboardingEnvironmentReportProvider);
        await _settleReport(container);
        expect(
          container.read(onboardingJourneyCoordinatorProvider),
          isA<OnboardingNeedsContactsAccess>(),
        );

        reports.current = _report(
          state: OnboardingEnvironmentState.readyToImport,
          blockerKind: OnboardingBlockerKind.none,
        );
        container.invalidate(onboardingEnvironmentReportProvider);
        await _settleReport(container);
        expect(
          container.read(onboardingJourneyCoordinatorProvider),
          isA<OnboardingReadyToImport>(),
        );
      },
    );

    test('recheck without new proof cannot advance the FDA Episode', () async {
      final reports = _MutableReportSource(
        _report(
          state: OnboardingEnvironmentState.permissionBlocked,
          blockerKind: OnboardingBlockerKind.fullDiskAccessMissing,
          hasFullDiskAccess: false,
        ),
      );
      final container = _container(reports);
      addTearDown(container.dispose);
      await _settleReport(container);

      final before = container.read(onboardingJourneyCoordinatorProvider);
      container
          .read(onboardingJourneyCoordinatorProvider.notifier)
          .refreshEnvironment();
      await _settleReport(container);
      final after = container.read(onboardingJourneyCoordinatorProvider);

      expect(before, isA<OnboardingNeedsMessagesAccess>());
      expect(after, isA<OnboardingNeedsMessagesAccess>());
      expect(after.occurrence, isNot(before.occurrence));
    });

    test('local-history acknowledgement is gated to its Episode', () async {
      final reports = _MutableReportSource(
        _report(
          state: OnboardingEnvironmentState.sourceSparseOrUnsynced,
          blockerKind: OnboardingBlockerKind.sourceDataSparseOrUnsynced,
        ),
      );
      final container = _container(reports);
      addTearDown(container.dispose);
      await _settleReport(container);

      expect(
        container.read(onboardingJourneyCoordinatorProvider),
        isA<OnboardingNeedsLocalHistoryConfirmation>(),
      );

      container
          .read(onboardingJourneyCoordinatorProvider.notifier)
          .acceptLocalMessageHistory();

      final accepted = container.read(onboardingJourneyCoordinatorProvider);
      expect(accepted, isA<OnboardingReadyToImport>());
      expect(
        (accepted as OnboardingReadyToImport).localHistoryAccepted,
        isTrue,
      );
    });

    test('import authorization is ignored outside readyToImport', () async {
      final reports = _MutableReportSource(
        _report(
          state: OnboardingEnvironmentState.permissionBlocked,
          blockerKind: OnboardingBlockerKind.fullDiskAccessMissing,
          hasFullDiskAccess: false,
        ),
      );
      final container = _container(reports);
      addTearDown(container.dispose);
      await _settleReport(container);

      await container
          .read(onboardingJourneyCoordinatorProvider.notifier)
          .startImportAndGraphBuild();

      expect(
        container.read(onboardingJourneyCoordinatorProvider),
        isA<OnboardingNeedsMessagesAccess>(),
      );
    });

    testWidgets(
      'import presentation owns the Journey before mutation admission',
      (tester) async {
        final reports = _MutableReportSource(
          _report(
            state: OnboardingEnvironmentState.readyToImport,
            blockerKind: OnboardingBlockerKind.none,
          ),
        );
        final mutationCoordinator = _HeldArchiveMutationCoordinator();
        final container = ProviderContainer(
          overrides: <Override>[
            onboardingEnvironmentReportProvider.overrideWith(
              (ref) async => reports.current,
            ),
            archiveMutationCoordinatorProvider.overrideWith(
              () => mutationCoordinator,
            ),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
          ],
        );
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const SizedBox(),
          ),
        );
        await container.read(onboardingEnvironmentReportProvider.future);
        container.read(onboardingJourneyCoordinatorProvider);
        await tester.pump();

        final seenStatuses = <OnboardingStatus>[];
        final subscription = container.listen<OnboardingStatus>(
          onboardingJourneyCoordinatorProvider.select(
            (journey) => journey.compatibilityStatus,
          ),
          (_, next) {
            seenStatuses.add(next);
          },
          fireImmediately: true,
        );
        addTearDown(subscription.close);

        final import = container
            .read(onboardingJourneyCoordinatorProvider.notifier)
            .startImportAndGraphBuild();

        expect(
          container.read(onboardingJourneyCoordinatorProvider),
          isA<OnboardingPreparingImport>(),
        );
        expect(mutationCoordinator.admissionRequested, isFalse);
        expect(seenStatuses, <OnboardingStatus>[
          OnboardingStatus.awaitingUserAction,
          OnboardingStatus.importing,
        ]);

        await tester.pump();
        expect(mutationCoordinator.admissionRequested, isTrue);
        mutationCoordinator.releaseAdmission.complete();
        await import;
      },
    );

    test(
      'invalidated stale evidence cannot replace a newer observation',
      () async {
        final first = Completer<OnboardingEnvironmentReport>();
        final second = Completer<OnboardingEnvironmentReport>();
        var invocation = 0;
        final container = ProviderContainer(
          overrides: <Override>[
            onboardingEnvironmentReportProvider.overrideWith((ref) {
              invocation += 1;
              return invocation == 1 ? first.future : second.future;
            }),
          ],
        );
        addTearDown(container.dispose);

        container.read(onboardingJourneyCoordinatorProvider);
        container
            .read(onboardingJourneyCoordinatorProvider.notifier)
            .refreshEnvironment();
        first.complete(
          _report(
            state: OnboardingEnvironmentState.readyToImport,
            blockerKind: OnboardingBlockerKind.none,
          ),
        );
        await Future<void>.delayed(Duration.zero);
        second.complete(
          _report(
            state: OnboardingEnvironmentState.permissionBlocked,
            blockerKind: OnboardingBlockerKind.fullDiskAccessMissing,
            hasFullDiskAccess: false,
          ),
        );
        await _settleReport(container);

        expect(invocation, 2);
        expect(
          container.read(onboardingJourneyCoordinatorProvider),
          isA<OnboardingNeedsMessagesAccess>(),
        );
      },
    );
  });

  group('Onboarding Journey commanded transition policy', () {
    test('permits the proven operation path', () {
      expect(
        onboardingJourneyAllowsCommandedTransition(
          OnboardingStatus.awaitingUserAction,
          OnboardingStatus.importing,
        ),
        isTrue,
      );
      expect(
        onboardingJourneyAllowsCommandedTransition(
          OnboardingStatus.importing,
          OnboardingStatus.buildingGraph,
        ),
        isTrue,
      );
      expect(
        onboardingJourneyAllowsCommandedTransition(
          OnboardingStatus.buildingGraph,
          OnboardingStatus.complete,
        ),
        isTrue,
      );
      expect(
        onboardingJourneyAllowsCommandedTransition(
          OnboardingStatus.complete,
          OnboardingStatus.notNeeded,
        ),
        isTrue,
      );
    });

    test('rejects impossible shortcuts', () {
      expect(
        onboardingJourneyAllowsCommandedTransition(
          OnboardingStatus.awaitingFda,
          OnboardingStatus.complete,
        ),
        isFalse,
      );
      expect(
        onboardingJourneyAllowsCommandedTransition(
          OnboardingStatus.importing,
          OnboardingStatus.notNeeded,
        ),
        isFalse,
      );
      expect(
        onboardingJourneyAllowsCommandedTransition(
          OnboardingStatus.complete,
          OnboardingStatus.awaitingUserAction,
        ),
        isFalse,
      );
    });
  });
}

ProviderContainer _container(_MutableReportSource reports) {
  return ProviderContainer(
    overrides: <Override>[
      onboardingEnvironmentReportProvider.overrideWith(
        (ref) async => reports.current,
      ),
    ],
  );
}

Future<void> _settleReport(ProviderContainer container) async {
  await container.read(onboardingEnvironmentReportProvider.future);
  await Future<void>.delayed(Duration.zero);
}

final class _MutableReportSource {
  _MutableReportSource(this.current);

  OnboardingEnvironmentReport current;
}

final class _HeldArchiveMutationCoordinator extends ArchiveMutationCoordinator {
  bool admissionRequested = false;
  final releaseAdmission = Completer<void>();

  @override
  ArchiveMutationCoordinatorState build() {
    return const ArchiveMutationCoordinatorState();
  }

  @override
  Future<T> run<T>({
    required ArchiveMutationOperation operation,
    required String ownerLabel,
    required Future<T> Function() action,
  }) async {
    admissionRequested = true;
    await releaseAdmission.future;
    throw StateError('test admission released without starting mutation');
  }
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
    overlayDatabase: OnboardingDatabaseProbe(
      path: appDatabaseFileName(AppDatabaseFile.overlay),
      exists: true,
      readable: true,
    ),
    sourceScopedImportDatabase: OnboardingDatabaseProbe(
      path: appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
      exists: true,
      readable: true,
      rowCount: 100,
    ),
    conversationGraph: OnboardingDatabaseProbe(
      path: appDatabaseFileName(AppDatabaseFile.conversationGraph),
      exists: true,
      readable: true,
      rowCount: 100,
    ),
    attachmentArchiveDirectory: const OnboardingDatabaseProbe(
      path: 'attachment_archive',
      exists: true,
      readable: true,
    ),
    hasFullDiskAccess: hasFullDiskAccess,
  );
}
