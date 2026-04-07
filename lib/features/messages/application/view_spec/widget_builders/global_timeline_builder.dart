import 'package:flutter/widgets.dart';

import '../../../domain/value_objects/message_timeline_scope.dart';
import '../../../presentation/view/messages_timeline_view.dart';

/// Widget builder for the global timeline center panel view.
Widget buildGlobalTimelineView({DateTime? scrollToDate}) {
  return MessagesTimelineView(
    key: ValueKey<String>(
      'messages-global:${scrollToDate?.toIso8601String() ?? 'latest'}',
    ),
    scope: const MessageTimelineScope.global(),
    scrollToDate: scrollToDate,
  );
}
