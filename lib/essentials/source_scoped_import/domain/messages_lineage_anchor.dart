import 'package:flutter/foundation.dart';

@immutable
final class MessagesLineageAnchor {
  const MessagesLineageAnchor({
    required this.originalMessagesRowId,
    required this.messageGuid,
  });

  final int originalMessagesRowId;
  final String messageGuid;
}

@immutable
final class MessagesLineageAnchorEvidence {
  const MessagesLineageAnchorEvidence({
    required this.anchors,
    required this.blankGuidRowIds,
    required this.observedRecordCount,
    required this.blankGuidCount,
    required this.inconsistentIdentityCount,
    required this.duplicateRowIdCount,
    required this.sourceShapeIsCoherent,
  });

  final List<MessagesLineageAnchor> anchors;
  final Set<int> blankGuidRowIds;
  final int observedRecordCount;
  final int blankGuidCount;
  final int inconsistentIdentityCount;
  final int duplicateRowIdCount;
  final bool sourceShapeIsCoherent;
}
