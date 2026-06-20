import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_data_reset_service.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';

void main() {
  test(
    'derived message data reset separates retired cleanup and active graph files',
    () {
      expect(
        retiredCleanupDatabaseBaseNames,
        containsAll(<String>[
          retiredMacosImportDatabaseFileName,
          retiredWorkingDatabaseFileName,
        ]),
      );
      expect(
        activeGraphDatabaseBaseNames,
        containsAll(<String>[
          importDatabaseFileName,
          conversationGraphDatabaseFileName,
        ]),
      );
      expect(
        messageDataResetDatabaseBaseNames,
        containsAll(<String>[
          retiredMacosImportDatabaseFileName,
          retiredWorkingDatabaseFileName,
          importDatabaseFileName,
          conversationGraphDatabaseFileName,
        ]),
      );
    },
  );
}
