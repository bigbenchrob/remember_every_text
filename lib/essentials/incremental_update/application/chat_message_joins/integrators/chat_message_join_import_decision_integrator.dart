import '../../../domain/sealed_unions/chat_message_join_import_decision.dart';
import '../../../domain/sealed_unions/chat_message_join_sync_state.dart';

class ChatMessageJoinImportDecisionIntegrator {
  const ChatMessageJoinImportDecisionIntegrator();

  ChatMessageJoinImportDecision integrate(ChatMessageJoinSyncState state) {
    return switch (state) {
      ChatMessageJoinSourceAndLedgerTopologyMatch() =>
        const ChatMessageJoinImportDecision.doNothing(),
      ChatMessageJoinSourceTopologyAheadOfLedger() =>
        const ChatMessageJoinImportDecision.considerTopologyImport(),
      ChatMessageJoinTopologyNotYetImported() =>
        const ChatMessageJoinImportDecision.considerTopologyImport(),
      ChatMessageJoinLedgerTopologyAheadOfSource() =>
        const ChatMessageJoinImportDecision.blockAndReportLedgerAhead(),
    };
  }
}
