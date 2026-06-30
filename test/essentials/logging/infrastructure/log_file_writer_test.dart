import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/logging/domain/log_entry.dart';
import 'package:remember_this_text/essentials/logging/infrastructure/log_file_writer.dart';

void main() {
  test('writes application logs into the configured log directory', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'log_file_writer_test_',
    );
    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final writer = LogFileWriter(logDirectory: tempDirectory);
    await writer.init();
    writer.append(_entry('graph lifecycle checked'));
    await writer.close();

    final logFile = File(path.join(tempDirectory.path, 'app.log'));
    expect(logFile.existsSync(), isTrue);
    expect(await logFile.readAsString(), contains('graph lifecycle checked'));
  });

  test(
    'does not write through a symlinked application log directory',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'log_file_writer_test_',
      );
      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final outsideDirectory = Directory(
        path.join(tempDirectory.path, 'outside'),
      )..createSync();
      final logDirectoryLink = Link(path.join(tempDirectory.path, 'logs'));
      await logDirectoryLink.create(outsideDirectory.path);

      final writer = LogFileWriter(
        logDirectory: Directory(logDirectoryLink.path),
      );
      await writer.init();
      writer.append(_entry('do not write'));
      await writer.close();

      expect(outsideDirectory.listSync(), isEmpty);
    },
  );

  test('does not append through a symlinked application log target', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'log_file_writer_test_',
    );
    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final outsideFile = File(path.join(tempDirectory.path, 'outside.log'));
    await outsideFile.writeAsString('do not append');
    final logLink = Link(path.join(tempDirectory.path, 'app.log'));
    await logLink.create(outsideFile.path);

    final writer = LogFileWriter(logDirectory: tempDirectory);
    await writer.init();
    writer.append(_entry('do not write'));
    await writer.close();

    expect(await outsideFile.readAsString(), 'do not append');
  });
}

LogEntry _entry(String message) {
  return LogEntry(
    timestamp: DateTime.utc(2026, 06, 29),
    level: LogLevel.info,
    message: message,
  );
}
