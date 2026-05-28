import 'package:flutter/widgets.dart';

import 'recovered_messages_evidence_view.dart';

class RecoveredUnlinkedMessagesPlaceholderView extends StatelessWidget {
  const RecoveredUnlinkedMessagesPlaceholderView({
    this.contactId,
    this.scrollToDate,
    this.onlyNoHandleFromMe = false,
    super.key,
  });

  final int? contactId;
  final DateTime? scrollToDate;
  final bool onlyNoHandleFromMe;

  @override
  Widget build(BuildContext context) {
    return RecoveredMessagesEvidenceView(
      key: key,
      contactId: contactId,
      scrollToDate: scrollToDate,
      onlyNoHandleFromMe: onlyNoHandleFromMe,
    );
  }
}
