import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../logging/feature_level_providers.dart';
import '../../feature_level_providers.dart';

part 'conversation_favourites_provider.g.dart';

enum ConversationFavouriteGroup {
  core;

  String get storageKey {
    return switch (this) {
      ConversationFavouriteGroup.core => 'core',
    };
  }
}

class ConversationFavourites {
  const ConversationFavourites({this.coreConversationIds = const <int>[]});

  final List<int> coreConversationIds;

  static ConversationFavourites fromCoreStorage(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return const ConversationFavourites();
    }

    final ids = <int>[];
    final seen = <int>{};
    for (final token in rawValue.split(',')) {
      final id = int.tryParse(token.trim());
      if (id == null || !seen.add(id)) {
        continue;
      }
      ids.add(id);
    }

    return ConversationFavourites(
      coreConversationIds: List<int>.unmodifiable(ids),
    );
  }

  Set<int> get coreConversationIdSet => coreConversationIds.toSet();

  String get coreStorageValue => coreConversationIds.join(',');

  bool isCoreFavourite(int conversationId) {
    return coreConversationIdSet.contains(conversationId);
  }

  ConversationFavourites addCoreFavourite(int conversationId) {
    if (isCoreFavourite(conversationId)) {
      return this;
    }
    return ConversationFavourites(
      coreConversationIds: List<int>.unmodifiable([
        conversationId,
        ...coreConversationIds,
      ]),
    );
  }

  ConversationFavourites removeCoreFavourite(int conversationId) {
    if (!isCoreFavourite(conversationId)) {
      return this;
    }
    return ConversationFavourites(
      coreConversationIds: List<int>.unmodifiable(
        coreConversationIds.where((id) => id != conversationId),
      ),
    );
  }
}

@Riverpod(keepAlive: true)
class ConversationFavouritesController
    extends _$ConversationFavouritesController {
  bool _restoreScheduled = false;
  bool _hasLocalMutation = false;

  @override
  ConversationFavourites build() {
    if (!_restoreScheduled) {
      _restoreScheduled = true;
      unawaited(_restoreFavourites());
    }

    return const ConversationFavourites();
  }

  Future<void> toggleCoreFavourite(int conversationId) async {
    _hasLocalMutation = true;
    state = state.isCoreFavourite(conversationId)
        ? state.removeCoreFavourite(conversationId)
        : state.addCoreFavourite(conversationId);
    await _persistCoreFavourites(conversationId: conversationId);
  }

  Future<void> _persistCoreFavourites({required int conversationId}) async {
    try {
      final store = await ref.read(conversationFavouritesStoreProvider.future);
      await store.writeCoreFavourites(state.coreStorageValue);
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Conversation favourites persist failed',
            source: 'ConversationFavouritesController',
            context: <String, Object?>{
              'conversationId': conversationId,
              'state': state.coreStorageValue,
              'error': error.toString(),
              'stackTrace': stackTrace.toString(),
            },
          );
    }
  }

  Future<void> _restoreFavourites() async {
    try {
      final store = await ref.read(conversationFavouritesStoreProvider.future);
      final rawValue = await store.readCoreFavourites();
      if (_hasLocalMutation) {
        return;
      }
      state = ConversationFavourites.fromCoreStorage(rawValue);
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Conversation favourites restore failed',
            source: 'ConversationFavouritesController',
            context: <String, Object?>{
              'error': error.toString(),
              'stackTrace': stackTrace.toString(),
            },
          );
    }
  }
}
