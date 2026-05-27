import 'package:flutter/widgets.dart';

import '../../../domain/value_objects/message_timeline_scope.dart';
import '../../../presentation/view/contact_graph_messages_view.dart';
import '../../../presentation/view/messages_timeline_view.dart';

/// Widget builder for the contact messages view.
///
/// Constructs a unified [MessagesTimelineView] for the given contact,
/// optionally scrolled to a specific date.
Widget buildMessagesForContactView({
  required int contactId,
  DateTime? scrollToDate,
  int? filterHandleId,
}) {
  if (filterHandleId == null) {
    return ContactGraphMessagesView(
      key: ValueKey<String>(
        'graph-messages-contact:$contactId:${scrollToDate?.toIso8601String() ?? 'latest'}',
      ),
      contactId: contactId,
      monthAnchor: scrollToDate,
    );
  }

  return MessagesTimelineView(
    key: ValueKey<String>(
      'messages-contact:$contactId:$filterHandleId:${scrollToDate?.toIso8601String() ?? 'latest'}',
    ),
    scope: MessageTimelineScope.contact(
      contactId: contactId,
      filterHandleId: filterHandleId,
    ),
    scrollToDate: scrollToDate,
  );
}
