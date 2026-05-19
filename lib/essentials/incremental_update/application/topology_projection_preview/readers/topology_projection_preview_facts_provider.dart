import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/topology_projection_preview.dart';
import 'topology_projection_preview_facts_reader_provider.dart';

part 'topology_projection_preview_facts_provider.g.dart';

@riverpod
Future<List<TopologyProjectionPreviewFact>> topologyProjectionPreviewFacts(
  Ref ref,
) async {
  final reader = await ref.watch(
    topologyProjectionPreviewFactsReaderProvider.future,
  );
  return reader.read();
}
