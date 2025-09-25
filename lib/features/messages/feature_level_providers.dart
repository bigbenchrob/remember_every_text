// Riverpod provider for a MessagesRepository implementation.
// Location: lib/features/messages/feature_level_providers/messages_repository_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'infrastructure/repositories/sqlite_messages_repository.dart';
// Bring in your DB/clients here and wire via ref.watch(...)
// import '../../shared/feature_level_providers/working_db_provider.dart';

part 'feature_level_providers.g.dart';

@riverpod
class MessageRepository extends _$MessageRepository {
  /// Build and return the concrete MessagesRepository.
  /// Wire real dependencies with ref.watch(...) as you implement infra.
  @override
  SqliteMessagesRepository build() {
    // final db = ref.watch(workingDbProvider);
    // return SqliteMessagesRepository(db: db);
    return SqliteMessagesRepository();
  }
}
