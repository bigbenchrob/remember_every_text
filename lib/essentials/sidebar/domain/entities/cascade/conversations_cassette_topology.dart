part of '../cassette_spec.dart';

// TOPOLOGY RULE:
// Determine ONLY the immediate next child of this spec.
// May consult flow state, but must not plan or assemble a chain.
// See cassette_child_resolver.dart for full contract.

CassetteSpec? resolveConversationsChild(ConversationsCassetteSpec spec) {
  return spec.when(conversationSignatures: () => null);
}

extension ConversationsCassetteSpecX on ConversationsCassetteSpec {
  CassetteSpec? childSpec() {
    return resolveConversationsChild(this);
  }
}
