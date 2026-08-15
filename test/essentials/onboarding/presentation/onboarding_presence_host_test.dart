import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_test_agent_bindings.dart';
import 'package:remember_this_text/essentials/onboarding/application/required_sources_readiness_schedule.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/onboarding_presence_host.dart';
import 'package:remember_this_text/essentials/presence/domain/services/fda_settings_opening_authority.dart';
import 'package:remember_this_text/essentials/presence/domain/services/presence_scheduler.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent_resolver.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/presence_database.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_presence_schedule_repository.dart';
import 'package:remember_this_text/essentials/presence/presentation/presence_step_presenter.dart';

void main() {
  late PresenceDatabase database;
  late _MutableTestAgent messagesAgent;
  late _MutableTestAgent messagesAccessDeniedAgent;
  late _MutableTestAgent contactsAgent;
  late _MutableTestAgent historyAgent;
  late _RecordingFdaSettingsAuthority fdaSettingsAuthority;

  setUp(() {
    database = PresenceDatabase(NativeDatabase.memory());
    messagesAgent = _MutableTestAgent(result: true);
    messagesAccessDeniedAgent = _MutableTestAgent(result: false);
    contactsAgent = _MutableTestAgent(result: true);
    historyAgent = _MutableTestAgent(result: true);
    fdaSettingsAuthority = _RecordingFdaSettingsAuthority();
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('real Onboarding Tell and sufficient path use Presence', (
    tester,
  ) async {
    final scheduler = await _startScheduler(
      database: database,
      messagesAgent: messagesAgent,
      messagesAccessDeniedAgent: messagesAccessDeniedAgent,
      contactsAgent: contactsAgent,
      historyAgent: historyAgent,
      fdaSettingsAuthority: fdaSettingsAuthority,
    );
    await _pumpSurface(tester, scheduler);

    expect(find.byType(PresenceStepPresenter), findsOneWidget);
    expect(find.text('Welcome to MessageLens.'), findsOneWidget);
    await _completeTell(tester);
    await _completeTell(tester);
    await _pumpUntilText(
      tester,
      'MessageLens can read the local Messages and Contacts information it needs.',
    );

    expect(find.text('Re-check'), findsNothing);
    expect(historyAgent.invocationCount, 1);
  });

  testWidgets('real sparse Choice re-checks a fresh fact in production host', (
    tester,
  ) async {
    historyAgent.result = false;
    final scheduler = await _startScheduler(
      database: database,
      messagesAgent: messagesAgent,
      messagesAccessDeniedAgent: messagesAccessDeniedAgent,
      contactsAgent: contactsAgent,
      historyAgent: historyAgent,
      fdaSettingsAuthority: fdaSettingsAuthority,
    );
    await _pumpSurface(tester, scheduler);

    await _advanceIntroductionToSparseChoice(tester);
    expect(find.text('Re-check'), findsOneWidget);
    expect(find.text('Import Anyway'), findsOneWidget);

    historyAgent.result = true;
    await tester.tap(find.text('Re-check'));
    await _pumpUntilText(
      tester,
      'MessageLens can read the local Messages and Contacts information it needs.',
    );

    expect(historyAgent.invocationCount, 2);
    expect(
      scheduler.currentTrip?.definition.id,
      confirmRequiredSourcesReadableTripId,
    );
  });

  testWidgets('real sparse Choice imports anyway through persisted geometry', (
    tester,
  ) async {
    historyAgent.result = false;
    final scheduler = await _startScheduler(
      database: database,
      messagesAgent: messagesAgent,
      messagesAccessDeniedAgent: messagesAccessDeniedAgent,
      contactsAgent: contactsAgent,
      historyAgent: historyAgent,
      fdaSettingsAuthority: fdaSettingsAuthority,
    );
    await _pumpSurface(tester, scheduler);

    await _advanceIntroductionToSparseChoice(tester);
    await tester.tap(find.text('Import Anyway'));
    await _pumpUntilText(
      tester,
      'MessageLens can read the local Messages and Contacts information it needs.',
    );

    expect(historyAgent.invocationCount, 1);
    expect(
      scheduler.currentTrip?.definition.id,
      confirmRequiredSourcesReadableTripId,
    );
  });

  testWidgets('FDA Step retains its explicit Onboarding presentation path', (
    tester,
  ) async {
    messagesAgent.result = false;
    messagesAccessDeniedAgent.result = true;
    final scheduler = await _startScheduler(
      database: database,
      messagesAgent: messagesAgent,
      messagesAccessDeniedAgent: messagesAccessDeniedAgent,
      contactsAgent: contactsAgent,
      historyAgent: historyAgent,
      fdaSettingsAuthority: fdaSettingsAuthority,
    );
    await _pumpSurface(tester, scheduler);

    await _completeTell(tester);
    await _completeTell(tester);
    await _pumpUntilText(
      tester,
      'MessageLens needs permission to read your Messages and Contacts data. '
      'On macOS, Apple calls this Full Disk Access.',
    );
    await _completeTell(tester);
    await _pumpUntilText(
      tester,
      'In Full Disk Access, add or enable MessageLens Development. macOS may '
      'ask you to quit and reopen the app after you make the change.',
    );
    expect(
      find.textContaining('add or enable MessageLens Development.'),
      findsOneWidget,
    );
    await _completeTell(tester);
    await _pumpUntilText(tester, 'Open System Settings');

    await tester.tap(find.text('Open System Settings'));
    await _pumpUntilText(
      tester,
      'Welcome back. I’ll check whether MessageLens can now read the protected '
      'Messages database.',
    );

    expect(fdaSettingsAuthority.invocationCount, 1);
    expect(
      scheduler.currentTrip?.definition.id,
      verifyMessagesSourceReadinessTripId,
    );
  });

  testWidgets('non-FDA source failure presents no permission remediation', (
    tester,
  ) async {
    messagesAgent.result = false;
    messagesAccessDeniedAgent.result = false;
    final scheduler = await _startScheduler(
      database: database,
      messagesAgent: messagesAgent,
      messagesAccessDeniedAgent: messagesAccessDeniedAgent,
      contactsAgent: contactsAgent,
      historyAgent: historyAgent,
      fdaSettingsAuthority: fdaSettingsAuthority,
    );
    await _pumpSurface(tester, scheduler);

    await _completeTell(tester);
    await _completeTell(tester);
    await _pumpUntilText(
      tester,
      'MessageLens can’t currently use your Messages data. If Messages or its '
      'local data changed recently, allow it to settle, then continue and I’ll '
      'check again.',
    );

    expect(find.textContaining('Full Disk Access'), findsNothing);
    expect(find.text('Open System Settings'), findsNothing);
    expect(fdaSettingsAuthority.invocationCount, 0);
  });
}

Future<PresenceScheduler> _startScheduler({
  required PresenceDatabase database,
  required TestAgent messagesAgent,
  required TestAgent messagesAccessDeniedAgent,
  required TestAgent contactsAgent,
  required TestAgent historyAgent,
  required FdaSettingsOpeningAuthority fdaSettingsAuthority,
}) async {
  final resolver = ImmutableTestAgentResolver(
    buildOnboardingTestAgentBindings(
      messagesSourceReadinessTestAgent: messagesAgent,
      messagesSourceAccessDeniedTestAgent: messagesAccessDeniedAgent,
      contactsSourceReadinessTestAgent: contactsAgent,
      messagesSourceHistorySufficiencyTestAgent: historyAgent,
    ),
  );
  final repository = DriftPresenceScheduleRepository(
    database: database,
    testAgentResolver: resolver,
    fdaSettingsOpeningAuthority: fdaSettingsAuthority,
  );
  await repository.insertDefinition(
    buildRequiredSourcesReadinessDefinition(
      testAgentResolver: resolver,
      fdaSettingsOpeningAuthority: fdaSettingsAuthority,
    ),
  );
  final scheduler = PresenceScheduler(
    repository: repository,
    scheduleDefinitionId: requiredSourcesReadinessScheduleId,
  );
  await scheduler.initialize();
  return scheduler;
}

Future<void> _pumpSurface(
  WidgetTester tester,
  PresenceScheduler scheduler,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1200, 900);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        onboardingEnvironmentReportProvider.overrideWith((ref) async {
          throw StateError('No environment report required by this test.');
        }),
      ],
      child: MacosApp(home: OnboardingPresenceSurface(scheduler: scheduler)),
    ),
  );
  await tester.pump();
}

Future<void> _advanceIntroductionToSparseChoice(WidgetTester tester) async {
  await _completeTell(tester);
  await _completeTell(tester);
  await _pumpUntilText(
    tester,
    'MessageLens found very little Messages history stored locally on this Mac.',
  );
  await _completeTell(tester);
  await _completeTell(tester);
  await _pumpUntilText(tester, 'Re-check');
}

Future<void> _completeTell(WidgetTester tester) async {
  await tester.tap(find.text('Complete Step'));
  await tester.pump();
}

Future<void> _pumpUntilText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  for (var attempt = 0; attempt < 80; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 10));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Expected text was not rendered: $text');
}

final class _MutableTestAgent implements TestAgent {
  _MutableTestAgent({required this.result});

  bool result;
  int invocationCount = 0;

  @override
  Future<bool> evaluate() async {
    invocationCount += 1;
    return result;
  }
}

final class _RecordingFdaSettingsAuthority
    implements FdaSettingsOpeningAuthority {
  int invocationCount = 0;

  @override
  Future<void> openSettings() async {
    invocationCount += 1;
  }
}
