import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers/persistent_database_providers.dart'
    show driftConversationGraphDatabaseProvider;
import '../../infrastructure/repositories/drift_graph_projection_resetter.dart';
import 'graph_projection_resetter.dart';

part 'graph_projection_resetter_provider.g.dart';

@riverpod
Future<GraphProjectionResetter> graphProjectionResetter(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return DriftGraphProjectionResetter(graphDatabase: graphDatabase);
}
