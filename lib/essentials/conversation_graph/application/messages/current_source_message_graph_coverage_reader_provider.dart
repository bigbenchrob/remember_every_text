import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider;
import '../../infrastructure/repositories/sqlite_current_source_message_graph_coverage_reader.dart';
import 'current_source_message_graph_coverage_reader.dart';

part 'current_source_message_graph_coverage_reader_provider.g.dart';

@riverpod
Future<CurrentSourceMessageGraphCoverageReader>
currentSourceMessageGraphCoverageReader(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return SqliteCurrentSourceMessageGraphCoverageReader(
    graphDatabase: graphDatabase,
  );
}
