import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../application/contacts/contact_graph_repository.dart';
import 'contact_graph_repository.dart';

part 'contact_graph_repository_provider.g.dart';

@riverpod
Future<ContactGraphRepository> contactGraphRepository(
  ContactGraphRepositoryRef ref,
) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  return SqliteContactGraphRepository(graphDatabase: graphDatabase);
}
