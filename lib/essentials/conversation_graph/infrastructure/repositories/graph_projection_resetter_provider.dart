import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../application/archives/graph_projection_resetter.dart';
import 'drift_graph_projection_resetter.dart';

part 'graph_projection_resetter_provider.g.dart';

@riverpod
Future<GraphProjectionResetter> graphProjectionResetter(
  GraphProjectionResetterRef ref,
) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return DriftGraphProjectionResetter(graphDatabase: graphDatabase);
}
