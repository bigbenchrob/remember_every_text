import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/features/environment_readiness/presentation/view/environment_readiness_panel_view.dart';

void main() {
  testWidgets('ready episode keeps import visible and diagnostics disclosed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => _readyReport(),
          ),
        ],
        child: const MacosApp(home: EnvironmentReadinessPanelView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Everything is ready'), findsOneWidget);
    expect(find.text('Import My Messages'), findsOneWidget);
    expect(
      tester.getBottomLeft(find.text('Import My Messages')).dy,
      lessThan(720),
    );
    expect(find.text('Full Disk Access'), findsNothing);

    await tester.tap(find.text('Details'));
    await tester.pump();

    expect(find.text('Full Disk Access'), findsOneWidget);
    expect(find.text('Available'), findsWidgets);
    expect(find.text('Import My Messages'), findsOneWidget);
  });
}

OnboardingEnvironmentReport _readyReport() {
  return OnboardingEnvironmentReport(
    state: OnboardingEnvironmentState.readyToImport,
    blockerKind: OnboardingBlockerKind.none,
    syncPlausibility: OnboardingSyncPlausibility.likelySyncedOrLocallyAvailable,
    messagesDatabase: const OnboardingDatabaseProbe(
      path: 'messages.db',
      exists: true,
      readable: true,
      rowCount: 137373,
    ),
    addressBookDatabase: const OnboardingDatabaseProbe(
      path: 'addressbook.db',
      exists: true,
      readable: true,
      rowCount: 100,
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
    ),
    conversationGraph: OnboardingDatabaseProbe(
      path: appDatabaseFileName(AppDatabaseFile.conversationGraph),
      exists: true,
      readable: true,
    ),
    attachmentArchiveDirectory: const OnboardingDatabaseProbe(
      path: 'attachment_archive',
      exists: true,
      readable: true,
    ),
    hasFullDiskAccess: true,
  );
}
