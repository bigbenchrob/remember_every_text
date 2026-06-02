import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_data_reset_service.dart';

void main() {
  test(
    'derived message data reset includes legacy and graph database files',
    () {
      expect(
        derivedMessageDataDatabaseBaseNames,
        containsAll(<String>[
          'macos_import.db',
          'working.db',
          'macos_import_ss.db',
          'working_ss.db',
        ]),
      );
    },
  );

  test('import ledger reset includes only import ledger database files', () {
    expect(
      importLedgerDatabaseBaseNames,
      <String>[
        'macos_import.db',
        'macos_import_ss.db',
      ],
    );
  });

  test('projection reset includes only projection database files', () {
    expect(
      projectionDatabaseBaseNames,
      <String>[
        'working.db',
        'working_ss.db',
      ],
    );
  });
}
