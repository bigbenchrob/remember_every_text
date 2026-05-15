import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/message_import_prerequisite_assessment_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/message_import_blocker.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_sync_state.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/handle_sync_state.dart';

void main() {
  const integrator = MessageImportPrerequisiteAssessmentIntegrator();

  group('MessageImportPrerequisiteAssessmentIntegrator', () {
    test('marks prerequisites satisfied when handles and chats are ready', () {
      final assessment = integrator.integrate(
        handleSyncState: const HandleSyncState.sourceAndLedgerCursorsMatch(),
        chatSyncState: const ChatSyncState.sourceAndLedgerCursorsMatch(),
      );

      expect(assessment.isSatisfied, isTrue);
      expect(assessment.blockers, isEmpty);
    });

    test('blocks messages when handles are not ready', () {
      final assessment = integrator.integrate(
        handleSyncState: const HandleSyncState.sourceAheadOfLedger(),
        chatSyncState: const ChatSyncState.sourceAndLedgerCursorsMatch(),
      );

      expect(assessment.isBlocked, isTrue);
      expect(assessment.blockers, <MessageImportBlocker>[
        MessageImportBlocker.handlesNotReady,
      ]);
    });

    test('blocks messages when chats are not ready', () {
      final assessment = integrator.integrate(
        handleSyncState: const HandleSyncState.sourceAndLedgerCursorsMatch(),
        chatSyncState: const ChatSyncState.sourceAheadOfLedger(),
      );

      expect(assessment.isBlocked, isTrue);
      expect(assessment.blockers, <MessageImportBlocker>[
        MessageImportBlocker.chatsNotReady,
      ]);
    });

    test('reports multiple prerequisite blockers in causal order', () {
      final assessment = integrator.integrate(
        handleSyncState: const HandleSyncState.ledgerAheadOfSource(),
        chatSyncState: const ChatSyncState.sourceAheadOfLedger(),
      );

      expect(assessment.isBlocked, isTrue);
      expect(assessment.blockers, <MessageImportBlocker>[
        MessageImportBlocker.handlesNotReady,
        MessageImportBlocker.chatsNotReady,
      ]);
    });
  });
}
