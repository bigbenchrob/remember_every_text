import 'package:freezed_annotation/freezed_annotation.dart';

part 'topology_projection_preview_status.freezed.dart';

@freezed
sealed class TopologyProjectionPreviewStatus
    with _$TopologyProjectionPreviewStatus {
  const factory TopologyProjectionPreviewStatus.projectable() =
      TopologyProjectionPreviewStatusProjectable;

  const factory TopologyProjectionPreviewStatus.missingLedgerMessage() =
      TopologyProjectionPreviewStatusMissingLedgerMessage;

  const factory TopologyProjectionPreviewStatus.missingLedgerChat() =
      TopologyProjectionPreviewStatusMissingLedgerChat;

  const factory TopologyProjectionPreviewStatus.missingWorkingMessage() =
      TopologyProjectionPreviewStatusMissingWorkingMessage;

  const factory TopologyProjectionPreviewStatus.missingWorkingChat() =
      TopologyProjectionPreviewStatusMissingWorkingChat;

  const factory TopologyProjectionPreviewStatus.ambiguousWorkingChat() =
      TopologyProjectionPreviewStatusAmbiguousWorkingChat;

  const factory TopologyProjectionPreviewStatus.alreadyProjected() =
      TopologyProjectionPreviewStatusAlreadyProjected;

  const factory TopologyProjectionPreviewStatus.notYetSupported() =
      TopologyProjectionPreviewStatusNotYetSupported;
}

extension TopologyProjectionPreviewStatusLabel
    on TopologyProjectionPreviewStatus {
  String get label => switch (this) {
    TopologyProjectionPreviewStatusProjectable() => 'projectable',
    TopologyProjectionPreviewStatusMissingLedgerMessage() =>
      'missingLedgerMessage',
    TopologyProjectionPreviewStatusMissingLedgerChat() => 'missingLedgerChat',
    TopologyProjectionPreviewStatusMissingWorkingMessage() =>
      'missingWorkingMessage',
    TopologyProjectionPreviewStatusMissingWorkingChat() => 'missingWorkingChat',
    TopologyProjectionPreviewStatusAmbiguousWorkingChat() =>
      'ambiguousWorkingChat',
    TopologyProjectionPreviewStatusAlreadyProjected() => 'alreadyProjected',
    TopologyProjectionPreviewStatusNotYetSupported() => 'notYetSupported',
  };
}
