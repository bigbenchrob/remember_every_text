import 'dart:io';

import 'package:remember_this_text/essentials/archive_environment/infrastructure/file_system_archive_checkpoint_service.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty || arguments.contains('--help')) {
    _usage();
    return;
  }

  final command = arguments.first;
  final options = _parseOptions(arguments.skip(1).toList());
  const service = FileSystemArchiveCheckpointService();

  switch (command) {
    case 'create':
      final source = _required(options, 'source');
      final checkpoint = _required(options, 'checkpoint');
      final manifest = await service.createOfflineCheckpoint(
        sourceRootPath: source,
        checkpointRootPath: checkpoint,
      );
      stdout.writeln(
        'Created ${manifest.checkpointId}: '
        '${manifest.files.length} files, ${manifest.totalBytes} bytes.',
      );
      return;
    case 'restore-verify':
      final checkpoint = _required(options, 'checkpoint');
      final restore = _required(options, 'restore');
      final receipt = await service.restoreAndVerify(
        checkpointRootPath: checkpoint,
        disposableRestoreRootPath: restore,
      );
      stdout.writeln(
        'Verified ${receipt.checkpointId} in disposable root $restore.',
      );
      return;
    default:
      _usage();
      stderr.writeln('Unknown checkpoint command: $command');
      exitCode = 64;
      return;
  }
}

Map<String, String> _parseOptions(List<String> arguments) {
  final result = <String, String>{};
  for (var index = 0; index < arguments.length; index += 2) {
    final key = arguments[index];
    if (!key.startsWith('--') || index + 1 >= arguments.length) {
      throw const FormatException(
        'Checkpoint options must use --name value pairs.',
      );
    }
    result[key.substring(2)] = arguments[index + 1];
  }
  return result;
}

String _required(Map<String, String> options, String name) {
  final value = options[name];
  if (value == null || value.isEmpty) {
    throw FormatException('Missing required option --$name.');
  }
  return value;
}

void _usage() {
  stdout.writeln(r'''
Offline archive checkpoint tool

Create:
  dart run tool/archive_checkpoint.dart create \\
    --source <offline-archive-root> \\
    --checkpoint <new-checkpoint-root>

Restore and verify:
  dart run tool/archive_checkpoint.dart restore-verify \\
    --checkpoint <checkpoint-root> \\
    --restore <new-disposable-root>

The source must be marked and offline. Existing destinations are refused.
This tool never restores over an existing archive.
''');
}
