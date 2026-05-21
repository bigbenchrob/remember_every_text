import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';

class SearchHighlightedText extends ConsumerWidget {
  const SearchHighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final String query;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final terms = searchHighlightTerms(query);
    if (terms.isEmpty) {
      return Text(
        text,
        style: effectiveStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return Text.rich(
      TextSpan(
        style: effectiveStyle,
        children: buildSearchHighlightSpans(
          text: text,
          terms: terms,
          highlightStyle:
              highlightStyle ??
              effectiveStyle.copyWith(
                backgroundColor: colors.messagePanels.accentTint,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

@visibleForTesting
List<String> searchHighlightTerms(String query) {
  final seenTerms = <String>{};
  final terms = query
      .split(RegExp(r'[\s,]+'))
      .map((term) => term.trim().toLowerCase())
      .where((term) => term.isNotEmpty)
      .where(seenTerms.add)
      .toList(growable: false);
  terms.sort((left, right) => right.length.compareTo(left.length));
  return terms;
}

@visibleForTesting
List<TextSpan> buildSearchHighlightSpans({
  required String text,
  required List<String> terms,
  required TextStyle highlightStyle,
}) {
  if (text.isEmpty || terms.isEmpty) {
    return [TextSpan(text: text)];
  }

  final lowerText = text.toLowerCase();
  final spans = <TextSpan>[];
  var cursor = 0;
  while (cursor < text.length) {
    final match = _nextMatch(lowerText, terms, cursor);
    if (match == null) {
      spans.add(TextSpan(text: text.substring(cursor)));
      break;
    }

    if (match.start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, match.start)));
    }

    spans.add(
      TextSpan(
        text: text.substring(match.start, match.end),
        style: highlightStyle,
      ),
    );
    cursor = match.end;
  }

  return spans;
}

_SearchHighlightMatch? _nextMatch(
  String lowerText,
  List<String> terms,
  int startIndex,
) {
  _SearchHighlightMatch? best;
  for (final term in terms) {
    final start = lowerText.indexOf(term, startIndex);
    if (start < 0) {
      continue;
    }

    final match = _SearchHighlightMatch(start: start, end: start + term.length);
    if (best == null ||
        match.start < best.start ||
        (match.start == best.start && match.length > best.length)) {
      best = match;
    }
  }
  return best;
}

class _SearchHighlightMatch {
  const _SearchHighlightMatch({required this.start, required this.end});

  final int start;
  final int end;

  int get length => end - start;
}
