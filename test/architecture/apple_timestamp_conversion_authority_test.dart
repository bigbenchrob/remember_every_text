import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Apple timestamp conversion remains centralized in DateConverter', () {
    const authorityPath = 'lib/core/util/date_converter.dart';
    final violations = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final normalizedPath = entity.path.replaceAll(r'\', '/');
      if (normalizedPath == authorityPath ||
          normalizedPath.endsWith('.g.dart')) {
        continue;
      }

      final source = entity.readAsStringSync();
      if (source.contains('978307200') ||
          source.contains("'unixepoch'") ||
          source.contains('"unixepoch"')) {
        violations.add(normalizedPath);
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Apple timestamp conversion must use DateConverter; do not reproduce epoch arithmetic or SQLite unixepoch conversion elsewhere.',
    );
  });
}
