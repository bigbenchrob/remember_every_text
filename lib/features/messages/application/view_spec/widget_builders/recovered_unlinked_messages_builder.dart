import 'package:flutter/widgets.dart';

import '../../../presentation/view/recovered_messages_evidence_view.dart';

/// Widget builder for the recovered-unlinked-messages center panel view.
Widget buildRecoveredUnlinkedMessagesView({
  int? contactId,
  DateTime? scrollToDate,
  bool onlyNoHandleFromMe = false,
}) {
  return RecoveredMessagesEvidenceView(
    key: ValueKey<String>(
      'messages-recovered:${contactId ?? 'global'}:$onlyNoHandleFromMe:${scrollToDate?.toIso8601String() ?? 'latest'}',
    ),
    contactId: contactId,
    scrollToDate: scrollToDate,
    onlyNoHandleFromMe: onlyNoHandleFromMe,
  );
}
