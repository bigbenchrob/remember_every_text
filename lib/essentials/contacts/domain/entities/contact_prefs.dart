// lib/features/contacts/domain/entities/contact_prefs.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/contact_id.dart';

part 'contact_prefs.freezed.dart';

@freezed
abstract class ContactPrefs with _$ContactPrefs {
  const factory ContactPrefs({
    required ContactId contactId,
    String? displayNameOverride,
    @Default(false) bool isFavorite,
    int? pinnedRank, // lower comes first (e.g., 0,1,2…)
    DateTime? updatedAt, // set by app
  }) = _ContactPrefs;

  const ContactPrefs._();
}
