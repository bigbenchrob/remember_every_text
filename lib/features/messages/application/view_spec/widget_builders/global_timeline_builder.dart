import 'package:flutter/widgets.dart';

import '../../../presentation/view/global_graph_messages_view.dart';

/// Widget builder for the global timeline center panel view.
Widget buildGlobalTimelineView({DateTime? scrollToDate}) {
  return GlobalGraphMessagesView(
    key: ValueKey<String>(
      'graph-messages-global:${scrollToDate?.toIso8601String() ?? 'latest'}',
    ),
    monthAnchor: scrollToDate,
  );
}
