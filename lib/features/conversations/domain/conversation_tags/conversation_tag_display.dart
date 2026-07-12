class ConversationTagDisplay {
  const ConversationTagDisplay({
    required this.id,
    required this.displayName,
    required this.normalizedName,
  });

  final int id;
  final String displayName;
  final String normalizedName;
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
