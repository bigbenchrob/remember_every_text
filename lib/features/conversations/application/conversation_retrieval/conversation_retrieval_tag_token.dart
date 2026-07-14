import '../../domain/conversation_tags/conversation_tag_display.dart';

class ConversationRetrievalTagToken {
  const ConversationRetrievalTagToken({
    required this.tagId,
    required this.label,
    required this.normalizedName,
  });

  factory ConversationRetrievalTagToken.fromTag(ConversationTagDisplay tag) {
    return ConversationRetrievalTagToken(
      tagId: tag.id,
      label: tag.displayName,
      normalizedName: tag.normalizedName,
    );
  }

  final int tagId;
  final String label;
  final String normalizedName;
}

List<ConversationTagDisplay> matchingConversationTagSuggestions({
  required Iterable<ConversationTagDisplay> tags,
  required String rawQuery,
  required Iterable<int> excludedTagIds,
}) {
  final query = normalizeConversationTagName(rawQuery);
  if (query.isEmpty) {
    return const <ConversationTagDisplay>[];
  }

  final excludedIds = excludedTagIds.toSet();
  final matches = [
    for (final tag in tags)
      if (!excludedIds.contains(tag.id) && tag.normalizedName.startsWith(query))
        tag,
  ];

  matches.sort((left, right) {
    final lengthComparison = left.normalizedName.length.compareTo(
      right.normalizedName.length,
    );
    if (lengthComparison != 0) {
      return lengthComparison;
    }
    return left.displayName.compareTo(right.displayName);
  });
  return matches;
}
