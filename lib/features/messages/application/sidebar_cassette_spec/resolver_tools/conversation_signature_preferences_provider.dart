import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/db/feature_level_providers.dart';
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
  static const String _settingKey = 'conversation_signature_preferences';

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
    await _persistPreferences();
  }

  Future<void> setSort(ConversationSignatureSort sort) async {
    _hasLocalMutation = true;
    state = state.copyWith(sort: sort);
    await _persistPreferences();
  }

  Future<void> _persistPreferences() async {
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    await overlayDb.writeOverlaySetting(
      settingKey: _settingKey,
      settingValue: state.storageValue,
    );
  }

  Future<void> _restorePersistedPreferences() async {
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    final rawValue = await overlayDb.readOverlaySetting(_settingKey);
    if (_hasLocalMutation) {
      return;
    }
    state = ConversationSignaturePreferences.fromStorage(rawValue);
  }
}
