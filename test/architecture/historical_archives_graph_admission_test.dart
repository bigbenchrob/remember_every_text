import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Historical Archives resolves graph import capability after admission',
    () {
      final source = File(
        'lib/features/settings/application/'
        'historical_archives_workflow_panel_model_provider.dart',
      ).readAsStringSync();
      final importOperationIndex = source.indexOf(
        'operation: ArchiveMutationOperation.historicalArchiveImport',
      );
      final graphServiceResolutionIndex = source.indexOf(
        'final archiveGraphImportService = await ref.read(',
        importOperationIndex,
      );

      expect(importOperationIndex, greaterThanOrEqualTo(0));
      expect(graphServiceResolutionIndex, greaterThan(importOperationIndex));
    },
  );
}
