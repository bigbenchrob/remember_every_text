import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'topology_projection_preview_integrator.dart';

part 'topology_projection_preview_integrator_provider.g.dart';

@riverpod
TopologyProjectionPreviewIntegrator topologyProjectionPreviewIntegrator(
  Ref ref,
) {
  return const TopologyProjectionPreviewIntegrator();
}
