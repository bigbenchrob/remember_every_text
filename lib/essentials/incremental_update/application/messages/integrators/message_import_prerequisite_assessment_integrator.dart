import '../../../domain/models/message_import_blocker.dart';
import '../../../domain/models/message_import_prerequisite_assessment.dart';
import '../../../domain/sealed_unions/chat_sync_state.dart';
import '../../../domain/sealed_unions/handle_sync_state.dart';

/// Architectural note:
///
/// This prerequisite assessment layer intentionally replaces ad-hoc
/// importer pre-validation booleans/functions with explicit semantic state.
///
/// Instead of importers privately deciding:
///
///   “can execution proceed? true/false”
///
/// the system now derives:
///
///   - what prerequisites were evaluated
///   - which prerequisites are unsatisfied
///   - why execution would be blocked
///   - what conditions must become true before execution is safe
///
/// This prevents prerequisite/validation logic from drifting into scattered,
/// hidden importer control flow.
///
/// Execution/orchestration layers can now depend on explicit semantic meaning
/// rather than opaque validation functions.
///
/// The assessment object therefore acts as:
///
///   facts
///   → prerequisite semantics
///   → policy meaning
///
/// rather than:
///
///   importer-local validation branching.
///
/// This preserves:
/// - causal explainability
/// - testability
/// - observability
/// - exhaustive semantic handling
/// - future graph-aware orchestration safety

class MessageImportPrerequisiteAssessmentIntegrator {
  const MessageImportPrerequisiteAssessmentIntegrator();

  MessageImportPrerequisiteAssessment integrate({
    required HandleSyncState handleSyncState,
    required ChatSyncState chatSyncState,
  }) {
    final blockers = <MessageImportBlocker>[
      if (handleSyncState is! HandleSyncCursorsMatch)
        MessageImportBlocker.handlesNotReady,
      if (chatSyncState is! ChatSyncCursorsMatch)
        MessageImportBlocker.chatsNotReady,
    ];

    return MessageImportPrerequisiteAssessment(blockers: blockers);
  }
}
