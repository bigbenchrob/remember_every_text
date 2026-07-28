import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/domain_driven_development/value_objects.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
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
import 'package:remember_this_text/essentials/onboarding/application/message_data_reset_service.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/attachments/attachment_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
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

    testWidgets('settings reimport completes when graph rebuild succeeds', (
      tester,
    ) async {
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
        OnboardingStatus.reimportComplete,
      );
      expect(graphBuildCallCount, 1);
      expect(resetService.resetDerivedDataCallCount, 1);
    });

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

        addTearDown(() {
          resetService.resetCompleter = null;
          resetService.onResetStarted = null;
        });

        container = ProviderContainer(
          overrides: [
            archiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
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

final class _FakeMessageDataResetService implements MessageDataResetService {
  int resetDerivedDataCallCount = 0;
  int confirmResetAndPrepareReimportCallCount = 0;
  Completer<void>? resetCompleter;
  void Function()? onResetStarted;

  @override
  Future<void> resetDerivedData() async {
    resetDerivedDataCallCount += 1;
    onResetStarted?.call();
    await resetCompleter?.future;
  }

  @override
  Future<void> confirmResetAndPrepareReimport() async {
    confirmResetAndPrepareReimportCallCount += 1;
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
  }

  return ConversationGraphBuildService(
    orchestrator: ConversationGraphBuildOrchestrator(
      importChats: step,
      importHandles: () async {},
      importContacts: () async {},
      importMessages: () async {
        await step();
        return const MessageImportResult(
          startedAfterSourceRowId: 0,
          insertedMessageCount: 1,
          lastImportedSourceRowId: 1,
        );
      },
      enrichMissingText: (_) async {
        return const MessageRichTextEnrichmentResult(
          candidateMessageCount: 0,
          enrichedMessageCount: 0,
          missingExtractionCount: 0,
          extractorAvailable: true,
        );
      },
      importAttachments: () async {
        return const AttachmentImportResult(
          startedAfterSourceRowId: 0,
          examinedAttachmentCount: 0,
          insertedAttachmentCount: 0,
          lastImportedSourceRowId: null,
        );
      },
      importChatMessageJoins: (_) async {},
      importChatHandleJoins: () async {},
      importMessageAttachmentJoins: (_) async {},
      projectHandles: () async {},
      projectContacts: () async {
        return const ContactProjectionResult(
          examinedContactCount: 0,
          insertedContactCount: 0,
          insertedContactHandleEdgeCount: 0,
        );
      },
      projectChatHandleEdges: () async {},
      projectChats: () async {},
      projectMessages: (_) async {
        return const MessageProjectionResult(
          examinedMessageCount: 1,
          insertedMessageCount: 1,
        );
      },
      projectAttachments: (_, _) async {},
      projectChatMessageEdges: (_) async {},
      projectMessageAttachmentEdges: (_) async {},
    ),
  );
}
