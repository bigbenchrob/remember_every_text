import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';

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
  static const String _settingPrefix = 'conversation_favourites';

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
    await _persistCoreFavourites();
  }

  Future<void> _persistCoreFavourites() async {
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    await overlayDb.writeOverlaySetting(
      settingKey: _settingKeyFor(ConversationFavouriteGroup.core),
      settingValue: state.coreStorageValue,
    );
  }

  Future<void> _restoreFavourites() async {
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    final rawValue = await overlayDb.readOverlaySetting(
      _settingKeyFor(ConversationFavouriteGroup.core),
    );
    if (_hasLocalMutation) {
      return;
    }
    state = ConversationFavourites.fromCoreStorage(rawValue);
  }

  static String _settingKeyFor(ConversationFavouriteGroup group) {
    return '$_settingPrefix/${group.storageKey}';
  }
}
