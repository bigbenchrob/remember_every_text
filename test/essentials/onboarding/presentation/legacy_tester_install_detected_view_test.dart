import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/onboarding/application/legacy_tester_install_deletion_action.dart';
import 'package:remember_this_text/essentials/onboarding/application/legacy_tester_install_deletion_action_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/legacy_tester_install_deletion_presentation_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/legacy_tester_install_deletion_presentation.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/legacy_tester_install_detected_view.dart';

void main() {
  testWidgets('presents the exact legacy compatibility authorization', (
    tester,
  ) async {
    final action = _RecordingAction();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          legacyTesterInstallDeletionActionProvider.overrideWithValue(action),
        ],
        child: MaterialApp(
          home: LegacyTesterInstallDetectedView(onQuit: () {}),
        ),
      ),
    );

    expect(
      find.text('This is data from an older MessageLens test version'),
      findsOneWidget,
    );
    expect(
      find.text('Your Apple Messages and Contacts will not be changed.'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete Old Data and Continue'), findsOneWidget);

    await tester.tap(
      find.byKey(LegacyTesterInstallDetectedView.cancelButtonKey),
    );
    await tester.pump();

    expect(action.cancelCalls, 1);
    expect(action.confirmCalls, 0);
  });

  testWidgets('confirmed deletion visibly owns presentation immediately', (
    tester,
  ) async {
    late ProviderContainer container;
    final action = _RecordingAction(
      onConfirm: () {
        container
            .read(
              legacyTesterInstallDeletionPresentationControllerProvider
                  .notifier,
            )
            .beginPreparing();
      },
    );
    container = ProviderContainer(
      overrides: [
        legacyTesterInstallDeletionActionProvider.overrideWithValue(action),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: LegacyTesterInstallDetectedView(onQuit: () {}),
        ),
      ),
    );

    await tester.tap(
      find.byKey(LegacyTesterInstallDetectedView.deleteButtonKey),
    );
    await tester.pump();

    expect(action.confirmCalls, 1);
    expect(
      find.text('Removing the old MessageLens test setup'),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('typed failure remains visible with a retry', (tester) async {
    final action = _RecordingAction();
    final container = ProviderContainer(
      overrides: [
        legacyTesterInstallDeletionActionProvider.overrideWithValue(action),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(
      legacyTesterInstallDeletionPresentationControllerProvider.notifier,
    );
    final occurrence = controller.beginPreparing()!;
    controller.showFailure(
      expectedOccurrence: occurrence,
      failure: const LegacyTesterInstallDeletionFailure(
        kind: LegacyTesterInstallDeletionFailureKind.executionFailed,
        summary: 'MessageLens could not finish removing the old test setup.',
        canRetry: true,
      ),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: LegacyTesterInstallDetectedView(onQuit: () {}),
        ),
      ),
    );

    expect(
      find.text("MessageLens couldn't remove the old test setup"),
      findsOneWidget,
    );
    expect(find.text('Try Again'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

final class _RecordingAction implements LegacyTesterInstallDeletionAction {
  _RecordingAction({this.onConfirm});

  final VoidCallback? onConfirm;
  var cancelCalls = 0;
  var confirmCalls = 0;

  @override
  void cancel() {
    cancelCalls += 1;
  }

  @override
  Future<LegacyTesterInstallDeletionActionResult> confirmDeletion() async {
    confirmCalls += 1;
    onConfirm?.call();
    return LegacyTesterInstallDeletionActionResult.deleted;
  }

  @override
  Future<LegacyTesterInstallDeletionActionResult> retry({
    required int occurrence,
  }) async {
    return LegacyTesterInstallDeletionActionResult.deleted;
  }
}
