import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db_importers/presentation/view_model/db_import_control_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/onboarding_overlay.dart';

void main() {
  testWidgets(
    'shows missing-ledger recovery explanation and report action during automatic cleanup',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer(
        overrides: [
          onboardingGateProvider.overrideWith(_RecoveringGate.new),
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => const OnboardingEnvironmentReport(
              state: OnboardingEnvironmentState.migrationFailed,
              blockerKind: OnboardingBlockerKind.importDatabaseMissing,
              syncPlausibility: OnboardingSyncPlausibility.unknown,
              messagesDatabase: OnboardingDatabaseProbe(
                path: 'messages.db',
                exists: true,
                readable: true,
                rowCount: 100,
              ),
              addressBookDatabase: OnboardingDatabaseProbe(
                path: 'addressbook.db',
                exists: true,
                readable: true,
                rowCount: 10,
              ),
              importDatabase: OnboardingDatabaseProbe(
                path: 'macos_import.db',
                exists: false,
                readable: false,
                rowCount: 0,
              ),
              workingDatabase: OnboardingDatabaseProbe(
                path: 'working.db',
                exists: true,
                readable: true,
                rowCount: 1,
                projectionStatus: 'incomplete',
              ),
              hasFullDiskAccess: true,
              shouldResetAppDatabasesBeforeImport: true,
              resetAppDatabasesReason:
                  'macos_import.db is missing while working.db remains incomplete',
            ),
          ),
          dbImportControlViewModelProvider.overrideWith(
            _IdleDbImportControlViewModel.new,
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: OnboardingOverlay())),
        ),
      );
      await tester.pump();

      expect(find.text('Rebuilding From Source Is Required'), findsOneWidget);
      expect(find.textContaining('working database is incomplete'), findsOne);
      expect(find.textContaining('macos_import.db'), findsWidgets);
      expect(
        find.textContaining('Migration cannot repair this state'),
        findsOne,
      );
      expect(
        find.textContaining(
          'rebuild message data from the original local sources on this Mac',
        ),
        findsOne,
      );
      expect(find.text('Send Report To Developer'), findsOneWidget);
      expect(find.text('Cleaning Up A Previous Setup Attempt'), findsNothing);
    },
  );
}

class _RecoveringGate extends OnboardingGate {
  @override
  OnboardingStatus build() {
    return OnboardingStatus.recoveringFailedAttempt;
  }
}

class _IdleDbImportControlViewModel extends DbImportControlViewModel {
  @override
  DbImportControlState build() {
    return const DbImportControlState(
      statusMessage: 'Resetting incomplete app databases...',
    );
  }
}
