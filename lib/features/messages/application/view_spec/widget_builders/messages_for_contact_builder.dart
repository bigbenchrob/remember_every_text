import 'package:flutter/widgets.dart';

import '../../../presentation/view/contact_messages_evidence_view.dart';

/// Widget builder for the contact messages view.
///
/// Constructs a message evidence view for the given contact,
/// optionally scrolled to a specific date.
Widget buildMessagesForContactView({
  required int contactId,
  DateTime? scrollToDate,
  int? filterHandleId,
}) {
  return ContactMessagesEvidenceView(
    key: ValueKey<String>(
      'evidence-messages-contact:$contactId:${filterHandleId ?? 'all'}:${scrollToDate?.toIso8601String() ?? 'latest'}',
    ),
    contactId: contactId,
    monthAnchor: scrollToDate,
    filterHandleId: filterHandleId,
  );
}
