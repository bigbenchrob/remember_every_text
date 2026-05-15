import '../../../domain/sealed_unions/handle_import_decision.dart';
import '../../../domain/sealed_unions/handle_sync_state.dart';

class HandleImportDecisionIntegrator {
  const HandleImportDecisionIntegrator();

  HandleImportDecision integrate(HandleSyncState state) {
    return switch (state) {
      HandleSyncCursorsMatch() => const HandleImportDecision.doNothing(),
      HandleSyncSourceAheadOfLedger() =>
        const HandleImportDecision.considerIncrementalImport(),
      HandleSyncLedgerAheadOfSource() =>
        const HandleImportDecision.blockAndReportLedgerAhead(),
    };
  }
}
