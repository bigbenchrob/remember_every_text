import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
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
  });
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
