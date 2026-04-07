import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../payloads/contact_message_scope_toggle_cassette_payload.dart';

part 'message_scope_toggle_resolver.g.dart';

/// Resolves the contact message-scope toggle cassette.
@riverpod
class MessageScopeToggleResolver extends _$MessageScopeToggleResolver {
  @override
  void build() {
    // Stateless resolver
  }

  Future<SidebarCassettePayload> resolve({
    required int contactId,
    required int cassetteIndex,
  }) async {
    return ContactMessageScopeToggleCassettePayload(contactId: contactId);
  }
}
