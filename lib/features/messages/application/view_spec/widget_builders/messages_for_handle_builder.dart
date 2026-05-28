import 'package:flutter/widgets.dart';

import '../../../presentation/view/handle_graph_messages_view.dart';

/// Widget builder for the messages-for-handle center panel view.
Widget buildMessagesForHandleView({required int handleId}) {
  return HandleGraphMessagesView(
    key: ValueKey<String>('graph-messages-handle:$handleId'),
    handleId: handleId,
  );
}
