import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/repositories/contact_display_name_override_store_provider.dart';
import '../../../infrastructure/repositories/contacts_list_repository.dart';
import '../../display_name_overrides/contact_display_name_override_controller.dart';
import 'unified_picker_sections_provider.dart';

part 'contact_display_name_override_actions_provider.g.dart';

@riverpod
class ContactDisplayNameOverrideActions
    extends _$ContactDisplayNameOverrideActions {
  @override
  FutureOr<void> build() {}

  Future<void> setDisplayNameOverride({
    required int contactId,
    required String? displayName,
  }) async {
    final store = await ref.watch(
      contactDisplayNameOverrideStoreProvider.future,
    );
    final controller = ContactDisplayNameOverrideController(store: store);
    await controller.setDisplayNameOverride(
      contactId: contactId,
      displayName: displayName,
    );
    ref.invalidate(contactsListRepositoryProvider);
    ref.invalidate(unifiedPickerSectionsProvider);
  }
}
