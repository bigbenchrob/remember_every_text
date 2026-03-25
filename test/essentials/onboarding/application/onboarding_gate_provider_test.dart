import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';

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
