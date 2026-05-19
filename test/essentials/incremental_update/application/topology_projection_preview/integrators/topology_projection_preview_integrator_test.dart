import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/topology_projection_preview/integrators/topology_projection_preview_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/topology_projection_preview.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/topology_projection_preview_status.dart';

void main() {
  group('TopologyProjectionPreviewIntegrator', () {
    test('classifies a fully resolved row as projectable', () {
      final result = const TopologyProjectionPreviewIntegrator().integrateRow(
        _fact(
          ledgerMessageId: 10,
          ledgerMessageGuid: 'message-guid',
          ledgerChatId: 20,
          ledgerChatGuid: 'chat-guid',
          workingMessageIds: <int>[100],
          workingChatIds: <int>[200],
        ),
      );

      expect(
        result.status,
        const TopologyProjectionPreviewStatus.projectable(),
      );
      expect(result.sourceJoinRowId, 1);
      expect(result.sourceChatRowId, 2);
      expect(result.sourceMessageRowId, 3);
    });

    test('classifies missing ledger message before other endpoint checks', () {
      final result = const TopologyProjectionPreviewIntegrator().integrateRow(
        _fact(
          ledgerChatId: 20,
          ledgerChatGuid: 'chat-guid',
          workingMessageIds: <int>[100],
          workingChatIds: <int>[200],
        ),
      );

      expect(
        result.status,
        const TopologyProjectionPreviewStatus.missingLedgerMessage(),
      );
    });

    test('classifies missing ledger chat', () {
      final result = const TopologyProjectionPreviewIntegrator().integrateRow(
        _fact(
          ledgerMessageId: 10,
          ledgerMessageGuid: 'message-guid',
          workingMessageIds: <int>[100],
          workingChatIds: <int>[200],
        ),
      );

      expect(
        result.status,
        const TopologyProjectionPreviewStatus.missingLedgerChat(),
      );
    });

    test('classifies missing working message', () {
      final result = const TopologyProjectionPreviewIntegrator().integrateRow(
        _fact(
          ledgerMessageId: 10,
          ledgerMessageGuid: 'message-guid',
          ledgerChatId: 20,
          ledgerChatGuid: 'chat-guid',
          workingChatIds: <int>[200],
        ),
      );

      expect(
        result.status,
        const TopologyProjectionPreviewStatus.missingWorkingMessage(),
      );
    });

    test('classifies missing working chat', () {
      final result = const TopologyProjectionPreviewIntegrator().integrateRow(
        _fact(
          ledgerMessageId: 10,
          ledgerMessageGuid: 'message-guid',
          ledgerChatId: 20,
          ledgerChatGuid: 'chat-guid',
          workingMessageIds: <int>[100],
        ),
      );

      expect(
        result.status,
        const TopologyProjectionPreviewStatus.missingWorkingChat(),
      );
    });

    test('classifies ambiguous working chat', () {
      final result = const TopologyProjectionPreviewIntegrator().integrateRow(
        _fact(
          ledgerMessageId: 10,
          ledgerMessageGuid: 'message-guid',
          ledgerChatId: 20,
          ledgerChatGuid: 'chat-guid',
          workingMessageIds: <int>[100],
          workingChatIds: <int>[200, 201],
        ),
      );

      expect(
        result.status,
        const TopologyProjectionPreviewStatus.ambiguousWorkingChat(),
      );
    });

    test('summarizes counts by projection status', () {
      final summary = const TopologyProjectionPreviewIntegrator().integrate(
        <TopologyProjectionPreviewFact>[
          _fact(
            sourceJoinRowId: 1,
            ledgerMessageId: 10,
            ledgerMessageGuid: 'message-guid-1',
            ledgerChatId: 20,
            ledgerChatGuid: 'chat-guid-1',
            workingMessageIds: <int>[100],
            workingChatIds: <int>[200],
          ),
          _fact(sourceJoinRowId: 2),
        ],
      );

      expect(summary.totalRowCount, 2);
      expect(summary.countsByStatus['projectable'], 1);
      expect(summary.countsByStatus['missingLedgerMessage'], 1);
      expect(summary.sampleResults, hasLength(2));
    });
  });
}

TopologyProjectionPreviewFact _fact({
  int sourceJoinRowId = 1,
  int sourceChatRowId = 2,
  int sourceMessageRowId = 3,
  int? ledgerMessageId,
  String? ledgerMessageGuid,
  int? ledgerChatId,
  String? ledgerChatGuid,
  List<int> workingMessageIds = const <int>[],
  List<int> workingChatIds = const <int>[],
}) {
  return TopologyProjectionPreviewFact(
    sourceId: 'live-chat-db',
    sourceKind: 'live_chat_db',
    sourceJoinRowId: sourceJoinRowId,
    sourceChatRowId: sourceChatRowId,
    sourceMessageRowId: sourceMessageRowId,
    ledgerMessageId: ledgerMessageId,
    ledgerMessageGuid: ledgerMessageGuid,
    ledgerChatId: ledgerChatId,
    ledgerChatGuid: ledgerChatGuid,
    workingMessageIds: workingMessageIds,
    workingChatIds: workingChatIds,
  );
}
