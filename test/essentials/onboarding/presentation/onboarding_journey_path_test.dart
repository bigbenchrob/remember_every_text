import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_journey_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/onboarding_journey_path.dart';

void main() {
  group('Onboarding Journey path projection', () {
    test('defines six human Episodes independently of internal states', () {
      expect(OnboardingJourneyPathNode.values, <OnboardingJourneyPathNode>[
        OnboardingJourneyPathNode.messages,
        OnboardingJourneyPathNode.history,
        OnboardingJourneyPathNode.contacts,
        OnboardingJourneyPathNode.ready,
        OnboardingJourneyPathNode.import,
        OnboardingJourneyPathNode.start,
      ]);
    });

    test('maps every first-run Episode to the compact canonical topology', () {
      final evidence = _evidence();
      final cases = <OnboardingJourneyState, OnboardingJourneyPathNode>{
        const OnboardingCheckingPrerequisites(occurrence: 1):
            OnboardingJourneyPathNode.messages,
        OnboardingNeedsMessagesAccess(occurrence: 2, evidence: evidence):
            OnboardingJourneyPathNode.messages,
        OnboardingNeedsLocalHistoryConfirmation(
          occurrence: 3,
          evidence: evidence,
        ): OnboardingJourneyPathNode.history,
        OnboardingNeedsContactsAccess(occurrence: 4, evidence: evidence):
            OnboardingJourneyPathNode.contacts,
        OnboardingReadyToImport(
          occurrence: 5,
          evidence: evidence,
          localHistoryAccepted: false,
        ): OnboardingJourneyPathNode.ready,
        const OnboardingRecoveringDerivedData(occurrence: 6):
            OnboardingJourneyPathNode.import,
        const OnboardingPreparingImport(occurrence: 7):
            OnboardingJourneyPathNode.import,
        const OnboardingBuildingLocalData(occurrence: 8):
            OnboardingJourneyPathNode.import,
        const OnboardingVerifyingDurableReadiness(occurrence: 9):
            OnboardingJourneyPathNode.import,
        const OnboardingOperationFailed(
          occurrence: 10,
          summary: 'Import did not finish.',
          compatibilityStatus: OnboardingStatus.preparationFailed,
        ): OnboardingJourneyPathNode.import,
        const OnboardingReadyToStart(occurrence: 11):
            OnboardingJourneyPathNode.start,
      };

      for (final entry in cases.entries) {
        expect(
          projectOnboardingJourneyPath(entry.key)?.currentNode,
          entry.value,
          reason: '${entry.key.episode} must map to ${entry.value}',
        );
      }
    });

    test(
      'keeps the human path on Import during the internal verification gate',
      () {
        final projection = projectOnboardingJourneyPath(
          const OnboardingVerifyingDurableReadiness(occurrence: 1),
        )!;

        expect(
          projection.nodeStates,
          <OnboardingJourneyPathNode, OnboardingJourneyPathNodeState>{
            OnboardingJourneyPathNode.messages:
                OnboardingJourneyPathNodeState.completed,
            OnboardingJourneyPathNode.history:
                OnboardingJourneyPathNodeState.completed,
            OnboardingJourneyPathNode.contacts:
                OnboardingJourneyPathNodeState.completed,
            OnboardingJourneyPathNode.ready:
                OnboardingJourneyPathNodeState.completed,
            OnboardingJourneyPathNode.import:
                OnboardingJourneyPathNodeState.current,
            OnboardingJourneyPathNode.start:
                OnboardingJourneyPathNodeState.future,
          },
        );
      },
    );

    test('fresh prerequisite regression moves the marker backward', () {
      final ready = projectOnboardingJourneyPath(
        OnboardingReadyToImport(
          occurrence: 1,
          evidence: _evidence(),
          localHistoryAccepted: false,
        ),
      )!;
      final regressed = projectOnboardingJourneyPath(
        OnboardingNeedsMessagesAccess(occurrence: 2, evidence: _evidence()),
      )!;

      expect(ready.currentNode, OnboardingJourneyPathNode.ready);
      expect(regressed.currentNode, OnboardingJourneyPathNode.messages);
      expect(
        regressed.nodeStates[OnboardingJourneyPathNode.history],
        OnboardingJourneyPathNodeState.future,
      );
    });

    test(
      'new occurrences and child progress cannot move the Episode marker',
      () {
        final first = projectOnboardingJourneyPath(
          const OnboardingBuildingLocalData(occurrence: 40),
        );
        final later = projectOnboardingJourneyPath(
          const OnboardingBuildingLocalData(occurrence: 41),
        );

        expect(first?.currentNode, OnboardingJourneyPathNode.import);
        expect(later?.currentNode, OnboardingJourneyPathNode.import);
        expect(first?.nodeStates, later?.nodeStates);
      },
    );

    test('normal application and reimport states do not project a path', () {
      expect(
        projectOnboardingJourneyPath(
          const OnboardingNormalApplication(occurrence: 1),
        ),
        isNull,
      );
      expect(
        projectOnboardingJourneyPath(
          const OnboardingReimporting(
            occurrence: 2,
            status: OnboardingStatus.reimporting,
          ),
        ),
        isNull,
      );
      expect(
        projectOnboardingJourneyPath(
          const OnboardingReimportReady(occurrence: 3),
        ),
        isNull,
      );
    });
  });

  testWidgets(
    'renders accessible compact state without narrow-width overflow',
    (tester) async {
      tester.view.physicalSize = const Size(430, 180);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MacosApp(
            home: Scaffold(
              body: OnboardingJourneyPath(
                journey: OnboardingVerifyingDurableReadiness(occurrence: 1),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Verify'), findsNothing);
      expect(find.text('Start'), findsOneWidget);
      expect(
        tester
            .getSemantics(find.byKey(const Key('onboarding-journey-path')))
            .label,
        'Current setup step: Importing. Messages access, Message history, '
        'Contacts, and Ready to import are complete.',
      );
    },
  );

  testWidgets('reduced motion removes Journey path transition durations', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MacosApp(
          home: Builder(
            builder: (context) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: OnboardingJourneyPath(
                  journey: OnboardingReadyToImport(
                    occurrence: 1,
                    evidence: _evidence(),
                    localHistoryAccepted: false,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final animations = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .toList(growable: false);
    expect(animations, isNotEmpty);
    expect(
      animations.every((widget) => widget.duration == Duration.zero),
      isTrue,
    );
  });
}

OnboardingPrerequisiteEvidence _evidence() {
  return OnboardingPrerequisiteEvidence(
    revision: 1,
    observedAtUtc: DateTime.utc(2026, 8, 26),
    report: const OnboardingEnvironmentReport(
      state: OnboardingEnvironmentState.readyToImport,
      blockerKind: OnboardingBlockerKind.none,
      syncPlausibility:
          OnboardingSyncPlausibility.likelySyncedOrLocallyAvailable,
      messagesDatabase: OnboardingDatabaseProbe(
        path: 'messages.db',
        exists: true,
        readable: true,
        rowCount: 100,
      ),
      addressBookDatabase: OnboardingDatabaseProbe(
        path: 'contacts.db',
        exists: true,
        readable: true,
        rowCount: 10,
      ),
      overlayDatabase: OnboardingDatabaseProbe(
        path: 'overlay.db',
        exists: true,
        readable: true,
      ),
      sourceScopedImportDatabase: OnboardingDatabaseProbe(
        path: 'macos_import_ss.db',
        exists: true,
        readable: true,
      ),
      conversationGraph: OnboardingDatabaseProbe(
        path: 'working_ss.db',
        exists: true,
        readable: true,
      ),
      attachmentArchiveDirectory: OnboardingDatabaseProbe(
        path: 'attachment_archive',
        exists: true,
        readable: true,
      ),
      hasFullDiskAccess: true,
    ),
  );
}
