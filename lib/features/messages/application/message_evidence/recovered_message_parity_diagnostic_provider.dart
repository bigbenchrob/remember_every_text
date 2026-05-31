import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/shared/handle_identifier_utils.dart';
import '../../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import '../../domain/message_evidence/recovered_message_evidence.dart';
import '../../domain/message_evidence/recovered_message_parity.dart';
import '../../infrastructure/repositories/graph_recovered_message_evidence_repository.dart';
import '../../infrastructure/repositories/graph_recovered_message_projectability_repository.dart';
import '../../infrastructure/repositories/legacy_working_recovered_message_evidence_repository.dart';

part 'recovered_message_parity_diagnostic_provider.g.dart';

class RecoveredMessageParityDiagnostic {
  const RecoveredMessageParityDiagnostic({
    required this.isReady,
    required this.reason,
    required this.report,
  });

  const RecoveredMessageParityDiagnostic.unavailable(String reason)
    : this(isReady: false, reason: reason, report: null);

  const RecoveredMessageParityDiagnostic.ready(
    RecoveredMessageParityReport report,
  ) : this(
        isReady: true,
        reason: 'recovered message parity checked',
        report: report,
      );

  final bool isReady;
  final String reason;
  final RecoveredMessageParityReport? report;

  bool get canCutOverWithoutEvidenceLoss {
    return report?.canCutOverWithoutEvidenceLoss ?? false;
  }
}

@riverpod
Future<RecoveredMessageParityDiagnostic> recoveredMessageParityDiagnostic(
  Ref ref,
) async {
  final workingReadiness = await ref.watch(
    workingProjectionReadinessProvider.future,
  );
  if (!workingReadiness.isReady) {
    return RecoveredMessageParityDiagnostic.unavailable(
      'legacy recovered evidence unavailable: ${workingReadiness.reason}',
    );
  }

  final graphReadiness = await ref.watch(
    conversationGraphReadinessProvider.future,
  );
  if (!graphReadiness.isReady) {
    return RecoveredMessageParityDiagnostic.unavailable(
      'conversation graph unavailable: ${graphReadiness.reason}',
    );
  }

  final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  final legacyMessages = await LegacyWorkingRecoveredMessageEvidenceRepository(
    db: workingDb,
    overlayDb: overlayDb,
  ).watchMessages().first;
  final graphRecoveredMessages = await GraphRecoveredMessageEvidenceRepository(
    graphDb: graphDb,
  ).watchMessages().first;

  final graphProjectableMessageIds =
      await GraphRecoveredMessageProjectabilityRepository(
        graphDb: graphDb,
      ).readProjectableMessageIds(_graphMessageIdsForLegacy(legacyMessages));
  final dismissedHandles = await overlayDb.getAllDismissedHandles();
  final suppressedLegacyMessageIds = _suppressedLegacyMessageIds(
    legacyMessages: legacyMessages,
    dismissedHandles: dismissedHandles,
  );

  return RecoveredMessageParityDiagnostic.ready(
    compareRecoveredMessageEvidence(
      legacyMessages: legacyMessages,
      graphRecoveredMessages: graphRecoveredMessages,
      graphProjectableMessageIds: graphProjectableMessageIds,
      legacyRecoveredSourceId: liveChatDbSourceId,
      suppressedLegacyMessageIds: suppressedLegacyMessageIds,
    ),
  );
}

Iterable<int> _graphMessageIdsForLegacy(
  List<RecoveredUnlinkedMessageItem> legacyMessages,
) sync* {
  for (final message in legacyMessages) {
    if (message.id < 1 || message.id > SourceScopedRowKey.maxSourceRowId) {
      continue;
    }
    yield SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: message.id,
    );
  }
}

Set<int> _suppressedLegacyMessageIds({
  required List<RecoveredUnlinkedMessageItem> legacyMessages,
  required Set<String> dismissedHandles,
}) {
  if (dismissedHandles.isEmpty) {
    return const <int>{};
  }

  return {
    for (final message in legacyMessages)
      if (_isSuppressedByDismissedHandle(message, dismissedHandles)) message.id,
  };
}

bool _isSuppressedByDismissedHandle(
  RecoveredUnlinkedMessageItem message,
  Set<String> dismissedHandles,
) {
  if (message.isFromMe) {
    return false;
  }

  final senderLabelKey = normalizeHandleIdentifier(message.senderLabel);
  if (senderLabelKey != null && dismissedHandles.contains(senderLabelKey)) {
    return true;
  }

  final contactNameKey = normalizeHandleIdentifier(message.contactName);
  return contactNameKey != null && dismissedHandles.contains(contactNameKey);
}
