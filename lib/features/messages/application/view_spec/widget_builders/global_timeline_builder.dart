import 'package:flutter/widgets.dart';

import '../../../presentation/view/global_messages_evidence_view.dart';

/// Widget builder for the global timeline center panel view.
Widget buildGlobalTimelineView({DateTime? scrollToDate}) {
  return GlobalMessagesEvidenceView(
    key: ValueKey<String>(
      'evidence-messages-global:${scrollToDate?.toIso8601String() ?? 'latest'}',
    ),
    monthAnchor: scrollToDate,
  );
}
