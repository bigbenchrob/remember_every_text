import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/search/presentation/widgets/search_highlighted_text.dart';

void main() {
  test('parses search terms from whitespace and comma separated input', () {
    expect(searchHighlightTerms('cathie, 17789908506 cathie'), [
      '17789908506',
      'cathie',
    ]);
  });

  test('builds case-insensitive highlight spans', () {
    final spans = buildSearchHighlightSpans(
      text: '+17789908506 cathie.campbell@gmail.com',
      terms: searchHighlightTerms('778990 cathie'),
      highlightStyle: const TextStyle(fontWeight: FontWeight.bold),
    );

    expect(spans.map((span) => span.text).toList(), [
      '+1',
      '778990',
      '8506 ',
      'cathie',
      '.campbell@gmail.com',
    ]);
    expect(spans[1].style?.fontWeight, FontWeight.bold);
    expect(spans[3].style?.fontWeight, FontWeight.bold);
  });

  testWidgets('renders rich highlighted text', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SearchHighlightedText(text: '+17789908506', query: '778990'),
        ),
      ),
    );

    expect(find.text('+17789908506', findRichText: true), findsOneWidget);
  });
}
