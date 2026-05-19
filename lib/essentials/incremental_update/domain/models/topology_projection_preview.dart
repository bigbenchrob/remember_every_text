import 'package:freezed_annotation/freezed_annotation.dart';

import '../sealed_unions/topology_projection_preview_status.dart';

part 'topology_projection_preview.freezed.dart';

@freezed
abstract class TopologyProjectionPreviewFact
    with _$TopologyProjectionPreviewFact {
  const factory TopologyProjectionPreviewFact({
    required String sourceId,
    required String sourceKind,
    required int sourceJoinRowId,
    required int sourceChatRowId,
    required int sourceMessageRowId,
    int? ledgerMessageId,
    String? ledgerMessageGuid,
    int? ledgerChatId,
    String? ledgerChatGuid,
    @Default(<int>[]) List<int> workingMessageIds,
    @Default(<int>[]) List<int> workingChatIds,
  }) = _TopologyProjectionPreviewFact;
}

@freezed
abstract class TopologyProjectionPreviewResult
    with _$TopologyProjectionPreviewResult {
  const factory TopologyProjectionPreviewResult({
    required String sourceId,
    required String sourceKind,
    required int sourceJoinRowId,
    required int sourceChatRowId,
    required int sourceMessageRowId,
    required TopologyProjectionPreviewStatus status,
    int? ledgerMessageId,
    String? ledgerMessageGuid,
    int? ledgerChatId,
    String? ledgerChatGuid,
    @Default(<int>[]) List<int> workingMessageIds,
    @Default(<int>[]) List<int> workingChatIds,
  }) = _TopologyProjectionPreviewResult;
}

@freezed
abstract class TopologyProjectionPreviewSummary
    with _$TopologyProjectionPreviewSummary {
  const factory TopologyProjectionPreviewSummary({
    required int totalRowCount,
    required Map<String, int> countsByStatus,
    @Default(<TopologyProjectionPreviewResult>[])
    List<TopologyProjectionPreviewResult> sampleResults,
  }) = _TopologyProjectionPreviewSummary;
}
