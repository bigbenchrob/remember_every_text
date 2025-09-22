import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacts_spec.freezed.dart';

@freezed
class ContactsSpec with _$ContactsSpec {
  const factory ContactsSpec.list() = _ContactsList;

  const factory ContactsSpec.detail({required String contactId}) =
      _ContactDetail;

  const factory ContactsSpec.search({required String query}) = _ContactsSearch;
}
