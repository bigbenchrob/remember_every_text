import '../../../domain/sealed_unions/chat_import_decision.dart';
import '../../../domain/sealed_unions/chat_sync_state.dart';

class ChatImportDecisionIntegrator {
  const ChatImportDecisionIntegrator();

  ChatImportDecision integrate(ChatSyncState state) {
    return switch (state) {
      ChatSyncCursorsMatch() => const ChatImportDecision.doNothing(),
      ChatSyncSourceAheadOfLedger() =>
        const ChatImportDecision.considerIncrementalImport(),
      ChatSyncLedgerAheadOfSource() =>
        const ChatImportDecision.blockAndReportLedgerAhead(),
    };
  }
}
