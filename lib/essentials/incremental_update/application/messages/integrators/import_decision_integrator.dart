import '../../../domain/sealed_unions/import_decision.dart';
import '../../../domain/sealed_unions/sync_state.dart';

class ImportDecisionIntegrator {
  ImportDecision integrate(MessageSyncState state) {
    return switch (state) {
      MessageSyncCursorsMatch() => const ImportDecision.doNothing(),

      MessageSyncSourceAheadOfLedger() =>
        const ImportDecision.considerIncrementalImport(),

      MessageSyncLedgerAheadOfSource() =>
        const ImportDecision.blockAndReportLedgerAhead(),
    };
  }
}
