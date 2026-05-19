import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/topology_projection_preview_repository_provider.dart';
import 'topology_projection_preview_facts_reader.dart';

part 'topology_projection_preview_facts_reader_provider.g.dart';

@riverpod
Future<TopologyProjectionPreviewFactsReader>
topologyProjectionPreviewFactsReader(Ref ref) async {
  final repository = await ref.watch(
    topologyProjectionPreviewRepositoryProvider.future,
  );
  return TopologyProjectionPreviewFactsReader(repository: repository);
}
