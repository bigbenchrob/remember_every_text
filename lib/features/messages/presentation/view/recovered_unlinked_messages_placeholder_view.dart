import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/value_objects/message_timeline_scope.dart';
import './messages_timeline_view.dart';

class RecoveredUnlinkedMessagesPlaceholderView extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return MessagesTimelineView(
      key: key,
      scope: MessageTimelineScope.recovered(
        contactId: contactId,
        onlyNoHandleFromMe: onlyNoHandleFromMe,
      ),
      scrollToDate: scrollToDate,
    );
  }
}
