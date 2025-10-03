import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:remember_this_text/providers.dart';

part 'contact_short_names_controller.g.dart';

const _contactShortNamesKey = 'contact_short_names';

@riverpod
class ContactShortNames extends _$ContactShortNames {
  @override
  Future<Map<String, String>> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return _loadFromPreferences(prefs);
  }

  Future<void> setShortName({
    required String contactKey,
    required String? shortName,
  }) async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final existing = state.value ?? await _loadFromPreferences(prefs);
    final trimmed = shortName?.trim();

    final updated = Map<String, String>.from(existing);
    if (trimmed == null || trimmed.isEmpty) {
      updated.remove(contactKey);
    } else {
      updated[contactKey] = trimmed;
    }

    if (updated.isEmpty) {
      await prefs.remove(_contactShortNamesKey);
    } else {
      final payload = jsonEncode(updated);
      await prefs.setString(_contactShortNamesKey, payload);
    }

    state = AsyncData(updated);
  }

  Future<void> refresh() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    state = const AsyncLoading<Map<String, String>>().copyWithPrevious(state);
    final latest = await _loadFromPreferences(prefs);
    state = AsyncData(latest);
  }

  Future<Map<String, String>> _loadFromPreferences(
    SharedPreferences prefs,
  ) async {
    final value = prefs.getString(_contactShortNamesKey);

    if (value == null) {
      return {};
    }

    if (value.trim().isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map) {
        return {};
      }
      final entries = <String, String>{};
      decoded.forEach((key, dynamic value) {
        final keyString = key?.toString();
        final valueString = value?.toString();
        if (keyString == null || keyString.isEmpty) {
          return;
        }
        if (valueString == null || valueString.isEmpty) {
          return;
        }
        entries[keyString] = valueString;
      });
      return entries;
    } on FormatException {
      return {};
    }
  }
}
