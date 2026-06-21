import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_data_reset_service.dart';
import 'package:remember_this_text/essentials/source_scoped_import/feature_level_providers.dart';

void main() {
  test(
    'derived message data reset separates retired cleanup and active graph files',
    () {
      expect(
        retiredHistoricalDatabaseCleanupBaseNames,
        containsAll(<String>[
          retiredMacosImportDatabaseFileName,
          retiredWorkingDatabaseFileName,
        ]),
      );
      expect(
        activeGraphDerivedDatabaseBaseNames,
        containsAll(<String>[
          sourceScopedImportDatabaseFileName,
          conversationGraphDatabaseFileName,
        ]),
      );
      expect(
        messageDataResetPostCleanupCheckBaseNames,
        containsAll(<String>[
          retiredMacosImportDatabaseFileName,
          retiredWorkingDatabaseFileName,
          sourceScopedImportDatabaseFileName,
          conversationGraphDatabaseFileName,
        ]),
      );
      expect(
        activeGraphDerivedDatabaseBaseNames.toSet().intersection(
          retiredHistoricalDatabaseCleanupBaseNames.toSet(),
        ),
        isEmpty,
        reason:
            'Active graph rebuild files and retired cleanup files must remain '
            'separate reset categories.',
      );
    },
  );
}
