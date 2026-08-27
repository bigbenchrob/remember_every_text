import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/onboarding/application/complete_installation_erase_virgin_verifier.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp(
      'complete-erase-virgin-verifier-',
    );
  });

  tearDown(() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  });

  test('canonical classifier proves an empty owned root is virgin', () async {
    final state = await const CompleteInstallationEraseVirginVerifier(
      evidenceReader: SqliteMessageLensInstallationEvidenceReader(),
    ).verify(archiveRootPath: root.path);

    expect(state.kind, MessageLensInstallationStateKind.virgin);
  });

  test('retired MessageLens data prevents false virgin verification', () async {
    await File(path.join(root.path, 'working.db')).writeAsString('legacy');

    await expectLater(
      const CompleteInstallationEraseVirginVerifier(
        evidenceReader: SqliteMessageLensInstallationEvidenceReader(),
      ).verify(archiveRootPath: root.path),
      throwsA(isA<CompleteInstallationEraseVirginVerificationException>()),
    );
  });
}
