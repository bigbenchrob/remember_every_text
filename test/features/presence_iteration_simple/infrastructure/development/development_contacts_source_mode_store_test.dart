import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/features/presence_iteration_simple/infrastructure/development/development_contacts_source_mode_store.dart';

void main() {
  late Directory tempDirectory;
  late File configurationFile;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'contacts_source_mode_store_test_',
    );
    configurationFile = File(
      path.join(tempDirectory.path, 'nested', 'source-mode.txt'),
    );
  });

  tearDown(() async {
    await tempDirectory.delete(recursive: true);
  });

  test(
    'defaults to the real source when no lab configuration exists',
    () async {
      final store = DevelopmentContactsSourceModeStore(
        configurationFile: configurationFile,
      );

      expect(await store.read(), DevelopmentContactsSourceMode.realSource);
    },
  );

  test('persists the disposable condition across store instances', () async {
    final first = DevelopmentContactsSourceModeStore(
      configurationFile: configurationFile,
    );
    await first.write(
      DevelopmentContactsSourceMode.disposableUnavailableSource,
    );
    final restarted = DevelopmentContactsSourceModeStore(
      configurationFile: configurationFile,
    );

    expect(
      await restarted.read(),
      DevelopmentContactsSourceMode.disposableUnavailableSource,
    );
  });
}
