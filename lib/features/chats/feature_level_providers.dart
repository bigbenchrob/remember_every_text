// Riverpod provider for a ChatsRepository implementation.
// Location: lib/features/chats/feature_level_providers/chat_repository_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

import './infrastructure/repositories/sqlite_chats_repository.dart';
// If you have a database or other deps, import their providers here:
// import '../../shared/feature_level_providers/working_db_provider.dart';

part 'feature_level_providers.g.dart';

@riverpod
class ChatsRepository extends _$ChatsRepository {
  /// Build and return the concrete ChatsRepository.
  /// Wire your dependencies via `ref.watch(...)` inside this method.
  @override
  SqliteChatsRepository build() {
    // Example (uncomment & adapt to your project):
    // final db = ref.watch(workingDbProvider);
    // return SqliteChatsRepository(db: db);

    // Temporary placeholder to keep compilation clear until infra is wired:
    return SqliteChatsRepository();
  }
}
