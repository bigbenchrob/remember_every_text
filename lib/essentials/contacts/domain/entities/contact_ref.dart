// lib/features/contacts/domain/entities/contact_ref.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/contact_id.dart';

part 'contact_ref.freezed.dart';

@freezed
abstract class ContactRef with _$ContactRef {
  const factory ContactRef({
    required ContactId id,
    String? displayNameFromSource,
    @Default(<String>[]) List<String> handles, // normalized (e164/email)
    String? sourceVersion, // or int? rowId/version
  }) = _ContactRef;
  const ContactRef._();
}
