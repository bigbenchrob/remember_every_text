import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:remember_this_text/domain_driven_development/value_objects.dart';
import 'package:remember_this_text/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart'
    show ArchiveMutationCapability;
import 'package:remember_this_text/essentials/archive_environment/domain.dart'
    show ArchiveMutationDeniedException, ArchiveMutationOperation;
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show
        ArchiveMutationCoordinator,
        ArchiveMutationCoordinatorState,
        archiveAccessAuthorityProvider,
        archiveMutationCoordinatorProvider;
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_controller_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_service_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_state.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/chat_db_change_monitor_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/navigation/feature_level_providers.dart'
    show SidebarMode, activeSidebarModeProvider;
import 'package:remember_this_text/essentials/onboarding/application/message_data_reset_service.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_durable_completion_verifier_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_failure_storage_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_controller.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_journey_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/onboarding_journey_path.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/onboarding_overlay.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/attachments/attachment_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/source_import_work_progress.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_import_anomaly_counts.dart';
import 'package:remember_this_text/features/address_book_folders/application/address_book_folder_providers.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_aggregate.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_entity.dart';
import 'package:remember_this_text/features/address_book_folders/domain/value_objects/value_objects.dart';
import '../../../test_support/test_archive_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('onboardingGateProvider', () {
    late TestArchiveFixture archiveFixture;
    late ProviderContainer container;

    setUpAll(() async {
      archiveFixture = await TestArchiveFixture.create(
        prefix: 'onboarding_gate_provider_shared_db_dir_',
      );
    });

    tearDownAll(() async {
      await archiveFixture.dispose();
    });

    tearDown(() {
      container.dispose();
    });

    test('maps permission-blocked environment to awaitingFda', () async {
      container = ProviderContainer(
        overrides: [
          archiveAccessAuthorityProvider.overrideWithValue(
            archiveFixture.authority,
          ),
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
          archiveAccessAuthorityProvider.overrideWithValue(
            archiveFixture.authority,
          ),
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
          archiveAccessAuthorityProvider.overrideWithValue(
            archiveFixture.authority,
          ),
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
      'keeps graph projection failures inside awaitingUserAction contract',
      () async {
        container = ProviderContainer(
          overrides: [
            archiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            onboardingEnvironmentReportProvider.overrideWith(
              (ref) async => _report(
                state: OnboardingEnvironmentState.graphProjectionFailed,
                blockerKind: OnboardingBlockerKind.graphProjectionFailed,
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
            archiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
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

    test('preserves importing workflow status during report rebuilds', () {
      final status = OnboardingGate.resolveBuildStatus(
        reportAsync: AsyncData(
          _report(
            state: OnboardingEnvironmentState.importFailed,
            blockerKind: OnboardingBlockerKind.importFailed,
          ),
        ),
        workflowOverrideStatus: OnboardingStatus.importing,
        fallbackBuildStatus: () => OnboardingStatus.awaitingUserAction,
      );

      expect(status, OnboardingStatus.importing);
    });

    test('preserves completion status during report rebuilds', () {
      final status = OnboardingGate.resolveBuildStatus(
        reportAsync: AsyncData(
          _report(
            state: OnboardingEnvironmentState.ready,
            blockerKind: OnboardingBlockerKind.none,
          ),
        ),
        workflowOverrideStatus: OnboardingStatus.complete,
        fallbackBuildStatus: () => OnboardingStatus.notNeeded,
      );

      expect(status, OnboardingStatus.complete);
    });

    test('preserves recovery status during report rebuilds', () {
      final status = OnboardingGate.resolveBuildStatus(
        reportAsync: AsyncData(
          _report(
            state: OnboardingEnvironmentState.graphProjectionFailed,
            blockerKind: OnboardingBlockerKind.graphProjectionFailed,
          ),
        ),
        workflowOverrideStatus: OnboardingStatus.recoveringFailedAttempt,
        fallbackBuildStatus: () => OnboardingStatus.awaitingUserAction,
      );

      expect(status, OnboardingStatus.recoveringFailedAttempt);
    });

    test(
      'preserves process-local preparation failure during report rebuilds',
      () {
        final status = OnboardingGate.resolveBuildStatus(
          reportAsync: AsyncData(
            _report(
              state: OnboardingEnvironmentState.readyToImport,
              blockerKind:
                  OnboardingBlockerKind.sourceScopedImportDatabaseMissing,
            ),
          ),
          workflowOverrideStatus: OnboardingStatus.preparationFailed,
          fallbackBuildStatus: () => OnboardingStatus.awaitingUserAction,
        );

        expect(status, OnboardingStatus.preparationFailed);
      },
    );

    test('falls back to derived status when no workflow override exists', () {
      final status = OnboardingGate.resolveBuildStatus(
        reportAsync: AsyncData(
          _report(
            state: OnboardingEnvironmentState.graphProjectionFailed,
            blockerKind: OnboardingBlockerKind.graphProjectionFailed,
          ),
        ),
        workflowOverrideStatus: null,
        fallbackBuildStatus: () => OnboardingStatus.notNeeded,
      );

      expect(status, OnboardingStatus.awaitingUserAction);
    });

    test('active maintenance does not request onboarding action', () {
      final status = OnboardingGate.resolveBuildStatus(
        reportAsync: AsyncData(
          _report(
            state: OnboardingEnvironmentState.maintenanceInProgress,
            blockerKind: OnboardingBlockerKind.none,
          ),
        ),
        workflowOverrideStatus: null,
        fallbackBuildStatus: () => OnboardingStatus.awaitingUserAction,
      );

      expect(status, OnboardingStatus.notNeeded);
    });

    test('refreshEnvironment re-checks full disk access', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'onboarding_gate_provider_test',
      );
      final overlayDb = OverlayDatabase(NativeDatabase.memory());
      final messagesDbPath = _createReadableFile(tempDir.path, 'messages.db');
      final addressBookPath = _createReadableFile(
        tempDir.path,
        'AddressBook-v22.abcddb',
      );
      var hasFullDiskAccess = true;

      addTearDown(() async {
        await overlayDb.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });

      container = ProviderContainer(
        overrides: [
          archiveAccessAuthorityProvider.overrideWithValue(
            archiveFixture.authority,
          ),
          ..._lifecycleOverrides(),
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          onboardingFullDiskAccessProvider.overrideWith(
            (ref) => hasFullDiskAccess,
          ),
          onboardingMessagesDatabasePathProvider.overrideWith(
            (ref) => messagesDbPath,
          ),
          onboardingDatabaseDirectoryPathProvider.overrideWith(
            (ref) => tempDir.path,
          ),
          futureGetFolderAggregateProvider.overrideWith(
            (ref) async => right(_addressBookAggregate(addressBookPath)),
          ),
        ],
      );

      expect(
        await _readGateStatus(container),
        OnboardingStatus.awaitingUserAction,
      );

      hasFullDiskAccess = false;
      container.read(onboardingGateProvider.notifier).refreshEnvironment();

      expect(await _readGateStatus(container), OnboardingStatus.awaitingFda);
    });

    testWidgets(
      'first-run preparation completes with preserved handle anomaly evidence',
      (tester) async {
        final resetCompleter = Completer<void>();
        final resetService = _FakeMessageDataResetService()
          ..resetCompleter = resetCompleter;
        final graphBuildCompleter = Completer<void>();
        final overlayDb = OverlayDatabase(NativeDatabase.memory());
        var graphBuildCallCount = 0;

        addTearDown(() async {
          resetService.resetCompleter = null;
          await overlayDb.close();
        });

        container = ProviderContainer(
          overrides: _firstRunOverrides(
            archiveFixture: archiveFixture,
            overlayDb: overlayDb,
            resetService: resetService,
            onGraphBuild: () {
              graphBuildCallCount += 1;
            },
            graphBuildCompleter: graphBuildCompleter,
            preservedUnnormalizedHandleCount: 1,
          ),
        );

        await _pumpGateOverlay(tester, container);
        expect(
          await _readGateStatus(container),
          OnboardingStatus.awaitingUserAction,
        );

        final firstStart = container
            .read(onboardingGateProvider.notifier)
            .startImportAndGraphBuild();
        await tester.pump();

        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.importing,
        );
        expect(resetService.resetDerivedDataCallCount, 1);
        expect(graphBuildCallCount, 0);
        expect(find.text('Preparing setup…'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);

        await container
            .read(onboardingGateProvider.notifier)
            .startImportAndGraphBuild();
        expect(resetService.resetDerivedDataCallCount, 1);
        expect(graphBuildCallCount, 0);

        resetCompleter.complete();
        await tester.pump();
        await tester.pump();

        expect(graphBuildCallCount, 1);
        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.buildingGraph,
        );
        expect(find.text('Building browsing data…'), findsOneWidget);

        graphBuildCompleter.complete();
        await tester.pump();
        await firstStart;
        await tester.pump();

        expect(graphBuildCallCount, 1);
        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.complete,
        );
        final completedOperation = (await container.read(
          onboardingOperationControllerProvider.future,
        )).current;
        expect(completedOperation.status, OnboardingOperationStatus.completed);
        expect(completedOperation.preservedUnnormalizedHandleCount, 1);

        final sidebarModeSubscription = container.listen<SidebarMode>(
          activeSidebarModeProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(sidebarModeSubscription.close);
        container
            .read(activeSidebarModeProvider.notifier)
            .setMode(SidebarMode.settings);

        await tester.tap(find.text('OK'));
        await tester.pump();
        await tester.pump();

        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.notNeeded,
        );
        expect(container.read(activeSidebarModeProvider), SidebarMode.messages);
      },
    );

    testWidgets(
      'durable verification gates Start while the human path remains on Import',
      (tester) async {
        final overlayDb = OverlayDatabase(NativeDatabase.memory());
        final verifier = _HeldDurableCompletionVerifier();
        addTearDown(overlayDb.close);

        container = ProviderContainer(
          overrides: _firstRunOverrides(
            archiveFixture: archiveFixture,
            overlayDb: overlayDb,
            resetService: _FakeMessageDataResetService(),
            onGraphBuild: () {},
            durableCompletionVerifier: verifier,
          ),
        );

        await _pumpGateOverlay(tester, container);
        expect(
          await _readGateStatus(container),
          OnboardingStatus.awaitingUserAction,
        );

        final import = container
            .read(onboardingGateProvider.notifier)
            .startImportAndGraphBuild();
        await tester.pump();
        await tester.pump();
        await tester.pump();

        expect(verifier.started.isCompleted, isTrue);
        final verifying = container.read(onboardingJourneyCoordinatorProvider);
        expect(verifying, isA<OnboardingVerifyingDurableReadiness>());
        final verifyingPath = projectOnboardingJourneyPath(verifying)!;
        expect(verifyingPath.currentNode, OnboardingJourneyPathNode.import);
        expect(
          verifyingPath.nodeStates[OnboardingJourneyPathNode.start],
          OnboardingJourneyPathNodeState.future,
        );

        verifier.completeSuccessfully();
        await import;
        await tester.pump();

        final ready = container.read(onboardingJourneyCoordinatorProvider);
        expect(ready, isA<OnboardingReadyToStart>());
        final readyPath = projectOnboardingJourneyPath(ready)!;
        expect(readyPath.currentNode, OnboardingJourneyPathNode.start);
        expect(
          readyPath.nodeStates[OnboardingJourneyPathNode.import],
          OnboardingJourneyPathNodeState.completed,
        );
      },
    );

    testWidgets('durable verification failure never exposes Start', (
      tester,
    ) async {
      final overlayDb = OverlayDatabase(NativeDatabase.memory());
      addTearDown(overlayDb.close);

      container = ProviderContainer(
        overrides: _firstRunOverrides(
          archiveFixture: archiveFixture,
          overlayDb: overlayDb,
          resetService: _FakeMessageDataResetService(),
          onGraphBuild: () {},
          durableCompletionVerifier: const _FailingDurableCompletionVerifier(),
        ),
      );

      await _pumpGateOverlay(tester, container);
      expect(
        await _readGateStatus(container),
        OnboardingStatus.awaitingUserAction,
      );

      final import = container
          .read(onboardingGateProvider.notifier)
          .startImportAndGraphBuild();
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await import;
      await tester.pump();

      final failed = container.read(onboardingJourneyCoordinatorProvider);
      expect(failed, isA<OnboardingOperationFailed>());
      final failedPath = projectOnboardingJourneyPath(failed)!;
      expect(failedPath.currentNode, OnboardingJourneyPathNode.import);
      expect(
        failedPath.nodeStates[OnboardingJourneyPathNode.start],
        OnboardingJourneyPathNodeState.future,
      );
      expect(find.text('Start'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey<String>('onboarding-journey-node-start-current'),
        ),
        findsNothing,
      );
    });

    testWidgets('first-run FDA failure does not publish preparation', (
      tester,
    ) async {
      final resetService = _FakeMessageDataResetService();
      final overlayDb = OverlayDatabase(NativeDatabase.memory());
      var graphBuildCallCount = 0;

      addTearDown(() async {
        await overlayDb.close();
      });

      container = ProviderContainer(
        overrides: _firstRunOverrides(
          archiveFixture: archiveFixture,
          overlayDb: overlayDb,
          resetService: resetService,
          hasFullDiskAccess: false,
          onGraphBuild: () {
            graphBuildCallCount += 1;
          },
        ),
      );

      await tester.pumpWidget(_GateHarness(container: container));
      expect(
        await _readGateStatus(container),
        OnboardingStatus.awaitingUserAction,
      );

      await container
          .read(onboardingGateProvider.notifier)
          .startImportAndGraphBuild();
      await tester.pump();

      expect(
        container.read(onboardingGateProvider),
        OnboardingStatus.awaitingFda,
      );
      expect(resetService.resetDerivedDataCallCount, 0);
      expect(graphBuildCallCount, 0);
    });

    testWidgets(
      'first-run reset failure presents stable process-local retry and support',
      (tester) async {
        final resetError = StateError('synthetic reset failure');
        final resetService = _FakeMessageDataResetService()
          ..resetError = resetError;
        final overlayDb = OverlayDatabase(NativeDatabase.memory());
        var graphBuildCallCount = 0;

        addTearDown(() async {
          await overlayDb.close();
        });

        container = ProviderContainer(
          overrides: _firstRunOverrides(
            archiveFixture: archiveFixture,
            overlayDb: overlayDb,
            resetService: resetService,
            onGraphBuild: () {
              graphBuildCallCount += 1;
            },
          ),
        );

        await _pumpGateOverlay(tester, container);
        expect(
          await _readGateStatus(container),
          OnboardingStatus.awaitingUserAction,
        );

        final startFuture = container
            .read(onboardingGateProvider.notifier)
            .startImportAndGraphBuild();
        await tester.pump();
        await startFuture;
        await tester.pump();

        expect(resetService.resetDerivedDataCallCount, 1);
        expect(graphBuildCallCount, 0);
        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.preparationFailed,
        );
        await tester.pump();
        expect(resetService.resetDerivedDataCallCount, 1);
        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.preparationFailed,
        );
        expect(find.text('Preparing setup…'), findsNothing);
        expect(find.text("MessageLens couldn't finish setup"), findsOneWidget);
        expect(
          find.text(
            "MessageLens couldn't finish preparing your browsing data. "
            'You can try again.',
          ),
          findsOneWidget,
        );
        expect(find.text('Try Again'), findsOneWidget);
        expect(find.text('Send Report To Developer'), findsOneWidget);
        expect(find.textContaining('synthetic reset failure'), findsNothing);
        final failedOperation = (await container.read(
          onboardingOperationControllerProvider.future,
        )).current;
        expect(failedOperation.status, OnboardingOperationStatus.failed);
        expect(
          failedOperation.failure?.category,
          OnboardingOperationFailureCategory.environmentPreparation,
        );

        resetService.resetError = null;
        await tester.tap(find.text('Try Again'));
        await tester.pump();
        await tester.pump();
        await tester.pump();

        expect(resetService.resetDerivedDataCallCount, 2);
        expect(graphBuildCallCount, 1);
        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.complete,
        );
      },
    );

    testWidgets(
      'refresh clears process-local preparation failure and reprojects environment',
      (tester) async {
        final resetService = _FakeMessageDataResetService()
          ..resetError = StateError('synthetic reset failure');
        final overlayDb = OverlayDatabase(NativeDatabase.memory());

        addTearDown(() async {
          await overlayDb.close();
        });

        container = ProviderContainer(
          overrides: _firstRunOverrides(
            archiveFixture: archiveFixture,
            overlayDb: overlayDb,
            resetService: resetService,
            onGraphBuild: () {},
          ),
        );

        await tester.pumpWidget(_GateHarness(container: container));
        expect(
          await _readGateStatus(container),
          OnboardingStatus.awaitingUserAction,
        );
        final startFuture = container
            .read(onboardingGateProvider.notifier)
            .startImportAndGraphBuild();
        await tester.pump();
        await startFuture;
        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.preparationFailed,
        );

        container.read(onboardingGateProvider.notifier).refreshEnvironment();

        expect(
          await _readGateStatus(container),
          OnboardingStatus.awaitingUserAction,
        );
      },
    );

    testWidgets(
      'process-local preparation failure is not reconstructed by a new Gate',
      (tester) async {
        final resetService = _FakeMessageDataResetService()
          ..resetError = StateError('synthetic reset failure');
        final overlayDb = OverlayDatabase(NativeDatabase.memory());

        addTearDown(() async {
          await overlayDb.close();
        });

        container = ProviderContainer(
          overrides: _firstRunOverrides(
            archiveFixture: archiveFixture,
            overlayDb: overlayDb,
            resetService: resetService,
            onGraphBuild: () {},
          ),
        );
        await tester.pumpWidget(_GateHarness(container: container));
        expect(
          await _readGateStatus(container),
          OnboardingStatus.awaitingUserAction,
        );
        final startFuture = container
            .read(onboardingGateProvider.notifier)
            .startImportAndGraphBuild();
        await tester.pump();
        await startFuture;
        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.preparationFailed,
        );

        container.dispose();
        container = ProviderContainer(
          overrides: _firstRunOverrides(
            archiveFixture: archiveFixture,
            overlayDb: overlayDb,
            resetService: _FakeMessageDataResetService(),
            onGraphBuild: () {},
          ),
        );

        expect(
          await _readGateStatus(container),
          OnboardingStatus.awaitingUserAction,
        );
      },
    );

    testWidgets(
      'settings reimport completes and Done returns to ordinary Messages',
      (tester) async {
        final resetService = _FakeMessageDataResetService();
        final overlayDb = OverlayDatabase(NativeDatabase.memory());
        var graphBuildCallCount = 0;

        addTearDown(() async {
          await overlayDb.close();
        });

        container = ProviderContainer(
          overrides: [
            archiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            onboardingEnvironmentReportProvider.overrideWith(
              (ref) async => _report(
                state: OnboardingEnvironmentState.ready,
                blockerKind: OnboardingBlockerKind.none,
              ),
            ),
            conversationGraphBuildServiceProvider.overrideWith(
              (ref) async => _fakeGraphBuildService(
                onBuild: () {
                  graphBuildCallCount += 1;
                },
              ),
            ),
            messageDataResetServiceProvider.overrideWith((ref) => resetService),
            onboardingDurableCompletionVerifierProvider.overrideWithValue(
              const _FakeDurableCompletionVerifier(),
            ),
          ],
        );

        await _pumpGateOverlay(tester, container);
        expect(await _readGateStatus(container), OnboardingStatus.notNeeded);

        final reimportFuture = container
            .read(onboardingGateProvider.notifier)
            .startReimport();
        await tester.pump();
        await tester.pump();
        await reimportFuture;
        await tester.pump();

        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.reimportComplete,
        );
        expect(graphBuildCallCount, 1);
        expect(resetService.resetDerivedDataCallCount, 1);

        final sidebarModeSubscription = container.listen<SidebarMode>(
          activeSidebarModeProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(sidebarModeSubscription.close);
        container
            .read(activeSidebarModeProvider.notifier)
            .setMode(SidebarMode.settings);

        await tester.tap(find.text('Done'));
        await tester.pump();
        await tester.pump();

        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.notNeeded,
        );
        expect(container.read(activeSidebarModeProvider), SidebarMode.messages);
      },
    );

    testWidgets(
      'settings reimport returns to awaitingUserAction when graph rebuild fails',
      (tester) async {
        final resetService = _FakeMessageDataResetService();
        final overlayDb = OverlayDatabase(NativeDatabase.memory());
        var graphBuildCallCount = 0;

        addTearDown(() async {
          await overlayDb.close();
        });

        container = ProviderContainer(
          overrides: [
            archiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            onboardingEnvironmentReportProvider.overrideWith(
              (ref) async => _report(
                state: OnboardingEnvironmentState.ready,
                blockerKind: OnboardingBlockerKind.none,
              ),
            ),
            conversationGraphBuildServiceProvider.overrideWith(
              (ref) async => _fakeGraphBuildService(
                error: StateError('graph failed'),
                onBuild: () {
                  graphBuildCallCount += 1;
                },
              ),
            ),
            messageDataResetServiceProvider.overrideWith((ref) => resetService),
            onboardingDurableCompletionVerifierProvider.overrideWithValue(
              const _FakeDurableCompletionVerifier(),
            ),
          ],
        );

        await tester.pumpWidget(_GateHarness(container: container));
        expect(await _readGateStatus(container), OnboardingStatus.notNeeded);

        final reimportFuture = container
            .read(onboardingGateProvider.notifier)
            .startReimport();
        await tester.pump();
        await tester.pump();
        await reimportFuture;

        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.awaitingUserAction,
        );
        expect(graphBuildCallCount, 1);
        expect(resetService.resetDerivedDataCallCount, 1);
      },
    );

    testWidgets(
      'automatically resets incomplete app databases once before returning to awaitingUserAction',
      (tester) async {
        var shouldReset = true;
        final seenStatuses = <OnboardingStatus>[];
        final resetCompleter = Completer<void>();
        final resetService = _FakeMessageDataResetService()
          ..resetCompleter = resetCompleter
          ..onResetStarted = () {
            shouldReset = false;
          };
        final overlayDb = OverlayDatabase(NativeDatabase.memory());

        addTearDown(() async {
          resetService.resetCompleter = null;
          resetService.onResetStarted = null;
          await overlayDb.close();
        });

        container = ProviderContainer(
          overrides: [
            archiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            onboardingEnvironmentReportProvider.overrideWith((ref) async {
              return _report(
                state: shouldReset
                    ? OnboardingEnvironmentState.graphProjectionFailed
                    : OnboardingEnvironmentState.readyToImport,
                blockerKind: shouldReset
                    ? OnboardingBlockerKind.graphProjectionFailed
                    : OnboardingBlockerKind.sourceScopedImportDatabaseMissing,
                shouldResetAppDatabasesBeforeImport: shouldReset,
                resetAppDatabasesReason: shouldReset
                    ? 'Synthetic incomplete setup state for gate recovery test'
                    : null,
              );
            }),
            messageDataResetServiceProvider.overrideWith((ref) => resetService),
          ],
        );

        await tester.pumpWidget(
          _GateHarness(container: container, seenStatuses: seenStatuses),
        );

        await container.read(onboardingEnvironmentReportProvider.future);

        await tester.pump();
        await tester.pump();

        expect(resetService.resetDerivedDataCallCount, 1);
        expect(seenStatuses, contains(OnboardingStatus.awaitingUserAction));
        expect(
          seenStatuses,
          contains(OnboardingStatus.recoveringFailedAttempt),
        );

        resetCompleter.complete();
        await tester.pump();
        await tester.pump();

        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.awaitingUserAction,
        );
        expect(resetService.resetDerivedDataCallCount, 1);
      },
    );

    testWidgets('automatic reset failure ends recovery in preparationFailed', (
      tester,
    ) async {
      final resetService = _FakeMessageDataResetService()
        ..resetError = StateError('synthetic automatic reset failure');
      final overlayDb = OverlayDatabase(NativeDatabase.memory());
      addTearDown(overlayDb.close);
      container = ProviderContainer(
        overrides: [
          archiveAccessAuthorityProvider.overrideWithValue(
            archiveFixture.authority,
          ),
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => _automaticRecoveryReport(),
          ),
          messageDataResetServiceProvider.overrideWith((ref) => resetService),
        ],
      );

      await tester.pumpWidget(_GateHarness(container: container));
      await container.read(onboardingEnvironmentReportProvider.future);
      await tester.pump();
      await tester.pump();

      expect(resetService.resetDerivedDataCallCount, 1);
      expect(
        container.read(onboardingGateProvider),
        OnboardingStatus.preparationFailed,
      );
    });

    testWidgets(
      'non-contention automatic admission error unwinds into preparationFailed',
      (tester) async {
        _AdmissionErrorArchiveMutationCoordinator.runCallCount = 0;
        final resetService = _FakeMessageDataResetService();
        container = ProviderContainer(
          overrides: [
            archiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            archiveMutationCoordinatorProvider.overrideWith(
              _AdmissionErrorArchiveMutationCoordinator.new,
            ),
            onboardingEnvironmentReportProvider.overrideWith(
              (ref) async => _automaticRecoveryReport(),
            ),
            messageDataResetServiceProvider.overrideWith((ref) => resetService),
          ],
        );

        await tester.pumpWidget(_GateHarness(container: container));
        await container.read(onboardingEnvironmentReportProvider.future);
        await tester.pump();
        await tester.pump();

        expect(_AdmissionErrorArchiveMutationCoordinator.runCallCount, 1);
        expect(resetService.resetDerivedDataCallCount, 0);
        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.preparationFailed,
        );

        container.read(onboardingGateProvider.notifier).refreshEnvironment();
        await container.read(onboardingEnvironmentReportProvider.future);
        await tester.pump();
        await tester.pump();

        expect(_AdmissionErrorArchiveMutationCoordinator.runCallCount, 2);
        expect(resetService.resetDerivedDataCallCount, 0);
      },
    );

    testWidgets(
      'busy automatic recovery stays silent and re-evaluates once on release',
      (tester) async {
        var environmentEvaluationCount = 0;
        var report = _automaticRecoveryReport();
        final seenStatuses = <OnboardingStatus>[];
        final resetService = _FakeMessageDataResetService();
        container = ProviderContainer(
          overrides: [
            archiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            onboardingEnvironmentReportProvider.overrideWith((ref) async {
              environmentEvaluationCount += 1;
              return report;
            }),
            messageDataResetServiceProvider.overrideWith((ref) => resetService),
          ],
        );
        final competingMutation = _holdMutationAuthority(container);

        await tester.pumpWidget(
          _GateHarness(container: container, seenStatuses: seenStatuses),
        );
        await container.read(onboardingEnvironmentReportProvider.future);
        await tester.pump();
        await tester.pump();

        expect(
          container.read(archiveMutationCoordinatorProvider).deniedRequests,
          1,
        );
        expect(resetService.resetDerivedDataCallCount, 0);
        expect(
          seenStatuses,
          isNot(contains(OnboardingStatus.recoveringFailedAttempt)),
        );
        expect(
          seenStatuses,
          isNot(contains(OnboardingStatus.preparationFailed)),
        );

        await tester.pump();
        await tester.pump();
        expect(
          container.read(archiveMutationCoordinatorProvider).deniedRequests,
          1,
        );

        report = _readyToImportReport();
        competingMutation.release.complete();
        await competingMutation.operation;
        await tester.pump();
        await container.read(onboardingEnvironmentReportProvider.future);
        await tester.pump();

        expect(environmentEvaluationCount, 2);
        expect(resetService.resetDerivedDataCallCount, 0);
        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.awaitingUserAction,
        );
      },
    );

    testWidgets(
      'fresh recovery requirement after release is admitted and shown once',
      (tester) async {
        var environmentEvaluationCount = 0;
        final seenStatuses = <OnboardingStatus>[];
        final resetCompleter = Completer<void>();
        final resetService = _FakeMessageDataResetService()
          ..resetCompleter = resetCompleter;
        final overlayDb = OverlayDatabase(NativeDatabase.memory());
        addTearDown(() async {
          resetService.resetCompleter = null;
          await overlayDb.close();
        });
        container = ProviderContainer(
          overrides: [
            archiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            onboardingEnvironmentReportProvider.overrideWith((ref) async {
              environmentEvaluationCount += 1;
              return _automaticRecoveryReport();
            }),
            messageDataResetServiceProvider.overrideWith((ref) => resetService),
          ],
        );
        final competingMutation = _holdMutationAuthority(container);

        await tester.pumpWidget(
          _GateHarness(container: container, seenStatuses: seenStatuses),
        );
        await container.read(onboardingEnvironmentReportProvider.future);
        await tester.pump();
        await tester.pump();
        expect(resetService.resetDerivedDataCallCount, 0);

        competingMutation.release.complete();
        await competingMutation.operation;
        await tester.pump();
        await container.read(onboardingEnvironmentReportProvider.future);
        await tester.pump();
        await tester.pump();
        await tester.pump();

        expect(environmentEvaluationCount, 2);
        expect(resetService.resetDerivedDataCallCount, 1);
        expect(
          seenStatuses,
          contains(OnboardingStatus.recoveringFailedAttempt),
        );
        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.recoveringFailedAttempt,
        );

        resetCompleter.complete();
        await tester.pump();
        await tester.pump();
        expect(resetService.resetDerivedDataCallCount, 1);
      },
    );

    testWidgets('a second mutation owner returns recovery to deferral', (
      tester,
    ) async {
      var environmentEvaluationCount = 0;
      final freshReport = Completer<OnboardingEnvironmentReport>();
      final resetService = _FakeMessageDataResetService();
      container = ProviderContainer(
        overrides: [
          archiveAccessAuthorityProvider.overrideWithValue(
            archiveFixture.authority,
          ),
          onboardingEnvironmentReportProvider.overrideWith((ref) async {
            environmentEvaluationCount += 1;
            if (environmentEvaluationCount == 1) {
              return _automaticRecoveryReport();
            }
            if (environmentEvaluationCount == 2) {
              return freshReport.future;
            }
            return _readyToImportReport();
          }),
          messageDataResetServiceProvider.overrideWith((ref) => resetService),
        ],
      );
      final firstMutation = _holdMutationAuthority(
        container,
        ownerLabel: 'first-owner',
      );

      await tester.pumpWidget(_GateHarness(container: container));
      await container.read(onboardingEnvironmentReportProvider.future);
      await tester.pump();
      await tester.pump();
      expect(
        container.read(archiveMutationCoordinatorProvider).deniedRequests,
        1,
      );

      firstMutation.release.complete();
      await firstMutation.operation;
      await tester.pump();
      expect(environmentEvaluationCount, 2);

      final secondMutation = _holdMutationAuthority(
        container,
        ownerLabel: 'second-owner',
      );
      freshReport.complete(_automaticRecoveryReport());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(
        container.read(archiveMutationCoordinatorProvider).deniedRequests,
        2,
      );
      expect(resetService.resetDerivedDataCallCount, 0);
      expect(
        container.read(onboardingGateProvider),
        isNot(OnboardingStatus.preparationFailed),
      );

      secondMutation.release.complete();
      await secondMutation.operation;
      await tester.pump();
      await container.read(onboardingEnvironmentReportProvider.future);
      await tester.pump();

      expect(environmentEvaluationCount, 3);
      expect(resetService.resetDerivedDataCallCount, 0);
    });

    testWidgets(
      'release before denial handling still causes fresh evaluation',
      (tester) async {
        var environmentEvaluationCount = 0;
        final resetService = _FakeMessageDataResetService();
        container = ProviderContainer(
          overrides: [
            archiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            archiveMutationCoordinatorProvider.overrideWith(
              _ReleaseBeforeDenialHandlingCoordinator.new,
            ),
            onboardingEnvironmentReportProvider.overrideWith((ref) async {
              environmentEvaluationCount += 1;
              return environmentEvaluationCount == 1
                  ? _automaticRecoveryReport()
                  : _readyToImportReport();
            }),
            messageDataResetServiceProvider.overrideWith((ref) => resetService),
          ],
        );

        await tester.pumpWidget(_GateHarness(container: container));
        await container.read(onboardingEnvironmentReportProvider.future);
        await tester.pump();
        await tester.pump();
        await container.read(onboardingEnvironmentReportProvider.future);
        await tester.pump();

        expect(environmentEvaluationCount, 2);
        expect(resetService.resetDerivedDataCallCount, 0);
        expect(
          container.read(onboardingGateProvider),
          OnboardingStatus.awaitingUserAction,
        );
      },
    );

    testWidgets('disposed deferral is not replayed by a new Gate', (
      tester,
    ) async {
      final resetService = _FakeMessageDataResetService();
      container = ProviderContainer(
        overrides: [
          archiveAccessAuthorityProvider.overrideWithValue(
            archiveFixture.authority,
          ),
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => _automaticRecoveryReport(),
          ),
          messageDataResetServiceProvider.overrideWith((ref) => resetService),
        ],
      );
      final competingMutation = _holdMutationAuthority(container);

      await tester.pumpWidget(_GateHarness(container: container));
      await container.read(onboardingEnvironmentReportProvider.future);
      await tester.pump();
      await tester.pump();
      expect(resetService.resetDerivedDataCallCount, 0);

      container.dispose();
      competingMutation.release.complete();
      await competingMutation.operation;
      expect(resetService.resetDerivedDataCallCount, 0);

      container = ProviderContainer(
        overrides: [
          archiveAccessAuthorityProvider.overrideWithValue(
            archiveFixture.authority,
          ),
          onboardingEnvironmentReportProvider.overrideWith(
            (ref) async => _readyToImportReport(),
          ),
          messageDataResetServiceProvider.overrideWith((ref) => resetService),
        ],
      );
      await tester.pumpWidget(_GateHarness(container: container));
      await tester.pump();
      final reconstructedStatus = await _readGateStatus(container);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      expect(reconstructedStatus, OnboardingStatus.awaitingUserAction);
      expect(resetService.resetDerivedDataCallCount, 0);
    });

    testWidgets('controller failure keeps the persisted graph-failure path', (
      tester,
    ) async {
      final resetService = _FakeMessageDataResetService();
      final overlayDb = OverlayDatabase(NativeDatabase.memory());

      addTearDown(() async {
        await overlayDb.close();
      });

      container = ProviderContainer(
        overrides: _firstRunOverrides(
          archiveFixture: archiveFixture,
          overlayDb: overlayDb,
          resetService: resetService,
          onGraphBuild: () {},
          graphBuildError: StateError('synthetic graph failure'),
        ),
      );

      await tester.pumpWidget(_GateHarness(container: container));
      expect(
        await _readGateStatus(container),
        OnboardingStatus.awaitingUserAction,
      );
      final startFuture = container
          .read(onboardingGateProvider.notifier)
          .startImportAndGraphBuild();
      await tester.pump();
      await tester.pump();
      await startFuture;

      expect(
        container.read(onboardingGateProvider),
        OnboardingStatus.awaitingUserAction,
      );
      expect(
        container.read(onboardingGateProvider),
        isNot(OnboardingStatus.preparationFailed),
      );
      final failure = await container
          .read(onboardingFailureStorageProvider)
          .loadGraphProjectionFailure();
      expect(failure?.message, contains('synthetic graph failure'));
      final failedOperation = (await container.read(
        onboardingOperationControllerProvider.future,
      )).current;
      expect(failedOperation.status, OnboardingOperationStatus.failed);
      expect(
        failedOperation.failure?.category,
        OnboardingOperationFailureCategory.messageDataBuild,
      );
    });
  });
}

class _GateHarness extends StatelessWidget {
  const _GateHarness({required this.container, this.seenStatuses});

  final ProviderContainer container;
  final List<OnboardingStatus>? seenStatuses;

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: container,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Consumer(
          builder: (context, ref, child) {
            final status = ref.watch(onboardingGateProvider);
            seenStatuses?.add(status);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _GateOverlayHarness extends StatelessWidget {
  const _GateOverlayHarness({required this.container});

  final ProviderContainer container;

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: container,
      child: const MacosApp(home: OnboardingOverlay()),
    );
  }
}

Future<void> _pumpGateOverlay(
  WidgetTester tester,
  ProviderContainer container,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1200, 1400);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(_GateOverlayHarness(container: container));
}

Future<OnboardingStatus> _readGateStatus(ProviderContainer container) async {
  await container.read(onboardingEnvironmentReportProvider.future);
  return container.read(onboardingGateProvider);
}

OnboardingEnvironmentReport _report({
  required OnboardingEnvironmentState state,
  required OnboardingBlockerKind blockerKind,
  bool hasFullDiskAccess = true,
  bool shouldResetAppDatabasesBeforeImport = false,
  String? resetAppDatabasesReason,
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
    shouldResetAppDatabasesBeforeImport: shouldResetAppDatabasesBeforeImport,
    resetAppDatabasesReason: resetAppDatabasesReason,
  );
}

OnboardingEnvironmentReport _automaticRecoveryReport() {
  return _report(
    state: OnboardingEnvironmentState.graphProjectionFailed,
    blockerKind: OnboardingBlockerKind.graphProjectionFailed,
    shouldResetAppDatabasesBeforeImport: true,
    resetAppDatabasesReason: 'Synthetic incomplete setup state',
  );
}

OnboardingEnvironmentReport _readyToImportReport() {
  return _report(
    state: OnboardingEnvironmentState.readyToImport,
    blockerKind: OnboardingBlockerKind.sourceScopedImportDatabaseMissing,
  );
}

({Completer<void> release, Future<void> operation}) _holdMutationAuthority(
  ProviderContainer container, {
  String ownerLabel = 'competing-owner',
}) {
  final release = Completer<void>();
  final operation = container
      .read(archiveMutationCoordinatorProvider.notifier)
      .run<void>(
        operation: ArchiveMutationOperation.graphBuild,
        ownerLabel: ownerLabel,
        action: () => release.future,
      );
  return (release: release, operation: operation);
}

final class _FakeMessageDataResetService implements MessageDataResetService {
  int resetDerivedDataCallCount = 0;
  Completer<void>? resetCompleter;
  Object? resetError;
  void Function()? onResetStarted;

  @override
  Future<void> resetDerivedData() async {
    resetDerivedDataCallCount += 1;
    onResetStarted?.call();
    final error = resetError;
    if (error != null) {
      throw error;
    }
    await resetCompleter?.future;
  }

  @override
  Future<void> resetDerivedDataForStartFresh(
    ArchiveMutationCapability capability,
  ) async {
    await resetDerivedData();
  }
}

List<Override> _firstRunOverrides({
  required TestArchiveFixture archiveFixture,
  required OverlayDatabase overlayDb,
  required _FakeMessageDataResetService resetService,
  required void Function() onGraphBuild,
  Completer<void>? graphBuildCompleter,
  Object? graphBuildError,
  bool hasFullDiskAccess = true,
  int preservedUnnormalizedHandleCount = 0,
  OnboardingDurableCompletionVerifier? durableCompletionVerifier,
}) {
  return [
    archiveAccessAuthorityProvider.overrideWithValue(archiveFixture.authority),
    overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
    onboardingEnvironmentReportProvider.overrideWith(
      (ref) async => _report(
        state: OnboardingEnvironmentState.readyToImport,
        blockerKind: OnboardingBlockerKind.sourceScopedImportDatabaseMissing,
      ),
    ),
    onboardingFullDiskAccessProvider.overrideWith((ref) => hasFullDiskAccess),
    conversationGraphBuildServiceProvider.overrideWith(
      (ref) async => _fakeGraphBuildService(
        error: graphBuildError,
        onBuild: onGraphBuild,
        buildCompleter: graphBuildCompleter,
        preservedUnnormalizedHandleCount: preservedUnnormalizedHandleCount,
      ),
    ),
    messageDataResetServiceProvider.overrideWith((ref) => resetService),
    onboardingDurableCompletionVerifierProvider.overrideWithValue(
      durableCompletionVerifier ?? const _FakeDurableCompletionVerifier(),
    ),
  ];
}

final class _FakeDurableCompletionVerifier
    implements OnboardingDurableCompletionVerifier {
  const _FakeDurableCompletionVerifier();

  @override
  Future<OnboardingInstallationReadyProof> verifyInstallationReady() async {
    return OnboardingInstallationReadyProof(
      verifiedAtUtc: DateTime.utc(2026, 8, 23),
      sourceScopedImportRows: 100,
      conversationGraphRows: 100,
    );
  }
}

final class _HeldDurableCompletionVerifier
    implements OnboardingDurableCompletionVerifier {
  final started = Completer<void>();
  final _result = Completer<OnboardingInstallationReadyProof>();

  @override
  Future<OnboardingInstallationReadyProof> verifyInstallationReady() {
    if (!started.isCompleted) {
      started.complete();
    }
    return _result.future;
  }

  void completeSuccessfully() {
    _result.complete(
      OnboardingInstallationReadyProof(
        verifiedAtUtc: DateTime.utc(2026, 8, 26),
        sourceScopedImportRows: 100,
        conversationGraphRows: 100,
      ),
    );
  }
}

final class _FailingDurableCompletionVerifier
    implements OnboardingDurableCompletionVerifier {
  const _FailingDurableCompletionVerifier();

  @override
  Future<OnboardingInstallationReadyProof> verifyInstallationReady() {
    throw StateError('synthetic durable verification failure');
  }
}

final class _AdmissionErrorArchiveMutationCoordinator
    extends ArchiveMutationCoordinator {
  static int runCallCount = 0;

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
    runCallCount += 1;
    throw StateError('synthetic admission failure');
  }
}

final class _ReleaseBeforeDenialHandlingCoordinator
    extends ArchiveMutationCoordinator {
  @override
  ArchiveMutationCoordinatorState build() {
    return const ArchiveMutationCoordinatorState(
      operation: ArchiveMutationOperation.messageDataReset,
      ownerId: 'released-owner#1',
      ownerLabel: 'released-owner',
      holdCount: 1,
    );
  }

  @override
  Future<T> run<T>({
    required ArchiveMutationOperation operation,
    required String ownerLabel,
    required Future<T> Function() action,
  }) async {
    state = ArchiveMutationCoordinatorState(
      lastReleasedAtUtc: DateTime.now().toUtc(),
    );
    throw ArchiveMutationDeniedException(
      requestedOperation: operation,
      requestedOwner: ownerLabel,
      currentOperation: ArchiveMutationOperation.messageDataReset,
      currentOwner: 'another-owner',
    );
  }
}

List<Override> _lifecycleOverrides() {
  return [
    conversationGraphBuildControllerProvider.overrideWith(
      _FakeConversationGraphBuildController.new,
    ),
    chatDbChangeMonitorProvider.overrideWith(_FakeChatDbChangeMonitor.new),
  ];
}

final class _FakeConversationGraphBuildController
    extends ConversationGraphBuildController {
  @override
  ConversationGraphBuildState build() {
    return const ConversationGraphBuildState.idle();
  }
}

final class _FakeChatDbChangeMonitor extends ChatDbChangeMonitor {
  @override
  ChatDbChangeMonitorState build() {
    return const ChatDbChangeMonitorState(lastMaxRowId: 149359);
  }
}

String _createReadableFile(String directoryPath, String fileName) {
  final file = File('$directoryPath/$fileName');
  file.writeAsStringSync('fixture');
  return file.path;
}

AddressBookFolderAggregate _addressBookAggregate(String addressBookPath) {
  return AddressBookFolderAggregate([
    AddressBookFolderEntity(
      path: FolderPathValueObject(addressBookPath),
      shortPath: AddressBookFolderShortPath('TEST-SOURCE'),
      lastCreationDate: FolderCreationDate(DateTime.utc(2026, 03, 24)),
      lastModificationDate: FolderModificationDate(DateTime.utc(2026, 03, 24)),
      recordCount: NonZeroInt(12),
    ),
  ]);
}

ConversationGraphBuildService _fakeGraphBuildService({
  Object? error,
  void Function()? onBuild,
  Completer<void>? buildCompleter,
  int preservedUnnormalizedHandleCount = 0,
}) {
  var reportedBuildStart = false;
  Future<void> step() async {
    if (!reportedBuildStart) {
      reportedBuildStart = true;
      onBuild?.call();
    }
    if (error != null) {
      throw error;
    }
    await buildCompleter?.future;
  }

  return ConversationGraphBuildService(
    orchestrator: ConversationGraphBuildOrchestrator(
      importChats: (_) => step(),
      importHandles: (onProgress) async {
        onProgress?.call(
          SourceImportWorkProgress(
            unit: SourceImportWorkUnit.handles,
            completedWorkCount: 1,
            totalWorkCount: 1,
            lastCompletedSourceRowId: 42,
            anomalyCounts: SourceImportAnomalyCounts(
              preservedUnnormalizedHandleCount:
                  preservedUnnormalizedHandleCount,
            ),
          ),
        );
      },
      importContacts: (_) async {},
      importMessages: (_) async {
        await step();
        return const MessageImportResult(
          startedAfterSourceRowId: 0,
          insertedMessageCount: 1,
          lastImportedSourceRowId: 1,
        );
      },
      enrichMissingText: (_, _) async {
        return const MessageRichTextEnrichmentResult(
          candidateMessageCount: 0,
          enrichedMessageCount: 0,
          missingExtractionCount: 0,
          extractorAvailable: true,
        );
      },
      importAttachments: (_) async {
        return const AttachmentImportResult(
          startedAfterSourceRowId: 0,
          examinedAttachmentCount: 0,
          insertedAttachmentCount: 0,
          lastImportedSourceRowId: null,
        );
      },
      importChatMessageJoins: (_, _) async {},
      importChatHandleJoins: (_) async {},
      importMessageAttachmentJoins: (_, _) async {},
      projectHandles: () async {},
      projectContacts: () async {
        return const ContactProjectionResult(
          examinedContactCount: 0,
          insertedContactCount: 0,
          insertedContactHandleEdgeCount: 0,
        );
      },
      projectChatHandleEdges: () async {},
      projectChats: (_) async {},
      projectMessages: (_, _) async {
        return const MessageProjectionResult(
          examinedMessageCount: 1,
          insertedMessageCount: 1,
        );
      },
      projectAttachments: (_, _, _) async {},
      projectChatMessageEdges: (_) async {},
      projectMessageAttachmentEdges: (_) async {},
    ),
  );
}
