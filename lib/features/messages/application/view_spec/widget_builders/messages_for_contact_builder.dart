import 'package:flutter/widgets.dart';

import '../../../presentation/view/contact_graph_messages_view.dart';

/// Widget builder for the contact messages view.
///
/// Constructs a graph-backed message evidence view for the given contact,
/// optionally scrolled to a specific date.
Widget buildMessagesForContactView({
  required int contactId,
  DateTime? scrollToDate,
  int? filterHandleId,
}) {
  return ContactGraphMessagesView(
    key: ValueKey<String>(
      'graph-messages-contact:$contactId:${filterHandleId ?? 'all'}:${scrollToDate?.toIso8601String() ?? 'latest'}',
    ),
    contactId: contactId,
    monthAnchor: scrollToDate,
    filterHandleId: filterHandleId,
  );
}
