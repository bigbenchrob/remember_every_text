import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/required_sources_readiness_scheduler_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/features/environment_readiness/application/view_spec/resolver_tools/environment_readiness_surface_provider.dart';
import 'package:remember_this_text/features/environment_readiness/domain/entities/environment_readiness_surface_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('environmentReadinessSurfaceProvider', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    test(
      'activates full disk access step when permission is blocked',
      () async {
        container = ProviderContainer(
          overrides: [
            _requiredSourcesAccepted(false),
            onboardingEnvironmentReportProvider.overrideWith(
              (ref) async => _report(
                state: OnboardingEnvironmentState.permissionBlocked,
                blockerKind: OnboardingBlockerKind.fullDiskAccessMissing,
                hasFullDiskAccess: false,
              ),
            ),
          ],
        );

        await container.read(onboardingEnvironmentReportProvider.future);
        final surface = container.read(environmentReadinessSurfaceProvider);

        expect(
          surface.detail.stepKey,
          EnvironmentReadinessStepKey.fullDiskAccess,
        );
        expect(
          surface.steps.first.status,
          EnvironmentReadinessStepStatus.active,
        );
        expect(
          surface.detail.actions.first.kind,
          EnvironmentReadinessActionKind.openSettings,
        );
      },
    );

    test('advances to contacts step when earlier checks are healthy', () async {
      container = ProviderContainer(
        overrides: [
          _requiredSourcesAccepted(false),
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => _report(
              state: OnboardingEnvironmentState.sourceUnavailable,
              blockerKind: OnboardingBlockerKind.addressBookUnavailable,
            ),
          ),
        ],
      );

      await container.read(onboardingEnvironmentReportProvider.future);
      final surface = container.read(environmentReadinessSurfaceProvider);

      expect(
        surface.detail.stepKey,
        EnvironmentReadinessStepKey.contactsDatabase,
      );
      expect(surface.steps[0].status, EnvironmentReadinessStepStatus.success);
      expect(surface.steps[1].status, EnvironmentReadinessStepStatus.success);
      expect(surface.steps[2].status, EnvironmentReadinessStepStatus.active);
      expect(surface.steps[3].status, EnvironmentReadinessStepStatus.pending);
    });

    test('uses retry copy when import has failed', () async {
      container = ProviderContainer(
        overrides: [
          _requiredSourcesAccepted(false),
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => _report(
              state: OnboardingEnvironmentState.importFailed,
              blockerKind: OnboardingBlockerKind.importFailed,
            ),
          ),
        ],
      );

      await container.read(onboardingEnvironmentReportProvider.future);
      final surface = container.read(environmentReadinessSurfaceProvider);

      expect(
        surface.detail.stepKey,
        EnvironmentReadinessStepKey.importReadiness,
      );
      expect(surface.detail.title, 'Retry Setup');
      expect(surface.detail.actions.first.label, 'Try Import Again');
      expect(surface.detail.actions.map((action) => action.kind), [
        EnvironmentReadinessActionKind.startImport,
        EnvironmentReadinessActionKind.sendReport,
        EnvironmentReadinessActionKind.recheck,
      ]);
      expect(surface.detail.tone, EnvironmentReadinessTone.warning);
    });

    test('shows normal-use readiness when graph is already ready', () async {
      container = ProviderContainer(
        overrides: [
          _requiredSourcesAccepted(false),
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => _report(
              state: OnboardingEnvironmentState.ready,
              blockerKind: OnboardingBlockerKind.none,
            ),
          ),
        ],
      );

      await container.read(onboardingEnvironmentReportProvider.future);
      final surface = container.read(environmentReadinessSurfaceProvider);

      expect(
        surface.detail.stepKey,
        EnvironmentReadinessStepKey.importReadiness,
      );
      expect(surface.detail.title, 'Ready To Use');
      expect(surface.detail.actions.map((action) => action.kind), [
        EnvironmentReadinessActionKind.recheck,
      ]);
      expect(surface.steps.map((step) => step.status).toSet(), {
        EnvironmentReadinessStepStatus.success,
      });
    });

    test('offers import when sparse source readiness was accepted', () async {
      container = ProviderContainer(
        overrides: [
          _requiredSourcesAccepted(true),
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => _report(
              state: OnboardingEnvironmentState.sourceSparseOrUnsynced,
              blockerKind: OnboardingBlockerKind.sourceDataSparseOrUnsynced,
            ),
          ),
        ],
      );

      await container.read(onboardingEnvironmentReportProvider.future);
      await container.read(requiredSourcesReadinessAcceptedProvider.future);
      final surface = container.read(environmentReadinessSurfaceProvider);

      expect(
        surface.activeStepKey,
        EnvironmentReadinessStepKey.importReadiness,
      );
      expect(surface.detail.title, 'Ready To Import');
      expect(surface.detail.body, contains('limited local Messages history'));
      expect(surface.detail.actions.map((action) => action.kind), [
        EnvironmentReadinessActionKind.startImport,
        EnvironmentReadinessActionKind.recheck,
      ]);
    });

    test('keeps sparse unaccepted source at confirmation', () async {
      container = ProviderContainer(
        overrides: [
          _requiredSourcesAccepted(false),
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => _report(
              state: OnboardingEnvironmentState.sourceSparseOrUnsynced,
              blockerKind: OnboardingBlockerKind.sourceDataSparseOrUnsynced,
            ),
          ),
        ],
      );

      await container.read(onboardingEnvironmentReportProvider.future);
      await container.read(requiredSourcesReadinessAcceptedProvider.future);
      final surface = container.read(environmentReadinessSurfaceProvider);

      expect(
        surface.activeStepKey,
        EnvironmentReadinessStepKey.messagesDatabase,
      );
      expect(surface.detail.title, 'Confirm Local Messages History');
      expect(surface.detail.actions.map((action) => action.kind), [
        EnvironmentReadinessActionKind.recheck,
      ]);
    });

    test('accepted readiness does not override import failure', () async {
      container = ProviderContainer(
        overrides: [
          _requiredSourcesAccepted(true),
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => _report(
              state: OnboardingEnvironmentState.importFailed,
              blockerKind: OnboardingBlockerKind.importFailed,
            ),
          ),
        ],
      );

      await container.read(onboardingEnvironmentReportProvider.future);
      await container.read(requiredSourcesReadinessAcceptedProvider.future);
      final surface = container.read(environmentReadinessSurfaceProvider);

      expect(surface.detail.title, 'Retry Setup');
      expect(surface.detail.actions.first.label, 'Try Import Again');
    });
  });
}

Override _requiredSourcesAccepted(bool accepted) {
  return requiredSourcesReadinessAcceptedProvider.overrideWith(
    (ref) => Stream<bool>.value(accepted),
  );
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
