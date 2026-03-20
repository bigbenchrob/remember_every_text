import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../widget_builders/contact_message_scope_toggle_widget.dart';

part 'message_scope_toggle_resolver.g.dart';

/// Resolves the contact message-scope toggle cassette.
@riverpod
class MessageScopeToggleResolver extends _$MessageScopeToggleResolver {
  @override
  void build() {
    // Stateless resolver
  }

  Future<SidebarCassetteCardViewModel> resolve({
    required int contactId,
    required int cassetteIndex,
  }) async {
    return SidebarCassetteCardViewModel(
      title: '',
      isNaked: true,
      child: ContactMessageScopeToggleWidget(contactId: contactId),
    );
  }
}
