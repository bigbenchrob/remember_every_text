import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/conversations/application/conversation_retrieval/conversation_retrieval_tag_token.dart';
import 'package:remember_this_text/features/conversations/domain/conversation_tags/conversation_tag_display.dart';

void main() {
  test('suggests known tags by partial normalized prefix', () {
    const tags = [
      ConversationTagDisplay(
        id: 1,
        displayName: 'Family',
        normalizedName: 'family',
      ),
      ConversationTagDisplay(
        id: 2,
        displayName: 'Family Estate',
        normalizedName: 'family estate',
      ),
      ConversationTagDisplay(
        id: 3,
        displayName: 'Travel',
        normalizedName: 'travel',
      ),
    ];

    final suggestions = matchingConversationTagSuggestions(
      tags: tags,
      rawQuery: 'fam',
      excludedTagIds: const <int>[],
    );

    expect(suggestions.map((tag) => tag.displayName), [
      'Family',
      'Family Estate',
    ]);
  });

  test('does not suggest already-selected tags or unknown free text', () {
    const tags = [
      ConversationTagDisplay(
        id: 1,
        displayName: 'Family',
        normalizedName: 'family',
      ),
    ];

    final selectedSuggestions = matchingConversationTagSuggestions(
      tags: tags,
      rawQuery: 'fam',
      excludedTagIds: const <int>[1],
    );
    expect(selectedSuggestions, isEmpty);

    final unknownSuggestions = matchingConversationTagSuggestions(
      tags: tags,
      rawQuery: 'hotel',
      excludedTagIds: const <int>[],
    );
    expect(unknownSuggestions, isEmpty);
  });
}
