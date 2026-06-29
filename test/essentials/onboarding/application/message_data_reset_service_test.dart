import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_data_reset_service.dart';

void main() {
  test(
    'derived message data reset separates retired cleanup and active graph files',
    () {
      expect(
        retiredDatabaseCleanupBaseNames.toSet(),
        equals(<String>{
          appDatabaseFileName(AppDatabaseFile.retiredMacosImport),
          appDatabaseFileName(AppDatabaseFile.retiredWorking),
        }),
      );
      expect(
        activeGraphDerivedDatabaseBaseNames.toSet(),
        equals(<String>{
          appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
          appDatabaseFileName(AppDatabaseFile.conversationGraph),
        }),
      );
      expect(
        messageDataResetPostCleanupCheckBaseNames.toSet(),
        equals(<String>{
          appDatabaseFileName(AppDatabaseFile.retiredMacosImport),
          appDatabaseFileName(AppDatabaseFile.retiredWorking),
          appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
          appDatabaseFileName(AppDatabaseFile.conversationGraph),
        }),
      );
      expect(
        activeGraphDerivedDatabaseBaseNames.toSet().intersection(
          retiredDatabaseCleanupBaseNames.toSet(),
        ),
        isEmpty,
        reason:
            'Active graph rebuild files and retired cleanup files must remain '
            'separate reset categories.',
      );
      expect(
        messageDataResetPostCleanupCheckBaseNames,
        isNot(contains(appDatabaseFileName(AppDatabaseFile.overlay))),
        reason:
            'Reset Message Data deletes derived graph/import files and retired '
            'cleanup files only. Overlay user intent must remain outside reset '
            'deletion and post-cleanup checks.',
      );
    },
  );
}
