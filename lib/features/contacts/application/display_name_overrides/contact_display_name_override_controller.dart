import 'contact_display_name_override_store.dart';

/// Application-level contact display-name override actions.
///
/// User-assigned display names are overlay intent. This controller preserves
/// that semantic boundary without exposing overlay tables to widgets.
class ContactDisplayNameOverrideController {
  const ContactDisplayNameOverrideController({
    required ContactDisplayNameOverrideStore store,
  }) : _store = store;

  final ContactDisplayNameOverrideStore _store;

  Future<void> setDisplayNameOverride({
    required int contactId,
    required String? displayName,
  }) {
    return _store.setDisplayNameOverride(
      contactId: contactId,
      displayName: displayName,
    );
  }
}
