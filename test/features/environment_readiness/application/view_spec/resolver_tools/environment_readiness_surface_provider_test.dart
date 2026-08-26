import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/feature_level_providers.dart'
    show onboardingJourneyCoordinatorProvider;
import 'package:remember_this_text/features/environment_readiness/application/view_spec/resolver_tools/environment_readiness_surface_provider.dart';
import 'package:remember_this_text/features/environment_readiness/domain/entities/environment_readiness_surface_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('environmentReadinessSurfaceProvider', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    test('projects provider loading as a calm checking episode', () {
      container = ProviderContainer(
        overrides: <Override>[
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) => Completer<OnboardingEnvironmentReport>().future,
          ),
        ],
      );

      final surface = container.read(environmentReadinessSurfaceProvider);

      expect(surface.kind, EnvironmentReadinessEpisodeKind.checking);
      expect(surface.title, 'Checking what MessageLens needs');
      expect(surface.actions, isEmpty);
    });

    test('makes Full Disk Access the one prioritized blocker', () async {
      container = _containerFor(
        _report(
          state: OnboardingEnvironmentState.permissionBlocked,
          blockerKind: OnboardingBlockerKind.fullDiskAccessMissing,
          hasFullDiskAccess: false,
        ),
      );

      final surface = await _surface(container);

      expect(surface.kind, EnvironmentReadinessEpisodeKind.blocked);
      expect(surface.title, 'MessageLens needs Full Disk Access');
      expect(surface.instructions, hasLength(3));
      expect(
        surface.primaryAction?.kind,
        EnvironmentReadinessActionKind.openSettings,
      );
      expect(
        surface.evidence.map((item) => item.label),
        containsAll(<String>['Full Disk Access', 'Messages database']),
      );
    });

    test(
      'prioritizes required Contacts source after earlier checks pass',
      () async {
        container = _containerFor(
          _report(
            state: OnboardingEnvironmentState.sourceUnavailable,
            blockerKind: OnboardingBlockerKind.addressBookUnavailable,
          ),
        );

        final surface = await _surface(container);

        expect(surface.kind, EnvironmentReadinessEpisodeKind.blocked);
        expect(surface.title, 'MessageLens needs local Contacts data');
        expect(surface.body, contains('current import pipeline'));
        expect(
          surface.primaryAction?.kind,
          EnvironmentReadinessActionKind.recheck,
        );
      },
    );

    test(
      'ready state has one dominant import action and concise evidence',
      () async {
        container = _containerFor(
          _report(
            state: OnboardingEnvironmentState.readyToImport,
            blockerKind: OnboardingBlockerKind.none,
            messageCount: 137373,
          ),
        );

        final surface = await _surface(container);

        expect(surface.kind, EnvironmentReadinessEpisodeKind.ready);
        expect(surface.title, 'Everything is ready');
        expect(
          surface.sanityEvidence,
          'I found 137,373 messages stored on this Mac.',
        );
        expect(surface.primaryAction?.label, 'Import My Messages');
        expect(surface.secondaryActions, isEmpty);
        expect(
          surface.actions.map((action) => action.kind),
          isNot(contains(EnvironmentReadinessActionKind.recheck)),
        );
      },
    );

    test(
      'accepted sparse-history decision exposes the same import action',
      () async {
        container = _containerFor(
          _report(
            state: OnboardingEnvironmentState.sourceSparseOrUnsynced,
            blockerKind: OnboardingBlockerKind.sourceDataSparseOrUnsynced,
          ),
        );

        await _surface(container);
        container
            .read(onboardingJourneyCoordinatorProvider.notifier)
            .acceptLocalMessageHistory();
        final surface = container.read(environmentReadinessSurfaceProvider);

        expect(surface.kind, EnvironmentReadinessEpisodeKind.ready);
        expect(
          surface.primaryAction?.kind,
          EnvironmentReadinessActionKind.startImport,
        );
      },
    );

    test(
      'unaccepted sparse history is honest guidance rather than a claim',
      () async {
        container = _containerFor(
          _report(
            state: OnboardingEnvironmentState.sourceSparseOrUnsynced,
            blockerKind: OnboardingBlockerKind.sourceDataSparseOrUnsynced,
          ),
        );

        final surface = await _surface(container);

        expect(surface.kind, EnvironmentReadinessEpisodeKind.blocked);
        expect(surface.title, 'Your local Messages history looks incomplete');
        expect(surface.body, contains('If messages you expect are missing'));
        expect(
          surface.body,
          isNot(contains('MessageLens checked your iPhone')),
        );
        expect(
          surface.actions.map((action) => action.kind),
          isNot(contains(EnvironmentReadinessActionKind.startImport)),
        );
      },
    );

    test(
      'inspection failure is distinct from a blocked prerequisite',
      () async {
        container = _containerFor(
          _report(
            state: OnboardingEnvironmentState.sourceUnavailable,
            blockerKind: OnboardingBlockerKind.messagesDatabaseMissing,
            messagesReadable: false,
            messagesFailure: 'SQLite inspection failed',
          ),
        );

        final surface = await _surface(container);

        expect(surface.kind, EnvironmentReadinessEpisodeKind.failed);
        expect(
          surface.title,
          'MessageLens couldn’t check the Messages database',
        );
        expect(surface.primaryAction?.label, 'Try Again');
        expect(
          surface.actions.map((action) => action.kind),
          contains(EnvironmentReadinessActionKind.sendReport),
        );
      },
    );

    test(
      'completed installation does not offer another first-run import',
      () async {
        container = _containerFor(
          _report(
            state: OnboardingEnvironmentState.ready,
            blockerKind: OnboardingBlockerKind.none,
          ),
        );

        final surface = await _surface(container);

        expect(surface.kind, EnvironmentReadinessEpisodeKind.ready);
        expect(surface.title, 'MessageLens is ready');
        expect(surface.actions, isEmpty);
      },
    );

    test(
      'import failure remains retryable even after source acceptance',
      () async {
        container = _containerFor(
          _report(
            state: OnboardingEnvironmentState.importFailed,
            blockerKind: OnboardingBlockerKind.importFailed,
          ),
        );

        final surface = await _surface(container);

        expect(surface.kind, EnvironmentReadinessEpisodeKind.failed);
        expect(surface.title, 'Setup needs another try');
        expect(surface.primaryAction?.label, 'Try Import Again');
      },
    );
  });
}

ProviderContainer _containerFor(OnboardingEnvironmentReport report) {
  return ProviderContainer(
    overrides: <Override>[
      onboardingEnvironmentReportProvider.overrideWith((ref) async => report),
    ],
  );
}

Future<EnvironmentReadinessSurfaceViewModel> _surface(
  ProviderContainer container,
) async {
  await container.read(onboardingEnvironmentReportProvider.future);
  return container.read(environmentReadinessSurfaceProvider);
}

OnboardingEnvironmentReport _report({
  required OnboardingEnvironmentState state,
  required OnboardingBlockerKind blockerKind,
  bool hasFullDiskAccess = true,
  bool messagesReadable = true,
  String? messagesFailure,
  int messageCount = 100,
}) {
  return OnboardingEnvironmentReport(
    state: state,
    blockerKind: blockerKind,
    syncPlausibility: OnboardingSyncPlausibility.unknown,
    messagesDatabase: OnboardingDatabaseProbe(
      path: 'messages.db',
      exists: true,
      readable: messagesReadable,
      rowCount: messageCount,
      failureMessage: messagesFailure,
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
