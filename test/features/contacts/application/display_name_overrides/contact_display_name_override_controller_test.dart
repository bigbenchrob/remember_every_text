import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/contacts/application/display_name_overrides/contact_display_name_override_controller.dart';
import 'package:remember_this_text/features/contacts/application/display_name_overrides/contact_display_name_override_store.dart';

void main() {
  test('sets display name override through the store boundary', () async {
    final store = _FakeContactDisplayNameOverrideStore();
    final controller = ContactDisplayNameOverrideController(store: store);

    await controller.setDisplayNameOverride(
      contactId: 42,
      displayName: 'Claire',
    );

    expect(store.calls, [(contactId: 42, displayName: 'Claire')]);
  });

  test('passes null override through the store boundary', () async {
    final store = _FakeContactDisplayNameOverrideStore();
    final controller = ContactDisplayNameOverrideController(store: store);

    await controller.setDisplayNameOverride(contactId: 42, displayName: null);

    expect(store.calls, [(contactId: 42, displayName: null)]);
  });
}

class _FakeContactDisplayNameOverrideStore
    implements ContactDisplayNameOverrideStore {
  final calls = <({int contactId, String? displayName})>[];

  @override
  Future<void> setDisplayNameOverride({
    required int contactId,
    required String? displayName,
  }) async {
    calls.add((contactId: contactId, displayName: displayName));
  }
}
