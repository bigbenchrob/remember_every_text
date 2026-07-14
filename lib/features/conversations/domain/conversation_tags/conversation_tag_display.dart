enum ConversationTagVisibilityPolicy {
  ordinary('ordinary'),
  suppressFromBrowse('suppress_from_browse');

  const ConversationTagVisibilityPolicy(this.storageValue);

  final String storageValue;

  bool get suppressesOrdinaryBrowse {
    return this == ConversationTagVisibilityPolicy.suppressFromBrowse;
  }
}

class ConversationTagDisplay {
  const ConversationTagDisplay({
    required this.id,
    required this.displayName,
    required this.normalizedName,
    this.visibilityPolicy = ConversationTagVisibilityPolicy.ordinary,
  });

  final int id;
  final String displayName;
  final String normalizedName;
  final ConversationTagVisibilityPolicy visibilityPolicy;
}

String normalizeConversationTagDisplayName(String input) {
  return input
      .trim()
      .split(RegExp(r'\s+'))
      .where((segment) {
        return segment.isNotEmpty;
      })
      .join(' ');
}

String normalizeConversationTagName(String input) {
  return normalizeConversationTagDisplayName(input).toLowerCase();
}

ConversationTagVisibilityPolicy parseConversationTagVisibilityPolicy(
  String? value,
) {
  for (final policy in ConversationTagVisibilityPolicy.values) {
    if (policy.storageValue == value) {
      return policy;
    }
  }
  return ConversationTagVisibilityPolicy.ordinary;
}
