import 'package:flutter/widgets.dart';

import '../../../../handles/domain/spec_classes/handles_cassette_spec.dart';
import '../../../domain/spec_classes/messages_view_spec.dart';
import '../../../presentation/view/handle_investigation_idle_view.dart';
import '../../../presentation/view/handle_lens_view.dart';

/// Builds the complete Messages-owned Unknown Sources center presentation.
Widget buildHandleInvestigationView({
  required HandleInvestigationTarget target,
  required StrayHandleInvestigation investigation,
}) {
  return target.when(
    idle: () => HandleInvestigationIdleView(investigation: investigation),
    selectedSource: (handleId) =>
        HandleLensView(handleId: handleId, investigation: investigation),
  );
}
