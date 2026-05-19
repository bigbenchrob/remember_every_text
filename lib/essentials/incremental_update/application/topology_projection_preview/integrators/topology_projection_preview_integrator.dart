import '../../../domain/models/topology_projection_preview.dart';
import '../../../domain/sealed_unions/topology_projection_preview_status.dart';

class TopologyProjectionPreviewIntegrator {
  const TopologyProjectionPreviewIntegrator();

  TopologyProjectionPreviewResult integrateRow(
    TopologyProjectionPreviewFact fact,
  ) {
    final status = _statusFor(fact);
    return TopologyProjectionPreviewResult(
      sourceId: fact.sourceId,
      sourceKind: fact.sourceKind,
      sourceJoinRowId: fact.sourceJoinRowId,
      sourceChatRowId: fact.sourceChatRowId,
      sourceMessageRowId: fact.sourceMessageRowId,
      status: status,
      ledgerMessageId: fact.ledgerMessageId,
      ledgerMessageGuid: fact.ledgerMessageGuid,
      ledgerChatId: fact.ledgerChatId,
      ledgerChatGuid: fact.ledgerChatGuid,
      workingMessageIds: fact.workingMessageIds,
      workingChatIds: fact.workingChatIds,
    );
  }

  TopologyProjectionPreviewSummary integrate(
    List<TopologyProjectionPreviewFact> facts, {
    int sampleLimit = 25,
  }) {
    final results = facts.map(integrateRow).toList(growable: false);
    final countsByStatus = <String, int>{};
    for (final result in results) {
      final label = result.status.label;
      countsByStatus[label] = (countsByStatus[label] ?? 0) + 1;
    }

    return TopologyProjectionPreviewSummary(
      totalRowCount: results.length,
      countsByStatus: Map<String, int>.unmodifiable(countsByStatus),
      sampleResults: List<TopologyProjectionPreviewResult>.unmodifiable(
        results.take(sampleLimit),
      ),
    );
  }

  TopologyProjectionPreviewStatus _statusFor(
    TopologyProjectionPreviewFact fact,
  ) {
    if (fact.ledgerMessageId == null) {
      return const TopologyProjectionPreviewStatus.missingLedgerMessage();
    }
    if (fact.ledgerChatId == null) {
      return const TopologyProjectionPreviewStatus.missingLedgerChat();
    }
    if (fact.workingMessageIds.isEmpty) {
      return const TopologyProjectionPreviewStatus.missingWorkingMessage();
    }
    if (fact.workingChatIds.isEmpty) {
      return const TopologyProjectionPreviewStatus.missingWorkingChat();
    }
    if (fact.workingChatIds.length > 1) {
      return const TopologyProjectionPreviewStatus.ambiguousWorkingChat();
    }
    return const TopologyProjectionPreviewStatus.projectable();
  }
}
