import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/logging/infrastructure/pipeline_audit_logger.dart';

void main() {
  test('writes pipeline audit logs into the requested directory', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'pipeline_audit_logger_test_',
    );
    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final log = await PipelineAuditLogger.open(
      'diagnostic_log',
      directoryPath: tempDirectory.path,
    );
    log.info('graph lifecycle checked');
    await log.close();

    final logFile = File(path.join(tempDirectory.path, 'diagnostic_log'));
    expect(logFile.existsSync(), isTrue);
    expect(await logFile.readAsString(), contains('graph lifecycle checked'));
  });

  test('rejects path-like pipeline audit log names', () async {
    await expectLater(
      PipelineAuditLogger.open('../diagnostic_log', directoryPath: '/tmp'),
      throwsStateError,
    );
  });

  test('rejects symlinked pipeline audit log targets', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'pipeline_audit_logger_test_',
    );
    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final outsideFile = File(path.join(tempDirectory.path, 'outside_log'));
    await outsideFile.writeAsString('do not append');
    final logLink = Link(path.join(tempDirectory.path, 'diagnostic_log'));
    await logLink.create(outsideFile.path);

    await expectLater(
      PipelineAuditLogger.open(
        'diagnostic_log',
        directoryPath: tempDirectory.path,
      ),
      throwsStateError,
    );
    expect(await outsideFile.readAsString(), 'do not append');
  });
}
