import 'package:flutter/widgets.dart';

import '../../../presentation/view/handle_messages_evidence_view.dart';

/// Widget builder for the messages-for-handle center panel view.
Widget buildMessagesForHandleView({required int handleId}) {
  return HandleMessagesEvidenceView(
    key: ValueKey<String>('evidence-messages-handle:$handleId'),
    handleId: handleId,
  );
}
