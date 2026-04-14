String normalizeMessageTagDisplay(String input) {
  return _collapseWhitespace(input);
}

String normalizeMessageTagValue(String input) {
  final display = normalizeMessageTagDisplay(input);
  if (display.isEmpty) {
    return '';
  }

  final lowerCased = display.toLowerCase();
  final folded = _foldDiacritics(lowerCased);
  final punctuationNormalized = folded.replaceAll(RegExp(r'[^a-z0-9\s-]'), ' ');

  return _collapseWhitespace(punctuationNormalized.replaceAll('-', ' '));
}

List<String> tokenizeNormalizedMessageTagQuery(String query) {
  final normalized = normalizeMessageTagValue(query);
  if (normalized.isEmpty) {
    return const <String>[];
  }

  return normalized.split(' ').where((token) => token.isNotEmpty).toList();
}

List<String> parseMessageTagInput(String rawInput) {
  final uniqueByNormalized = <String, String>{};

  for (final segment in rawInput.split(RegExp(r'[,\n]'))) {
    final display = normalizeMessageTagDisplay(segment);
    final normalized = normalizeMessageTagValue(display);
    if (display.isEmpty || normalized.isEmpty) {
      continue;
    }
    uniqueByNormalized[normalized] = display;
  }

  return uniqueByNormalized.values.toList(growable: false);
}

bool normalizedMessageTagMatchesToken({
  required String normalizedTag,
  required String normalizedToken,
  required bool allowPrefix,
}) {
  if (normalizedTag.isEmpty || normalizedToken.isEmpty) {
    return false;
  }

  if (normalizedTag == normalizedToken) {
    return true;
  }

  final words = normalizedTag.split(' ');
  if (allowPrefix) {
    return words.any((word) => word.startsWith(normalizedToken));
  }

  return words.contains(normalizedToken);
}

List<String> matchedMessageTagsForQuery({
  required Iterable<String> displayTags,
  required String query,
}) {
  final tokens = tokenizeNormalizedMessageTagQuery(query);
  if (tokens.isEmpty) {
    return const <String>[];
  }

  final hasTrailingWhitespace = query.isNotEmpty && query != query.trimRight();
  final matches = <String>[];

  for (final displayTag in displayTags) {
    final normalizedTag = normalizeMessageTagValue(displayTag);
    if (normalizedTag.isEmpty) {
      continue;
    }

    final coversAllTokens = tokens.asMap().entries.every((entry) {
      final isLastToken = entry.key == tokens.length - 1;
      return normalizedMessageTagMatchesToken(
        normalizedTag: normalizedTag,
        normalizedToken: entry.value,
        allowPrefix: isLastToken && !hasTrailingWhitespace,
      );
    });

    if (coversAllTokens) {
      matches.add(displayTag);
    }
  }

  return matches;
}

String _collapseWhitespace(String input) {
  return input
      .trim()
      .split(RegExp(r'\s+'))
      .where((segment) {
        return segment.isNotEmpty;
      })
      .join(' ');
}

String _foldDiacritics(String input) {
  const replacements = <String, String>{
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'å': 'a',
    'ā': 'a',
    'ă': 'a',
    'ą': 'a',
    'ǎ': 'a',
    'ç': 'c',
    'ć': 'c',
    'ĉ': 'c',
    'ċ': 'c',
    'č': 'c',
    'ď': 'd',
    'đ': 'd',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ē': 'e',
    'ĕ': 'e',
    'ė': 'e',
    'ę': 'e',
    'ě': 'e',
    'ĝ': 'g',
    'ğ': 'g',
    'ġ': 'g',
    'ģ': 'g',
    'ĥ': 'h',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ĩ': 'i',
    'ī': 'i',
    'ĭ': 'i',
    'į': 'i',
    'ı': 'i',
    'ĵ': 'j',
    'ķ': 'k',
    'ĺ': 'l',
    'ļ': 'l',
    'ľ': 'l',
    'ł': 'l',
    'ñ': 'n',
    'ń': 'n',
    'ņ': 'n',
    'ň': 'n',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ø': 'o',
    'ō': 'o',
    'ŏ': 'o',
    'ő': 'o',
    'œ': 'oe',
    'ŕ': 'r',
    'ŗ': 'r',
    'ř': 'r',
    'ś': 's',
    'ŝ': 's',
    'ş': 's',
    'š': 's',
    'ß': 'ss',
    'ť': 't',
    'ţ': 't',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ũ': 'u',
    'ū': 'u',
    'ŭ': 'u',
    'ů': 'u',
    'ű': 'u',
    'ų': 'u',
    'ý': 'y',
    'ÿ': 'y',
    'ŷ': 'y',
    'ź': 'z',
    'ż': 'z',
    'ž': 'z',
  };

  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final character = String.fromCharCode(rune);
    if (rune >= 0x0300 && rune <= 0x036F) {
      continue;
    }
    buffer.write(replacements[character] ?? character);
  }

  return buffer.toString();
}
