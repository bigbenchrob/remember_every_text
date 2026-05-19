import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/topology_projection_preview.dart';
import '../readers/topology_projection_preview_facts_provider.dart';
import 'topology_projection_preview_integrator_provider.dart';

part 'topology_projection_preview_provider.g.dart';

@riverpod
Future<TopologyProjectionPreviewSummary> topologyProjectionPreview(
  Ref ref,
) async {
  final facts = await ref.watch(topologyProjectionPreviewFactsProvider.future);
  final integrator = ref.watch(topologyProjectionPreviewIntegratorProvider);
  return integrator.integrate(facts);
}
