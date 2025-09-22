import 'dart:convert';
import 'dart:io';

import '../../domain/ports/message_extractor_port.dart';

class RustMessageExtractor implements MessageExtractorPort {
  String get extractorPath {
    if (Platform.isMacOS) {
      final executableDir = File(Platform.resolvedExecutable).parent.path;
      final bundledPath = '$executableDir/extract_messages_limited';
      if (File(bundledPath).existsSync()) {
        return bundledPath;
      }
    }
    return 'target/release/extract_messages_limited';
  }

  @override
  Future<Map<int, String>> extractAllMessageTexts({
    int? limit,
    String? dbPath,
  }) async {
    final args = <String>[];
    if (limit != null) {
      args.add(limit.toString());
    }
    if (dbPath != null) {
      args.add(dbPath);
    }
    final process = await Process.run(
      extractorPath,
      args,
      workingDirectory: Directory.current.path,
    );
    if (process.exitCode != 0) {
      throw Exception(
        'Rust extractor failed: ${process.exitCode}\n${process.stderr}',
      );
    }
    final data = jsonDecode(process.stdout.toString()) as Map<String, dynamic>;
    final messages = data['messages'] as List<dynamic>;
    final map = <int, String>{};
    for (final m in messages) {
      final row = m as Map<String, dynamic>;
      map[row['rowid'] as int] = row['text'] as String;
    }
    return map;
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final result = await Process.run('ls', [extractorPath]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  // Optional helper to build the Rust extractor in development environments
  Future<bool> buildExtractor() async {
    try {
      final result = await Process.run('cargo', [
        'build',
        '--release',
        '--bin',
        'extract_messages_limited',
      ]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
