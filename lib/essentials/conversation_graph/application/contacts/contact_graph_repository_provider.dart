import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers/persistent_database_providers.dart'
    show driftConversationGraphDatabaseProvider;
import '../../infrastructure/repositories/contact_graph_repository.dart';
import 'contact_graph_repository.dart';

part 'contact_graph_repository_provider.g.dart';

@riverpod
Future<ContactGraphRepository> contactGraphRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return SqliteContactGraphRepository(graphDatabase: graphDatabase);
}
