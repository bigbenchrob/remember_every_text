import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_test_agent_bindings.dart';
import 'package:remember_this_text/essentials/onboarding/application/required_sources_readiness_schedule.dart';
import 'package:remember_this_text/essentials/onboarding/application/required_sources_readiness_scheduler_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_value.dart';
import 'package:remember_this_text/essentials/presence/domain/services/fda_settings_opening_authority.dart';
import 'package:remember_this_text/essentials/presence/domain/services/presence_scheduler.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent_resolver.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/data_sources/local/presence_database.dart';
import 'package:remember_this_text/essentials/presence/infrastructure/repositories/drift_presence_schedule_repository.dart';
import 'package:remember_this_text/features/environment_readiness/application/view_spec/resolver_tools/environment_readiness_surface_provider.dart';
import 'package:remember_this_text/features/environment_readiness/domain/entities/environment_readiness_surface_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PresenceDatabase database;
  late _MutableTestAgent historyAgent;
  late DriftPresenceScheduleRepository repository;

  setUp(() async {
    database = PresenceDatabase(NativeDatabase.memory());
    historyAgent = _MutableTestAgent(result: false);
    final resolver = ImmutableTestAgentResolver(
      buildOnboardingTestAgentBindings(
        messagesSourceReadinessTestAgent: _MutableTestAgent(result: true),
        messagesSourceAccessDeniedTestAgent: _MutableTestAgent(result: false),
        contactsSourceReadinessTestAgent: _MutableTestAgent(result: true),
        messagesSourceHistorySufficiencyTestAgent: historyAgent,
      ),
    );
    repository = DriftPresenceScheduleRepository(
      database: database,
      testAgentResolver: resolver,
      fdaSettingsOpeningAuthority: const _NoOpSettingsAuthority(),
    );
    await repository.insertDefinition(
      buildRequiredSourcesReadinessDefinition(
        testAgentResolver: resolver,
        fdaSettingsOpeningAuthority: const _NoOpSettingsAuthority(),
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'completed sparse workflow exposes import and survives provider restart',
    () async {
      final completionChanges = expectLater(
        repository.watchLatestRunCompletion(requiredSourcesReadinessScheduleId),
        emitsInOrder(<bool>[false, true]),
      );
      final scheduler = await _startScheduler(repository);
      await _completeSparseImportAnywayPath(scheduler);
      await completionChanges;

      var container = _buildContainer(repository, _sparseReport());
      expect(
        await container.read(requiredSourcesReadinessAcceptedProvider.future),
        isTrue,
      );
      await container.read(onboardingEnvironmentReportProvider.future);
      var surface = container.read(environmentReadinessSurfaceProvider);
      expect(surface.title, 'Everything is ready');
      expect(
        surface.actions.map((action) => action.kind),
        contains(EnvironmentReadinessActionKind.startImport),
      );
      container.dispose();

      final restartedRepository = DriftPresenceScheduleRepository(
        database: database,
        fdaSettingsOpeningAuthority: const _NoOpSettingsAuthority(),
      );
      container = _buildContainer(restartedRepository, _sparseReport());
      expect(
        await container.read(requiredSourcesReadinessAcceptedProvider.future),
        isTrue,
      );
      await container.read(onboardingEnvironmentReportProvider.future);
      surface = container.read(environmentReadinessSurfaceProvider);
      expect(surface.title, 'Everything is ready');
      expect(
        surface.actions.map((action) => action.kind),
        contains(EnvironmentReadinessActionKind.startImport),
      );
      container.dispose();
    },
  );

  test('incomplete sparse workflow does not expose import', () async {
    final scheduler = await _startScheduler(repository);
    await _reachSparseChoice(scheduler);
    final container = _buildContainer(repository, _sparseReport());
    addTearDown(container.dispose);

    expect(
      await container.read(requiredSourcesReadinessAcceptedProvider.future),
      isFalse,
    );
    await container.read(onboardingEnvironmentReportProvider.future);
    final surface = container.read(environmentReadinessSurfaceProvider);

    expect(surface.title, 'Your local Messages history looks incomplete');
    expect(
      surface.actions.map((action) => action.kind),
      isNot(contains(EnvironmentReadinessActionKind.startImport)),
    );
  });

  test(
    'sufficient and import-anyway completions establish the same fact',
    () async {
      historyAgent.result = true;
      final scheduler = await _startScheduler(repository);
      await _completeSufficientPath(scheduler);
      final container = _buildContainer(repository, _readyToImportReport());
      addTearDown(container.dispose);

      expect(
        await container.read(requiredSourcesReadinessAcceptedProvider.future),
        isTrue,
      );
      await container.read(onboardingEnvironmentReportProvider.future);
      final surface = container.read(environmentReadinessSurfaceProvider);

      expect(surface.title, 'Everything is ready');
      expect(
        surface.actions.first.kind,
        EnvironmentReadinessActionKind.startImport,
      );
    },
  );
}

ProviderContainer _buildContainer(
  DriftPresenceScheduleRepository repository,
  OnboardingEnvironmentReport report,
) {
  return ProviderContainer(
    overrides: <Override>[
      requiredSourcesReadinessRepositoryProvider.overrideWith(
        (ref) async => repository,
      ),
      onboardingEnvironmentReportProvider.overrideWith((ref) async => report),
    ],
  );
}

Future<PresenceScheduler> _startScheduler(
  DriftPresenceScheduleRepository repository,
) async {
  final scheduler = PresenceScheduler(
    repository: repository,
    scheduleDefinitionId: requiredSourcesReadinessScheduleId,
  );
  await scheduler.initialize();
  return scheduler;
}

Future<void> _completeSparseImportAnywayPath(
  PresenceScheduler scheduler,
) async {
  await _reachSparseChoice(scheduler);
  await scheduler.issueCurrentChoiceSelection()(ChoiceValue('import_anyway'));
  await scheduler.completeCurrentStep();
  expect(scheduler.isComplete, isTrue);
}

Future<void> _reachSparseChoice(PresenceScheduler scheduler) async {
  await scheduler.completeCurrentStep();
  await scheduler.completeCurrentStep();
  await scheduler.completeCurrentStep();
  await scheduler.completeCurrentStep();
  await scheduler.completeCurrentStep();
  await scheduler.completeCurrentStep();
  await scheduler.completeCurrentStep();
}

Future<void> _completeSufficientPath(PresenceScheduler scheduler) async {
  await scheduler.completeCurrentStep();
  await scheduler.completeCurrentStep();
  await scheduler.completeCurrentStep();
  await scheduler.completeCurrentStep();
  await scheduler.completeCurrentStep();
  await scheduler.completeCurrentStep();
  expect(scheduler.isComplete, isTrue);
}

OnboardingEnvironmentReport _sparseReport() {
  return _report(
    state: OnboardingEnvironmentState.sourceSparseOrUnsynced,
    blockerKind: OnboardingBlockerKind.sourceDataSparseOrUnsynced,
  );
}

OnboardingEnvironmentReport _readyToImportReport() {
  return _report(
    state: OnboardingEnvironmentState.readyToImport,
    blockerKind: OnboardingBlockerKind.none,
  );
}

OnboardingEnvironmentReport _report({
  required OnboardingEnvironmentState state,
  required OnboardingBlockerKind blockerKind,
}) {
  return OnboardingEnvironmentReport(
    state: state,
    blockerKind: blockerKind,
    syncPlausibility: OnboardingSyncPlausibility.unknown,
    messagesDatabase: const OnboardingDatabaseProbe(
      path: 'messages.db',
      exists: true,
      readable: true,
      rowCount: 10,
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
      exists: false,
      readable: false,
    ),
    conversationGraph: OnboardingDatabaseProbe(
      path: appDatabaseFileName(AppDatabaseFile.conversationGraph),
      exists: false,
      readable: false,
    ),
    attachmentArchiveDirectory: const OnboardingDatabaseProbe(
      path: 'attachment_archive',
      exists: true,
      readable: true,
    ),
    hasFullDiskAccess: true,
  );
}

final class _MutableTestAgent implements TestAgent {
  _MutableTestAgent({required this.result});

  bool result;

  @override
  Future<bool> evaluate() async => result;
}

final class _NoOpSettingsAuthority implements FdaSettingsOpeningAuthority {
  const _NoOpSettingsAuthority();

  @override
  Future<void> openSettings() async {}
}
