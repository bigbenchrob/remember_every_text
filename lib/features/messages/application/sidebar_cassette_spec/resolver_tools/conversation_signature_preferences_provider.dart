import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import 'conversation_signature_display_provider.dart';
import 'conversation_signature_preferences_store_provider.dart';

part 'conversation_signature_preferences_provider.g.dart';

class ConversationSignaturePreferences {
  const ConversationSignaturePreferences({
    this.filter = ConversationSignatureFilter.all,
    this.sort = ConversationSignatureSort.mostRecentlyUpdated,
    this.mode = ConversationSignatureMode.browse,
  });

  final ConversationSignatureFilter filter;
  final ConversationSignatureSort sort;
  final ConversationSignatureMode mode;

  static ConversationSignaturePreferences fromStorage(String? rawValue) {
    final parts = rawValue?.split('|') ?? const <String>[];
    return ConversationSignaturePreferences(
      filter: _filterFromStorage(parts.isEmpty ? null : parts[0]),
      sort: _sortFromStorage(parts.length < 2 ? null : parts[1]),
      mode: _modeFromStorage(parts.length < 3 ? null : parts[2]),
    );
  }

  String get storageValue {
    return '${filter.storageValue}|${sort.storageValue}|${mode.storageValue}';
  }

  ConversationSignaturePreferences copyWith({
    ConversationSignatureFilter? filter,
    ConversationSignatureSort? sort,
    ConversationSignatureMode? mode,
  }) {
    return ConversationSignaturePreferences(
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      mode: mode ?? this.mode,
    );
  }
}

enum ConversationSignatureMode { favourites, browse }

extension ConversationSignatureModeStorage on ConversationSignatureMode {
  String get storageValue {
    return switch (this) {
      ConversationSignatureMode.favourites => 'favourites',
      ConversationSignatureMode.browse => 'browse',
    };
  }
}

extension ConversationSignatureFilterStorage on ConversationSignatureFilter {
  String get storageValue {
    return switch (this) {
      ConversationSignatureFilter.all => 'all',
      ConversationSignatureFilter.groups => 'groups',
      ConversationSignatureFilter.oneToOne => 'one_to_one',
      ConversationSignatureFilter.highActivity => 'high_activity',
    };
  }
}

extension ConversationSignatureSortStorage on ConversationSignatureSort {
  String get storageValue {
    return switch (this) {
      ConversationSignatureSort.byDateOfCreation => 'by_date_of_creation',
      ConversationSignatureSort.mostRecentlyUpdated => 'most_recently_updated',
      ConversationSignatureSort.mostTotalMessages => 'most_total_messages',
      ConversationSignatureSort.startedMostRecently => 'started_most_recently',
      ConversationSignatureSort.longestRunning => 'longest_running',
      ConversationSignatureSort.dormant => 'dormant',
    };
  }
}

ConversationSignatureFilter _filterFromStorage(String? rawValue) {
  return switch (rawValue) {
    'recent' || 'all' => ConversationSignatureFilter.all,
    'groups' => ConversationSignatureFilter.groups,
    'one_to_one' => ConversationSignatureFilter.oneToOne,
    'high_activity' => ConversationSignatureFilter.highActivity,
    'dormant_revived' => ConversationSignatureFilter.all,
    _ => ConversationSignatureFilter.all,
  };
}

ConversationSignatureSort _sortFromStorage(String? rawValue) {
  return switch (rawValue) {
    'recent' ||
    'most_active_recently' ||
    'most_recently_updated' => ConversationSignatureSort.mostRecentlyUpdated,
    'largest' ||
    'most_total_messages' => ConversationSignatureSort.mostTotalMessages,
    'longest_running' => ConversationSignatureSort.longestRunning,
    'recently_started' ||
    'started_most_recently' => ConversationSignatureSort.startedMostRecently,
    'started_longest_ago' ||
    'by_date_of_creation' => ConversationSignatureSort.byDateOfCreation,
    'dormant' => ConversationSignatureSort.dormant,
    _ => ConversationSignatureSort.mostRecentlyUpdated,
  };
}

ConversationSignatureMode _modeFromStorage(String? rawValue) {
  return switch (rawValue) {
    'favourites' => ConversationSignatureMode.favourites,
    _ => ConversationSignatureMode.browse,
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

  Future<void> setMode(ConversationSignatureMode mode) async {
    _hasLocalMutation = true;
    state = state.copyWith(mode: mode);
    await _persistPreferences(
      operation: 'setMode',
      attemptedValue: mode.storageValue,
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
