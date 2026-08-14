import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_controller_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_state.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/onboarding_overlay.dart';

void main() {
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
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        onboardingGateProvider.overrideWith(
          () => _FixedStatusOnboardingGate(status),
        ),
        conversationGraphBuildControllerProvider.overrideWith(
          _RunningConversationGraphBuildController.new,
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

  @override
  OnboardingStatus build() {
    return status;
  }
}

final class _RunningConversationGraphBuildController
    extends ConversationGraphBuildController {
  @override
  ConversationGraphBuildState build() {
    return ConversationGraphBuildState(
      status: ConversationGraphBuildStatus.running,
      owner: 'onboarding-progress-test',
      startedAt: DateTime.utc(2026, 8, 14),
    );
  }
}
