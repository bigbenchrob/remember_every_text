import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_controller_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_report.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_state.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/onboarding_overlay.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';

void main() {
  const technicalFailure =
      'SQLiteException(1): no such table: messages\n'
      '/Users/example/Library/Application Support/MessageLens/graph.db';
  const resetReason =
      'The conversation graph contains far fewer messages than the import '
      'ledger, which strongly suggests an incomplete graph projection.';

  testWidgets('automatic recovery uses calm truthful non-interactive copy', (
    tester,
  ) async {
    await _pumpRecoveryOverlay(tester, resetReason: resetReason);

    expect(find.text('Preparing MessageLens to try again'), findsOneWidget);
    expect(
      find.text(
        'MessageLens found incomplete browsing data and is preparing for '
        'another setup attempt. Please wait.',
      ),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(resetReason), findsNothing);

    for (final unsupportedCopy in <String>[
      'Cleaning Up A Previous Setup Attempt',
      'previous',
      'earlier setup attempt',
      'local data',
      'clearing that data',
      'restart cleanly',
      'import ledger',
      'Conversation Graph',
      'graph projection',
      'row disparity',
    ]) {
      expect(
        find.textContaining(unsupportedCopy, findRichText: true),
        findsNothing,
        reason: 'Unexpected automatic-recovery copy: $unsupportedCopy',
      );
    }

    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(IconButton), findsNothing);
    _expectNoCancellationControl();
    expect(tester.takeException(), isNull);
  });

  testWidgets('first-run progress gives truthful keep-open guidance', (
    tester,
  ) async {
    await _pumpProgressOverlay(tester, status: OnboardingStatus.buildingGraph);

    expect(find.text('Building browsing data…'), findsOneWidget);
    _expectTruthfulActiveProgress(tester);
  });

  testWidgets('reimport progress reuses truthful keep-open guidance', (
    tester,
  ) async {
    await _pumpProgressOverlay(
      tester,
      status: OnboardingStatus.reimportBuildingGraph,
    );

    expect(find.text('Rebuilding browsing data…'), findsOneWidget);
    _expectTruthfulActiveProgress(tester);
  });

  testWidgets('real durable work renders typed determinate progress', (
    tester,
  ) async {
    await _pumpProgressOverlay(
      tester,
      status: OnboardingStatus.buildingGraph,
      operationSnapshot: _runningSnapshot(
        substage: OnboardingOperationSubstage.importingMessages,
        completed: 42000,
        total: 137000,
      ),
    );

    expect(find.text('Messages  42000 / 137000'), findsOneWidget);
    final progressIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progressIndicator.value, closeTo(42000 / 137000, 0.000001));
  });

  testWidgets('first-run active failure uses a bounded human headline', (
    tester,
  ) async {
    final graphBuildState = ConversationGraphBuildState(
      status: ConversationGraphBuildStatus.failed,
      owner: 'failed-first-run',
      startedAt: DateTime.utc(2026, 8, 14),
      finishedAt: DateTime.utc(2026, 8, 14, 0, 1),
      lastError: technicalFailure,
    );

    await _pumpProgressOverlay(
      tester,
      status: OnboardingStatus.buildingGraph,
      graphBuildState: graphBuildState,
    );

    expect(
      find.text("MessageLens couldn't finish preparing browsing data."),
      findsOneWidget,
    );
    expect(find.text(technicalFailure), findsNothing);
    expect(graphBuildState.lastError, technicalFailure);
    _expectTruthfulActiveProgress(tester);
  });

  testWidgets('reimport active failure uses the same bounded headline', (
    tester,
  ) async {
    await _pumpProgressOverlay(
      tester,
      status: OnboardingStatus.reimportBuildingGraph,
      graphBuildState: ConversationGraphBuildState(
        status: ConversationGraphBuildStatus.failed,
        owner: 'failed-reimport',
        startedAt: DateTime.utc(2026, 8, 14),
        finishedAt: DateTime.utc(2026, 8, 14, 0, 1),
        lastError: technicalFailure,
      ),
    );

    expect(
      find.text("MessageLens couldn't finish preparing browsing data."),
      findsOneWidget,
    );
    expect(find.text(technicalFailure), findsNothing);
    _expectTruthfulActiveProgress(tester);
  });

  testWidgets('active first-run success keeps its existing presentation', (
    tester,
  ) async {
    await _pumpProgressOverlay(
      tester,
      status: OnboardingStatus.buildingGraph,
      graphBuildState: _successfulGraphBuildState(),
    );

    expect(find.text('Browsing data ready'), findsOneWidget);
    final progressIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progressIndicator.value, 1.0);
  });

  testWidgets('first-run preparation overrides stale controller success', (
    tester,
  ) async {
    await _pumpProgressOverlay(
      tester,
      status: OnboardingStatus.importing,
      graphBuildState: ConversationGraphBuildState(
        status: ConversationGraphBuildStatus.succeeded,
        owner: 'previous-attempt',
        startedAt: DateTime.utc(2026, 8, 13),
        finishedAt: DateTime.utc(2026, 8, 13, 0, 1),
      ),
    );

    expect(find.text('Preparing setup…'), findsOneWidget);
    expect(find.text('Browsing data ready'), findsNothing);
    _expectTruthfulActiveProgress(tester);
  });

  testWidgets('first-run preparation overrides stale controller failure', (
    tester,
  ) async {
    await _pumpProgressOverlay(
      tester,
      status: OnboardingStatus.importing,
      graphBuildState: ConversationGraphBuildState(
        status: ConversationGraphBuildStatus.failed,
        owner: 'previous-attempt',
        startedAt: DateTime.utc(2026, 8, 13),
        finishedAt: DateTime.utc(2026, 8, 13, 0, 1),
        lastError: 'old graph failure',
      ),
    );

    expect(find.text('Preparing setup…'), findsOneWidget);
    expect(find.text('old graph failure'), findsNothing);
    _expectTruthfulActiveProgress(tester);
  });

  testWidgets('first-run completion presents a calm readiness handoff', (
    tester,
  ) async {
    final gate = _FixedStatusOnboardingGate(OnboardingStatus.complete);
    await _pumpProgressOverlay(
      tester,
      status: OnboardingStatus.complete,
      gate: gate,
      graphBuildState: _successfulGraphBuildState(),
    );

    _expectCalmCompletion(
      title: 'You’re ready to start',
      body: 'Your local MessageLens browsing data is prepared.',
      actionLabel: 'OK',
    );

    await tester.tap(find.text('OK'));

    expect(gate.dismissCallCount, 1);
  });

  testWidgets('direct reimport completion reuses the calm readiness handoff', (
    tester,
  ) async {
    final gate = _FixedStatusOnboardingGate(OnboardingStatus.reimportComplete);
    await _pumpProgressOverlay(
      tester,
      status: OnboardingStatus.reimportComplete,
      gate: gate,
      graphBuildState: _successfulGraphBuildState(),
    );

    _expectCalmCompletion(
      title: 'MessageLens is ready',
      body: 'Your local browsing data is prepared.',
      actionLabel: 'Done',
    );

    await tester.tap(find.text('Done'));

    expect(gate.dismissCallCount, 1);
  });
}

void _expectCalmCompletion({
  required String title,
  required String body,
  required String actionLabel,
}) {
  expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  expect(find.text(title), findsOneWidget);
  expect(find.text(body), findsOneWidget);
  expect(find.text(actionLabel), findsOneWidget);
  expect(find.text('Import Complete!'), findsNothing);

  for (final diagnosticLabel in <String>[
    'Imported',
    'Projected',
    'Text enriched',
  ]) {
    expect(find.text(diagnosticLabel), findsNothing);
  }

  for (final unsupportedClaim in <String>[
    'all attachments archived',
    'everything preserved',
    'all messages copied permanently',
  ]) {
    expect(
      find.textContaining(unsupportedClaim, findRichText: true),
      findsNothing,
    );
  }
}

void _expectTruthfulActiveProgress(WidgetTester tester) {
  expect(
    find.text(
      'Keep MessageLens open while it prepares your messages. '
      'You can use other apps in the meantime.',
    ),
    findsOneWidget,
  );

  final progressIndicator = tester.widget<LinearProgressIndicator>(
    find.byType(LinearProgressIndicator),
  );
  expect(
    progressIndicator.value,
    isNull,
    reason: 'Active progress must remain indeterminate.',
  );

  for (final unsupportedClaim in <String>[
    'Importing messages…',
    'Building conversations…',
    'Indexing attachments…',
    'ETA',
    'time remaining',
    '%',
    'resume',
    'relaunch',
  ]) {
    expect(
      find.textContaining(unsupportedClaim, findRichText: true),
      findsNothing,
      reason: 'Unexpected unsupported progress claim: $unsupportedClaim',
    );
  }

  expect(
    find.text('MessageLens is building its local browsing data from Messages.'),
    findsNothing,
  );
  expect(
    find.text(
      'MessageLens is rebuilding its local browsing data from Messages.',
    ),
    findsNothing,
  );

  _expectNoCancellationControl();
}

Future<void> _pumpProgressOverlay(
  WidgetTester tester, {
  required OnboardingStatus status,
  _FixedStatusOnboardingGate? gate,
  ConversationGraphBuildState? graphBuildState,
  OnboardingOperationSnapshot? operationSnapshot,
}) async {
  final resolvedGraphBuildState =
      graphBuildState ??
      ConversationGraphBuildState(
        status: ConversationGraphBuildStatus.running,
        owner: 'onboarding-progress-test',
        startedAt: DateTime.utc(2026, 8, 14),
      );
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        onboardingGateProvider.overrideWith(
          () => gate ?? _FixedStatusOnboardingGate(status),
        ),
        conversationGraphBuildControllerProvider.overrideWith(
          () => _FixedConversationGraphBuildController(resolvedGraphBuildState),
        ),
        onboardingOperationSnapshotProvider.overrideWith(
          (ref) => Stream<OnboardingOperationSnapshot>.value(
            operationSnapshot ?? const OnboardingOperationSnapshot.idle(),
          ),
        ),
        onboardingEnvironmentReportProvider.overrideWith((ref) {
          throw StateError('Progress presentation does not require a report.');
        }),
      ],
      child: const MacosApp(home: OnboardingOverlay()),
    ),
  );
  await tester.pump();
}

OnboardingOperationSnapshot _runningSnapshot({
  required OnboardingOperationSubstage substage,
  required int completed,
  required int total,
}) {
  final observedAt = DateTime.utc(2026, 8, 23, 12);
  return OnboardingOperationSnapshot.running(
    operationId: OnboardingOperationId('123e4567-e89b-42d3-a456-426614174000'),
    processSessionId: OnboardingProcessSessionId(
      '123e4567-e89b-42d3-a456-426614174001',
    ),
    kind: OnboardingOperationKind.initialImport,
    stage: OnboardingOperationStage.messageDataBuild,
    observedAtUtc: observedAt,
  ).observeProgress(
    observedAtUtc: observedAt,
    substage: substage,
    progress: OnboardingOperationProgress(
      completedWorkUnits: completed,
      totalWorkUnits: total,
    ),
  );
}

Future<void> _pumpRecoveryOverlay(
  WidgetTester tester, {
  required String resetReason,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        onboardingGateProvider.overrideWith(
          () => _FixedStatusOnboardingGate(
            OnboardingStatus.recoveringFailedAttempt,
          ),
        ),
        onboardingEnvironmentReportProvider.overrideWith(
          (ref) async => _recoveryReport(resetReason),
        ),
      ],
      child: const MacosApp(home: OnboardingOverlay()),
    ),
  );
  await tester.pump();
}

OnboardingEnvironmentReport _recoveryReport(String resetReason) {
  return OnboardingEnvironmentReport(
    state: OnboardingEnvironmentState.graphProjectionFailed,
    blockerKind: OnboardingBlockerKind.graphProjectionFailed,
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
    overlayDatabase: const OnboardingDatabaseProbe(
      path: 'overlay.db',
      exists: true,
      readable: true,
    ),
    sourceScopedImportDatabase: const OnboardingDatabaseProbe(
      path: 'source_scoped_import.db',
      exists: true,
      readable: true,
      rowCount: 100,
    ),
    conversationGraph: const OnboardingDatabaseProbe(
      path: 'conversation_graph.db',
      exists: true,
      readable: true,
      rowCount: 10,
    ),
    attachmentArchiveDirectory: const OnboardingDatabaseProbe(
      path: 'attachment_archive',
      exists: true,
      readable: true,
    ),
    hasFullDiskAccess: true,
    shouldResetAppDatabasesBeforeImport: true,
    resetAppDatabasesReason: resetReason,
  );
}

ConversationGraphBuildState _successfulGraphBuildState() {
  final startedAt = DateTime.utc(2026, 8, 14);
  final finishedAt = startedAt.add(const Duration(minutes: 1));
  return ConversationGraphBuildState(
    status: ConversationGraphBuildStatus.succeeded,
    owner: 'onboarding-completion-test',
    startedAt: startedAt,
    finishedAt: finishedAt,
    lastReport: ConversationGraphBuildReport(
      startedAt: startedAt,
      finishedAt: finishedAt,
      completedStageNames: const <String>[],
      stageTimings: const <ConversationGraphBuildStageTiming>[],
      messageImportResult: const MessageImportResult(
        startedAfterSourceRowId: 0,
        insertedMessageCount: 54201,
        lastImportedSourceRowId: 54201,
      ),
      richTextEnrichmentResult: const MessageRichTextEnrichmentResult(
        candidateMessageCount: 3842,
        enrichedMessageCount: 3842,
        missingExtractionCount: 0,
        extractorAvailable: true,
      ),
      messageProjectionResult: const MessageProjectionResult(
        examinedMessageCount: 54201,
        insertedMessageCount: 54201,
      ),
    ),
  );
}

void _expectNoCancellationControl() {
  for (final label in <String>[
    'Abort Import',
    'Cancel',
    'Stop',
    'Quit Setup',
    'Clean Up',
    'Return',
    'Try Later',
  ]) {
    expect(
      find.text(label),
      findsNothing,
      reason: 'Unexpected control: $label',
    );
  }
}

final class _FixedStatusOnboardingGate extends OnboardingGate {
  _FixedStatusOnboardingGate(this.status);

  final OnboardingStatus status;
  int dismissCallCount = 0;

  @override
  OnboardingStatus build() {
    return status;
  }

  @override
  void dismiss() {
    dismissCallCount += 1;
  }
}

final class _FixedConversationGraphBuildController
    extends ConversationGraphBuildController {
  _FixedConversationGraphBuildController(this.graphBuildState);

  final ConversationGraphBuildState graphBuildState;

  @override
  ConversationGraphBuildState build() {
    return graphBuildState;
  }
}
