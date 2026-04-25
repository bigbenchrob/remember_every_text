import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/spec_classes/environment_readiness_view_spec.dart';
import '../resolvers/pipeline_incident_panel_resolver.dart';
import '../resolvers/readiness_panel_resolver.dart';

part 'view_spec_coordinator.g.dart';

@riverpod
class ViewSpecCoordinator extends _$ViewSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator.
  }

  Widget buildForSpec(EnvironmentReadinessSpec spec) {
    return spec.when(
      readinessPanel: () => ReadinessPanelResolver().resolve(),
      pipelineIncidentPanel: () => PipelineIncidentPanelResolver().resolve(),
    );
  }
}
