import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../payloads/conversation_signatures_cassette_payload.dart';

part 'conversation_signatures_resolver.g.dart';

@riverpod
class ConversationSignaturesResolver extends _$ConversationSignaturesResolver {
  @override
  void build() {
    // Stateless resolver.
  }

  Future<SidebarCassettePayload> resolve({required int cassetteIndex}) async {
    return ConversationSignaturesCassettePayload(cassetteIndex: cassetteIndex);
  }
}
