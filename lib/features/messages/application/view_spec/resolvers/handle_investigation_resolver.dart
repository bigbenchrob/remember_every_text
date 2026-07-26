import 'package:flutter/widgets.dart';

import '../../../../handles/domain/spec_classes/handles_cassette_spec.dart';
import '../../../domain/spec_classes/messages_view_spec.dart';
import '../widget_builders/handle_investigation_builder.dart';

/// Resolves one Unknown Sources investigation and its current target.
class HandleInvestigationResolver {
  Widget resolve({
    required StrayHandleInvestigation investigation,
    required HandleInvestigationTarget target,
  }) {
    return buildHandleInvestigationView(
      investigation: investigation,
      target: target,
    );
  }
}
