import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/prerequisite_aware_message_import_decision_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/message_import_blocker.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/message_import_prerequisite_assessment.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/prerequisite_aware_message_import_decision.dart';

void main() {
  const integrator = PrerequisiteAwareMessageImportDecisionIntegrator();

  group('PrerequisiteAwareMessageImportDecisionIntegrator', () {
    test('preserves do-nothing when no message import is needed', () {
      final decision = integrator.integrate(
        baseDecision: const ImportDecision.doNothing(),
        prerequisites: const MessageImportPrerequisiteAssessment(
          blockers: <MessageImportBlocker>[
            MessageImportBlocker.handlesNotReady,
          ],
        ),
      );

      expect(
        decision,
        const PrerequisiteAwareMessageImportDecision.doNothing(),
      );
    });

    test('allows incremental import when prerequisites are satisfied', () {
      final decision = integrator.integrate(
        baseDecision: const ImportDecision.considerIncrementalImport(),
        prerequisites: const MessageImportPrerequisiteAssessment(
          blockers: <MessageImportBlocker>[],
        ),
      );

      expect(
        decision,
        const PrerequisiteAwareMessageImportDecision.considerIncrementalImport(),
      );
    });

    test('blocks incremental import when one prerequisite is missing', () {
      final decision = integrator.integrate(
        baseDecision: const ImportDecision.considerIncrementalImport(),
        prerequisites: const MessageImportPrerequisiteAssessment(
          blockers: <MessageImportBlocker>[
            MessageImportBlocker.handlesNotReady,
          ],
        ),
      );

      expect(
        decision,
        const PrerequisiteAwareMessageImportDecision.blockedPendingPrerequisites(
          blockers: <MessageImportBlocker>[
            MessageImportBlocker.handlesNotReady,
          ],
        ),
      );
    });

    test('blocks incremental import with multiple prerequisite blockers', () {
      final decision = integrator.integrate(
        baseDecision: const ImportDecision.considerIncrementalImport(),
        prerequisites: const MessageImportPrerequisiteAssessment(
          blockers: <MessageImportBlocker>[
            MessageImportBlocker.handlesNotReady,
            MessageImportBlocker.chatsNotReady,
          ],
        ),
      );

      expect(
        decision,
        const PrerequisiteAwareMessageImportDecision.blockedPendingPrerequisites(
          blockers: <MessageImportBlocker>[
            MessageImportBlocker.handlesNotReady,
            MessageImportBlocker.chatsNotReady,
          ],
        ),
      );
    });

    test('preserves ledger-ahead safety block over prerequisite state', () {
      final decision = integrator.integrate(
        baseDecision: const ImportDecision.blockAndReportLedgerAhead(),
        prerequisites: const MessageImportPrerequisiteAssessment(
          blockers: <MessageImportBlocker>[
            MessageImportBlocker.handlesNotReady,
          ],
        ),
      );

      expect(
        decision,
        const PrerequisiteAwareMessageImportDecision.blockAndReportLedgerAhead(),
      );
    });
  });
}
