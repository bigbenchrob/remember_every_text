import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/logging/feature_level_providers.dart';
import '../../../feature_level_providers.dart';
import 'conversation_signature_display_provider.dart';

part 'conversation_signature_preferences_provider.g.dart';

class ConversationSignaturePreferences {
  const ConversationSignaturePreferences({
    this.filter = ConversationSignatureFilter.recent,
    this.sort = ConversationSignatureSort.recent,
  });

  final ConversationSignatureFilter filter;
  final ConversationSignatureSort sort;

  static ConversationSignaturePreferences fromStorage(String? rawValue) {
    final parts = rawValue?.split('|') ?? const <String>[];
    return ConversationSignaturePreferences(
      filter: _filterFromStorage(parts.isEmpty ? null : parts[0]),
      sort: _sortFromStorage(parts.length < 2 ? null : parts[1]),
    );
  }

  String get storageValue {
    return '${filter.storageValue}|${sort.storageValue}';
  }

  ConversationSignaturePreferences copyWith({
    ConversationSignatureFilter? filter,
    ConversationSignatureSort? sort,
  }) {
    return ConversationSignaturePreferences(
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
    );
  }
}

extension ConversationSignatureFilterStorage on ConversationSignatureFilter {
  String get storageValue {
    return switch (this) {
      ConversationSignatureFilter.recent => 'recent',
      ConversationSignatureFilter.groups => 'groups',
      ConversationSignatureFilter.oneToOne => 'one_to_one',
      ConversationSignatureFilter.highActivity => 'high_activity',
      ConversationSignatureFilter.dormantRevived => 'dormant_revived',
    };
  }
}

extension ConversationSignatureSortStorage on ConversationSignatureSort {
  String get storageValue {
    return switch (this) {
      ConversationSignatureSort.recent => 'recent',
      ConversationSignatureSort.largest => 'largest',
      ConversationSignatureSort.longestRunning => 'longest_running',
      ConversationSignatureSort.mostActiveRecently => 'most_active_recently',
    };
  }
}

ConversationSignatureFilter _filterFromStorage(String? rawValue) {
  return switch (rawValue) {
    'groups' => ConversationSignatureFilter.groups,
    'one_to_one' => ConversationSignatureFilter.oneToOne,
    'high_activity' => ConversationSignatureFilter.highActivity,
    'dormant_revived' => ConversationSignatureFilter.dormantRevived,
    _ => ConversationSignatureFilter.recent,
  };
}

ConversationSignatureSort _sortFromStorage(String? rawValue) {
  return switch (rawValue) {
    'largest' => ConversationSignatureSort.largest,
    'longest_running' => ConversationSignatureSort.longestRunning,
    'most_active_recently' => ConversationSignatureSort.mostActiveRecently,
    _ => ConversationSignatureSort.recent,
  };
}

@Riverpod(keepAlive: true)
class ConversationSignaturePreferencesController
    extends _$ConversationSignaturePreferencesController {
  bool _restoreScheduled = false;
  bool _hasLocalMutation = false;

  @override
  ConversationSignaturePreferences build() {
    if (!_restoreScheduled) {
      _restoreScheduled = true;
      unawaited(_restorePersistedPreferences());
    }

    return const ConversationSignaturePreferences();
  }

  Future<void> setFilter(ConversationSignatureFilter filter) async {
    _hasLocalMutation = true;
    state = state.copyWith(filter: filter);
    await _persistPreferences(
      operation: 'setFilter',
      attemptedValue: filter.storageValue,
    );
  }

  Future<void> setSort(ConversationSignatureSort sort) async {
    _hasLocalMutation = true;
    state = state.copyWith(sort: sort);
    await _persistPreferences(
      operation: 'setSort',
      attemptedValue: sort.storageValue,
    );
  }

  Future<void> _persistPreferences({
    required String operation,
    required String attemptedValue,
  }) async {
    try {
      final store = await ref.read(
        conversationSignaturePreferencesStoreProvider.future,
      );
      await store.writePreferences(state.storageValue);
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Conversation signature preferences persist failed',
            source: 'ConversationSignaturePreferencesController',
            context: <String, Object?>{
              'operation': operation,
              'attemptedValue': attemptedValue,
              'state': state.storageValue,
              'error': error.toString(),
              'stackTrace': stackTrace.toString(),
            },
          );
    }
  }

  Future<void> _restorePersistedPreferences() async {
    try {
      final store = await ref.read(
        conversationSignaturePreferencesStoreProvider.future,
      );
      final rawValue = await store.readPreferences();
      if (_hasLocalMutation) {
        return;
      }
      state = ConversationSignaturePreferences.fromStorage(rawValue);
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Conversation signature preferences restore failed',
            source: 'ConversationSignaturePreferencesController',
            context: <String, Object?>{
              'error': error.toString(),
              'stackTrace': stackTrace.toString(),
            },
          );
    }
  }
}
