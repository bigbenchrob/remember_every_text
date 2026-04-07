import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const Set<String> _legacySidebarPresentationImportExceptions = <String>{};

const Set<String> _legacyWidgetPayloadFiles = <String>{};

const Set<String> _sidebarSemanticActionTransportFiles = {
  'lib/essentials/sidebar/domain/sidebar_action_intent.dart',
  'lib/essentials/sidebar/domain/sidebar_body_model.dart',
  'lib/essentials/sidebar/domain/sidebar_body_option.dart',
  'lib/essentials/sidebar/domain/sidebar_list_item_model.dart',
};

void main() {
  group('Architecture tripwires', () {
    test('Do not import flutter_riverpod', () async {
      final libDir = Directory('lib');
      final bad = <String>[];
      await for (final entity in libDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final lines = await entity.readAsLines();
          var inBlockComment = false;
          for (final rawLine in lines) {
            final line = rawLine;
            if (inBlockComment) {
              if (line.contains('*/')) {
                inBlockComment = false;
              }
              continue;
            }
            final trimmed = line.trimLeft();
            if (trimmed.startsWith('/*')) {
              inBlockComment = true;
              continue;
            }
            if (trimmed.startsWith('//')) {
              continue;
            }
            final importPattern = RegExp(
              r'''^import\s+['"]package:flutter_riverpod/flutter_riverpod\.dart['"];\s*''',
            );
            if (importPattern.hasMatch(trimmed)) {
              bad.add(entity.path);
              break;
            }
          }
        }
      }
      expect(
        bad,
        isEmpty,
        reason: 'Found flutter_riverpod imports in:\n${bad.join('\n')}',
      );
    });

    test('Discourage withOpacity usage', () async {
      final libDir = Directory('lib');
      final offenders = <String>[];
      await for (final entity in libDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final lines = await entity.readAsLines();
          var inBlockComment = false;
          for (final rawLine in lines) {
            final line = rawLine;
            if (inBlockComment) {
              if (line.contains('*/')) {
                inBlockComment = false;
              }
              continue;
            }
            final trimmed = line.trimLeft();
            if (trimmed.startsWith('/*')) {
              inBlockComment = true;
              continue;
            }
            if (trimmed.startsWith('//')) {
              continue;
            }
            if (trimmed.contains('.withOpacity(')) {
              offenders.add(entity.path);
              break;
            }
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            'Use withValues(alpha:) instead of withOpacity() in:\n${offenders.join('\n')}',
      );
    });

    test(
      'Sidebar semantic/application imports do not grow beyond tracked legacy exceptions',
      () async {
        final offenders = await _findSidebarPresentationImportOffenders();

        expect(
          offenders,
          orderedEquals(
            _legacySidebarPresentationImportExceptions.toList()..sort(),
          ),
          reason:
              'Sidebar resolver/coordinator presentation imports changed. '
              'Remove offenders as the migration progresses, or explicitly '
              'track any narrow temporary exception in TEMPORARY_EXCEPTIONS.md.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Sidebar payload transport contains no runtime UI types', () async {
      final payloadFiles = await _collectSidebarPayloadFiles();
      final offenders = await _findPayloadTypeOffenders(payloadFiles);

      expect(
        offenders,
        orderedEquals(_legacyWidgetPayloadFiles.toList()..sort()),
        reason:
            'Payload transport picked up forbidden runtime UI types.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Sidebar semantic action transport stays data-only', () async {
      final offenders = await _findSemanticActionTransportOffenders(
        _sidebarSemanticActionTransportFiles.toList()..sort(),
      );

      expect(
        offenders,
        isEmpty,
        reason:
            'Sidebar semantic action transport must not carry callbacks, '
            'dispatcher objects, or widget/runtime execution types.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });
  });
}

Future<List<String>> _findSidebarPresentationImportOffenders() async {
  final offenders = <String>{};
  final files = await _collectSidebarSemanticLayerFiles();

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);

    for (final importTarget in _extractImports(uncommented)) {
      if (importTarget.endsWith('sidebar_cassette_card_view_model.dart')) {
        continue;
      }

      final isForbiddenFeatureImport =
          importTarget.contains('/widget_builders/') ||
          importTarget.contains('/presentation/');
      final isForbiddenFlutterImport = RegExp(
        r'^package:flutter/(widgets|material|cupertino)\.dart$',
      ).hasMatch(importTarget);

      if (isForbiddenFeatureImport || isForbiddenFlutterImport) {
        offenders.add(filePath);
        break;
      }
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findPayloadTypeOffenders(List<String> filePaths) async {
  final offenders = <String>{};
  final forbiddenTypePattern = RegExp(
    r'\b(Widget|WidgetBuilder|BuildContext|WidgetRef|Ref|ScrollController|FocusNode|VoidCallback|Function)\b',
  );

  for (final filePath in filePaths) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);

    if (forbiddenTypePattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findSemanticActionTransportOffenders(
  List<String> filePaths,
) async {
  final offenders = <String>{};
  final forbiddenTypePattern = RegExp(
    r'\b(Widget|WidgetBuilder|BuildContext|WidgetRef|Ref|ScrollController|FocusNode|VoidCallback|Function|SidebarActionDispatcher)\b',
  );
  final forbiddenFlutterImportPattern = RegExp(
    r'^package:flutter/(widgets|material|cupertino)\.dart$',
  );
  final forbiddenRiverpodImportPattern = RegExp(r'^package:(hooks_)?riverpod');

  for (final filePath in filePaths) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);

    final hasForbiddenImport = imports.any((importTarget) {
      return forbiddenFlutterImportPattern.hasMatch(importTarget) ||
          forbiddenRiverpodImportPattern.hasMatch(importTarget) ||
          importTarget.contains('/application/');
    });

    if (hasForbiddenImport || forbiddenTypePattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _collectSidebarSemanticLayerFiles() async {
  return _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }

    final isSidebarApplicationArea =
        path.contains('/application/sidebar_cassette_spec/') ||
        path.contains('/application/settings_cassette_spec/') ||
        path.contains('/application/info_cassette_spec/');
    final isSemanticSubfolder =
        path.contains('/resolvers/') ||
        path.contains('/coordinators/') ||
        path.contains('/resolver_tools/');

    return isSidebarApplicationArea && isSemanticSubfolder;
  });
}

Future<List<String>> _collectSidebarPayloadFiles() async {
  return _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }

    return path ==
            'lib/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart' ||
        path.contains('/application/') && path.contains('/payloads/');
  });
}

Future<List<String>> _collectDartFiles(
  bool Function(String path) include,
) async {
  final libDir = Directory('lib');
  final files = <String>[];

  await for (final entity in libDir.list(recursive: true, followLinks: false)) {
    if (entity is! File) {
      continue;
    }

    final normalizedPath = entity.path.replaceAll(r'\', '/');
    if (!normalizedPath.endsWith('.dart')) {
      continue;
    }

    if (include(normalizedPath)) {
      files.add(normalizedPath);
    }
  }

  files.sort();
  return files;
}

Iterable<String> _extractImports(String source) sync* {
  final importPattern = RegExp(
    r'''^import\s+['\"]([^'\"]+)['\"];''',
    multiLine: true,
  );

  for (final match in importPattern.allMatches(source)) {
    final importTarget = match.group(1);
    if (importTarget != null) {
      yield importTarget;
    }
  }
}

String _stripComments(String source) {
  final withoutBlockComments = source.replaceAll(
    RegExp(r'/\*[\s\S]*?\*/', multiLine: true),
    '',
  );

  return withoutBlockComments.replaceAll(RegExp(r'//.*$', multiLine: true), '');
}
