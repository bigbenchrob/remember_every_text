// lib/features/contacts/domain/view/contact.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../entities/contact_prefs.dart';
import '../entities/contact_ref.dart';
import '../value_objects/contact_id.dart';

part 'contact.freezed.dart';

@freezed
abstract class Contact with _$Contact {
  const factory Contact({
    required ContactId id,
    required List<String> handles,
    required String? displayNameFromSource,
    required String? displayNameOverride,
    required bool isFavorite,
    required int? pinnedRank,
  }) = _Contact;

  factory Contact.fromRefAndPrefs(ContactRef ref, ContactPrefs? prefs) =>
      Contact(
        id: ref.id,
        handles: ref.handles,
        displayNameFromSource: ref.displayNameFromSource,
        displayNameOverride: prefs?.displayNameOverride,
        isFavorite: prefs?.isFavorite ?? false,
        pinnedRank: prefs?.pinnedRank,
      );

  const Contact._();

  String get displayName =>
      displayNameOverride ?? displayNameFromSource ?? _bestFrom(handles);

  static String _bestFrom(List<String> hs) => hs.isEmpty
      ? 'Unknown'
      : hs.first; // replace with smarter heuristic if you like
}
